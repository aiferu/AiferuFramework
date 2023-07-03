Shader "Roystan/Toon/Water"
{
    Properties
    {
        //阴影颜色
        _DepthGradientShallow("DepthGradientShallow", Color) = (0.325, 0.807, 0.971, 0.725)
        //海水颜色
        _DepthGradientDeep("DepthGradientDeep", Color) = (0.086, 0.407, 1, 0.749)
        //渐变范围限制
        _DepthMaxDistance("DepthMaxDistance", Float) = 1
        //透明度
        _AlphaScale("AlphaScale",Range(0,1)) = 1

        //高光颜色
        _SpecularColor("SpecularColor",Color) = (1,1,1,1)
        //光滑度
        _Smoothness("Smoothness",float) = 10
      
    }
        SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"//声明这是一个URP Shader！
            "RenderType" = "Transparent"
            "IgnoreProjector" = "true"
            "Queue" = "Transparent"
        }

        ZWrite Off

        Blend SrcAlpha OneMinusSrcAlpha
        HLSLINCLUDE
        //CG中核心代码库 #include "UnityCG.cginc"
       #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
     


       //除了贴图外，要暴露在Inspector面板上的变量都需要缓存到CBUFFER中
       //在pass通道外面声明
       CBUFFER_START(UnityPerMaterial)

            float4 _DepthGradientShallow;
            float4 _DepthGradientDeep;
            float _DepthMaxDistance;
            float _AlphaScale;
            float _SpecularColor;
            float _Smoothness;
            CBUFFER_END

            //摄像机深度贴图
            TEXTURE2D_X_FLOAT(_CameraDepthTexture);
            SAMPLER(sampler_CameraDepthTexture);





            struct VertInput
            {
                float4 positionOS : POSITION;
                float4 uv : TEXCOORD0;
                float3 normalOS :NORMAL;
            };


            struct VertInout
            {
                float4 positionCS : SV_POSITION;
                //屏幕空间坐标存储
                float4 screenPosition : TEXCOORD0;
                float3 viewDirWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
                float3 positionWS : TEXCOORD3;
                float3 vertexLight : TEXCOORD4;
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
            
           




            VertInout vert(VertInput IN)
            {
                VertInout OUT;
                //物体坐标转换成裁剪空间坐标
                VertexPositionInputs positionInputs = GetVertexPositionInputs(IN.positionOS.xyz);
                OUT.positionCS = positionInputs.positionCS;
                OUT.positionWS = positionInputs.positionWS;
                //获取齐次裁剪空间中的屏幕坐标
                OUT.screenPosition = ComputeScreenPos(positionInputs.positionCS);
                //获取视角方向
                OUT.viewDirWS = GetCameraPositionWS() - positionInputs.positionWS;
                //获取法线方向
                VertexNormalInputs normalInputs = GetVertexNormalInputs(IN.normalOS.xyz);
                OUT.normalWS = normalInputs.normalWS;
                //获取累加的光源颜色 通过基于世界坐标空间的顶点位置和法线方向，获取累加的光源颜色
                OUT.vertexLight = VertexLighting(positionInputs.positionWS,normalInputs.normalWS);

                return OUT;
            }

            float4 frag(VertInout IN) : SV_Target
            {
            //采样深度图
             //将齐次裁剪空间中的坐标轴/w分量，转换坐标系 w存储的就是当前片元的深度信息
            float2 screenUV= IN.screenPosition.xy / IN.screenPosition.w;
            float depth = SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_CameraDepthTexture, screenUV).r;
            //把深度值变化到01之间;
            //Linear01Depth LinearEyeDepth 基于视线空间的深度转换，可以获得更准确，且可以运用与全局摄像机上的深度
            float depthValue = LinearEyeDepth(depth, _ZBufferParams);

            //获取水面深度（水最深的地方到屏幕的深度）与屏幕深度（摄像机水面的深度）的差值
            float depthDifference = depthValue - IN.screenPosition.w;

            //限制深度差值到0-1之间，当颜色混合值来用
            float waterDepthDifference01 = saturate(depthDifference / _DepthMaxDistance);
            //混合水面和阴影的颜色
            float4 waterColor = lerp(_DepthGradientShallow, _DepthGradientDeep, waterDepthDifference01);

            //计算光照
            //获取光源方向
            Light light = GetMainLight();
            float3 lightDirWS = light.direction;

            //视角方向
            float3 viewDirWS = normalize(IN.viewDirWS);
            //半角向量
            float3 halfVector = normalize(lightDirWS+viewDirWS);

            float NdotH = dot(IN.normalWS,halfVector);
            
            //blinPhong高光计算
            float3 specular = pow(NdotH*light.color,_Smoothness*_Smoothness);

            //漫反射                                   使用light.hlsl文件中为我们定义的兰伯特漫反射光照模型
            half3 diffuse = waterColor.xyz*LightingLambert(light.color,lightDirWS,IN.normalWS);
            
            //blinPhong高光计算
          //  half3 specular = LightingSpecular(light.color,lightDirWS,normalize(IN.normalWS),normalize(IN.viewDirWS),_SpecularColor,_Smoothness);

            //逐片元计算附加光源
            //获取当前片元所受附加光源的个数，如果数量超过了URP的附加光源上限，那么他就会返回上限的数量。
            uint pixelLightCount = GetAdditionalLightsCount();

            for (uint lightIndex = 0; lightIndex < pixelLightCount; ++lightIndex)
            {
                //GetAdditionalLight(lightIndex, IN.positionWS);方法会按照index去找到对应的光源，并根据提供的片段世界坐标位置计算光照和阴影衰减，并存储在返回的Light结构体内。
                Light light = GetAdditionalLight(lightIndex, IN.positionWS);
                //diffuse += LightingLambert(light.color, light.direction, IN.normalWS);
               //specular += LightingSpecular(light.color, light.direction, normalize(IN.normalWS), normalize(IN.viewDirWS), _SpecularColor, _Smoothness);
            }

            half3 color = diffuse + specular;

            return float4(color, _AlphaScale);
       }
       ENDHLSL  //ENDCG       
   }
    }
}