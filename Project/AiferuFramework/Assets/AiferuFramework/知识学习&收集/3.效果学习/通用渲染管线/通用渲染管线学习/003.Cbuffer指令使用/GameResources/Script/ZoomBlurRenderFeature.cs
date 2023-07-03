using System.Runtime.InteropServices.WindowsRuntime;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

/// <summary>
/// ����ģ������RenderFeature
/// </summary>
public class ZoomBlurRenderFeature : ScriptableRendererFeature
{
    class ZoomBlurPass : ScriptableRenderPass
    {
        #region ����
        /// <summary>
        /// ����RenderTag,������CBufferPool��ȥ��ȡ��,�����Ļ�������FrameDebugger�п����ҵ���
        /// </summary>
        static readonly string k_RenderTag = "Render ZoomBlur Effects";

        //��ȡShader�е�����ID
        static readonly int MainTexId = Shader.PropertyToID("_MainTex");
        static readonly int TempTargetId = Shader.PropertyToID("_TempTargetZoomBlur");
        static readonly int FocusPowerId = Shader.PropertyToID("_FocusPower");
        static readonly int FocusDetailId = Shader.PropertyToID("_FocusDetail");
        static readonly int FocusScreenPositionId = Shader.PropertyToID("_FocusScreenPosition");
        static readonly int ReferenceResolutionXId = Shader.PropertyToID("_ReferenceResolutionX");

        ZoomBlur zoomBlur;
        Material zoomBlurMaterial;
        //��ʶCBuffer�е�RenderTexture
        RenderTargetIdentifier currentTarget;

        #endregion

        #region ���캯��
        /// <summary>
        /// ZoomBlurPass���캯��
        /// </summary>
        /// <param name="evt">��Ⱦʱ��</param>
        public ZoomBlurPass(RenderPassEvent evt)
        {
            renderPassEvent = evt;

            //���Ҷ�Ӧshader��������Ӧ�Ĳ���
            var shader = Shader.Find("PostEffect/ZoomBlur");

            if (shader != null)
            {
                Debug.LogError("Shader not found.");
                return;
            }

            zoomBlurMaterial = CoreUtils.CreateEngineMaterial(shader);
        }
        #endregion

        #region ����

        public void Setup(in RenderTargetIdentifier currentTarget)
        {
            this.currentTarget = currentTarget;
        }

        public void Render(CommandBuffer cmd, ref RenderingData renderingData)
        {
            // ��ȡ��ǰ�������
            ref var cameraData = ref renderingData.cameraData;
            // ��ȡcamera ����ȾĿ��
            var source = currentTarget;
            // ��ȡ��ʱ��ȾĿ��shader���Զ�Ӧ��ID
            int destination = TempTargetId;

            //��ȡ��Ļ�ֱ���
            var w = cameraData.camera.scaledPixelWidth;
            var h = cameraData.camera.scaledPixelHeight;

            //���ò�������
            zoomBlurMaterial.SetFloat(FocusPowerId, zoomBlur.focusPower.value);
            zoomBlurMaterial.SetInt(FocusDetailId, zoomBlur.focusDetail.value);
            zoomBlurMaterial.SetVector(FocusScreenPositionId, zoomBlur.focusScreenPosition.value);
            zoomBlurMaterial.SetInt(ReferenceResolutionXId, zoomBlur.referenceResolutionx.value);
            //shader �ĵ�һ��pass
            int shaderPass = 0;

            //����ȫ����ȾͼΪshader��Ӧ��mainTex
            cmd.SetGlobalTexture(MainTexId, source);

            //������ʱ��Ⱦ����
            cmd.GetTemporaryRT(destination,w,h,0,FilterMode.Point,RenderTextureFormat.Default);

            cmd.Blit(source, destination);

            cmd.Blit(destination,source,zoomBlurMaterial,shaderPass);
        }

        #endregion



        /// <summary>
        /// �����������
        /// ��ִ����Ⱦ����֮ǰ,Renderer�����ô˷���.�����Ҫ������ȾĿ�꼰�����״̬,��������ʱ��ȾĿ������,�Ǿ�Ҫ��д�������.
        /// �����Ⱦ������δ��д�������,�����Ⱦ���̽���Ⱦ������״̬��Camera����ȾĿ��
        /// </summary>
        /// <param name="cmd"></param>
        /// <param name="renderingData"></param>
        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            
        }

        /// <summary>
        /// �������ǵ�ִ�й���;������Ⱦ�߼�,������Ⱦ״̬.������Ⱦ������Ƴ�������,���ȼ���ȵ�
        /// </summary>
        /// <param name="context"></param>
        /// <param name="renderingData"></param>
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            #region �ж��Ƿ�ִ��
            if (zoomBlurMaterial == null)
            {
                Debug.LogError("Material not Created.");
                return;
            }

            if (!renderingData.cameraData.postProcessEnabled) return;

            var stack = VolumeManager.instance.stack;
            zoomBlur = stack.GetComponent<ZoomBlur>();

            if (zoomBlur == null) return; 
            if (!zoomBlur.active) return;
            #endregion

            //����������л�ȡһ�������
            var cmd = CommandBufferPool.Get(k_RenderTag);

            Render(cmd,ref renderingData);

            //ִ��,����
            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
            
        }



        /// <summary>
        /// �������ͷ�ͨ���˹��̴����ķ�����Դ.�����Ⱦ��������.�Ϳ���ʹ�ô˻ص��ͷŴ���Ⱦ���̴�����������Դ.
        /// </summary>
        /// <param name="cmd"></param>
        public override void OnCameraCleanup(CommandBuffer cmd)
        {
        }
    }



    ZoomBlurPass zoomBlurPass;

    /// <summary>
    /// ��ʼ��RenderFeature����Դ
    /// </summary>
    public override void Create()
    {
        zoomBlurPass = new ZoomBlurPass(RenderPassEvent.BeforeRenderingPostProcessing);
    }

    /// <summary>
    /// ��Renderer�в���һ������ScriptableRenderPass,�����Rendererÿ�������������һ��
    /// </summary>
    /// <param name="renderer"></param>
    /// <param name="renderingData"></param>
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(zoomBlurPass);
    }
}


