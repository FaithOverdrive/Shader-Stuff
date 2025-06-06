Shader "Unlit/MultiLighting"{
    Properties {
        //_MainTex ("Texture", 2D) = "white" {}
        _Gloss ("Gloss", Range(0,1)) = 1
        _ObjectColor ("ObjectColor", Color) = (1,1,1,1)
        _RockAlbedo ("Rock Albedo", 2D) = "white" {}
        _RockNormals ("Rock Normals", 2D) = "bump" {}
        _RockNormalsScale ("Rock Normals Scale", Range(0, 1)) = 1
        _RockHeight ("Rock Height", 2D) = "white" {}
        _RockHeightScale ("Rock Height Scale", Range(0, 0.2)) = 0
        _AmbientLight ("Ambient Light", Color) = (0,0,0,0)
        _DiffuseIBLTexture ("Diffuse IBL Texture", 2D) = "black" {}
        _SpecularIBLTexture ("Specular IBL Texture", 2D) = "black" {}
        _SpecularIBLIntensity ("Specular IBL Intensity", Range(0,1)) = 0
    }
    
    SubShader {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }

        // Base pass
        Pass {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define IS_IN_BASE_PASS
            #include "FGLighting.cginc"
            ENDCG
        }
        
        // Add pass
        Pass {
            Tags { "LightMode" = "ForwardAdd" }
            Blend One One // src*1 + dst*1
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd
            #include "FGLighting.cginc"
            ENDCG
        }
    }
}
