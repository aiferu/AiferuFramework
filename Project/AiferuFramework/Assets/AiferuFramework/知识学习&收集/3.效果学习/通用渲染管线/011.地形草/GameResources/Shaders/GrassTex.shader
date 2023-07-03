Shader "Aiferu/URP/GrassTex"
{
    Properties
    {
        _NoiseMap ("NoiseMap",2D) = "white"{}
        _UpColor("Up Color",Color)=(1,1,1,1)
        _DownColor("Down Color",Color)=(1,1,1,1)
        _BaseColorThresholed ("BaseColorthresholed" ,Range(0,1)) = 0.5
        _WaveSize("WaveSzie",vector) = (1,1,1,1)
        _WaveSpeed("WaveSpeed",vector) = (1,1,1,1)
        _SpecularPower("SpecularPower",float) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"//声明这是一个URP Shader！
            "Queue"="Geometry"
            "RenderType"="Opaque"
        }
        HLSLINCLUDE
        #pragma multi_compile_instancing

        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

        //Cbuffer
        CBUFFER_START(UnityPerMaterial)
        half4 _NoiseMap_ST;
        half4 _UpColor;
        half4 _DownColor;
        half _BaseColorThresholed;
        half4 _WaveSize;
        half4 _WaveSpeed;
        half _SpecularPower;
        CBUFFER_END

        ENDHLSL

        Pass
        {                                        //声明这个pass是一个渲染pass
            Tags{"LightMode"="UniversalForward"}//这个Pass最终会输出到颜色缓冲里//URP只支持一个pass通道输出渲染，其他pass只能进行计算

            HLSLPROGRAM //CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct Attributes//a2v
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID  //GPU Instancing
            };
            struct Varings//v2f
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float2 uv : TEXCOORD2;
                float3 waveColor : TEXCOORD3;
                float3 viewDirWS : TEXCOORD4;
                UNITY_VERTEX_INPUT_INSTANCE_ID //GPU Instancing
            };

            TEXTURE2D(_NoiseMap);
            SAMPLER(sampler_NoiseMap);


            Varings vert(Attributes IN)
            {
                //基础Shader部分
                Varings OUT;
                
                //GPU Instancing
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_TRANSFER_INSTANCE_ID(IN, OUT);

                VertexPositionInputs positionInputs = GetVertexPositionInputs(IN.positionOS.xyz);
                VertexNormalInputs normalInputs = GetVertexNormalInputs(IN.normalOS.xyz);
                half3 positionWS = positionInputs.positionWS;
                OUT.normalWS = normalInputs.normalWS;
                OUT.uv = IN.uv;

                //顶点偏移
                //使用_WaveSize来调整地图的大小 基于世界空间采样噪声图
                half2 sampleUV = half2(positionWS.x / _WaveSize.x,positionWS.z / _WaveSize.z);
                //_WaveSpeed控制噪声图的读取速度
                sampleUV.x += _Time.x * _WaveSpeed.x;
                sampleUV.y += _Time.x * _WaveSpeed.z;
                //采样噪声图
                half3 waveSample = SAMPLE_TEXTURE2D_LOD(_NoiseMap,sampler_NoiseMap, sampleUV,0).xyz;
                OUT.waveColor = waveSample;
                //根据噪声图的采样值来偏移顶点 
                positionWS.x += sin(waveSample*_WaveSpeed.x) * _WaveSize.x* IN.uv.y;
                positionWS.z += sin(waveSample*_WaveSpeed.z) * _WaveSize.z* IN.uv.y;
                OUT.positionWS = positionWS;
                OUT.positionCS = TransformWorldToHClip(positionWS);

                //BlinnPhong
                OUT.viewDirWS = GetCameraPositionWS() - OUT.positionWS;


                return OUT;
            }

            float4 frag(Varings IN):SV_Target
            {
                //GPU Instancing
                UNITY_SETUP_INSTANCE_ID(IN);
                half4 Maincolor = lerp(_DownColor,_UpColor,IN.uv.y+_BaseColorThresholed);

                //BlinnPhong
                Light light = GetMainLight();
                half3 viewDirWS = normalize(IN.viewDirWS);
                half3 halfDir = normalize(viewDirWS + normalize(light.direction));
                half3 specular = dot(normalize(IN.normalWS),halfDir);
                specular = lerp(0,specular,IN.uv.y);
                specular = pow(specular,_SpecularPower);
                // Maincolor.xyz+= specular;
                return  Maincolor;
                return half4(specular,1);
            }
            ENDHLSL        
        }
    }
}