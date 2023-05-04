Shader "URPCustom/Unlit/Urp002"
{
    Properties
    {
        _BaseMap ("Base Texture",2D) = "white"{}
        _BaseColor("Base Color",Color)=(1,1,1,1)
        _SpecularColor("SpecularColor",Color) = (1,1,1,1)
        _Smoothness("Smoothness",float) = 10
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
         //CG中核心代码库 #include "UnityCG.cginc"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
       
        
        //除了贴图外，要暴露在Inspector面板上的变量都需要缓存到CBUFFER中
        //在pass通道外面声明
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseMap_ST;
        half4 _BaseColor;
        float4 _SpecularColor;
        float _Smoothness;
        float _Cutoff;
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
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normalOS : NORMAL;
            };
            struct Varings//这就是v2f
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 viewDirWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
                float3 positionWS : TEXCOORD3;
                float3 vertexLight :TEXCOORD4;
            };

            TEXTURE2D(_BaseMap);//在CG中会写成sampler2D _MainTex;
            SAMPLER(sampler_BaseMap);

            Varings vert(Attributes IN)
            {
                Varings OUT;
                //在CG里面，我们这样转换空间坐标 o.vertex = UnityObjectToClipPos(v.vertex);
                VertexPositionInputs positionInputs = GetVertexPositionInputs(IN.positionOS.xyz);
                OUT.positionCS = positionInputs.positionCS;
                OUT.positionWS = positionInputs.positionWS;

                //获取视角方向
                OUT.viewDirWS = GetCameraPositionWS() - positionInputs.positionWS;

                //获取法线方向
                VertexNormalInputs normalInputs = GetVertexNormalInputs(IN.normalOS.xyz);
                OUT.normalWS = normalInputs.normalWS;

                //计算所有附加光源的累加颜色
                OUT.vertexLight = VertexLighting(positionInputs.positionWS, normalInputs.normalWS);
                


                OUT.uv=TRANSFORM_TEX(IN.uv,_BaseMap);
                return OUT;
            }

            float4 frag(Varings IN):SV_Target
            {
                //在CG里，我们这样对贴图采样 fixed4 col = tex2D(_MainTex, i.uv);
                half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv); 

                //获取光线方向
                Light light = GetMainLight();
                float3 lightDirWS = light.direction;

                //计算光照
                // 
                //漫反射                                   Lighting.hlsl为我们封装好了兰伯特漫反射光照模型
                half3 diffuse = baseMap.xyz * _BaseColor * LightingLambert(light.color, lightDirWS, IN.normalWS);
                //等同于：
                //half3 diffuse = lightColor*saturate(dot(normal, lightDir));

                //高光计算 blinPhong 高光模型                                           normalWS ViewDirWS
                half3 specular = LightingSpecular(light.color, lightDirWS, normalize(IN.normalWS ), normalize(IN.viewDirWS), _SpecularColor, _Smoothness);
                // 等同于：
                //float3 halfVec = SafeNormalize(float3(lightDir) + float3(viewDir));
                //half NdotH = saturate(dot(normal, halfVec));
                //half3 specular = lightColor * specular.rgb * pow(NdotH, smoothness);

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
              

                half3 color = diffuse*3 + specular ;

                return float4(color,1);
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