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

		//����ϸ�ֿ��� �Կ���ϸ�������`�`�����Ե�ƥ��������� CustomTessellation.cginc ��������
		_TessellationUniform("Tessellation Uniform", Range(1, 64)) = 1
		//Ť������ͼ
		_WindDistortionMap("Wind Distortion Map", 2D) = "white" {}
		//����
		_WindFrequency("Wind Frequency", Vector) = (0.05, 0.05, 0, 0)
		//��ǿ��
		_WindStrength("Wind Strength", Float) = 1
		
		//��Ƭ�����ɶ�
		_BladeForward("Blade Forward Amount", Float) = 0.38
		_BladeCurve("Blade Curvature Amount", Range(1, 4)) = 2
    }

	CGINCLUDE   //д������Ĵ����������pass�б�Ӧ��
	#include "UnityCG.cginc"
	#include "Autolight.cginc"
	#include "Shaders/CustomTessellation.cginc"
//������ɫ�����Կ��Ƶ�Ƭ������
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
		unityShadowCoord4 _ShadowCoord : TEXCOORD1;//��Ӱ��ͼͨ�� ��ʵ������ĻUV����
		float3 normal : NORMAL;
	};

	//��ΪCustomTessellation.cginc���Ѿ���������Щ�����Բ����Լ�����
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
	//	o.vertex = v.vertex; //os����
	//	o.normal = v.normal;
	//	o.tangent = v.tangent;
	//	return o;
	//}
	
	////��geometryOutput��ֵ�ķ���
	geometryOutput VertexOutput(float3 pos,float2 uv,float3 normal)
	{
		geometryOutput o;
		o.pos = UnityObjectToClipPos(pos);
		o.uv = uv;
		o._ShadowCoord = ComputeScreenPos(o.pos);
		o.normal = UnityObjectToWorldNormal(normal);
#if UNITY_PASS_SHADOWCASTER //�������������Ͷ����Ӱ���ճ���Ӱ����
		// Applying the bias prevents artifacts from appearing on the surface.
		o.pos = UnityApplyLinearShadowBias(o.pos);
#endif
		return o;
	}

	//ȡһ��λ�á���Ⱥ͸߶ȣ���ͨ���ṩ�ľ�����ȷ��ת�����㣬����������һ�� UV ����
	geometryOutput GenerateGrassVertex(float3 vertexPosition, float width, float height, float forward, float2 uv, float3x3 transformMatrix)
	{
		float3 tangentPoint = float3(width, forward, height);

		//��������߿ռ�ľֲ�����
		float3 tangentNormal = normalize(float3(0, -1, forward));
		float3 localNormal = mul(transformMatrix, tangentNormal);

		float3 localPosition = vertexPosition + mul(transformMatrix, tangentPoint);
		return VertexOutput(localPosition, uv, localNormal);
	}




	//maxvertexcount ���嵱ǰ������ɫ�������񹹽���ʽ ���߸����㣬��3��Ϊһ��
	[maxvertexcount(BLADE_SEGMENTS * 2 + 1)]
	void geo(triangle vertexOutput IN[3] : SV_POSITION, inout TriangleStream<geometryOutput> triStream)
	{
		//��ǰ�����x��
		float3 pos = IN[0].vertex;


		float3 vNormal = IN[0].normal;
		float4 vTangent = IN[0].tangent;
		//���㸱���� 
		//vTangent.w ��һ�������Ǵ�һ����ά��ģ�������������ͨ���и�����(Ҳ��Ϊ������)�Ѿ��洢���������ݡ�Unity û�е�����Щ�����ߣ����Ǽ򵥵ػ�ȡÿ��˫���ߵķ��򣬲����丳�����ߵ� w ���ꡣ�������ĺô��ǿ��Խ�ʡ�ڴ棬ͬʱ������ȷ���Ժ�������¹�����ȷ�Ķ�������
		//cross ��ά�����Ĳ��
		float3 vBinormal = cross(vNormal, vTangent) * vTangent.w;

		//os תts ����
		float3x3 tangentToLocal = float3x3(
			vTangent.x, vBinormal.x, vNormal.x,
			vTangent.y, vBinormal.y, vNormal.y,
			vTangent.z, vBinormal.z, vNormal.z
			);
		//��� �Ʒ�����ת 
		//rand������һ����ά��������һ�������
		//AngleAxis3x3��������һ���Ƕ�(�Ի���Ϊ��λ) ��������һ�����󣬸þ���Χ�����ṩ������ת����һ�������Ĺ�����ʽ����Ԫ����ͬ��
		//Rand ��������һ����0... 1��Χ�ڵ�����; ���ǽ�������ֳ�������Բ���ʣ��õ��Ƕ�ֵ��ȫ����Χ��
		float3x3 facingRotationMatrix = AngleAxis3x3(rand(pos) * UNITY_TWO_PI, float3(0, 0, 1));
		float3x3 bendRotationMatrix = AngleAxis3x3(rand(pos.zzx) * _BendRotationRandom * UNITY_PI * 0.5, float3(-1, 0, 0));
		//��UV���㣬ʵ��ȫ����ͬ��������е�UV����ͬ�����е�
		float2 uv = pos.xz * _WindDistortionMap_ST.xy + _WindDistortionMap_ST.zw + _WindFrequency * _Time.y;
		//����������ͼ
		float2 windSample = (tex2Dlod(_WindDistortionMap, float4(uv, 0, 0)).xy * 2 - 1) * _WindStrength;
		//����һ����ʾ����Ĺ�һ��������
		float3 wind = normalize(float3(windSample.x, windSample.y, 0));
		//����һ��������Χ�����������ת��
		float3x3 windRotation = AngleAxis3x3(UNITY_PI * windSample, wind);
		//��ȡ�����ض�����ƶ���ת����
		float3x3 transformationMatrix = mul(mul(mul(tangentToLocal, facingRotationMatrix), bendRotationMatrix), windRotation);
		//����ֻ�е�����ת�ľ���
		float3x3 transformationMatrixFacing = mul(tangentToLocal, facingRotationMatrix);
		//������ת�������߿ռ��ٹ���������

		float height = (rand(pos.zyx) * 2 - 1) * _BladeHeightRandom + _BladeHeight;
		float width = (rand(pos.xzy) * 2 - 1) * _BladeWidthRandom + _BladeWidth;

		//�������ƫ��ֵ
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
            #pragma vertex vert//������ɫ��
            #pragma fragment frag//ƬԪ��ɫ��
			#pragma hull hull
			#pragma domain domain//����ϸ����ɫ��
			#pragma geometry geo//������ɫ��
			#pragma target 4.6
			#pragma multi_compile_fwdbase //��Ӱ��Ԥ�������
			#include "Lighting.cginc"

			float4 _TopColor;
			float4 _BottomColor;
			float _TranslucentGain;
			
		
			float4 frag (geometryOutput i, fixed facing : VFACE) : SV_Target
            {	
				float3 normal = facing > 0 ? i.normal : -i.normal;

				//����߹��������
				//return float4(normal * 0.5 + 0.5, 1);  
				float shadow = SHADOW_ATTENUATION(i);
				float NdotL = saturate(saturate(dot(normal, _WorldSpaceLightPos0)) + _TranslucentGain) * shadow;

				float3 ambient = ShadeSH9(float4(normal, 1));
				float4 lightIntensity = NdotL * _LightColor0 + float4(ambient, 1);
				float4 col = lerp(_BottomColor, _TopColor * lightIntensity, i.uv.y);

				return col;
				//return lerp(_BottomColor, _TopColor, i.uv.y);
				//Ϊ�˽�����Ӱ��ʹ��Unity�Դ�����ӰͶ���,�᷵����Ӱ����
				//return SHADOW_ATTENUATION(i);
			}
				ENDCG
	}



		Pass
			{
				Tags
				{
					"LightMode" = "ShadowCaster" //����Ϊ��Ͷ����Ӱ
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
					SHADOW_CASTER_FRAGMENT(i); //Unity������Ӱ�ĺ꣬��ƬԪ��ɫ����ʹ��
			}

			ENDCG
}
    }

		//�̳����ӣ�https://roystan.net/articles/grass-shader.html
}