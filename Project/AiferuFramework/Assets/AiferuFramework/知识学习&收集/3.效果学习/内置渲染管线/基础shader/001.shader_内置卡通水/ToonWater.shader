Shader "Roystan/Toon/Water"
{
    Properties
    {	
        //阴影颜色
        _DepthGradientShallow("Depth Gradient Shallow", Color) = (0.325, 0.807, 0.971, 0.725)
        //海水颜色
        _DepthGradientDeep("Depth Gradient Deep", Color) = (0.086, 0.407, 1, 0.749)
        _DepthMaxDistance("Depth Maximum Distance", Float) = 1
        //噪声贴图
        _SurfaceNoise("Surface Noise", 2D) = "white" {}
        //噪声限制
        _SurfaceNoiseCutoff("Surface Noise Cutoff", Range(0, 1)) = 0.777
        //噪声截止阈值
        _FoamDistance("Foam Distance", Float) = 0.4
        //水移动的方向
        _SurfaceNoiseScroll("Surface Noise Scroll Amount", Vector) = (0.03, 0.03, 0, 0)
        //失真贴图，这个失真纹理将类似于法线贴图，除了只有两个通道(红色和绿色)而不是三个。
        //我们将这两个通道解释为二维平面上的向量，并使用它们来拉动我们的噪声纹理的UV。
        _SurfaceDistortion("Surface Distortion", 2D) = "white" {}	
        //失真贴图强度
        _SurfaceDistortionAmount("Surface Distortion Amount", Range(0, 1)) = 0.27

    }
    SubShader
    {
        Pass
        {
			CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
            };

           
            struct v2f
            {
                float4 vertex : SV_POSITION;
                //屏幕空间坐标存储
                float4 screenPosition : TEXCOORD2;
                //噪声UV
                float2 noiseUV : TEXCOORD0;
                //失真贴图uv
                float2 distortUV : TEXCOORD1;
            };

            float4 _DepthGradientShallow;
            float4 _DepthGradientDeep;
            float _DepthMaxDistance;
            //摄像机深度贴图
            sampler2D _CameraDepthTexture;
            //噪声贴图
            sampler2D _SurfaceNoise;
            float4 _SurfaceNoise_ST;
            //噪声贴图限制
            float _SurfaceNoiseCutoff;
            //噪声截止阈值
            float _FoamDistance;
            //水移动的方向
            float2 _SurfaceNoiseScroll;

            //失真贴图
            sampler2D _SurfaceDistortion;
            float4 _SurfaceDistortion_ST;
            //失真贴图强度
            float _SurfaceDistortionAmount;

            v2f vert (appdata v)
            {
                v2f o;
                //物体坐标转换成裁剪空间坐标
                o.vertex = UnityObjectToClipPos(v.vertex);
                //裁剪空间坐标转换成屏幕空间坐标
                o.screenPosition = ComputeScreenPos(o.vertex);
                //噪声uv采样
                o.noiseUV = TRANSFORM_TEX(v.uv, _SurfaceNoise);
                //失真UV采样
                o.distortUV = TRANSFORM_TEX(v.uv, _SurfaceDistortion);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                //获取屏幕深度信息
                float existingDepth01 = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPosition)).r;
                //将非线性的深度信息转换陈线性的深度信息
                float existingDepthLinear = LinearEyeDepth(existingDepth01);
                //获取水面深度（水最深的地方到屏幕的深度）与屏幕深度（摄像机水面的深度）的差值
				float depthDifference = existingDepthLinear - i.screenPosition.w;
                //限制深度差值到0-1之间，当颜色混合值来用
                float waterDepthDifference01 = saturate(depthDifference / _DepthMaxDistance);
                //混合水面和阴影的颜色
                float4 waterColor = lerp(_DepthGradientShallow, _DepthGradientDeep, waterDepthDifference01);

                 //失真贴图纹理采样                                //限制到-1 ，1区间
                float2 distortSample = (tex2D(_SurfaceDistortion, i.distortUV).xy * 2 - 1) * _SurfaceDistortionAmount;
                //移动噪声贴图，添加流水效果  
                float2 noiseUV = float2((i.noiseUV.x + _Time.y * _SurfaceNoiseScroll.x) + distortSample.x, (i.noiseUV.y + _Time.y * _SurfaceNoiseScroll.y) + distortSample.y);
                //噪声贴图纹理采样
                float surfaceNoiseSample = tex2D(_SurfaceNoise,noiseUV).r;

               
                //限制深度差值到0-1之间，限定噪波增强范围
                float foamDepthDifference01 = saturate(depthDifference / _FoamDistance);
                float surfaceNoiseCutoff = foamDepthDifference01 * _SurfaceNoiseCutoff;
                
                float surfaceNoise = surfaceNoiseSample > surfaceNoiseCutoff ? 1 : 0;



                return waterColor+surfaceNoise;
            }
            ENDCG
        }
    }
}