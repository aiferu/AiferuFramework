Shader "Roystan/Toon/Water"
{
    Properties
    {
        //阴影颜色
        _DepthGradientShallow("Depth Gradient Shallow", Color) = (0.325, 0.807, 0.971, 0.725)
        //海水颜色
        _DepthGradientDeep("Depth Gradient Deep", Color) = (0.086, 0.407, 1, 0.749)
        _DepthMaxDistance("Depth Maximum Distance", Float) = 1
        //噪声贴图
        _SurfaceNoise("Surface Noise", 2D) = "white" {}
        //噪声限制
        _SurfaceNoiseCutoff("Surface Noise Cutoff",float) = 0.777
        //噪声截止阈值
        _FoamDistance("Foam Distance", Float) = 0.4
        //水移动的方向
        _SurfaceNoiseScroll("Surface Noise Scroll Amount", Vector) = (0.03, 0.03, 0, 0)
        //失真贴图，这个失真纹理将类似于法线贴图，除了只有两个通道(红色和绿色)而不是三个。
        //我们将这两个通道解释为二维平面上的向量，并使用它们来拉动我们的噪声纹理的UV。
        _SurfaceDistortion("Surface Distortion", 2D) = "white" {}
        //失真贴图强度
        _SurfaceDistortionAmount("Surface Distortion Amount", float) = 0.27
        
        _DepthFactor("深度参数",float) = 1
    }
        SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"//声明这是一个URP Shader！
            "RenderType" = "Transparent"

            "Queue" = "Transparent"
        }
        HLSLINCLUDE
        //CG中核心代码库 #include "UnityCG.cginc"
       #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
       
      // #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"


       //除了贴图外，要暴露在Inspector面板上的变量都需要缓存到CBUFFER中
       //在pass通道外面声明
       CBUFFER_START(UnityPerMaterial)

            float4 _DepthGradientShallow;
            float4 _DepthGradientDeep;
            float _DepthMaxDistance;
            //噪声贴图
            float4 _SurfaceNoise_ST;
            //噪声贴图限制
            float _SurfaceNoiseCutoff;
            //噪声截止阈值
            float _FoamDistance;
            //水移动的方向
            float2 _SurfaceNoiseScroll;

            //失真贴图
            float4 _SurfaceDistortion_ST;
            //失真贴图强度
            float _SurfaceDistortionAmount;
            //深度参数
            float _DepthFactor;
            CBUFFER_END



            //摄像机深度贴图
            TEXTURE2D_X_FLOAT(_CameraDepthTexture);
            SAMPLER(sampler_CameraDepthTexture);


            //噪声贴图
            TEXTURE2D(_SurfaceNoise);//在CG中会写成sampler2D _MainTex;
            SAMPLER(sampler_SurfaceNoise);


            //失真贴图
            TEXTURE2D(_SurfaceDistortion);//在CG中会写成sampler2D _MainTex;
            SAMPLER(sampler_SurfaceDistortion);


                struct Attributes
            {
                float4 positionOS : POSITION;
                float4 uv : TEXCOORD0;
            };


            struct Varings
            {
                float4 positionCS : SV_POSITION;
                //屏幕空间坐标存储
                float4 screenPosition : TEXCOORD2;
                //噪声UV
                float2 noiseUV : TEXCOORD0;
                //失真贴图uv
                float2 distortUV : TEXCOORD1;
            };



       ENDHLSL

        Pass
        {
                                                   //声明这个pass是一个渲染pass
            Tags{"LightMode" = "UniversalForward"}//这个Pass最终会输出到颜色缓冲里//URP只支持一个pass通道输出渲染，其他pass只能进行计算

            HLSLPROGRAM //CGPROGRAM

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #pragma vertex vert
            #pragma fragment frag

           




            Varings vert(Attributes IN)
            {
                Varings OUT;
                //物体坐标转换成裁剪空间坐标
                VertexPositionInputs positionInputs = GetVertexPositionInputs(IN.positionOS.xyz);
                OUT.positionCS = positionInputs.positionCS;
                //裁剪空间坐标转换成屏幕空间坐标
               // float3 positionCS = TransformObjectToHClip(v.positionOS.xyz);
               // OUT.screenPosition = ComputeScreenPos(positionCS);
                //获取齐次裁剪空间中的屏幕坐标
                OUT.screenPosition = ComputeScreenPos(positionInputs.positionCS);

                //噪声uv采样
                OUT.noiseUV = TRANSFORM_TEX(IN.uv, _SurfaceNoise);
                //失真UV采样
                OUT.distortUV = TRANSFORM_TEX(IN.uv, _SurfaceDistortion);
                return OUT;
            }

            float4 frag(Varings IN) : SV_Target
            {
            //采样深度图
             //将齐次裁剪空间中的坐标轴/w分量，转换坐标系 w存储的就是当前片元的深度信息
            float2 screenUV= IN.screenPosition.xy / IN.screenPosition.w;
            float depth = SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_CameraDepthTexture, screenUV).r;
            //把深度值变化到01之间;
            //Linear01Depth LinearEyeDepth 基于视线空间的深度转换，可以获得更准确，且可以运用与全局摄像机上的深度
            float depthValue = LinearEyeDepth(depth, _ZBufferParams);
          
           // return depthValue;
           // //内置渲染管线采样深度信息
           // ////获取屏幕深度信息
           // // float existingDepth01 = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPosition)).r;
           // ////将非线性的深度信息转换陈线性的深度信息
           // //float existingDepthLinear = LinearEyeDepth(existingDepth01);
           // //end

           //获取水面深度（水最深的地方到屏幕的深度）与屏幕深度（摄像机水面的深度）的差值
            float depthDifference = depthValue - IN.screenPosition.w;

            //限制深度差值到0-1之间，当颜色混合值来用
            float waterDepthDifference01 = saturate(depthDifference / _DepthMaxDistance);
          //  return waterDepthDifference01;
           //混合水面和阴影的颜色
            float4 waterColor = lerp(_DepthGradientShallow, _DepthGradientDeep, waterDepthDifference01);
          //  return waterColor;
           //失真贴图纹理采样                                //限制到-1 ，1区间
           
           float2 distortSample = (SAMPLE_TEXTURE2D(_SurfaceDistortion, sampler_SurfaceDistortion, IN.distortUV).xy * 2 - 1) * _SurfaceDistortionAmount;
           //移动噪声贴图，添加流水效果  
           float2 noiseUV = float2((IN.noiseUV.x + _Time.y * _SurfaceNoiseScroll.x) + distortSample.x, (IN.noiseUV.y + _Time.y * _SurfaceNoiseScroll.y) + distortSample.y);
           //噪声贴图纹理采样
           float surfaceNoiseSample = SAMPLE_TEXTURE2D(_SurfaceNoise, sampler_SurfaceNoise, noiseUV).r;


          //限制深度差值到0-1之间，限定噪波增强范围
          float foamDepthDifference01 = saturate(depthDifference / _FoamDistance);
          float surfaceNoiseCutoff = foamDepthDifference01 * _SurfaceNoiseCutoff;

          float surfaceNoise = surfaceNoiseSample > surfaceNoiseCutoff ? 1 : 0;



           return waterColor + surfaceNoise;
       }
       ENDHLSL  //ENDCG       
   }
    }
}