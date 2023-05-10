Shader "MyFrostedGlass_UI"
{
    Properties
    {
        _FrostTexture("FrostTexture",2D) = "white"{}
        _FrostIntensity("Frost Intensity", Range(0.0, 1.0)) = 0.5
        _MaskTexture("MaskTexture",2D) = "white"{}
        
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"//��������һ��URP Shader��
        }
        HLSLINCLUDE
         //CG�к��Ĵ���� #include "UnityCG.cginc"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
       
        //������ͼ�⣬Ҫ��¶��Inspector����ϵı�������Ҫ���浽CBUFFER��
        //��passͨ����������
        CBUFFER_START(UnityPerMaterial)
        float4 _FrostTexture_ST;
        float4 _MaskTexture_ST;
        float _FrostIntensity;

        CBUFFER_END
        ENDHLSL

        Pass
        {                                        //�������pass��һ����Ⱦpass
            Tags{"LightMode"="UniversalForward" "RenderType" = "Transparent" "Queue" = "Transparent"}//���Pass���ջ��������ɫ������//URPֻ֧��һ��passͨ�������Ⱦ������passֻ�ܽ��м���

            blend SrcAlpha OneMinusSrcAlpha  
            
            HLSLPROGRAM //CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            TEXTURE2D(_FrostTexture);
            SAMPLER(sampler_FrostTexture);

            TEXTURE2D(_MaskTexture);
            SAMPLER(sampler_MaskTexture);

            TEXTURE2D(_BluredTexture0);
            SAMPLER(sampler_BluredTexture0);

            TEXTURE2D(_BluredTexture1);
            TEXTURE2D(_BluredTexture2);
            TEXTURE2D(_BluredTexture3);

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varings
            {
                float4 positionCS : SV_POSITION;
                float2 uvFrostTex : TEXCOORD0;
                float4 uvBluredTex : TEXCOORD1;
                float2 uvMaskTex : TEXCOORD2;
            };

            Varings vert(Attributes i)
            {
                Varings o;
                VertexPositionInputs posInputs = GetVertexPositionInputs(i.positionOS.xyz);
                o.positionCS = posInputs.positionCS;
                o.uvFrostTex = TRANSFORM_TEX(i.uv, _FrostTexture);
                o.uvMaskTex = TRANSFORM_TEX(i.uv, _MaskTexture);
                o.uvBluredTex = ComputeScreenPos(o.positionCS);

                return o;
            }

            half4 frag(Varings i) : SV_Target
            {
                
                float surfSmooth = 1 - SAMPLE_TEXTURE2D(_FrostTexture, sampler_FrostTexture, i.uvFrostTex).x * _FrostIntensity;
                surfSmooth = clamp(0, 1, surfSmooth);

                half4 mask = SAMPLE_TEXTURE2D(_MaskTexture, sampler_MaskTexture, i.uvMaskTex);

                half4 ref00 = SAMPLE_TEXTURE2D(_BluredTexture0, sampler_BluredTexture0, i.uvBluredTex.xy / i.uvBluredTex.w);
                
                half4 ref01 = SAMPLE_TEXTURE2D(_BluredTexture1, sampler_BluredTexture0, i.uvBluredTex.xy / i.uvBluredTex.w);
                half4 ref02 = SAMPLE_TEXTURE2D(_BluredTexture2, sampler_BluredTexture0, i.uvBluredTex.xy / i.uvBluredTex.w);
                half4 ref03 = SAMPLE_TEXTURE2D(_BluredTexture3, sampler_BluredTexture0, i.uvBluredTex.xy / i.uvBluredTex.w);

                float step00 = smoothstep(0.75, 1.00, surfSmooth);
                float step01 = smoothstep(0.5, 0.75, surfSmooth);
                float step02 = smoothstep(0.05, 0.5, surfSmooth);
                float step03 = smoothstep(0.00, 0.05, surfSmooth);

                half4 color = lerp(ref03, lerp(lerp(lerp(ref03, ref02, step02), ref01, step01), ref00, step00), step03);
                
                return half4(color.x,color.y,color.z,mask.x);
            }
            ENDHLSL  //ENDCG          
        }
    }
}