Shader "Unlit/TextureTransparent"
{
	Properties
	{
		_MainTex("Texture For Diffuse Material Color", 2D) = "white" {}
	}
		SubShader
	{
		Tags { "RenderType" = "Transparent" }
		Tags{ "Queue" = "Transparent" }

		Pass
		{
			Cull Front // draw front and back faces
			ZWrite Off // don't write to depth buffer 
					   // in order not to occlude other objects

			Blend SrcAlpha OneMinusSrcAlpha  // use alpha blending

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"


			sampler2D _MainTex;

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
				float4 textureColor = tex2D(_MainTex, i.uv.xy);

                return textureColor;
            }
            ENDCG
        }

		Pass
		{
			Cull Back // draw front and back faces
			ZWrite Off // don't write to depth buffer 
						// in order not to occlude other objects

			Blend SrcAlpha OneMinusSrcAlpha  // use alpha blending

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"


			sampler2D _MainTex;

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


			Interpolators vert(MeshData v)
			{
				Interpolators o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			float4 frag(Interpolators i) : SV_Target
			{
				// sample the texture
				float4 textureColor = tex2D(_MainTex, i.uv.xy);

				return textureColor;
			}
				ENDCG
		}
    }
}
