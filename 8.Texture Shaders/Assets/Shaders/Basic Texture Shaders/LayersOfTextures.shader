Shader "Unlit/LayersOfTexture"
{
	Properties
	{
		_DecalTex("Daytime Earth", 2D) = "white" {}
		_MainTex("Nighttime Earth", 2D) = "white" {}
		_Color("Nighttime Color Filter", Color) = (1,1,1,1)
		
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
			#include "Lighting.cginc"


			sampler2D _MainTex;
			sampler2D _DecalTex;
			float4 _Color;

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal: NORMAL;
            };

            struct Interpolators
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				float levelOfLighting : TEXCOORD1;
            };


			Interpolators vert (MeshData v)
            {
				Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;

				float3 normalDirection = UnityObjectToWorldNormal(v.normal);
				float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);

				o.levelOfLighting =
					max(0.0, dot(normalDirection, lightDirection));

                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
				float4 nighttimeColor =
					tex2D(_MainTex, i.uv.xy) * _Color;
				float4 daytimeColor =
					tex2D(_DecalTex, i.uv.xy) * _LightColor0;
				return lerp(nighttimeColor, daytimeColor,
					i.levelOfLighting);
				// = daytimeColor * levelOfLighting 
				// + nighttimeColor * (1.0 - levelOfLighting)
            }
            ENDCG
        }
    }
}
