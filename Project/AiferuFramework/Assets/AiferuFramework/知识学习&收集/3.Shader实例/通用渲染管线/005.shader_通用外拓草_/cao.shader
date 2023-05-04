Shader "URPCustom/Unlit/cao"
{
    Properties
    {
        _BaseMap("Base Texture",2D) = "white"{}
        _BaseColor("Base Color",Color) = (1,1,1,1)
        _OutLine("OutLine", Range(0,1)) = 1
    }
        SubShader
        {
            Tags
            {
                "RenderPipeline" = "UniversalPipeline"//声明这是一个URP Shader！
                "Queue" = "Geometry"
                "RenderType" = "Opaque"
            }
            HLSLINCLUDE
            //CG中核心代码库 #include "UnityCG.cginc"
           #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

           //除了贴图外，要暴露在Inspector面板上的变量都需要缓存到CBUFFER中
           //在pass通道外面声明
           CBUFFER_START(UnityPerMaterial)
           float4 _BaseMap_ST;
           half4 _BaseColor;
           float _OutLine;
           CBUFFER_END
           ENDHLSL


           Pass
           {                                        //声明这个pass是一个渲染pass
               Tags{"LightMode" = "UniversalForward"}//这个Pass最终会输出到颜色缓冲里//URP只支持一个pass通道输出渲染，其他pass只能进行计算

               HLSLPROGRAM //CGPROGRAM
               #pragma vertex vert
               #pragma fragment frag

               struct Attributes//这就是a2v
               {
                   float4 positionOS : POSITION;
                   float2 uv : TEXCOORD;
                   float3 normal :NORMAL;
               };
               struct Varings//这就是v2f
               {
                   float4 positionCS : SV_POSITION;
                   float2 uv : TEXCOORD;
               };

               TEXTURE2D(_BaseMap);//在CG中会写成sampler2D _MainTex;
               SAMPLER(sampler_BaseMap);

               Varings vert(Attributes IN)
               {
                   Varings OUT;
                   IN.positionOS.xyz += IN.normal * _OutLine;
                   //在CG里面，我们这样转换空间坐标 o.vertex = UnityObjectToClipPos(v.vertex);
                   VertexPositionInputs positionInputs = GetVertexPositionInputs(IN.positionOS.xyz);
                   OUT.positionCS = positionInputs.positionCS;

                   OUT.uv = TRANSFORM_TEX(IN.uv,_BaseMap);
                   return OUT;
               }

               float4 frag(Varings IN) :SV_Target
               {
                   //在CG里，我们这样对贴图采样 fixed4 col = tex2D(_MainTex, i.uv);
                   half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv);
                   return baseMap * _BaseColor;
               }
               ENDHLSL  //ENDCG          
           }
        }
}