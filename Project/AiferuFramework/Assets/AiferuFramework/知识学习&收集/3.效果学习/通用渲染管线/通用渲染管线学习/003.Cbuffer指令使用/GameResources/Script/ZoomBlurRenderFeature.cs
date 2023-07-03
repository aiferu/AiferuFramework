using System.Runtime.InteropServices.WindowsRuntime;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

/// <summary>
/// 径向模糊后处理RenderFeature
/// </summary>
public class ZoomBlurRenderFeature : ScriptableRendererFeature
{
    class ZoomBlurPass : ScriptableRenderPass
    {
        #region 属性
        /// <summary>
        /// 创建RenderTag,后续在CBufferPool中去获取它,这样的话我们在FrameDebugger中可以找到它
        /// </summary>
        static readonly string k_RenderTag = "Render ZoomBlur Effects";

        //获取Shader中的属性ID
        static readonly int MainTexId = Shader.PropertyToID("_MainTex");
        static readonly int TempTargetId = Shader.PropertyToID("_TempTargetZoomBlur");
        static readonly int FocusPowerId = Shader.PropertyToID("_FocusPower");
        static readonly int FocusDetailId = Shader.PropertyToID("_FocusDetail");
        static readonly int FocusScreenPositionId = Shader.PropertyToID("_FocusScreenPosition");
        static readonly int ReferenceResolutionXId = Shader.PropertyToID("_ReferenceResolutionX");

        ZoomBlur zoomBlur;
        Material zoomBlurMaterial;
        //标识CBuffer中的RenderTexture
        RenderTargetIdentifier currentTarget;

        #endregion

        #region 构造函数
        /// <summary>
        /// ZoomBlurPass构造函数
        /// </summary>
        /// <param name="evt">渲染时机</param>
        public ZoomBlurPass(RenderPassEvent evt)
        {
            renderPassEvent = evt;

            //查找对应shader并创建对应的材质
            var shader = Shader.Find("PostEffect/ZoomBlur");

            if (shader != null)
            {
                Debug.LogError("Shader not found.");
                return;
            }

            zoomBlurMaterial = CoreUtils.CreateEngineMaterial(shader);
        }
        #endregion

        #region 函数

        public void Setup(in RenderTargetIdentifier currentTarget)
        {
            this.currentTarget = currentTarget;
        }

        public void Render(CommandBuffer cmd, ref RenderingData renderingData)
        {
            // 获取当前相机数据
            ref var cameraData = ref renderingData.cameraData;
            // 获取camera 的渲染目标
            var source = currentTarget;
            // 获取临时渲染目标shader属性对应的ID
            int destination = TempTargetId;

            //获取屏幕分辨率
            var w = cameraData.camera.scaledPixelWidth;
            var h = cameraData.camera.scaledPixelHeight;

            //设置材质属性
            zoomBlurMaterial.SetFloat(FocusPowerId, zoomBlur.focusPower.value);
            zoomBlurMaterial.SetInt(FocusDetailId, zoomBlur.focusDetail.value);
            zoomBlurMaterial.SetVector(FocusScreenPositionId, zoomBlur.focusScreenPosition.value);
            zoomBlurMaterial.SetInt(ReferenceResolutionXId, zoomBlur.referenceResolutionx.value);
            //shader 的第一个pass
            int shaderPass = 0;

            //设置全局渲染图为shader对应的mainTex
            cmd.SetGlobalTexture(MainTexId, source);

            //创建临时渲染纹理
            cmd.GetTemporaryRT(destination,w,h,0,FilterMode.Point,RenderTextureFormat.Default);

            cmd.Blit(source, destination);

            cmd.Blit(destination,source,zoomBlurMaterial,shaderPass);
        }

        #endregion



        /// <summary>
        /// 当摄像机更新
        /// 在执行渲染过程之前,Renderer将调用此方法.如果需要配置渲染目标及其清除状态,并创建临时渲染目标纹理,那就要重写这个方法.
        /// 如果渲染过程中未重写这个方法,则该渲染过程将渲染到激活状态下Camera的渲染目标
        /// </summary>
        /// <param name="cmd"></param>
        /// <param name="renderingData"></param>
        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            
        }

        /// <summary>
        /// 定义我们的执行规则;包含渲染逻辑,设置渲染状态.绘制渲染器或绘制程序网格,调度计算等等
        /// </summary>
        /// <param name="context"></param>
        /// <param name="renderingData"></param>
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            #region 判断是否执行
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

            //从命令缓冲区中获取一个命令缓存
            var cmd = CommandBufferPool.Get(k_RenderTag);

            Render(cmd,ref renderingData);

            //执行,回收
            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
            
        }



        /// <summary>
        /// 可用于释放通过此过程创建的分配资源.完成渲染相机后调用.就可以使用此回调释放此渲染过程创建的所有资源.
        /// </summary>
        /// <param name="cmd"></param>
        public override void OnCameraCleanup(CommandBuffer cmd)
        {
        }
    }



    ZoomBlurPass zoomBlurPass;

    /// <summary>
    /// 初始化RenderFeature的资源
    /// </summary>
    public override void Create()
    {
        zoomBlurPass = new ZoomBlurPass(RenderPassEvent.BeforeRenderingPostProcessing);
    }

    /// <summary>
    /// 在Renderer中插入一个或多个ScriptableRenderPass,对这个Renderer每个摄像机都设置一次
    /// </summary>
    /// <param name="renderer"></param>
    /// <param name="renderingData"></param>
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(zoomBlurPass);
    }
}


