#include "UnityCG.cginc"
#include "AutoLight.cginc"
#include "UnityLightingCommon.cginc"

#define USE_LIGHTING
            
struct MeshData {
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
    float3 normal: NORMAL;
    float4 tangent: TANGENT;
};

struct Interpolators {
    float4 vertex : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 normal : TEXCOORD1;
    float3 tangent: TEXCOORD2;
    float3 bitangent: TEXCOORD3;
    float3 wPos : TEXCOORD4;
    LIGHTING_COORDS(5,6) //Macro for interpolated lighting data in channels TEXCOORD3 and 4
};

float _Gloss;
float4 _ObjectColor;

sampler2D _RockAlbedo;
float4 _RockAlbedo_ST;

sampler2D _RockNormals;
float _RockNormalsScale;

sampler2D _RockHeight;
float _RockHeightScale;

float4 _AmbientLight;

sampler2D _DiffuseIBLTexture;
sampler2D _SpecularIBLTexture;
float _SpecularIBLIntensity;

float2 DirectionToRectilinear (float3 direction) {
    float x = atan2(direction.z, direction.x) / 3.14159265359 * 0.5 + 0.5;
    float y = direction.y * 0.5 + 0.5;
    return float2(x, y);
}

Interpolators vert (MeshData v) {
    Interpolators o;
    o.uv = TRANSFORM_TEX(v.uv, _RockAlbedo);

    //rock height
    float height = tex2Dlod(_RockHeight, float4(o.uv, 0, 0)).x * 2 - 1;
    v.vertex.xyz += v.normal * height * _RockHeightScale;
    o.vertex = UnityObjectToClipPos(v.vertex);
    
    //rock normal
    o.normal = UnityObjectToWorldNormal(v.normal);
    o.tangent =  UnityObjectToWorldDir(v.tangent.xyz);
    o.bitangent = cross( o.normal, o.tangent ) * (v.tangent.w * unity_WorldTransformParams.w);
    
    o.wPos = mul(unity_ObjectToWorld, v.vertex);
    TRANSFER_VERTEX_TO_FRAGMENT(o); //Populating LIGHTING_COORDS interpolators with whatever the fragment shader needs to calculate the lighting //About Lighting Actually
    return o;
}

fixed4 frag (Interpolators i) : SV_Target {
    #ifdef USE_LIGHTING
        //Rock Texture
        float3 rock = tex2D(_RockAlbedo, i.uv).rgb;
        float3 surfaceColor = rock * _ObjectColor.rgb;

        //Rock Normals
        float3 tangentSpaceNormal = UnpackNormal(tex2D(_RockNormals, i.uv));
        float3x3 mtxTangentToWorld = {
            i.tangent.x, i.bitangent.x, i.normal.x,
            i.tangent.y, i.bitangent.y, i.normal.y,
            i.tangent.z, i.bitangent.z, i.normal.z,
        };
        float3 N = mul(mtxTangentToWorld, tangentSpaceNormal);
        N = lerp(N, i.normal, _RockNormalsScale);

        //Diffused Lighting
        float3 L = normalize( UnityWorldSpaceLightDir(i.wPos) ); //_WorldSpaceLightPos0.xyz additional light sources can be either a point vector or a direction vector depending on type of light source
        float attenuation = LIGHT_ATTENUATION(i); //Factor that applies how light intensity decreases over distnace from source
        float3 lambert = max(0,dot(N,L));
        float3 diffuseLight = lambert * _LightColor0.xyz * attenuation; //multiply by attenuation
    
        #ifdef IS_IN_BASE_PASS
            //Diffuse IBL
            float2 rectilinearCoords = DirectionToRectilinear(N);
            float3 IBLDiffuseLight = tex2Dlod(_DiffuseIBLTexture, float4(rectilinearCoords,0,0)).rgb;
            diffuseLight += IBLDiffuseLight;
        #endif

        //Specular Lighting (Blinn Phong method)
        float3 V = normalize(_WorldSpaceCameraPos - i.wPos);
        float3 H = normalize(L + V);
        float3 specularLight = max(0, dot(H, N)) * (lambert > 0);

        float specularExponent = exp2(_Gloss * 11) + 2;
        specularLight = pow(specularLight, specularExponent) * _Gloss;
        specularLight *= _LightColor0.xyz * attenuation; //multiply by attenuation

        #ifdef IS_IN_BASE_PASS
            //Specular IBL
            float fresnel = pow(1 - saturate(dot(V, N)),5);
    
            float3 ReflectedViewVector = reflect(-V, N);
            float2 RectilinearReflectedViewVector = DirectionToRectilinear(ReflectedViewVector);
            float mip = 6 - _Gloss * 6;
    
            float4 IBLSpecularLight = tex2Dlod(_SpecularIBLTexture, float4(RectilinearReflectedViewVector,mip,mip));
            specularLight += IBLSpecularLight * _SpecularIBLIntensity * fresnel;
        #endif
            
        return float4(diffuseLight * surfaceColor + specularLight, 1);
    #else
        #ifdef IS_IN_BASE_PASS
            return surfaceColor;
        #else
            return 0;
        #endif
    #endif
}