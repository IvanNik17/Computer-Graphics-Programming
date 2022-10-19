Shader "Unlit/SilhouetteEnhance"
{
	Properties
	{
		_AdditionalEnhance("Additional Enhance", float) = 1
		_Color("Color", Color) = (1, 1, 1, 0.5)
	}
		SubShader
	{
		Tags{ "RenderType" = "Transparent" }
		Tags{ "Queue" = "Transparent" }

		Pass
		{
			ZWrite Off // don't occlude other objects
			Blend SrcAlpha OneMinusSrcAlpha // standard alpha blending

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"


			float _AdditionalEnhance;
			float4 _Color;

			struct MeshData
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct Interpolators
			{
				float3 normal : TEXCOORD0;
				float3 viewDir : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};


			Interpolators vert(MeshData v)
			{
				Interpolators o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				float4x4 modelMatrix = unity_ObjectToWorld;
				float4x4 modelMatrixInverse = unity_WorldToObject;

				o.normal = normalize(
					mul(float4(v.normal, 0.0), modelMatrixInverse).xyz);

				/*o.normal = normalize(
					mul(modelMatrix, float4(v.normal, 0.0)).xyz);*/
				o.viewDir = normalize(_WorldSpaceCameraPos
					- mul(modelMatrix, v.vertex).xyz);
	
				return o;

			}

			float4 frag(Interpolators i) : SV_Target
			{
				float3 normalDirection = normalize(i.normal);
				float3 viewDirection = normalize(i.viewDir);

				float4 dotProduct = abs(dot(viewDirection, normalDirection));

				float4 dotProductSquared = pow(dotProduct, _AdditionalEnhance);

				float newOpacity = min(1.0, _Color.a
						/ dotProductSquared);
				return float4(_Color.rgb, newOpacity);
			}
			ENDCG
		}
	}
}
