Shader "URPCustom/Unlit/3t2shader"
{
    Properties
    {
        //基础贴图
        _BaseMap ("Base Texture",2D) = "white"{}
        //基础颜色
        _BaseColor("Base Color",Color)=(1,1,1,1)
        //反射光颜色
        _SpecularColor("SpecularColor",Color) = (1,1,1,1)
        //光滑度
        _Smoothness("Smoothness",float) = 10
        //阴影截断
        _Cutoff("Cutoff",float) = 0.5
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"//声明这是一个URP Shader！
            "Queue"="Geometry"
            "RenderType"="Opaque"
        }
        HLSLINCLUDE
        
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
       
       
        
       
        CBUFFER_START(UnityPerMaterial)
        half4 _BaseMap_ST;
        half4 _BaseColor;
        half4 _SpecularColor;
        half _Smoothness;
        half _Cutoff;
        CBUFFER_END
        ENDHLSL

        

        Pass
        {                                        //声明这个pass是一个渲染pass
            Tags{"LightMode"="UniversalForward"}//这个Pass最终会输出到颜色缓冲里//URP只支持一个pass通道输出渲染，其他pass只能进行计算

            HLSLPROGRAM //CGPROGRAM

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #pragma vertex vert
            #pragma fragment frag

            struct Attributes//这就是a2v
            {
                half4 positionOS : POSITION;
                half2 uv : TEXCOORD0;
                half3 normalOS : NORMAL;
            };
            struct Varings//这就是v2f
            {
                half4 positionCS : SV_POSITION;
                half2 uv : TEXCOORD0;
                half3 viewDirWS : TEXCOORD1;
                half3 normalWS : TEXCOORD2;
                half3 positionWS : TEXCOORD3;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            Varings vert(Attributes IN)
            {
                Varings OUT;
                //获取顶点位置
                VertexPositionInputs positionInputs = GetVertexPositionInputs(IN.positionOS.xyz);
                OUT.positionCS = positionInputs.positionCS;
                OUT.positionWS = positionInputs.positionWS;

                //获取视角方向
                OUT.viewDirWS = GetCameraPositionWS() - positionInputs.positionWS;

                //获取法线方向
                VertexNormalInputs normalInputs = GetVertexNormalInputs(IN.normalOS.xyz);
                OUT.normalWS = normalInputs.normalWS;
                //采样基础贴图UV
                OUT.uv=TRANSFORM_TEX(IN.uv,_BaseMap);
                return OUT;
            }

            half4 frag(Varings IN):SV_Target
            {
                //采样基础贴图纹理
                half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv); 

                //获取光线方向和颜色
                Light light = GetMainLight();
                half3 lightDirWS = light.direction;
                half3 lightColor = light.color;
                //计算光照
                
                //环境光
                half3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                //漫反射                                   Lighting.hlsl为我们封装好了兰伯特漫反射光照模型
                half3 diffuse = baseMap.xyz * _BaseColor * LightingLambert(light.color, lightDirWS, IN.normalWS);
               
                //高光计算 blinPhong 高光模型                                           normalWS ViewDirWS
                half3 specular = LightingSpecular(light.color, lightDirWS, normalize(IN.normalWS ), normalize(IN.viewDirWS), _SpecularColor, _Smoothness);
                //LightweightFragmentBlinnPhong(InputData inputData, half3 diffuse, half4 specularGloss, half smoothness, half3 emission, half alpha)

                //逐片元计算附加光源
                //获取当前片元所受附加光源的个数，如果数量超过了URP的附加光源上限，那么他就会返回上限的数量。
                uint pixelLightCount = GetAdditionalLightsCount();

                for (uint lightIndex = 0; lightIndex < pixelLightCount; ++lightIndex)
                {
                    //GetAdditionalLight(lightIndex, IN.positionWS);方法会按照index去找到对应的光源，并根据提供的片段世界坐标位置计算光照和阴影衰减，并存储在返回的Light结构体内。
                    Light light = GetAdditionalLight(lightIndex, IN.positionWS);
                    diffuse += LightingLambert(light.color, light.direction, IN.normalWS);
                    specular += LightingSpecular(light.color, light.direction, normalize(IN.normalWS), normalize(IN.viewDirWS), _SpecularColor, _Smoothness);
                }
              

                half3 color = ambient+diffuse + specular ;

                return half4(color,1);
            }
            ENDHLSL  //ENDCG          
        }


        Pass
        {
                Name "ShadowCaster"
                Tags{"LightMode" = "ShadowCaster"}

                ZWrite On
                ZTest LEqual
                Cull[_Cull]

                HLSLPROGRAM
                // Required to compile gles 2.0 with standard srp library
                #pragma prefer_hlslcc gles
                #pragma exclude_renderers d3d11_9x
                #pragma target 2.0

                // -------------------------------------
                // Material Keywords
                #pragma shader_feature _ALPHATEST_ON
                #pragma shader_feature _GLOSSINESS_FROM_BASE_ALPHA

                //--------------------------------------
                // GPU Instancing
                #pragma multi_compile_instancing

                #pragma vertex ShadowPassVertex
                #pragma fragment ShadowPassFragment


                //由于这段代码中声明了自己的CBUFFER，与我们需要的不一样，所以我们注释掉他
                //#include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitInput.hlsl"
                //它还引入了下面2个hlsl文件
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
                ENDHLSL
        }
    }
}