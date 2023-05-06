using System;
using UnityEngine.Rendering;
using UnityEngine;
using UnityEngine.Rendering.Universal;

public class GrabScreenBlurRendererFeature : ScriptableRendererFeature
{
    [Serializable]
    public class Config
    {
        public float blurAmount;
        public Material blurMaterial;
    }

    [SerializeField]
    private Config config;

    private GrabScreenBlurPass grabScreenBlurPass;

    public override void Create()
    {
        grabScreenBlurPass = new GrabScreenBlurPass(config);
        grabScreenBlurPass.renderPassEvent = RenderPassEvent.AfterRenderingTransparents;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        grabScreenBlurPass.SetUpColorRT(renderer.cameraColorTarget);
        renderer.EnqueuePass(grabScreenBlurPass);
    }

    // render pass
    class GrabScreenBlurPass : ScriptableRenderPass
    {
        private Material blurMat;
        private float blurAmount;

        private RenderTextureDescriptor rtDesc;
        private RenderTargetIdentifier colorRT;
        private ProfilingSampler profilingSampler;

        private int[] sizes = { 1, 2, 4, 8 };

        public GrabScreenBlurPass(Config config)
        {
            blurMat = CoreUtils.CreateEngineMaterial(Shader.Find("Aiferu/URP/SeparableBlur"));
            blurAmount = config.blurAmount;

            profilingSampler = new ProfilingSampler(nameof(GrabScreenBlurPass));
        }

        public void SetUpColorRT(RenderTargetIdentifier rt)
        {
            colorRT = rt;
        }

        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            rtDesc = cameraTextureDescriptor;
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmd = CommandBufferPool.Get();
            using (new ProfilingScope(cmd, profilingSampler))
            {
                for (int i = 0; i < sizes.Length; ++i)
                {
                    //downsample
                    int size = sizes[i];
                    rtDesc.width = Screen.width / size;
                    rtDesc.height = Screen.height / size;
                    //ÉêÇëÁÙÊ±RT
                    int blurRT1 = Shader.PropertyToID("_BlurRT1_" + i);
                    int blurRT2 = Shader.PropertyToID("_BlurRT2_" + i);
                    cmd.GetTemporaryRT(blurRT1, rtDesc);
                    cmd.GetTemporaryRT(blurRT2, rtDesc);

                    //Blur
                    cmd.SetGlobalVector("_BlurAmount", new Vector4(blurAmount / rtDesc.width, 0, 0, 0));
                    cmd.Blit(colorRT, blurRT1, blurMat);
                    cmd.SetGlobalVector("_BlurAmount", new Vector4(0, blurAmount / rtDesc.height, 0, 0));
                    cmd.Blit(blurRT1, blurRT2, blurMat);
                    cmd.SetGlobalVector("_BlurAmount", new Vector4(blurAmount * 2 / rtDesc.width, 0, 0, 0));
                    cmd.Blit(blurRT2, blurRT1, blurMat);
                    cmd.SetGlobalVector("_BlurAmount", new Vector4(0, blurAmount * 2 / rtDesc.height, 0, 0));
                    cmd.Blit(blurRT1, blurRT2, blurMat);

                    cmd.SetGlobalTexture("_BluredTexture" + i, blurRT2);
                }

                cmd.SetRenderTarget(colorRT);
            }
            //schedule command buffer
            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }
    }
}