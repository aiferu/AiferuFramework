using TMPro;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class MRTXRenderFeature : ScriptableRendererFeature
{

    public class RayTraceSettings
    {

        public RayTracingShader _shader;
        /// <summary>
        /// 设置渲染时机
        /// </summary>
        public RenderPassEvent mrenderPassEvent = RenderPassEvent.AfterRendering;
    }
    class RayTracingPass : ScriptableRenderPass
    {

        // This method is called before executing the render pass.
        //在执行渲染通道之前调用这个方法。
        // It can be used to configure render targets and their clear state. Also to create temporary render target textures.
        //它可以用来配置渲染目标和它们的清除状态。还可以创建临时渲染目标纹理。
        // When empty this render pass will render to the active camera render target.
        //当渲染通道为空时，渲染通道将渲染到活动摄像机渲染目标。
        // You should never call CommandBuffer.SetRenderTarget. Instead call <c>ConfigureTarget</c> and <c>ConfigureClear</c>.
        //永远不要调用CommandBuffer.SetRenderTarget。而是调用<c>ConfigureTarget</c>和<c>ConfigureClear</c>。
        // The render pipeline will ensure target setup and clearing happens in a performant manner.
        //渲染管道将确保目标设置和清除以高性能的方式进行。
        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {

        }

        // Here you can implement the rendering logic.
        //在这里你可以实现渲染逻辑。
        // Use <c>ScriptableRenderContext</c> to issue drawing commands or execute command buffers
        //使用<c>ScriptableRenderContext</c>发出绘图命令或执行命令缓冲区
        // https://docs.unity3d.com/ScriptReference/Rendering.ScriptableRenderContext.html
        // You don't have to call ScriptableRenderContext.submit, the render pipeline will call it at specific points in the pipeline.
        //不需要调用ScriptableRenderContext。提交时，渲染管道将在管道中的特定点调用它。
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
        }

        // Cleanup any allocated resources that were created during the execution of this render pass.
        //清除在渲染过程中创建的所有已分配资源。
        public override void OnCameraCleanup(CommandBuffer cmd)
        {
        }
    }



    RayTracingPass m_RayTracingPass;
    public RayTraceSettings settings = new RayTraceSettings();

    /// <inheritdoc/>
    public override void Create()
    {
        m_RayTracingPass = new RayTracingPass();

        // Configures where the render pass should be injected.
        //配置渲染通道注入的位置。
        m_RayTracingPass.renderPassEvent = settings.mrenderPassEvent;
    }

    // Here you can inject one or multiple render passes in the renderer.
    //你可以在渲染器中注入一个或多个渲染通道。
    // This method is called when setting up the renderer once per-camera.
    //这个方法在为每个摄像机设置渲染器时调用。
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_RayTracingPass);
    }
}



