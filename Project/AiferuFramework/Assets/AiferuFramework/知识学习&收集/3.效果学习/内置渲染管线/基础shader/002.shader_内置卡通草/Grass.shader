Shader "Roystan/Grass"
{
    Properties
    {
		[Header(Shading)]
        _TopColor("Top Color", Color) = (1,1,1,1)
		_BottomColor("Bottom Color", Color) = (1,1,1,1)
		_TranslucentGain("Translucent Gain", Range(0,1)) = 0.5
		_BendRotationRandom("Bend Rotation Random", Range(0, 1)) = 0.2

		_BladeWidth("Blade Width", Float) = 0.05
		_BladeWidthRandom("Blade Width Random", Float) = 0.02
		_BladeHeight("Blade Height", Float) = 0.5
		_BladeHeightRandom("Blade Height Random", Float) = 0.3

		//曲面细分控制 以控制细分数量ーー此属性的匹配变量已在 CustomTessellation.cginc 中声明。
		_TessellationUniform("Tessellation Uniform", Range(1, 64)) = 1
		//扭曲风贴图
		_WindDistortionMap("Wind Distortion Map", 2D) = "white" {}
		//风速
		_WindFrequency("Wind Frequency", Vector) = (0.05, 0.05, 0, 0)
		//风强度
		_WindStrength("Wind Strength", Float) = 1
		
		//面片弯曲成都
		_BladeForward("Blade Forward Amount", Float) = 0.38
		_BladeCurve("Blade Curvature Amount", Range(1, 4)) = 2
    }

	CGINCLUDE   //写在这里的代码会在所有pass中被应用
	#include "UnityCG.cginc"
	#include "Autolight.cginc"
	#include "Shaders/CustomTessellation.cginc"
//定义着色器可以控制的片段数量
#define BLADE_SEGMENTS 3

	float _BladeHeight;
	float _BladeHeightRandom;
	float _BladeWidth;
	float _BladeWidthRandom;
	float _BendRotationRandom;
	
	sampler2D _WindDistortionMap;
	float4 _WindDistortionMap_ST;

	float2 _WindFrequency;
	float _WindStrength;


	float _BladeForward;
	float _BladeCurve;
	// Simple noise function, sourced from http://answers.unity.com/answers/624136/view.html
	// Extended discussion on this function can be found at the following link:
	// https://forum.unity.com/threads/am-i-over-complicating-this-random-function.454887/#post-2949326
	// Returns a number in the 0...1 range.
	float rand(float3 co)
	{
		return frac(sin(dot(co.xyz, float3(12.9898, 78.233, 53.539))) * 43758.5453);
	}

	// Construct a rotation matrix that rotates around the provided axis, sourced from:
	// https://gist.github.com/keijiro/ee439d5e7388f3aafc5296005c8c3f33
	float3x3 AngleAxis3x3(float angle, float3 axis)
	{
		float c, s;
		sincos(angle, s, c);

		float t = 1 - c;
		float x = axis.x;
		float y = axis.y;
		float z = axis.z;

		return float3x3(
			t * x * x + c, t * x * y - s * z, t * x * z + s * y,
			t * x * y + s * z, t * y * y + c, t * y * z - s * x,
			t * x * z - s * y, t * y * z + s * x, t * z * z + c
			);
	}


	struct geometryOutput
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
		unityShadowCoord4 _ShadowCoord : TEXCOORD1;//阴影贴图通道 事实上是屏幕UV坐标
		float3 normal : NORMAL;
	};

	//因为CustomTessellation.cginc中已经定义了这些，所以不用自己定义
	//struct vertexInput
	//{
	//	float4 vertex : POSITION;
	//	float3 normal : NORMAL;
	//	float4 tangent : TANGENT;
	//};

	//struct vertexOutput
	//{
	//	float4 vertex : SV_POSITION;
	//	float3 normal : NORMAL;
	//	float4 tangent : TANGENT;
	//};

	//vertexOutput vert(vertexInput v)
	//{
	//	vertexOutput o;
	//	o.vertex = v.vertex; //os坐标
	//	o.normal = v.normal;
	//	o.tangent = v.tangent;
	//	return o;
	//}
	
	////给geometryOutput赋值的方法
	geometryOutput VertexOutput(float3 pos,float2 uv,float3 normal)
	{
		geometryOutput o;
		o.pos = UnityObjectToClipPos(pos);
		o.uv = uv;
		o._ShadowCoord = ComputeScreenPos(o.pos);
		o.normal = UnityObjectToWorldNormal(normal);
#if UNITY_PASS_SHADOWCASTER //解决物体向自身投射阴影，照成阴影错误
		// Applying the bias prevents artifacts from appearing on the surface.
		o.pos = UnityApplyLinearShadowBias(o.pos);
#endif
		return o;
	}

	//取一个位置、宽度和高度，它通过提供的矩阵正确地转换顶点，并给它分配一个 UV 坐标
	geometryOutput GenerateGrassVertex(float3 vertexPosition, float width, float height, float forward, float2 uv, float3x3 transformMatrix)
	{
		float3 tangentPoint = float3(width, forward, height);

		//计算出切线空间的局部法线
		float3 tangentNormal = normalize(float3(0, -1, forward));
		float3 localNormal = mul(transformMatrix, tangentNormal);

		float3 localPosition = vertexPosition + mul(transformMatrix, tangentPoint);
		return VertexOutput(localPosition, uv, localNormal);
	}




	//maxvertexcount 定义当前几何着色器的网格构建形式 有七个顶点，且3个为一组
	[maxvertexcount(BLADE_SEGMENTS * 2 + 1)]
	void geo(triangle vertexOutput IN[3] : SV_POSITION, inout TriangleStream<geometryOutput> triStream)
	{
		//当前顶点的x轴
		float3 pos = IN[0].vertex;


		float3 vNormal = IN[0].normal;
		float4 vTangent = IN[0].tangent;
		//计算副法线 
		//vTangent.w 当一个网格是从一个三维建模软件包导出，它通常有副法线(也称为副切线)已经存储在网格数据。Unity 没有导入这些副法线，而是简单地获取每个双法线的方向，并将其赋给切线的 w 坐标。这样做的好处是可以节省内存，同时还可以确保以后可以重新构造正确的二进制数
		//cross 三维向量的叉乘
		float3 vBinormal = cross(vNormal, vTangent) * vTangent.w;

		//os 转ts 矩阵
		float3x3 tangentToLocal = float3x3(
			vTangent.x, vBinormal.x, vNormal.x,
			vTangent.y, vBinormal.y, vNormal.y,
			vTangent.z, vBinormal.z, vNormal.z
			);
		//随机 绕法线旋转 
		//rand，它从一个三维输入生成一个随机数
		//AngleAxis3x3，它接受一个角度(以弧度为单位) ，并返回一个矩阵，该矩阵围绕所提供的轴旋转。后一个函数的工作方式与四元数相同。
		//Rand 函数返回一个在0... 1范围内的数字; 我们将这个数字乘以两个圆周率，得到角度值的全部范围。
		float3x3 facingRotationMatrix = AngleAxis3x3(rand(pos) * UNITY_TWO_PI, float3(0, 0, 1));
		float3x3 bendRotationMatrix = AngleAxis3x3(rand(pos.zzx) * _BendRotationRandom * UNITY_PI * 0.5, float3(-1, 0, 0));
		//风UV计算，实现全场不同物体的所有的UV都是同步进行的
		float2 uv = pos.xz * _WindDistortionMap_ST.xy + _WindDistortionMap_ST.zw + _WindFrequency * _Time.y;
		//采样噪声贴图
		float2 windSample = (tex2Dlod(_WindDistortionMap, float4(uv, 0, 0)).xy * 2 - 1) * _WindStrength;
		//构造一个表示风向的归一化向量。
		float3 wind = normalize(float3(windSample.x, windSample.y, 0));
		//构造一个矩阵来围绕这个向量旋转，
		float3x3 windRotation = AngleAxis3x3(UNITY_PI * windSample, wind);
		//获取基于特定轴的移动旋转矩阵
		float3x3 transformationMatrix = mul(mul(mul(tangentToLocal, facingRotationMatrix), bendRotationMatrix), windRotation);
		//仅仅只有单轴旋转的矩阵
		float3x3 transformationMatrixFacing = mul(tangentToLocal, facingRotationMatrix);
		//将顶点转换成切线空间再构建三角形

		float height = (rand(pos.zyx) * 2 - 1) * _BladeHeightRandom + _BladeHeight;
		float width = (rand(pos.xzy) * 2 - 1) * _BladeWidthRandom + _BladeWidth;

		//生成随机偏移值
		float forward = rand(pos.yyz) * _BladeForward;

		for (int i = 0; i < BLADE_SEGMENTS; i++)
		{
			float t = i / (float)BLADE_SEGMENTS;

			float segmentHeight = height * t;
			float segmentWidth = width * (1 - t);
			float segmentForward = pow(t, _BladeCurve) * forward;

			float3x3 transformMatrix = i == 0 ? transformationMatrixFacing : transformationMatrix;

			triStream.Append(GenerateGrassVertex(pos, segmentWidth, segmentHeight, segmentForward, float2(0, t), transformMatrix));
			triStream.Append(GenerateGrassVertex(pos, -segmentWidth, segmentHeight, segmentForward, float2(1, t), transformMatrix));
		}

		/*triStream.Append(VertexOutput(pos + mul(transformationMatrixFacing, float3(width, 0, 0)), float2(0, 0)));
		triStream.Append(VertexOutput(pos + mul(transformationMatrixFacing, float3(-width, 0, 0)), float2(1, 0)));
		triStream.Append(VertexOutput(pos + mul(transformationMatrix, float3(0, 0, height)), float2(0.5, 1)));*/

		/*triStream.Append(GenerateGrassVertex(pos, width, 0, float2(0, 0), transformationMatrixFacing));
		triStream.Append(GenerateGrassVertex(pos, -width, 0, float2(1, 0), transformationMatrixFacing));
		triStream.Append(GenerateGrassVertex(pos, 0, height, float2(0.5, 1), transformationMatrix));*/
		triStream.Append(GenerateGrassVertex(pos, 0, height, forward, float2(0.5, 1), transformationMatrix));
	}


	ENDCG

    SubShader
    {
		Cull Off

        Pass
        {
			Tags
			{
				"RenderType" = "Opaque"
				"LightMode" = "ForwardBase"
			}

            CGPROGRAM
            #pragma vertex vert//顶点着色器
            #pragma fragment frag//片元着色器
			#pragma hull hull
			#pragma domain domain//曲面细分着色器
			#pragma geometry geo//几何着色器
			#pragma target 4.6
			#pragma multi_compile_fwdbase //阴影用预处理组件
			#include "Lighting.cginc"

			float4 _TopColor;
			float4 _BottomColor;
			float _TranslucentGain;
			
		
			float4 frag (geometryOutput i, fixed facing : VFACE) : SV_Target
            {	
				float3 normal = facing > 0 ? i.normal : -i.normal;

				//计算高光和漫反射
				//return float4(normal * 0.5 + 0.5, 1);  
				float shadow = SHADOW_ATTENUATION(i);
				float NdotL = saturate(saturate(dot(normal, _WorldSpaceLightPos0)) + _TranslucentGain) * shadow;

				float3 ambient = ShadeSH9(float4(normal, 1));
				float4 lightIntensity = NdotL * _LightColor0 + float4(ambient, 1);
				float4 col = lerp(_BottomColor, _TopColor * lightIntensity, i.uv.y);

				return col;
				//return lerp(_BottomColor, _TopColor, i.uv.y);
				//为了接受阴影，使用Unity自带的阴影投射宏,会返回阴影数据
				//return SHADOW_ATTENUATION(i);
			}
				ENDCG
	}



		Pass
			{
				Tags
				{
					"LightMode" = "ShadowCaster" //定义为可投射阴影
				}

				CGPROGRAM
				#pragma vertex vert
				#pragma geometry geo
				#pragma fragment frag
				#pragma hull hull
				#pragma domain domain
				#pragma target 4.6
				#pragma multi_compile_shadowcaster

				float4 frag(geometryOutput i) : SV_Target
				{
					SHADOW_CASTER_FRAGMENT(i); //Unity处理阴影的宏，在片元着色器中使用
			}

			ENDCG
}
    }

		//教程链接：https://roystan.net/articles/grass-shader.html
}