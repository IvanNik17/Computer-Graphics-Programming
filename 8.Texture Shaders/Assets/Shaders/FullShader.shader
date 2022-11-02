Shader "Unlit/FullShader"
{
	Properties
	{
		_Color("Diffuse Material Color", Color) = (1,1,1,1)
		_SpecC("Specular Material Color", Color) = (1,1,1,1)
		_Shininess("Shininess", Float) = 10

		_NormalTex("Normal Texture", 2D) = "white" {}
		_DiffuseIBL("Diffuse Environment Map", 2D) = "black" {}

		_SpecularIBL("Specular Environment Map", 2D) = "black" {}

		_Gloss("How Glossy is the Specular", Range(0,1)) = 1
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
			#define TAU 6.28318530718  //or known as 2* PI

			struct MeshData
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal: NORMAL;
				float4 tangent : TANGENT;
			};

			struct Interpolators
			{
				float2 uv : TEXCOORD0;
				float4 wPos : TEXCOORD1;
				float3 normal : TEXCOORD2;
				float4 vertex : SV_POSITION;
				float4 posWorld : TEXCOORD3;
				float3 tangentWorld : TEXCOORD4;
				float3 normalWorld : TEXCOORD5;
				float3 binormalWorld : TEXCOORD6;

			};


			float4 _Color;
			float4 _SpecC;
			float _Shininess;
			sampler2D _NormalTex;
			float4 _NormalTex_ST;

			sampler2D  _DiffuseIBL;
		    sampler2D  _SpecularIBL;
			float _Gloss;


			float2 DirToRectilinear(float3 dir) {
				float x = atan2(dir.z, dir.x) / TAU + 0.5; //-tau/2 tau/2  -> -0.5 0.5 -> 0  1
				float y = dir.y * 0.5 + 0.5; //-0.5 0.5 -> 0 1

				return float2(x, y);
			}

			Interpolators vert(MeshData v)
			{
				Interpolators o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				o.normal = UnityObjectToWorldNormal(v.normal);

				o.wPos = mul(unity_ObjectToWorld, v.vertex);

				o.uv = v.uv;
				o.tangentWorld = normalize(
					mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz);
				o.normalWorld = normalize(
					mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
				o.binormalWorld = normalize(
					cross(o.normalWorld, o.tangentWorld)
					* v.tangent.w); // tangent.w is specific to Unity

				o.posWorld = mul(unity_ObjectToWorld, v.vertex);

				return o;
			}

			float4 frag(Interpolators i) : SV_Target
			{

				float4 encodedNormal = tex2D(_NormalTex,
				_NormalTex_ST.xy * i.uv.xy + _NormalTex_ST.zw);
				float3 localCoords = float3(2.0 * encodedNormal.a - 1.0,
					2.0 * encodedNormal.g - 1.0, 0.0);
				localCoords.z = sqrt(1.0 - dot(localCoords, localCoords));

				float3x3 local2WorldTranspose = float3x3(
					i.tangentWorld,
					i.binormalWorld,
					i.normalWorld);
				float3 normalDirection =
					normalize(mul(localCoords, local2WorldTranspose));



				float3 ambientLighting =
				UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;



				/*float3 normalDirection = normalize(i.normal);*/
				

				float3 lightDirection;
				float attenuation;
				if (0.0 == _WorldSpaceLightPos0.w) { //directional Light

					lightDirection = normalize(_WorldSpaceLightPos0.xyz); //this we get from the Lighting.cginc
					attenuation = 1;
				}
				else {
					float3 vertexToLightSource = _WorldSpaceLightPos0.xyz - i.wPos.xyz;
					float distance = length(vertexToLightSource);
					attenuation = 1.0 / distance; // linear attenuation 

					//attenuation = exp(-distance);// exponential attenuation
					lightDirection = normalize(vertexToLightSource);
				}



				float3 diffuseReflection = attenuation * _LightColor0.rgb * _Color.rgb //this we get from the Lighting.cginc
					* max(0.0, dot(normalDirection, lightDirection));

				float3 diffIBL = tex2Dlod(_DiffuseIBL, float4(DirToRectilinear(normalDirection), 0, 0)).xyz;

				diffuseReflection += diffIBL*0.8;


				/*Specular Part*/

				float3 viewDirection = normalize(_WorldSpaceCameraPos - i.wPos.xyz);

				float3 reflectedLightDirection = reflect(-lightDirection, normalDirection); //because we need the inverse light direction for the reflection

				/*For Blinn-Phong specular*/
				float3 halfVector = normalize(lightDirection + viewDirection);

				float3 specularReflection;


				if (dot(normalDirection, lightDirection) < 0.0) {

					specularReflection = float3(0.0, 0.0, 0.0);
				}
				else {

					//specularReflection = attenuation * _LightColor0.rgb * _SpecC * pow(max(0.0, dot(reflectedLightDirection, viewDirection)), _Shininess);

					/*For Blinn-Phong specular*/
					specularReflection = attenuation * _LightColor0.rgb * _SpecC * pow(max(0.0, dot(halfVector, normalDirection)), _Shininess);
				}

				
				float3 reflectedDir = reflect(viewDirection, normalDirection);
				float mipLevel = (1 - _Gloss) * 7;
				float3 specIBL = tex2Dlod(_SpecularIBL, float4(DirToRectilinear(reflectedDir), mipLevel, mipLevel)).xyz;

				specularReflection += specIBL*0.3;

				return float4(diffuseReflection
					+ specularReflection, 1.0);

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
				float2 uv : TEXCOORD0;
				float3 normal: NORMAL;
				float4 tangent : TANGENT;
			};

			struct Interpolators
			{
				float2 uv : TEXCOORD0;
				float4 wPos : TEXCOORD1;
				float3 normal : TEXCOORD2;
				float4 vertex : SV_POSITION;
				float4 posWorld : TEXCOORD3;
				float3 tangentWorld : TEXCOORD4;
				float3 normalWorld : TEXCOORD5;
				float3 binormalWorld : TEXCOORD6;

			};


				float4 _Color;
				float4 _SpecC;
				float _Shininess;
				sampler2D _NormalTex;
				float4 _NormalTex_ST;


				

				Interpolators vert(MeshData v)
				{
					Interpolators o;
					o.vertex = UnityObjectToClipPos(v.vertex);

					o.normal = UnityObjectToWorldNormal(v.normal);

					o.wPos = mul(unity_ObjectToWorld, v.vertex);

					o.uv = v.uv;
					o.tangentWorld = normalize(
						mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz);
					o.normalWorld = normalize(
						mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
					o.binormalWorld = normalize(
						cross(o.normalWorld, o.tangentWorld)
						* v.tangent.w); // tangent.w is specific to Unity

					o.posWorld = mul(unity_ObjectToWorld, v.vertex);

					return o;
				}

				float4 frag(Interpolators i) : SV_Target
				{

					float4 encodedNormal = tex2D(_NormalTex,
					_NormalTex_ST.xy * i.uv.xy + _NormalTex_ST.zw);
					float3 localCoords = float3(2.0 * encodedNormal.a - 1.0,
						2.0 * encodedNormal.g - 1.0, 0.0);
					localCoords.z = sqrt(1.0 - dot(localCoords, localCoords));

					float3x3 local2WorldTranspose = float3x3(
						i.tangentWorld,
						i.binormalWorld,
						i.normalWorld);
					float3 normalDirection =
						normalize(mul(localCoords, local2WorldTranspose));




					float3 ambientLighting =
					UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;



					//float3 normalDirection =  normalize(i.normal);


					float3 lightDirection;
					float attenuation;
					if (0.0 == _WorldSpaceLightPos0.w) { //directional Light

						lightDirection = normalize(_WorldSpaceLightPos0.xyz); //this we get from the Lighting.cginc
						attenuation = 1;
					}
					else {
						float3 vertexToLightSource = _WorldSpaceLightPos0.xyz - i.wPos.xyz;
						float distance = length(vertexToLightSource);
						attenuation = 1.0 / distance; // linear attenuation 

						//attenuation = exp(-distance); // exponential attenuation 

						lightDirection = normalize(vertexToLightSource);
					}



					float3 diffuseReflection = attenuation * _LightColor0.rgb * _Color.rgb //this we get from the Lighting.cginc
						* max(0.0, dot(normalDirection, lightDirection));


					/*Specular Part*/

					float3 viewDirection = normalize(_WorldSpaceCameraPos - i.wPos.xyz);

					float3 reflectedLightDirection = reflect(-lightDirection, normalDirection); //because we need the inverse light direction for the reflection

					/*For Blinn-Phong specular*/
					float3 halfVector = normalize(lightDirection + viewDirection);

					float3 specularReflection;


					if (dot(normalDirection, lightDirection) < 0.0) {

						specularReflection = float3(0.0, 0.0, 0.0);
					}
					else {

						//specularReflection = attenuation * _LightColor0.rgb * _SpecC * pow(max(0.0, dot(reflectedLightDirection, viewDirection)), _Shininess);

						/*For Blinn-Phong specular*/
						specularReflection = attenuation * _LightColor0.rgb * _SpecC * pow(max(0.0, dot(halfVector, normalDirection)), _Shininess);
					}


					return float4(diffuseReflection
						+ specularReflection, 1.0);

				//float3 L = _WorldSpaceLightPos0.xyz;//light direction
				//return float4(L, 1);
				}
				ENDCG
			}


	}
}
