using UnityEngine;
using UnityEngine.Rendering.Universal;

public class GlassBlurRenderPassFeature : ScriptableRendererFeature
{
    [System.Serializable]
    public class Settings
    {
        public RenderPassEvent renderEvent = RenderPassEvent.BeforeRenderingPostProcessing;
        public LayerMask layerMask = -1;
        public Material blurMat;
        public string textureName = "";
        public string cmdName = "";
        public string passName = "";
        public RenderTexture blurRt = null;
    }

    GlassBlurRenderPass m_ScriptablePass;
    private RenderTargetHandle dest;
    public Settings settings;
    public override void Create()
    {
        m_ScriptablePass = new GlassBlurRenderPass(settings);
        m_ScriptablePass.renderPassEvent = settings.renderEvent;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        var src = renderer.cameraColorTarget;
        dest = RenderTargetHandle.CameraTarget;
        m_ScriptablePass.Setup(src,this.dest);
        renderer.EnqueuePass(m_ScriptablePass);
    }
}