Shader "Unlit/DisplacementMapping"
{
    Properties
    {
		_MainTex("Main Texture", 2D) = "white" {}
		_DisplacementTex("Displacement Texture", 2D) = "white" {}
		_MaxDisplacement("Max Displacement", Float) = 1.0
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
			sampler2D _DisplacementTex;
			float _MaxDisplacement;

            struct MeshData
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
				float3 normal : NORMAL;
            };

            struct Interpolators
            {
				float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

			Interpolators vert (MeshData v)
            {
				Interpolators o;


				float4 dispTexColor = tex2Dlod(_DisplacementTex, float4(v.uv.xy, 0.0, 0.0));
				float displacement = dot(float3(0.21, 0.72, 0.07), dispTexColor.rgb) * _MaxDisplacement;

				// displace vertices along surface normal vector
				float4 newVertexPos = v.vertex + float4(v.normal * displacement, 0.0);

                o.vertex = UnityObjectToClipPos(newVertexPos);
				o.uv = v.uv;
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
				return tex2D(_MainTex, i.uv.xy);
            }
            ENDCG
        }
    }
		Fallback "Unlit/Texture"
}
