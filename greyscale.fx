//Greyscale rendering shader, created by George Kristiansen 

//////////////////// 
//Global variables// 
//////////////////// 

float4x4 World; 
float4x4 WorldViewProjection; 
float LightPower; 
float LightAmbient; 
float3 LightDir; 
Texture xTexture; 

////////////////// 
//Sampler states// 
////////////////// 
sampler TextureSampler = sampler_state 
{ 
    texture = ; 
    magfilter = LINEAR; 
    minfilter = LINEAR; 
    mipfilter = LINEAR; 
    AddressU = Wrap; 
    AddressV = Wrap; 
}; 

////////////////// 
//I/O structures// 
////////////////// 

struct PixelColourOut { float4 Colour : COLOR0; }; 
struct SceneVertexToPixel { 
    float4 Position : POSITION; 
    float2 TexCoords : TEXCOORD0; 
    float3 Normal : TEXCOORD1; 
    float4 Position3D : TEXCOORD2; 
}; 

/////////////////////////////////////////////////////////////////////// 
//TECHNIQUE 1: Shaders for drawing an object using greyscale lighting// 
/////////////////////////////////////////////////////////////////////// 

SceneVertexToPixel GreyscaleVertexShader(float4 inPos : POSITION, float2 inTexCoords : TEXCOORD0, float3 inNormal : NORMAL) 
{
    SceneVertexToPixel Output = (SceneVertexToPixel)0; 
    Output.Position = mul(inPos, WorldViewProjection); 
    Output.Normal = normalize(mul(inNormal, (float3x3)World)); 
    Output.Position3D = mul(inPos, World); 
    Output.TexCoords = inTexCoords; return Output; 
} 

PixelColourOut GreyscalePixelShader(SceneVertexToPixel PSIn) 
{ 
    PixelColourOut Output = (PixelColourOut)0; 
    float4 baseColour = tex2D(TextureSampler, PSIn.TexCoords); 
    float diffuseLightingFactor = saturate(dot(-normalize(LightDir), PSIn.Normal))*LightPower; float4 trueColour = baseColour*(diffuseLightingFactor + LightAmbient); 
    float greyscaleAverage = (trueColour.r + trueColour.g + trueColour.b)/3.0f; 
    Output.Colour = float4(greyscaleAverage, greyscaleAverage, greyscaleAverage, trueColour.a); 
    return Output; 
} 

technique GreyscaleObject 
{ 
    pass pass0 { 
        VertexShader = compile vs_2_0 GreyscaleVertexShader(); 
        PixelShader = compile ps_2_0 GreyscalePixelShader(); 
    } 
} 