Shader "Unlit/Shader1"{
    Properties {
        //variableName, DisplayName in unity inspector, type of property, default value
        _Color ("Color", Color) = (1, 1, 1, 1)
    }
    SubShader {
        Tags { "RenderType"="Opaque" }

        Pass {
            
            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag

            #include "UnityCG.cginc"
            
            float4 _Color;//Automatically gets the _Value defined in the properties

            //Automatically filled out by unity
            struct meshData { // per-vertex mesh data
                float4 vertex : POSITION; // vertex position
                float3 normals : NORMAL; // normal direction of vertex
                float4 tangent : TANGENT; // tangent direction
                float4 color : COLOR;
                float4 uv0 : TEXCOORD0; // uv0 coordinates - diffuse/normal map textures
                float4 uv1 : TEXCOORD1; // uv1 coordinates - lightmap coordinates
            };

            struct Interpolators { // Every data that we pass from vertex to fragment shader is inside this structure, v2f
                float4 vertex : SV_POSITION; // clip space position
                //float2 uv : TEXCOORD0; // any data you want it to be
                };

            Interpolators vert (meshData v) {
                Interpolators o; //o for output
                o.vertex = UnityObjectToClipPos(v.vertex); // converts local space to clip space (by multiplying by MVP(model view projection) matrix)
                return o;
            }

            
            // float (32 bit float)
            // half (16 bit float)
            // fixed (lower precision)
            
            // float4 -> half4 -> fixed4 (vectors)
            // float4x4 -> half4x4       (matrices)

            //int2
            //bool4

            float4 frag (Interpolators i) : SV_Target {
                return _Color;
            }
            ENDCG
        }
    }
}
