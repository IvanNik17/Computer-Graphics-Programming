Shader "Unlit/Basic Texture"
{
    Properties
    {
		_MainTex("Texture Image", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
			
			ZWrite On
			
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

		    sampler2D _MainTex;
			float4 _MainTex_ST;

            struct MeshData
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
            };

            struct Interpolators
            {
				float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0; // OR float4 uv if you dont use TRANSFORM_TEX();
            };

			Interpolators vert (MeshData v)
            {
				Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex); // used to ensure that the texture scale and offset are correct
				//o.uv = i.uv;
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
				return tex2D(_MainTex, i.uv.xy);
				/*return tex2D(_MainTex,
					_MainTex_ST.xy * i.uv.xy + _MainTex_ST.zw);*/

				/*return tex2D(_MainTex, TRANSFORM_TEX(input.tex, _MainTex));*/
            }
            ENDCG
        }
    }
		Fallback "Unlit/Texture"
}
