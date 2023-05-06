Shader "Aiferu/URP/SeparableBlur"
{
    Properties
    {
        _MainTex ("MainTex",2D) = "white"{}
        _BlurAmount("_BlurAmount", vector) = (1,1,1)
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
        float4 _MainTex_ST;
        float3 _BlurAmount;
        CBUFFER_END
        ENDHLSL

        Pass
        {                                        //声明这个pass是一个渲染pass
            Tags{"LightMode"="UniversalForward"}//这个Pass最终会输出到颜色缓冲里//URP只支持一个pass通道输出渲染，其他pass只能进行计算

            HLSLPROGRAM //CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct Attributes
            {
	            float4 positionOS : POSITION;
	            float2 uv : TEXCOORD;
            };

            struct Varings
            {
	            float4 positionCS : SV_POSITION;
	            float2 uv : TEXCOORD;
	            float4 uv01 : TEXCOORD1;
	            float4 uv23 : TEXCOORD2;
	            float4 uv45 : TEXCOORD3;
            };

            TEXTURE2D(_MainTex);//在CG中会写成sampler2D _MainTex;
            SAMPLER(sampler_MainTex);

            Varings vert(Attributes i)
            {
	            Varings o;
	            VertexPositionInputs posInputs = GetVertexPositionInputs(i.positionOS.xyz);
	            o.positionCS = posInputs.positionCS;

	            o.uv = TRANSFORM_TEX(i.uv, _MainTex);
	            o.uv01 =  i.uv.xyxy + _BlurAmount.xyxy * float4(1, 1, -1, -1);
	            o.uv23 =  i.uv.xyxy + _BlurAmount.xyxy * float4(1, 1, -1, -1) * 2.0;
	            o.uv45 =  i.uv.xyxy + _BlurAmount.xyxy * float4(1, 1, -1, -1) * 3.0;

	            return o;
            }

            float4 frag(Varings i) : SV_Target 
            {
	            float4 color = float4(0, 0, 0, 0);
	            color += 0.40 * SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
	            color += 0.15 * SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv01.xy); 
	            color += 0.15 * SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv01.zw); 
	            color += 0.10 * SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv23.xy); 
	            color += 0.10 * SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv23.zw); 
	            color += 0.05 * SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv45.xy); 
	            color += 0.05 * SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv45.zw); 

	            return color;
            }
            ENDHLSL  //ENDCG          
        }
    }
}