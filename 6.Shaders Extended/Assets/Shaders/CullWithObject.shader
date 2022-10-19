Shader "Unlit/CullWithObject"
{

	SubShader
	{
		Tags{ "RenderType" = "Opaque" }

		Pass
		{

			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			float4x4 CullerShape;


			struct MeshData
			{
				float4 vertex : POSITION;
				
			};

			struct Interpolators
			{
				float4 vertex : SV_POSITION;
				float4 worldpos : TEXCOORD0;
				float4 localpos : TEXCOORD1;
				float4 cullerpos : TEXCOORD2;

			};


			Interpolators vert(MeshData v)
			{
				Interpolators o;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.localpos = v.vertex;
				o.worldpos = mul(unity_ObjectToWorld, v.vertex);
				o.cullerpos = mul(CullerShape, o.worldpos);

				return o;
			}

			float4 frag(Interpolators i) : SV_Target
			{

				if (dot(i.cullerpos.xyz,i.cullerpos.xyz) < 0.25)
				{
					discard;
				}

				/*if (length(i.cullerpos.xyz) < 0.5)
				{
					discard;
				}*/

				/*float maskDiscard = i.posObjCoords.y < 0.0;

				clip(maskDiscard - 0.000001);*/

				return float4(1,0,0,1);

				
			}
			ENDCG
		}
	}
}
