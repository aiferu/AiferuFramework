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
            "RenderPipeline"="UniversalPipeline"//��������һ��URP Shader��
            "Queue"="Geometry"
            "RenderType"="Opaque"
        }
        HLSLINCLUDE
         //CG�к��Ĵ���� #include "UnityCG.cginc"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
       
        
        //������ͼ�⣬Ҫ��¶��Inspector����ϵı�������Ҫ���浽CBUFFER��
        //��passͨ����������
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseMap_ST;
        half4 _BaseColor;
        float4 _SpecularColor;
        float _Smoothness;
        float _Cutoff;
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
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normalOS : NORMAL;
            };
            struct Varings//�����v2f
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 viewDirWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
                float3 positionWS : TEXCOORD3;
                float3 vertexLight :TEXCOORD4;
            };

            TEXTURE2D(_BaseMap);//��CG�л�д��sampler2D _MainTex;
            SAMPLER(sampler_BaseMap);

            Varings vert(Attributes IN)
            {
                Varings OUT;
                //��CG���棬��������ת���ռ����� o.vertex = UnityObjectToClipPos(v.vertex);
                VertexPositionInputs positionInputs = GetVertexPositionInputs(IN.positionOS.xyz);
                OUT.positionCS = positionInputs.positionCS;
                OUT.positionWS = positionInputs.positionWS;

                //��ȡ�ӽǷ���
                OUT.viewDirWS = GetCameraPositionWS() - positionInputs.positionWS;

                //��ȡ���߷���
                VertexNormalInputs normalInputs = GetVertexNormalInputs(IN.normalOS.xyz);
                OUT.normalWS = normalInputs.normalWS;

                //�������и��ӹ�Դ���ۼ���ɫ
                OUT.vertexLight = VertexLighting(positionInputs.positionWS, normalInputs.normalWS);
                


                OUT.uv=TRANSFORM_TEX(IN.uv,_BaseMap);
                return OUT;
            }

            float4 frag(Varings IN):SV_Target
            {
                //��CG�������������ͼ���� fixed4 col = tex2D(_MainTex, i.uv);
                half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv); 

                //��ȡ���߷���
                Light light = GetMainLight();
                float3 lightDirWS = light.direction;

                //�������
                // 
                //������                                   Lighting.hlslΪ���Ƿ�װ�������������������ģ��
                half3 diffuse = baseMap.xyz * _BaseColor * LightingLambert(light.color, lightDirWS, IN.normalWS);
                //��ͬ�ڣ�
                //half3 diffuse = lightColor*saturate(dot(normal, lightDir));

                //�߹���� blinPhong �߹�ģ��                                           normalWS ViewDirWS
                half3 specular = LightingSpecular(light.color, lightDirWS, normalize(IN.normalWS ), normalize(IN.viewDirWS), _SpecularColor, _Smoothness);
                // ��ͬ�ڣ�
                //float3 halfVec = SafeNormalize(float3(lightDir) + float3(viewDir));
                //half NdotH = saturate(dot(normal, halfVec));
                //half3 specular = lightColor * specular.rgb * pow(NdotH, smoothness);

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