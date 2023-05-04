Shader "Roystan/Toon/Water"
{
    Properties
    {
        //��Ӱ��ɫ
        _DepthGradientShallow("DepthGradientShallow", Color) = (0.325, 0.807, 0.971, 0.725)
        //��ˮ��ɫ
        _DepthGradientDeep("DepthGradientDeep", Color) = (0.086, 0.407, 1, 0.749)
        //���䷶Χ����
        _DepthMaxDistance("DepthMaxDistance", Float) = 1
        //͸����
        _AlphaScale("AlphaScale",Range(0,1)) = 1

        //�߹���ɫ
        _SpecularColor("SpecularColor",Color) = (1,1,1,1)
        //�⻬��
        _Smoothness("Smoothness",float) = 10
      
    }
        SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"//��������һ��URP Shader��
            "RenderType" = "Transparent"
            "IgnoreProjector" = "true"
            "Queue" = "Transparent"
        }

        ZWrite Off

        Blend SrcAlpha OneMinusSrcAlpha
        HLSLINCLUDE
        //CG�к��Ĵ���� #include "UnityCG.cginc"
       #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
     


       //������ͼ�⣬Ҫ��¶��Inspector����ϵı�������Ҫ���浽CBUFFER��
       //��passͨ����������
       CBUFFER_START(UnityPerMaterial)

            float4 _DepthGradientShallow;
            float4 _DepthGradientDeep;
            float _DepthMaxDistance;
            float _AlphaScale;
            float _SpecularColor;
            float _Smoothness;
            CBUFFER_END

            //����������ͼ
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
                //��Ļ�ռ�����洢
                float4 screenPosition : TEXCOORD0;
                float3 viewDirWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
                float3 positionWS : TEXCOORD3;
                float3 vertexLight : TEXCOORD4;
            };



       ENDHLSL

        Pass
        {
                                                   //�������pass��һ����Ⱦpass
            Tags{"LightMode" = "UniversalForward"}//���Pass���ջ��������ɫ������//URPֻ֧��һ��passͨ�������Ⱦ������passֻ�ܽ��м���

            HLSLPROGRAM //CGPROGRAM

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #pragma vertex vert
            #pragma fragment frag
            
           




            VertInout vert(VertInput IN)
            {
                VertInout OUT;
                //��������ת���ɲü��ռ�����
                VertexPositionInputs positionInputs = GetVertexPositionInputs(IN.positionOS.xyz);
                OUT.positionCS = positionInputs.positionCS;
                OUT.positionWS = positionInputs.positionWS;
                //��ȡ��βü��ռ��е���Ļ����
                OUT.screenPosition = ComputeScreenPos(positionInputs.positionCS);
                //��ȡ�ӽǷ���
                OUT.viewDirWS = GetCameraPositionWS() - positionInputs.positionWS;
                //��ȡ���߷���
                VertexNormalInputs normalInputs = GetVertexNormalInputs(IN.normalOS.xyz);
                OUT.normalWS = normalInputs.normalWS;
                //��ȡ�ۼӵĹ�Դ��ɫ ͨ��������������ռ�Ķ���λ�úͷ��߷��򣬻�ȡ�ۼӵĹ�Դ��ɫ
                OUT.vertexLight = VertexLighting(positionInputs.positionWS,normalInputs.normalWS);

                return OUT;
            }

            float4 frag(VertInout IN) : SV_Target
            {
            //�������ͼ
             //����βü��ռ��е�������/w������ת������ϵ w�洢�ľ��ǵ�ǰƬԪ�������Ϣ
            float2 screenUV= IN.screenPosition.xy / IN.screenPosition.w;
            float depth = SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_CameraDepthTexture, screenUV).r;
            //�����ֵ�仯��01֮��;
            //Linear01Depth LinearEyeDepth �������߿ռ�����ת�������Ի�ø�׼ȷ���ҿ���������ȫ��������ϵ����
            float depthValue = LinearEyeDepth(depth, _ZBufferParams);

            //��ȡˮ����ȣ�ˮ����ĵط�����Ļ����ȣ�����Ļ��ȣ������ˮ�����ȣ��Ĳ�ֵ
            float depthDifference = depthValue - IN.screenPosition.w;

            //������Ȳ�ֵ��0-1֮�䣬����ɫ���ֵ����
            float waterDepthDifference01 = saturate(depthDifference / _DepthMaxDistance);
            //���ˮ�����Ӱ����ɫ
            float4 waterColor = lerp(_DepthGradientShallow, _DepthGradientDeep, waterDepthDifference01);

            //�������
            //��ȡ��Դ����
            Light light = GetMainLight();
            float3 lightDirWS = light.direction;

            //�ӽǷ���
            float3 viewDirWS = normalize(IN.viewDirWS);
            //�������
            float3 halfVector = normalize(lightDirWS+viewDirWS);

            float NdotH = dot(IN.normalWS,halfVector);
            
            //blinPhong�߹����
            float3 specular = pow(NdotH*light.color,_Smoothness*_Smoothness);

            //������                                   ʹ��light.hlsl�ļ���Ϊ���Ƕ�������������������ģ��
            half3 diffuse = waterColor.xyz*LightingLambert(light.color,lightDirWS,IN.normalWS);
            
            //blinPhong�߹����
          //  half3 specular = LightingSpecular(light.color,lightDirWS,normalize(IN.normalWS),normalize(IN.viewDirWS),_SpecularColor,_Smoothness);

            //��ƬԪ���㸽�ӹ�Դ
            //��ȡ��ǰƬԪ���ܸ��ӹ�Դ�ĸ������������������URP�ĸ��ӹ�Դ���ޣ���ô���ͻ᷵�����޵�������
            uint pixelLightCount = GetAdditionalLightsCount();

            for (uint lightIndex = 0; lightIndex < pixelLightCount; ++lightIndex)
            {
                //GetAdditionalLight(lightIndex, IN.positionWS);�����ᰴ��indexȥ�ҵ���Ӧ�Ĺ�Դ���������ṩ��Ƭ����������λ�ü�����պ���Ӱ˥�������洢�ڷ��ص�Light�ṹ���ڡ�
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