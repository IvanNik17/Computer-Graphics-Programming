Shader "Unlit/PhongCompact"
{
    Properties
    {
		_Color("Diffuse Material Color", Color) = (1,1,1,1)
		_SpecC("Specular Material Color", Color) = (1,1,1,1)
		_Shininess("Shininess", Float) = 10

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
			Tags{ "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

			#include "LightingInclude.cginc"
            
            ENDCG
        }

		Pass
		{
			Tags{ "LightMode" = "ForwardAdd" }
			Blend One One // additive blending 
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "LightingInclude.cginc"

			ENDCG
		}
    }
}
