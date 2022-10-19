Shader "Unlit/TransparentExample"
{
	Properties
	{
		_Alpha("Alpha component", Range(0,1)) = 1
	}
		SubShader
	{
		Tags { "RenderType" = "Transparent" }
		Tags{ "Queue" = "Transparent" }

		Pass
		{
			Cull Off // draw front and back faces
			ZWrite Off // don't write to depth buffer 
					   // in order not to occlude other objects

			Blend Zero OneMinusSrcAlpha // use alpha blending

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"


			float _Alpha;

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };


			Interpolators vert (MeshData v)
            {
				Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                // sample the texture
				float4 col = float4(0,1,0, _Alpha);

                return col;
            }
            ENDCG
        }
    }
}
