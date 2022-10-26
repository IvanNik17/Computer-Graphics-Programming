Shader "Unlit/PhongCombined"
{
	Properties
	{
		_Color("Diffuse Material Color", Color) = (1,1,1,1)
		_SpecC("Specular Material Color", Color) = (1,1,1,1)
		_Shininess("Shininess", Float) = 10

	}
	SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		
		Pass
		{
			Tags{ "LightMode" = "ForwardBase" }
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


			float4 _Color;
			float4 _SpecC;
			float _Shininess;

			Interpolators vert(MeshData v)
			{
				Interpolators o;
				o.vertex = UnityObjectToClipPos(v.vertex);


				float3 ambientLighting =
					UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;



				float3 normalDirection = normalize(UnityObjectToWorldNormal(v.normal));
				/*float3 normalDirection = normalize(mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);*/

				float3 lightDirection;
				float attenuation;
				if (0.0 == _WorldSpaceLightPos0.w) { //directional Light

					lightDirection = normalize(_WorldSpaceLightPos0.xyz); //this we get from the Lighting.cginc
					attenuation = 1;
				}
				else {
					float3 vertexToLightSource = _WorldSpaceLightPos0.xyz - mul(unity_ObjectToWorld, v.vertex).xyz;
					float distance = length(vertexToLightSource);
					attenuation = 1.0 / distance; // linear attenuation 

					lightDirection = normalize(vertexToLightSource);
				}



				float3 diffuseReflection = attenuation * _LightColor0.rgb * _Color.rgb //this we get from the Lighting.cginc
					* max(0.0, dot(normalDirection, lightDirection));


				/*Specular Part*/

				float3 viewDirection = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, v.vertex).xyz);

				float3 reflectedLightDirection = reflect(-lightDirection, normalDirection); //because we need the inverse light direction for the reflection

				float3 specularReflection;


				if (dot(normalDirection, lightDirection) < 0.0) {

					specularReflection = float3(0.0, 0.0, 0.0);
				}
				else {

					specularReflection = attenuation * _LightColor0.rgb * _SpecC * pow(max(0.0, dot(reflectedLightDirection, viewDirection)), _Shininess);
				}


				o.col = float4(diffuseReflection
					+ specularReflection, 1.0);


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


		Pass
			{
				Tags{ "LightMode" = "ForwardAdd" }
				// pass for additional light sources
				Blend One One // additive blending 
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


				float4 _Color;
				uniform float4 _SpecC;
				float _Shininess;

				Interpolators vert(MeshData v)
				{
					Interpolators o;
					o.vertex = UnityObjectToClipPos(v.vertex);


					float3 ambientLighting =
						UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;


					float3 normalDirection = UnityObjectToWorldNormal(v.normal);
					/*float3 normalDirection = normalize(mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);*/

					float3 lightDirection;
					float attenuation;
					if (0.0 == _WorldSpaceLightPos0.w) { //directional Light

						lightDirection = normalize(_WorldSpaceLightPos0.xyz); //this we get from the Lighting.cginc
						attenuation = 1;
					}
					else {
						float3 vertexToLightSource = _WorldSpaceLightPos0.xyz - mul(unity_ObjectToWorld, v.vertex).xyz;
						float distance = length(vertexToLightSource);
						attenuation = 1.0 / distance; // linear attenuation 

						lightDirection = normalize(vertexToLightSource);
					}



					float3 diffuseReflection = attenuation * _LightColor0.rgb * _Color.rgb //this we get from the Lighting.cginc
						* max(0.0, dot(normalDirection, lightDirection));

					
					float3 viewDirection = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, v.vertex).xyz);

					float3 reflectedLightDirection = reflect(-lightDirection, normalDirection); //because we need the inverse light direction for the reflection

					float3 specularReflection;

					if (dot(normalDirection, lightDirection) < 0.0) {

						specularReflection = float3(0.0, 0.0, 0.0);
					}
					else {

						specularReflection = attenuation * _LightColor0.rgb * _SpecC * pow(max(0.0, dot(reflectedLightDirection, viewDirection)), _Shininess);
					}


					o.col = float4(diffuseReflection + specularReflection, 1.0);


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
