// Made with Amplify Shader Editor v1.9.0.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MaterialBlend"
{
	Properties
	{
		_BlendContrast("BlendContrast", Range( 0 , 1)) = 0.1
		_Layer1_BaseColor("Layer1_BaseColor", 2D) = "white" {}
		_Layer1_Tiling("Layer1_Tiling", Float) = 1
		_Layer1_Normal("Layer1_Normal", 2D) = "bump" {}
		_Layer1_HRA("Layer1_HRA", 2D) = "white" {}
		_Layer2_BaseColor("Layer2_BaseColor", 2D) = "white" {}
		_Layer2_Tilling("Layer2_Tilling", Float) = 1
		_Layer2_Normal("Layer2_Normal", 2D) = "bump" {}
		_Layer2_HRA("Layer2_HRA", 2D) = "white" {}
		_Layer3_BaseColor("Layer3_BaseColor", 2D) = "white" {}
		_Layer3_Tilling("Layer3_Tilling", Float) = 1
		_Layer3_Normal("Layer3_Normal", 2D) = "bump" {}
		_Layer3_HRA("Layer3_HRA", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform sampler2D _Layer1_BaseColor;
		uniform float _Layer1_Tiling;
		uniform sampler2D _Layer1_HRA;
		uniform sampler2D _Layer2_HRA;
		uniform float _Layer2_Tilling;
		uniform sampler2D _Layer3_HRA;
		uniform float _Layer3_Tilling;
		uniform float _BlendContrast;
		uniform sampler2D _Layer2_BaseColor;
		uniform sampler2D _Layer3_BaseColor;
		uniform sampler2D _Layer1_Normal;
		uniform sampler2D _Layer2_Normal;
		uniform sampler2D _Layer3_Normal;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			SurfaceOutputStandard s1 = (SurfaceOutputStandard ) 0;
			float2 LayerUV5 = i.uv_texcoord;
			float2 temp_output_10_0 = ( LayerUV5 * _Layer1_Tiling );
			float4 Layer1BaseColor13 = tex2D( _Layer1_BaseColor, temp_output_10_0 );
			float4 tex2DNode3 = tex2D( _Layer1_HRA, temp_output_10_0 );
			float Layer1_Height65 = tex2DNode3.r;
			float temp_output_157_0 = ( Layer1_Height65 + i.vertexColor.r );
			float2 temp_output_27_0 = ( LayerUV5 * _Layer2_Tilling );
			float4 tex2DNode28 = tex2D( _Layer2_HRA, temp_output_27_0 );
			float Layer2_Height64 = tex2DNode28.r;
			float temp_output_160_0 = ( Layer2_Height64 + i.vertexColor.g );
			float2 temp_output_78_0 = ( LayerUV5 * _Layer3_Tilling );
			float4 tex2DNode79 = tex2D( _Layer3_HRA, temp_output_78_0 );
			float Layer3_Height80 = tex2DNode79.r;
			float temp_output_161_0 = ( Layer3_Height80 + i.vertexColor.b );
			float temp_output_100_0 = ( max( max( temp_output_157_0 , temp_output_160_0 ) , temp_output_161_0 ) - _BlendContrast );
			float temp_output_109_0 = max( ( temp_output_157_0 - temp_output_100_0 ) , 0.0 );
			float temp_output_111_0 = max( ( temp_output_160_0 - temp_output_100_0 ) , 0.0 );
			float temp_output_110_0 = max( ( temp_output_161_0 - temp_output_100_0 ) , 0.0 );
			float3 appendResult114 = (float3(temp_output_109_0 , temp_output_111_0 , temp_output_110_0));
			float3 BlendWeight117 = ( appendResult114 / ( temp_output_109_0 + temp_output_111_0 + temp_output_110_0 ) );
			float3 break120 = BlendWeight117;
			float4 Layer2BaseColor32 = tex2D( _Layer2_BaseColor, temp_output_27_0 );
			float4 Layer3BaseColor85 = tex2D( _Layer3_BaseColor, temp_output_78_0 );
			float4 BaseColor40 = ( ( Layer1BaseColor13 * break120.x ) + ( Layer2BaseColor32 * break120.y ) + ( Layer3BaseColor85 * break120.z ) );
			s1.Albedo = BaseColor40.rgb;
			float3 Layer1Normal15 = UnpackNormal( tex2D( _Layer1_Normal, temp_output_10_0 ) );
			float3 break145 = BlendWeight117;
			float3 Layer2Normal33 = UnpackNormal( tex2D( _Layer2_Normal, temp_output_27_0 ) );
			float3 Layer3Normal84 = UnpackNormal( tex2D( _Layer3_Normal, temp_output_78_0 ) );
			float3 Normal54 = ( ( Layer1Normal15 * break145.x ) + ( Layer2Normal33 * break145.y ) + ( Layer3Normal84 * break145.z ) );
			s1.Normal = WorldNormalVector( i , Normal54 );
			s1.Emission = float3( 0,0,0 );
			s1.Metallic = 0.0;
			float Layer1Roughness16 = tex2DNode3.g;
			float3 break142 = BlendWeight117;
			float Layer2Roughness31 = tex2DNode28.g;
			float Layer3Roughness82 = tex2DNode79.g;
			float Rougness46 = ( ( Layer1Roughness16 * break142.x ) + ( Layer2Roughness31 * break142.y ) + ( Layer3Roughness82 * break142.z ) );
			s1.Smoothness = ( 1.0 - Rougness46 );
			float Layer1AO17 = tex2DNode3.b;
			float3 break151 = BlendWeight117;
			float Layer2AO34 = tex2DNode28.b;
			float Layer3AO86 = tex2DNode79.b;
			float AO61 = ( ( Layer1AO17 * break151.x ) + ( Layer2AO34 * break151.y ) + ( Layer3AO86 * break151.z ) );
			s1.Occlusion = AO61;

			data.light = gi.light;

			UnityGI gi1 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g1 = UnityGlossyEnvironmentSetup( s1.Smoothness, data.worldViewDir, s1.Normal, float3(0,0,0));
			gi1 = UnityGlobalIllumination( data, s1.Occlusion, s1.Normal, g1 );
			#endif

			float3 surfResult1 = LightingStandard ( s1, viewDir, gi1 ).rgb;
			surfResult1 += s1.Emission;

			#ifdef UNITY_PASS_FORWARDADD//1
			surfResult1 -= s1.Emission;
			#endif//1
			c.rgb = surfResult1;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				half4 color : COLOR0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.color = v.color;
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.vertexColor = IN.color;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19002
-1198.933;-163.3333;1211.667;696.3333;9531.912;1631.016;8.127728;True;False
Node;AmplifyShaderEditor.CommentaryNode;6;-5715.892,-90.96707;Inherit;False;566;206;UV;2;4;5;UV;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;4;-5665.892,-40.96706;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;75;-5719.665,1943.665;Inherit;False;1148.369;760.8695;Layer03;11;86;85;84;83;82;81;80;79;78;77;76;Layer03;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;5;-5377.891,-28.9671;Inherit;False;LayerUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;8;-5706.481,200.7636;Inherit;False;1148.369;760.8695;Layer01;11;17;15;13;16;7;2;3;10;9;11;65;Layer01;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;24;-5717.463,1074.863;Inherit;False;1148.369;760.8695;Layer02;11;34;33;32;31;30;29;28;27;26;25;64;Layer02;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-5703.942,1280.357;Inherit;False;Property;_Layer2_Tilling;Layer2_Tilling;6;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;77;-5690.674,2049.37;Inherit;False;5;LayerUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-5676.961,410.2578;Inherit;False;Property;_Layer1_Tiling;Layer1_Tiling;2;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;9;-5700.348,298.8515;Inherit;False;5;LayerUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-5683.289,2156.776;Inherit;False;Property;_Layer3_Tilling;Layer3_Tilling;10;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;26;-5711.329,1172.951;Inherit;False;5;LayerUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-5513.198,1221.357;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-5502.216,347.2578;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;-5492.543,2097.775;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;3;-5225.099,488.8515;Inherit;True;Property;_Layer1_HRA;Layer1_HRA;4;0;Create;True;0;0;0;False;0;False;-1;None;0bc83a0095e29674a936bddc1dea3e0c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;28;-5236.081,1362.951;Inherit;True;Property;_Layer2_HRA;Layer2_HRA;8;0;Create;True;0;0;0;False;0;False;-1;None;ee82d1d8011b4ac4c87f30e3c928d2f7;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;68;-5714.935,-827.6225;Inherit;False;2422.029;672.7042;BlendWeight混合权重计算;26;117;115;116;114;109;110;111;104;105;102;101;107;165;100;99;98;162;160;157;161;164;156;163;158;159;95;BlendWeight;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;79;-5238.283,2231.752;Inherit;True;Property;_Layer3_HRA;Layer3_HRA;12;0;Create;True;0;0;0;False;0;False;-1;None;b2c98b5bc31bb6a49901fb7eb2032853;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;95;-5671.52,-750.5269;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;64;-4822.474,1306.872;Inherit;False;Layer2_Height;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;65;-4810.088,446.1662;Inherit;False;Layer1_Height;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;80;-4824.675,2178.673;Inherit;False;Layer3_Height;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;164;-5475.26,-696.6713;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;162;-5442.886,-492.3147;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;158;-5410.023,-654.1188;Inherit;False;64;Layer2_Height;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;159;-5409.209,-557.3553;Inherit;False;80;Layer3_Height;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;156;-5411.208,-758.606;Inherit;False;65;Layer1_Height;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;163;-5459.073,-605.6212;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;161;-5141.878,-549.4606;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;157;-5131.744,-754.8828;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;160;-5139.313,-648.9205;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;165;-4986.425,-364.201;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;98;-4914.975,-434.2975;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;101;-4983.815,-297.4148;Inherit;False;Property;_BlendContrast;BlendContrast;0;0;Create;True;0;0;0;False;0;False;0.1;0.486;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;99;-4744.953,-418.6977;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;107;-4681.83,-293.3883;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;100;-4592.86,-417.8595;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;104;-4348.979,-646.0981;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;102;-4348.607,-737.9505;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;105;-4352.017,-555.2544;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;111;-4202.265,-642.5286;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;110;-4201.265,-546.5286;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;109;-4206.265,-741.5289;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;114;-4015.44,-753.0927;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;116;-4009.518,-546.8005;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;115;-3844.515,-632.8003;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;117;-3601.186,-622.1492;Inherit;False;BlendWeight;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;43;-2861.238,-168.2363;Inherit;False;1162.57;517.0775;RougnessBlend;10;143;142;46;72;45;141;139;138;140;48;RougnessBlend;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;82;-4821.562,2276.719;Inherit;False;Layer3Roughness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;41;-2850.182,-674.9202;Inherit;False;1165.744;458.0717;BaseColorBlend;10;70;120;40;126;123;125;124;37;36;122;BaseColorBlend;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;81;-5241.229,2443.03;Inherit;True;Property;_Layer3_Normal;Layer3_Normal;11;0;Create;True;0;0;0;False;0;False;-1;None;97781186bbadd694391d096f9436080f;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-4822.377,535.8182;Inherit;False;Layer1Roughness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-5228.914,270.4652;Inherit;True;Property;_Layer1_BaseColor;Layer1_BaseColor;1;0;Create;True;0;0;0;False;0;False;-1;None;980b695f963d7c8459bb68f1629ab8f0;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;30;-5239.028,1574.229;Inherit;True;Property;_Layer2_Normal;Layer2_Normal;7;0;Create;True;0;0;0;False;0;False;-1;None;253534c7b8d97e443b9284c6a6c81f12;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;7;-5228.046,700.1298;Inherit;True;Property;_Layer1_Normal;Layer1_Normal;3;0;Create;True;0;0;0;False;0;False;-1;None;a58342221a5c83946bdc3dd452ad121e;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;143;-2811.165,175.2207;Inherit;False;117;BlendWeight;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;83;-5242.098,2013.367;Inherit;True;Property;_Layer3_BaseColor;Layer3_BaseColor;9;0;Create;True;0;0;0;False;0;False;-1;None;cfee46c3d6826c14f82768194180b065;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;29;-5239.896,1144.564;Inherit;True;Property;_Layer2_BaseColor;Layer2_BaseColor;5;0;Create;True;0;0;0;False;0;False;-1;None;defb24939e3c9704c87bd05036142653;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;49;-2864.918,421.817;Inherit;False;1166.598;480.8574;NormalBlend;10;144;54;149;148;147;146;145;73;51;53;NormalBlend;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;31;-4833.359,1409.917;Inherit;False;Layer2Roughness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;56;-2857.631,975.9794;Inherit;False;1162.414;500.912;AOBlend;10;61;155;154;153;152;151;150;74;57;59;AOBlend;1,1,1,1;0;0
Node;AmplifyShaderEditor.BreakToComponentsNode;142;-2622.241,180.006;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RegisterLocalVarNode;33;-4832.25,1617.977;Inherit;False;Layer2Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;84;-4810.452,2490.778;Inherit;False;Layer3Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;150;-2823.723,1308.081;Inherit;False;117;BlendWeight;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;70;-2827.61,-375.0461;Inherit;False;117;BlendWeight;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;15;-4821.269,743.8776;Inherit;False;Layer1Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;34;-4827.76,1501.19;Inherit;False;Layer2AO;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;-4822.77,1174.937;Inherit;False;Layer2BaseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;72;-2816.63,88.64738;Inherit;False;82;Layer3Roughness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;13;-4811.787,300.8374;Inherit;False;Layer1BaseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;85;-4824.972,2043.738;Inherit;False;Layer3BaseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;86;-4819.961,2367.992;Inherit;False;Layer3AO;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;144;-2851.06,745.5717;Inherit;False;117;BlendWeight;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;45;-2814.238,-3.235891;Inherit;False;31;Layer2Roughness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;48;-2811.238,-118.2363;Inherit;False;16;Layer1Roughness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;17;-4816.777,627.0912;Inherit;False;Layer1AO;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;145;-2662.136,754.4302;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;59;-2807.631,1025.98;Inherit;False;17;Layer1AO;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;51;-2817.918,541.8175;Inherit;False;33;Layer2Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;37;-2825.678,-539.039;Inherit;False;32;Layer2BaseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;140;-2454.202,-101.7577;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;120;-2634.95,-367.1787;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;139;-2457.202,74.24234;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;122;-2827.696,-453.7123;Inherit;False;85;Layer3BaseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;74;-2811.264,1183.259;Inherit;False;86;Layer3AO;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;138;-2455.202,-12.75777;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;151;-2634.799,1312.866;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;57;-2810.631,1103.719;Inherit;False;34;Layer2AO;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;73;-2819.26,619.9407;Inherit;False;84;Layer3Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;53;-2814.918,461.8171;Inherit;False;15;Layer1Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;36;-2825.678,-623.9202;Inherit;False;13;Layer1BaseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;123;-2431.551,-620.5261;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;148;-2494.097,472.6664;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;125;-2434.551,-444.5261;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;154;-2466.76,1031.102;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;153;-2467.76,1120.102;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;124;-2432.551,-531.5261;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;141;-2209.386,18.2849;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;152;-2469.76,1207.102;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;147;-2495.097,561.6665;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;146;-2497.097,648.6666;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;126;-2186.735,-500.4835;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;149;-2249.281,592.7092;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;46;-1976.267,28.97871;Inherit;False;Rougness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;155;-2245.8,1103.434;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;61;-2033.548,1111.387;Inherit;False;AO;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;40;-1965.607,-510.7188;Inherit;False;BaseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;-1985.238,583.9796;Inherit;False;Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;20;-824.2873,450.532;Inherit;False;46;Rougness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-578.5956,337.6934;Inherit;False;Constant;_Metallic;Metallic;3;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;19;-720.4153,247.4784;Inherit;False;54;Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;22;-736.6307,634.6638;Inherit;False;61;AO;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;18;-726.4153,171.4784;Inherit;False;40;BaseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;21;-622.9866,455.0068;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomStandardSurface;1;-338.9455,244.7719;Inherit;False;Metallic;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;104.7837,-2.831995;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;MaterialBlend;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;18;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;5;0;4;0
WireConnection;27;0;26;0
WireConnection;27;1;25;0
WireConnection;10;0;9;0
WireConnection;10;1;11;0
WireConnection;78;0;77;0
WireConnection;78;1;76;0
WireConnection;3;1;10;0
WireConnection;28;1;27;0
WireConnection;79;1;78;0
WireConnection;64;0;28;1
WireConnection;65;0;3;1
WireConnection;80;0;79;1
WireConnection;164;0;95;1
WireConnection;162;0;95;3
WireConnection;163;0;95;2
WireConnection;161;0;159;0
WireConnection;161;1;162;0
WireConnection;157;0;156;0
WireConnection;157;1;164;0
WireConnection;160;0;158;0
WireConnection;160;1;163;0
WireConnection;165;0;161;0
WireConnection;98;0;157;0
WireConnection;98;1;160;0
WireConnection;99;0;98;0
WireConnection;99;1;165;0
WireConnection;107;0;101;0
WireConnection;100;0;99;0
WireConnection;100;1;107;0
WireConnection;104;0;160;0
WireConnection;104;1;100;0
WireConnection;102;0;157;0
WireConnection;102;1;100;0
WireConnection;105;0;161;0
WireConnection;105;1;100;0
WireConnection;111;0;104;0
WireConnection;110;0;105;0
WireConnection;109;0;102;0
WireConnection;114;0;109;0
WireConnection;114;1;111;0
WireConnection;114;2;110;0
WireConnection;116;0;109;0
WireConnection;116;1;111;0
WireConnection;116;2;110;0
WireConnection;115;0;114;0
WireConnection;115;1;116;0
WireConnection;117;0;115;0
WireConnection;82;0;79;2
WireConnection;81;1;78;0
WireConnection;16;0;3;2
WireConnection;2;1;10;0
WireConnection;30;1;27;0
WireConnection;7;1;10;0
WireConnection;83;1;78;0
WireConnection;29;1;27;0
WireConnection;31;0;28;2
WireConnection;142;0;143;0
WireConnection;33;0;30;0
WireConnection;84;0;81;0
WireConnection;15;0;7;0
WireConnection;34;0;28;3
WireConnection;32;0;29;0
WireConnection;13;0;2;0
WireConnection;85;0;83;0
WireConnection;86;0;79;3
WireConnection;17;0;3;3
WireConnection;145;0;144;0
WireConnection;140;0;48;0
WireConnection;140;1;142;0
WireConnection;120;0;70;0
WireConnection;139;0;72;0
WireConnection;139;1;142;2
WireConnection;138;0;45;0
WireConnection;138;1;142;1
WireConnection;151;0;150;0
WireConnection;123;0;36;0
WireConnection;123;1;120;0
WireConnection;148;0;53;0
WireConnection;148;1;145;0
WireConnection;125;0;122;0
WireConnection;125;1;120;2
WireConnection;154;0;59;0
WireConnection;154;1;151;0
WireConnection;153;0;57;0
WireConnection;153;1;151;1
WireConnection;124;0;37;0
WireConnection;124;1;120;1
WireConnection;141;0;140;0
WireConnection;141;1;138;0
WireConnection;141;2;139;0
WireConnection;152;0;74;0
WireConnection;152;1;151;2
WireConnection;147;0;51;0
WireConnection;147;1;145;1
WireConnection;146;0;73;0
WireConnection;146;1;145;2
WireConnection;126;0;123;0
WireConnection;126;1;124;0
WireConnection;126;2;125;0
WireConnection;149;0;148;0
WireConnection;149;1;147;0
WireConnection;149;2;146;0
WireConnection;46;0;141;0
WireConnection;155;0;154;0
WireConnection;155;1;153;0
WireConnection;155;2;152;0
WireConnection;61;0;155;0
WireConnection;40;0;126;0
WireConnection;54;0;149;0
WireConnection;21;0;20;0
WireConnection;1;0;18;0
WireConnection;1;1;19;0
WireConnection;1;3;23;0
WireConnection;1;4;21;0
WireConnection;1;5;22;0
WireConnection;0;13;1;0
ASEEND*/
//CHKSM=22D162740A61B970729807F3A7034034B2CA5861