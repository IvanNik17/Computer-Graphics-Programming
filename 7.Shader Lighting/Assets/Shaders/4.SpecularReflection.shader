Shader "Unlit/SpecularReflection"
{
	Properties
	{
		
		_SpecC("Specular Material Color", Color) = (1,1,1,1)
		_Shininess("Shininess", Float) = 10

	}
	SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		Tags{ "LightMode" = "ForwardBase" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
					// make fog work
			#pragma multi_compile_fog

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			struct MeshData
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct Interpolators
			{
				float4 col : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};


			
			uniform float4 _SpecC;
			float _Shininess;

			Interpolators vert(MeshData v)
			{
				Interpolators o;

				o.vertex = UnityObjectToClipPos(v.vertex);

				float3 normalDirection = UnityObjectToWorldNormal(v.normal);
				/*float3 normalDirection = normalize(mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);*/
				float3 lightDirection = _WorldSpaceLightPos0.xyz; //this we get from the Lighting.cginc



				float3 viewDirection = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, v.vertex));

				float3 reflectedLightDirection = reflect(-lightDirection, normalDirection); //because we need the inverse light direction for the reflection

				float3 specularLight = max(0.0, dot(viewDirection, reflectedLightDirection));

				specularLight = pow(specularLight, _Shininess);

				float3 specularReflection;



				if (dot(normalDirection, lightDirection) < 0.0) {

					specularReflection = float3(0.0, 0.0, 0.0);
				}
				else {

					specularReflection = _LightColor0.rgb * _SpecC * specularLight;
				}

				

				o.col = float4(specularReflection, 1.0);

				return o;
			}

			float4 frag(Interpolators i) : SV_Target
			{


				return i.col;

			//float3 L = _WorldSpaceLightPos0.xyz;//light direction
			//return float4(L, 1);
			}
			ENDCG
		}
	}
}
