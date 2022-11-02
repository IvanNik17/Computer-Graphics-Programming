Shader "Unlit/NormalMapping"
{
    Properties
    {
        _NormalTex ("Normal Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

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
                float4 vertex : SV_POSITION;
				float4 posWorld : TEXCOORD1;
				float3 tangentWorld : TEXCOORD2;
				float3 normalWorld : TEXCOORD3;
				float3 binormalWorld : TEXCOORD4;
            };

            sampler2D _NormalTex;
            float4 _NormalTex_ST;

			Interpolators vert (MeshData v)
            {
				Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
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

            float4 frag (Interpolators i) : SV_Target
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



                return float4(normalDirection,1);
            }
            ENDCG
        }
    }
}
