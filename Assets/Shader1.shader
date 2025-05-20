Shader "Unlit/Shader1"{
    Properties {
        //variableName, DisplayName in unity inspector, type of property, default value
        _ColorA ("Color A", Color) = (1, 1, 1, 1)
        _ColorB ("Color B", Color) = (1, 1, 1, 1)
        _ColorStart ("Color Start", Range(0, 1)) = 0
        _ColorEnd ("Color End", Range(0, 1)) = 1
    }
    SubShader {
        Tags {
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }
        Pass {
            
            ZWrite Off
            Cull Off
            //ZTest Always
            Blend One One
            
            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define TAU 6.28318530718
            
            float4 _ColorA;//Automatically gets the _Value defined in the properties
            float4 _ColorB;
            float _ColorStart;
            float _ColorEnd;

            //Automatically filled out by unity
            struct meshData { // per-vertex mesh data
                float4 vertex : POSITION; // vertex position
                float3 normal : NORMAL; // normal direction of vertex
                float4 tangent : TANGENT; // tangent direction
                float4 color : COLOR;
                float4 uv0 : TEXCOORD0; // uv0 coordinates - diffuse/normal map textures
                float4 uv1 : TEXCOORD1; // uv1 coordinates - lightmap coordinates
            };

            struct Interpolators { // Every data that we pass from vertex to fragment shader is inside this structure, v2f
                float4 vertex : SV_POSITION; // clip space position
                float3 normal : TEXCOORD0;
                float2 uv : TEXCOORD1;
                //float2 uv : TEXCOORD0; // any data you want it to be
                };

            Interpolators vert (meshData v) {
                Interpolators o; //o for output
                o.vertex = UnityObjectToClipPos(v.vertex); // converts local space to clip space (by multiplying by MVP(model view projection) matrix)
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv = v.uv0; //(v.uv0 + _Offset) * _Scale;
                return o;
            }

            float InverseLerp(float _ColorStart, float _ColorEnd, float t)
            {
                return saturate((t-_ColorStart)/(_ColorEnd-_ColorStart));
            }
            
            float4 frag (Interpolators i) : SV_Target {
                float xoffSet = cos(i.uv.x * TAU * 8) * 0.01;
                //return i.uv.y;
                
                float t = i.uv.y + xoffSet - _Time.y*0.1;
                t = cos(TAU * t * 5);
                t *= 1-i.uv.y;

                if (abs(i.normal.y) > 0.99)
                {
                    return 0;
                }
                return t;
            }
            ENDCG
        }
    }
}
