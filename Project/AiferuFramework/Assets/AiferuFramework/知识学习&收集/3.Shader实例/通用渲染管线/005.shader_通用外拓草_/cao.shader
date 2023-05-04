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
                "RenderPipeline" = "UniversalPipeline"//��������һ��URP Shader��
                "Queue" = "Geometry"
                "RenderType" = "Opaque"
            }
            HLSLINCLUDE
            //CG�к��Ĵ���� #include "UnityCG.cginc"
           #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

           //������ͼ�⣬Ҫ��¶��Inspector����ϵı�������Ҫ���浽CBUFFER��
           //��passͨ����������
           CBUFFER_START(UnityPerMaterial)
           float4 _BaseMap_ST;
           half4 _BaseColor;
           float _OutLine;
           CBUFFER_END
           ENDHLSL


           Pass
           {                                        //�������pass��һ����Ⱦpass
               Tags{"LightMode" = "UniversalForward"}//���Pass���ջ��������ɫ������//URPֻ֧��һ��passͨ�������Ⱦ������passֻ�ܽ��м���

               HLSLPROGRAM //CGPROGRAM
               #pragma vertex vert
               #pragma fragment frag

               struct Attributes//�����a2v
               {
                   float4 positionOS : POSITION;
                   float2 uv : TEXCOORD;
                   float3 normal :NORMAL;
               };
               struct Varings//�����v2f
               {
                   float4 positionCS : SV_POSITION;
                   float2 uv : TEXCOORD;
               };

               TEXTURE2D(_BaseMap);//��CG�л�д��sampler2D _MainTex;
               SAMPLER(sampler_BaseMap);

               Varings vert(Attributes IN)
               {
                   Varings OUT;
                   IN.positionOS.xyz += IN.normal * _OutLine;
                   //��CG���棬��������ת���ռ����� o.vertex = UnityObjectToClipPos(v.vertex);
                   VertexPositionInputs positionInputs = GetVertexPositionInputs(IN.positionOS.xyz);
                   OUT.positionCS = positionInputs.positionCS;

                   OUT.uv = TRANSFORM_TEX(IN.uv,_BaseMap);
                   return OUT;
               }

               float4 frag(Varings IN) :SV_Target
               {
                   //��CG�������������ͼ���� fixed4 col = tex2D(_MainTex, i.uv);
                   half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv);
                   return baseMap * _BaseColor;
               }
               ENDHLSL  //ENDCG          
           }
        }
}