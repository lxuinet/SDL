Texture2D theTextureY : register(t0);
Texture2D theTextureU : register(t1);
Texture2D theTextureV : register(t2);
SamplerState theSampler : register(s0);

struct PixelShaderInput
{
    float4 pos : SV_POSITION;
    float2 tex : TEXCOORD0;
    float4 color : COLOR0;
};

cbuffer Constants : register(b1)
{
    float4 Yoffset;
    float4 Rcoeff;
    float4 Gcoeff;
    float4 Bcoeff;
};


#define YUVRS \
    "RootFlags ( ALLOW_INPUT_ASSEMBLER_INPUT_LAYOUT |" \
    "            DENY_DOMAIN_SHADER_ROOT_ACCESS |" \
    "            DENY_GEOMETRY_SHADER_ROOT_ACCESS |" \
    "            DENY_HULL_SHADER_ROOT_ACCESS )," \
    "RootConstants(num32BitConstants=16, b1),"\
    "DescriptorTable ( SRV(t0), visibility = SHADER_VISIBILITY_PIXEL ),"\
    "DescriptorTable ( SRV(t1), visibility = SHADER_VISIBILITY_PIXEL ),"\
    "DescriptorTable ( SRV(t2), visibility = SHADER_VISIBILITY_PIXEL ),"\
    "DescriptorTable ( Sampler(s0), visibility = SHADER_VISIBILITY_PIXEL )"

[RootSignature(YUVRS)]
float4 main(PixelShaderInput input) : SV_TARGET
{
    const float3 offset = {0.0, -0.501960814, -0.501960814};
    const float3 Rcoeff = {1.0000,  0.0000,  1.4020};
    const float3 Gcoeff = {1.0000, -0.3441, -0.7141};
    const float3 Bcoeff = {1.0000,  1.7720,  0.0000};

    float4 Output;

    float3 yuv;
    yuv.x = theTextureY.Sample(theSampler, input.tex).r;
    yuv.y = theTextureU.Sample(theSampler, input.tex).r;
    yuv.z = theTextureV.Sample(theSampler, input.tex).r;

    yuv += Yoffset.xyz;
    Output.r = dot(yuv, Rcoeff.xyz);
    Output.g = dot(yuv, Gcoeff.xyz);
    Output.b = dot(yuv, Bcoeff.xyz);
    Output.a = 1.0f;

    return Output * input.color;
}
