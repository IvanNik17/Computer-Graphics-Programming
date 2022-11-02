Shader "Unlit/IrradianceMappingPremade"
{
    Properties
    {
		_DiffuseIBL("Diffuse Environment Map", 2D) = "black" {}

		_SpecularIBL("Specular Environment Map", 2D) = "black" {}

		_Gloss("How Glossy is the Specular", Range(0,1)) = 1
	}
		SubShader
	{
		Tags{ "RenderType" = "Opaque" }

		Pass
		{


			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			#define TAU 6.28318530718  //or known as 2* PI

			uniform sampler2D  _DiffuseIBL;
			uniform sampler2D  _SpecularIBL;
			float _Gloss;

            struct MeshData
            {
                float4 vertex : POSITION;
				float3 normal : NORMAL;
            };

            struct Interpolators
            {
				float4 vertex : SV_POSITION;
				float3 normal : TEXCOORD0;
				float4 wPos : TEXCOORD1;
            };

			float2 DirToRectilinear(float3 dir) { 
				float x = atan2(dir.z, dir.x)/ TAU + 0.5; //-tau/2 tau/2  -> -0.5 0.5 -> 0  1
				float y = dir.y * 0.5 + 0.5; //-0.5 0.5 -> 0 1

				return float2(x, y);
			}

			Interpolators vert (MeshData v)
            {
				Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);

				o.normal = UnityObjectToWorldNormal(v.normal);

				o.wPos = mul(unity_ObjectToWorld, v.vertex);

                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {

				float3 diffIBL = tex2Dlod(_DiffuseIBL, float4(DirToRectilinear(i.normal),0,0) ).xyz;

				float3 viewDirection = normalize(i.wPos - _WorldSpaceCameraPos);
				float3 reflectedDir = reflect(viewDirection, normalize(i.normal));
				float mipLevel = (1 - _Gloss) * 7;
				float3 specIBL = tex2Dlod(_SpecularIBL, float4(DirToRectilinear(reflectedDir), mipLevel, mipLevel)).xyz;


				
				/*float3 reflectedDir =
					reflect(i.viewDir, normalize(i.normal));*/
				return float4(specIBL,1);

				
            }
            ENDCG
        }
    }
		Fallback "Unlit/Texture"
}
