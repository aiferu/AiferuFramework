Shader "Roystan/Toon/Water"
{
    Properties
    {
        //��Ӱ��ɫ
        _DepthGradientShallow("Depth Gradient Shallow", Color) = (0.325, 0.807, 0.971, 0.725)
        //��ˮ��ɫ
        _DepthGradientDeep("Depth Gradient Deep", Color) = (0.086, 0.407, 1, 0.749)
        _DepthMaxDistance("Depth Maximum Distance", Float) = 1
        //������ͼ
        _SurfaceNoise("Surface Noise", 2D) = "white" {}
        //��������
        _SurfaceNoiseCutoff("Surface Noise Cutoff",float) = 0.777
        //������ֹ��ֵ
        _FoamDistance("Foam Distance", Float) = 0.4
        //ˮ�ƶ��ķ���
        _SurfaceNoiseScroll("Surface Noise Scroll Amount", Vector) = (0.03, 0.03, 0, 0)
        //ʧ����ͼ�����ʧ�����������ڷ�����ͼ������ֻ������ͨ��(��ɫ����ɫ)������������
        //���ǽ�������ͨ������Ϊ��άƽ���ϵ���������ʹ���������������ǵ����������UV��
        _SurfaceDistortion("Surface Distortion", 2D) = "white" {}
        //ʧ����ͼǿ��
        _SurfaceDistortionAmount("Surface Distortion Amount", float) = 0.27
        
        _DepthFactor("��Ȳ���",float) = 1
    }
        SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"//��������һ��URP Shader��
            "RenderType" = "Transparent"

            "Queue" = "Transparent"
        }
        HLSLINCLUDE
        //CG�к��Ĵ���� #include "UnityCG.cginc"
       #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
       
      // #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"


       //������ͼ�⣬Ҫ��¶��Inspector����ϵı�������Ҫ���浽CBUFFER��
       //��passͨ����������
       CBUFFER_START(UnityPerMaterial)

            float4 _DepthGradientShallow;
            float4 _DepthGradientDeep;
            float _DepthMaxDistance;
            //������ͼ
            float4 _SurfaceNoise_ST;
            //������ͼ����
            float _SurfaceNoiseCutoff;
            //������ֹ��ֵ
            float _FoamDistance;
            //ˮ�ƶ��ķ���
            float2 _SurfaceNoiseScroll;

            //ʧ����ͼ
            float4 _SurfaceDistortion_ST;
            //ʧ����ͼǿ��
            float _SurfaceDistortionAmount;
            //��Ȳ���
            float _DepthFactor;
            CBUFFER_END



            //����������ͼ
            TEXTURE2D_X_FLOAT(_CameraDepthTexture);
            SAMPLER(sampler_CameraDepthTexture);


            //������ͼ
            TEXTURE2D(_SurfaceNoise);//��CG�л�д��sampler2D _MainTex;
            SAMPLER(sampler_SurfaceNoise);


            //ʧ����ͼ
            TEXTURE2D(_SurfaceDistortion);//��CG�л�д��sampler2D _MainTex;
            SAMPLER(sampler_SurfaceDistortion);


                struct Attributes
            {
                float4 positionOS : POSITION;
                float4 uv : TEXCOORD0;
            };


            struct Varings
            {
                float4 positionCS : SV_POSITION;
                //��Ļ�ռ�����洢
                float4 screenPosition : TEXCOORD2;
                //����UV
                float2 noiseUV : TEXCOORD0;
                //ʧ����ͼuv
                float2 distortUV : TEXCOORD1;
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

           




            Varings vert(Attributes IN)
            {
                Varings OUT;
                //��������ת���ɲü��ռ�����
                VertexPositionInputs positionInputs = GetVertexPositionInputs(IN.positionOS.xyz);
                OUT.positionCS = positionInputs.positionCS;
                //�ü��ռ�����ת������Ļ�ռ�����
               // float3 positionCS = TransformObjectToHClip(v.positionOS.xyz);
               // OUT.screenPosition = ComputeScreenPos(positionCS);
                //��ȡ��βü��ռ��е���Ļ����
                OUT.screenPosition = ComputeScreenPos(positionInputs.positionCS);

                //����uv����
                OUT.noiseUV = TRANSFORM_TEX(IN.uv, _SurfaceNoise);
                //ʧ��UV����
                OUT.distortUV = TRANSFORM_TEX(IN.uv, _SurfaceDistortion);
                return OUT;
            }

            float4 frag(Varings IN) : SV_Target
            {
            //�������ͼ
             //����βü��ռ��е�������/w������ת������ϵ w�洢�ľ��ǵ�ǰƬԪ�������Ϣ
            float2 screenUV= IN.screenPosition.xy / IN.screenPosition.w;
            float depth = SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_CameraDepthTexture, screenUV).r;
            //�����ֵ�仯��01֮��;
            //Linear01Depth LinearEyeDepth �������߿ռ�����ת�������Ի�ø�׼ȷ���ҿ���������ȫ��������ϵ����
            float depthValue = LinearEyeDepth(depth, _ZBufferParams);
          
           // return depthValue;
           // //������Ⱦ���߲��������Ϣ
           // ////��ȡ��Ļ�����Ϣ
           // // float existingDepth01 = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPosition)).r;
           // ////�������Ե������Ϣת�������Ե������Ϣ
           // //float existingDepthLinear = LinearEyeDepth(existingDepth01);
           // //end

           //��ȡˮ����ȣ�ˮ����ĵط�����Ļ����ȣ�����Ļ��ȣ������ˮ�����ȣ��Ĳ�ֵ
            float depthDifference = depthValue - IN.screenPosition.w;

            //������Ȳ�ֵ��0-1֮�䣬����ɫ���ֵ����
            float waterDepthDifference01 = saturate(depthDifference / _DepthMaxDistance);
          //  return waterDepthDifference01;
           //���ˮ�����Ӱ����ɫ
            float4 waterColor = lerp(_DepthGradientShallow, _DepthGradientDeep, waterDepthDifference01);
          //  return waterColor;
           //ʧ����ͼ�������                                //���Ƶ�-1 ��1����
           
           float2 distortSample = (SAMPLE_TEXTURE2D(_SurfaceDistortion, sampler_SurfaceDistortion, IN.distortUV).xy * 2 - 1) * _SurfaceDistortionAmount;
           //�ƶ�������ͼ�������ˮЧ��  
           float2 noiseUV = float2((IN.noiseUV.x + _Time.y * _SurfaceNoiseScroll.x) + distortSample.x, (IN.noiseUV.y + _Time.y * _SurfaceNoiseScroll.y) + distortSample.y);
           //������ͼ�������
           float surfaceNoiseSample = SAMPLE_TEXTURE2D(_SurfaceNoise, sampler_SurfaceNoise, noiseUV).r;


          //������Ȳ�ֵ��0-1֮�䣬�޶��벨��ǿ��Χ
          float foamDepthDifference01 = saturate(depthDifference / _FoamDistance);
          float surfaceNoiseCutoff = foamDepthDifference01 * _SurfaceNoiseCutoff;

          float surfaceNoise = surfaceNoiseSample > surfaceNoiseCutoff ? 1 : 0;



           return waterColor + surfaceNoise;
       }
       ENDHLSL  //ENDCG       
   }
    }
}