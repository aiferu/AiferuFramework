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
        /// ������Ⱦʱ��
        /// </summary>
        public RenderPassEvent mrenderPassEvent = RenderPassEvent.AfterRendering;
    }
    class RayTracingPass : ScriptableRenderPass
    {

        // This method is called before executing the render pass.
        //��ִ����Ⱦͨ��֮ǰ�������������
        // It can be used to configure render targets and their clear state. Also to create temporary render target textures.
        //����������������ȾĿ������ǵ����״̬�������Դ�����ʱ��ȾĿ������
        // When empty this render pass will render to the active camera render target.
        //����Ⱦͨ��Ϊ��ʱ����Ⱦͨ������Ⱦ����������ȾĿ�ꡣ
        // You should never call CommandBuffer.SetRenderTarget. Instead call <c>ConfigureTarget</c> and <c>ConfigureClear</c>.
        //��Զ��Ҫ����CommandBuffer.SetRenderTarget�����ǵ���<c>ConfigureTarget</c>��<c>ConfigureClear</c>��
        // The render pipeline will ensure target setup and clearing happens in a performant manner.
        //��Ⱦ�ܵ���ȷ��Ŀ�����ú�����Ը����ܵķ�ʽ���С�
        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {

        }

        // Here you can implement the rendering logic.
        //�����������ʵ����Ⱦ�߼���
        // Use <c>ScriptableRenderContext</c> to issue drawing commands or execute command buffers
        //ʹ��<c>ScriptableRenderContext</c>������ͼ�����ִ���������
        // https://docs.unity3d.com/ScriptReference/Rendering.ScriptableRenderContext.html
        // You don't have to call ScriptableRenderContext.submit, the render pipeline will call it at specific points in the pipeline.
        //����Ҫ����ScriptableRenderContext���ύʱ����Ⱦ�ܵ����ڹܵ��е��ض����������
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
        }

        // Cleanup any allocated resources that were created during the execution of this render pass.
        //�������Ⱦ�����д����������ѷ�����Դ��
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
        //������Ⱦͨ��ע���λ�á�
        m_RayTracingPass.renderPassEvent = settings.mrenderPassEvent;
    }

    // Here you can inject one or multiple render passes in the renderer.
    //���������Ⱦ����ע��һ��������Ⱦͨ����
    // This method is called when setting up the renderer once per-camera.
    //���������Ϊÿ�������������Ⱦ��ʱ���á�
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_RayTracingPass);
    }
}



