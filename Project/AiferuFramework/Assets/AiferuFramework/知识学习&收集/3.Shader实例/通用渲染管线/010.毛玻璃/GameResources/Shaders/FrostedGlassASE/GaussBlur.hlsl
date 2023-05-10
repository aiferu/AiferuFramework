#ifndef GAUSSIAN_BLUR_INCLUDE
#define GAUSSIAN_BLUR_INCLUDE

#define MAX_PARAMS_LENGHT 4

// 0.25, 0.5, 0.25
static const float gaussianCoreParams3[MAX_PARAMS_LENGHT] = {0.5, 0.25, 0, 0};
static const int gaussianCoreParams3_Length = 2;

// 0.06542056, 0.2429907, 0.3831776, 0.2429907, 0.06542056
static const float gaussianCoreParams5[MAX_PARAMS_LENGHT] = {0.3831776, 0.2429907, 0.06542056, 0};
static const int gaussianCoreParams5_Length = 3;

// 0.004987531, 0.054862843, 0.241895262, 0.396508728, 0.241895262, 0.054862843, 0.004987531
static const float gaussianCoreParams7[MAX_PARAMS_LENGHT] = {0.396508728, 0.241895262, 0.054862843, 0.004987531};
static const int gaussianCoreParams7_Length = 4;

float4 GaussianSampleLine_Common(sampler2D tex, float2 uv, float2 uv_delta,
    const float params[MAX_PARAMS_LENGHT], const int params_length)
{
    float4 result = (float4)0;
    result += tex2D(tex, uv) * params[0];
    UNITY_UNROLL
    for (int i=1; i<params_length; i++)
    {
        result += tex2D(tex, uv + uv_delta*i) * params[i];
        result += tex2D(tex, uv - uv_delta*i) * params[i];
    }
    return result;
}

float4 GaussianBlur_Common(sampler2D tex, float2 uv, float2 uv_delta,
    const float params[MAX_PARAMS_LENGHT], const int params_length)
{
    float4 result = (float4)0;
    float2 delta_U = float2(uv_delta.x, 0);
    float2 delta_V = float2(0, uv_delta.y);
    result += GaussianSampleLine_Common(tex, uv, delta_U, params, params_length) * params[0];
    UNITY_UNROLL
    for (int i=1; i<params_length; i++)
    {
        result += GaussianSampleLine_Common(tex, uv + delta_V*i, delta_U, params, params_length) * params[i];
        result += GaussianSampleLine_Common(tex, uv - delta_V*i, delta_U, params, params_length) * params[i];
    }
    return result;
}

float4 GaussianSampleLine_3(sampler2D tex, float2 uv, float2 uv_delta)
{
    return GaussianSampleLine_Common(tex, uv, uv_delta, gaussianCoreParams3, gaussianCoreParams3_Length);
}

float4 GaussianBlur_3x3(sampler2D tex, float2 uv, float2 uv_delta)
{
    return GaussianBlur_Common(tex, uv, uv_delta, gaussianCoreParams3, gaussianCoreParams3_Length);
}

float4 GaussianSampleLine_5(sampler2D tex, float2 uv, float2 uv_delta)
{
    return GaussianSampleLine_Common(tex, uv, uv_delta, gaussianCoreParams5, gaussianCoreParams5_Length);
}

float4 GaussianBlur_5x5(sampler2D tex, float2 uv, float2 uv_delta)
{
    return GaussianBlur_Common(tex, uv, uv_delta, gaussianCoreParams5, gaussianCoreParams5_Length);
}

float4 GaussianSampleLine_7(sampler2D tex, float2 uv, float2 uv_delta)
{
    return GaussianSampleLine_Common(tex, uv, uv_delta, gaussianCoreParams7, gaussianCoreParams7_Length);
}

float4 GaussianBlur_7x7(sampler2D tex, float2 uv, float2 uv_delta)
{
    return GaussianBlur_Common(tex, uv, uv_delta, gaussianCoreParams7, gaussianCoreParams7_Length);
}


#endif