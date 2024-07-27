// Greyscale.fx
#include "ReShade.fxh"

// Define the grayscale shader technique
texture2D tex : register(t0);

sampler s0 : register(s0);

float3x3 LuminanceWeights = float3x3(0.299, 0.587, 0.114, 
                                     0.299, 0.587, 0.114, 
                                     0.299, 0.587, 0.114);

float4 GrayscalePass(float4 color : SV_Target) : SV_Target
{
    float3 grayscale = mul(color.rgb, LuminanceWeights);
    return float4(grayscale, color.a);
}

technique Grayscale
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = GrayscalePass;
    }
}
