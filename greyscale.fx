#include "ReShade.fxh"

float curve( float x, float k )
{
float s = sign( x - 0.5f );
float o = ( 1.0f + s ) / 2.0f;
return o - 0.5f * s * pow( max( 2.0f * ( o - s * x ), 0.0f ), k );
}

float3 makeBW( float3 col, float r, float y, float g, float c, float b, float m )
{
float3 hsl         = RGBToHSL( col.xyz );
// Inverse of luma channel to no apply boosts to intensity on already intense brightness (and blow out easily)
float lum          = 1.0f - hsl.z;

// Calculate the individual weights per color component in RGB and CMY
// Sum of all the weights for a given hue is 1.0
float weight_r     = curve( max( 1.0f - abs(  hsl.x               * 6.0f ), 0.0f ), curve_str ) +
                     curve( max( 1.0f - abs(( hsl.x - 1.0f      ) * 6.0f ), 0.0f ), curve_str );
float weight_y     = curve( max( 1.0f - abs(( hsl.x - 0.166667f ) * 6.0f ), 0.0f ), curve_str );
float weight_g     = curve( max( 1.0f - abs(( hsl.x - 0.333333f ) * 6.0f ), 0.0f ), curve_str );
float weight_c     = curve( max( 1.0f - abs(( hsl.x - 0.5f      ) * 6.0f ), 0.0f ), curve_str );
float weight_b     = curve( max( 1.0f - abs(( hsl.x - 0.666667f ) * 6.0f ), 0.0f ), curve_str );
float weight_m     = curve( max( 1.0f - abs(( hsl.x - 0.833333f ) * 6.0f ), 0.0f ), curve_str );

// No saturation (greyscale) should not influence B&W image
float sat          = hsl.y * ( 1.0f - hsl.y ) + hsl.y;
float ret          = hsl.z;
ret                += ( hsl.z * ( weight_r * r ) * sat * lum );
ret                += ( hsl.z * ( weight_y * y ) * sat * lum );
ret                += ( hsl.z * ( weight_g * g ) * sat * lum );
ret                += ( hsl.z * ( weight_c * c ) * sat * lum );
ret                += ( hsl.z * ( weight_b * b ) * sat * lum );
ret                += ( hsl.z * ( weight_m * m ) * sat * lum );

return saturate( ret );
}

float4 blackwhite(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
float4 color      = tex2D( ReShade::BackBuffer, texcoord );
color.xyz         = saturate( color.xyz );

// Do the Black & White
color.xyz         = makeBW( color.xyz, red, yellow, green, cyan, blue, magenta );

if( show_clip )
{
    float h       = 0.98f;
    float l       = 0.01f;
    color.xyz     = min( min( color.x, color.y ), color.z ) >= h ? lerp( color.xyz, float3( 1.0f, 0.0f, 0.0f ), smoothstep( h, 1.0f, min( min( color.x, color.y ), color.z ))) : color.xyz;
    color.xyz     = max( max( color.x, color.y ), color.z ) <= l ? lerp( float3( 0.0f, 0.0f, 1.0f ), color.xyz, smoothstep( 0.0f, l, max( max( color.x, color.y ), color.z ))) : color.xyz;
}
color.xyz         = saturate( color.xyz + dnoise.xyz );
return float4( color.xyz, 1.0f );
}