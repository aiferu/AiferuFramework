Shader "Aiferu/URP/FrostedGlass"
{
    Properties
    {
        _FrostTexture ("FrostTexture",2D) = "white"{}
        _FrostIntensity("FrostIntensity",float) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"//声明这是一个URP Shader！
        }
        HLSLINCLUDE
         //CG中核心代码库 #include "UnityCG.cginc"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
       
        //除了贴图外，要暴露在Inspector面板上的变量都需要缓存到CBUFFER中
        //在pass通道外面声明
        CBUFFER_START(UnityPerMaterial)
        float4 _FrostTexture_ST;
        float _FrostIntensity;
        CBUFFER_END
        ENDHLSL

        Pass
        {                                        //声明这个pass是一个渲染pass
            Tags{"LightMode"="UniversalForward"}//这个Pass最终会输出到颜色缓冲里//URP只支持一个pass通道输出渲染，其他pass只能进行计算

            HLSLPROGRAM //CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            TEXTURE2D(_FrostTexture);
            SAMPLER(sampler_FrostTexture);

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
	            float2 uv : TEXCOORD0;
	            float4 uvBluredTex : TEXCOORD1;
            };

            Varings vert(Attributes i)
            {
	            Varings o;
	            VertexPositionInputs posInputs = GetVertexPositionInputs(i.positionOS.xyz);
	            o.positionCS = posInputs.positionCS;
	            o.uv = TRANSFORM_TEX(i.uv, _FrostTexture);
	            o.uvBluredTex = ComputeScreenPos(o.positionCS);

	            return o;
            }

            half4 frag(Varings i) : SV_Target 
            {
	            float surfSmooth = 1 - SAMPLE_TEXTURE2D(_FrostTexture, sampler_FrostTexture, i.uv).x * _FrostIntensity;
	            surfSmooth = clamp(0, 1, surfSmooth);

	            half4 ref00 = SAMPLE_TEXTURE2D(_BluredTexture0, sampler_BluredTexture0, i.uvBluredTex.xy / i.uvBluredTex.w);
	            half4 ref01 = SAMPLE_TEXTURE2D(_BluredTexture1, sampler_BluredTexture0, i.uvBluredTex.xy / i.uvBluredTex.w);
	            half4 ref02 = SAMPLE_TEXTURE2D(_BluredTexture2, sampler_BluredTexture0, i.uvBluredTex.xy / i.uvBluredTex.w);
	            half4 ref03 = SAMPLE_TEXTURE2D(_BluredTexture3, sampler_BluredTexture0, i.uvBluredTex.xy / i.uvBluredTex.w);

	            float step00 = smoothstep(0.75, 1.00, surfSmooth);
	            float step01 = smoothstep(0.5, 0.75, surfSmooth);
	            float step02 = smoothstep(0.05, 0.5, surfSmooth);
	            float step03 = smoothstep(0.00, 0.05, surfSmooth);

	            return lerp(ref03, lerp(lerp(lerp(ref03, ref02, step02), ref01, step01), ref00, step00), step03);
            }
            ENDHLSL  //ENDCG          
        }
    }
}