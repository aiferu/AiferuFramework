Shader "Unlit/1btpost"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _SplitTex1("Texture", 2D) = "white" {}
        _SplitTex2("Texture", 2D) = "white" {}
        _SplitTex3("Texture", 2D) = "white" {}
        _SplitTex4("Texture", 2D) = "white" {}
        _SplitTex5("Texture", 2D) = "white" {}
        _Split1To2("Split1To2",float) = 0.2
        _Split2To3("Split2To3",float) = 0.4
        _Split3To4("Split3To4",float) = 0.6
        _Split4To5("Split4To5",float) = 0.8

    }
        SubShader
        {
            Tags { "RenderType" = "Opaque" }
            LOD 100

            Pass
            {
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag


                #include "UnityCG.cginc"

                struct appdata
                {
                    float4 vertex : POSITION;
                    float2 uv : TEXCOORD0;
                };

                struct v2f
                {
                    float2 uv : TEXCOORD0;
                    float2 uv1 : TEXCOORD1;

                    float4 vertex : SV_POSITION;
                };

                sampler2D _MainTex;
                float4 _MainTex_ST;
                sampler2D _SplitTex1;
                float4 _SplitTex1_ST;
                sampler2D _SplitTex2;
                float4 _SplitTex2_ST;
                sampler2D _SplitTex3;
                float4 _SplitTex3_ST;
                sampler2D _SplitTex4;
                float4 _SplitTex4_ST;
                sampler2D _SplitTex5;
                float4 _SplitTex5_ST;

                float _Split1To2;
                float _Split2To3;
                float _Split3To4;
                float _Split4To5;


                v2f vert(appdata v)
                {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                    o.uv1 = TRANSFORM_TEX(v.uv, _SplitTex1);
                    UNITY_TRANSFER_FOG(o,o.vertex);
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target
                {
                    // sample the texture
                    fixed4 col = tex2D(_MainTex, i.uv);
                    fixed4 col1 = tex2D(_SplitTex1, i.uv1);
                    fixed4 col2 = tex2D(_SplitTex2, i.uv1);
                    fixed4 col3 = tex2D(_SplitTex3, i.uv1);
                    fixed4 col4 = tex2D(_SplitTex4, i.uv1);
                    fixed4 col5 = tex2D(_SplitTex5, i.uv1);
                    //明亮度计算公式
                    float luminance = 0.2125 * col.r + 0.7154 * col.g + 0.0721 * col.b;
                    if (luminance <= _Split1To2)
                    {
                        //col = float4(luminance,luminance,luminance,col.a);
                        col = col1;
                        }
                        if (luminance <= _Split2To3 && luminance > _Split1To2)
                        {
                            //col = float4(luminance,luminance,luminance,col.a);
                            col = col2;
                            }
                            if (luminance <= _Split3To4 && luminance > _Split2To3)
                            {
                                //col = float4(luminance,luminance,luminance,col.a);
                                col = col3;
                                }
                                if (luminance <= _Split4To5 && luminance > _Split3To4)
                                {
                                    //col = float4(luminance,luminance,luminance,col.a);
                                    col = col4;
                                    }
                                    if (luminance > _Split4To5)
                                    {
                                        //col = float4(luminance,luminance,luminance,col.a);
                                        col = col5;
                                        }


                                    // col = float4(luminance,luminance,luminance,col.a);
                                     return col;
                                 }
                                 ENDCG
                             }
        }
}
