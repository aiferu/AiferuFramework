Shader "URPCustom/Unlit/3t2shader"
{
    Properties
    {
        //������ͼ
        _BaseMap ("Base Texture",2D) = "white"{}
        //������ɫ
        _BaseColor("Base Color",Color)=(1,1,1,1)
        //�������ɫ
        _SpecularColor("SpecularColor",Color) = (1,1,1,1)
        //�⻬��
        _Smoothness("Smoothness",float) = 10
        //��Ӱ�ض�
        _Cutoff("Cutoff",float) = 0.5
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"//��������һ��URP Shader��
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
        {                                        //�������pass��һ����Ⱦpass
            Tags{"LightMode"="UniversalForward"}//���Pass���ջ��������ɫ������//URPֻ֧��һ��passͨ�������Ⱦ������passֻ�ܽ��м���

            HLSLPROGRAM //CGPROGRAM

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #pragma vertex vert
            #pragma fragment frag

            struct Attributes//�����a2v
            {
                half4 positionOS : POSITION;
                half2 uv : TEXCOORD0;
                half3 normalOS : NORMAL;
            };
            struct Varings//�����v2f
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
                //��ȡ����λ��
                VertexPositionInputs positionInputs = GetVertexPositionInputs(IN.positionOS.xyz);
                OUT.positionCS = positionInputs.positionCS;
                OUT.positionWS = positionInputs.positionWS;

                //��ȡ�ӽǷ���
                OUT.viewDirWS = GetCameraPositionWS() - positionInputs.positionWS;

                //��ȡ���߷���
                VertexNormalInputs normalInputs = GetVertexNormalInputs(IN.normalOS.xyz);
                OUT.normalWS = normalInputs.normalWS;
                //����������ͼUV
                OUT.uv=TRANSFORM_TEX(IN.uv,_BaseMap);
                return OUT;
            }

            half4 frag(Varings IN):SV_Target
            {
                //����������ͼ����
                half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv); 

                //��ȡ���߷������ɫ
                Light light = GetMainLight();
                half3 lightDirWS = light.direction;
                half3 lightColor = light.color;
                //�������
                
                //������
                half3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                //������                                   Lighting.hlslΪ���Ƿ�װ�������������������ģ��
                half3 diffuse = baseMap.xyz * _BaseColor * LightingLambert(light.color, lightDirWS, IN.normalWS);
               
                //�߹���� blinPhong �߹�ģ��                                           normalWS ViewDirWS
                half3 specular = LightingSpecular(light.color, lightDirWS, normalize(IN.normalWS ), normalize(IN.viewDirWS), _SpecularColor, _Smoothness);
                //LightweightFragmentBlinnPhong(InputData inputData, half3 diffuse, half4 specularGloss, half smoothness, half3 emission, half alpha)

                //��ƬԪ���㸽�ӹ�Դ
                //��ȡ��ǰƬԪ���ܸ��ӹ�Դ�ĸ������������������URP�ĸ��ӹ�Դ���ޣ���ô���ͻ᷵�����޵�������
                uint pixelLightCount = GetAdditionalLightsCount();

                for (uint lightIndex = 0; lightIndex < pixelLightCount; ++lightIndex)
                {
                    //GetAdditionalLight(lightIndex, IN.positionWS);�����ᰴ��indexȥ�ҵ���Ӧ�Ĺ�Դ���������ṩ��Ƭ����������λ�ü�����պ���Ӱ˥�������洢�ڷ��ص�Light�ṹ���ڡ�
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


                //������δ������������Լ���CBUFFER����������Ҫ�Ĳ�һ������������ע�͵���
                //#include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitInput.hlsl"
                //��������������2��hlsl�ļ�
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
                ENDHLSL
        }
    }
}