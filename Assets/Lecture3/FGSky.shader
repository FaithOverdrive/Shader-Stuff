Shader "Unlit/FGSky" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float3 uv : TEXCOORD0;
            };

            struct v2f {
                float3 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            #define PI = 3.14159265359

            float2 DirectionToRectilinear (float3 direction) {
                float x = atan2(direction.z, direction. x) / 3.14159265359 * 0.5 + 0.5; //-pi to pi -> -1 to 1 -> -0.5 to 0.5 -> 0 to 1
                float y = direction.y * 0.5 + 0.5;
                return float2(x, y);
            }

            v2f vert (appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                float2 rectCoords = DirectionToRectilinear(i.uv);
                return tex2Dlod(_MainTex, float4(rectCoords,0,0));
                
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
