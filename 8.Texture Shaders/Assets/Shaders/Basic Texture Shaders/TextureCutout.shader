Shader "Unlit/TextureCutout"
{
	Properties
	{
		_MainTex("Texture For Diffuse Material Color", 2D) = "white" {}
		_Cutoff("Alpha Cutoff", Range(0,1)) = 0.5
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }
		Pass
		{
			Cull Off // draw front and back faces

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"


			sampler2D _MainTex;
		float _Cutoff;

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

				/*if (textureColor.a < _Cutoff)
				{
					discard;
				}*/

				float maskDiscard = textureColor.a > _Cutoff;

				clip(maskDiscard - 0.000001);

                return textureColor;
            }
            ENDCG
        }
    }
}
