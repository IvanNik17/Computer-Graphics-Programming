// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/Color Cube Shader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
			
			Cull Off
			
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

			float4 _Color;


            struct MeshData
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
				float3 normal: NORMAL;
            };

            struct Interpolators
            {
				float4 vertex : SV_POSITION;
                float4 uv : TEXCOORD0;
				float3 normal: TEXCOORD1;

				//nointerpolation
				float4 posObjCoords: TEXCOORD2;
				float4 posWorldCoords: TEXCOORD3;
            };

			float InverseLerp(float a, float b, float v) {

				return (v - a) / (b - a);
			}

			Interpolators vert (MeshData v)
            {
				Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				//o.uv = v.uv;
				o.uv = mul(unity_ObjectToWorld, v.uv);

				o.posObjCoords = v.vertex + float4(0.5, 0.5, 0.5, 0.0);

				o.posWorldCoords = UnityObjectToClipPos(v.vertex);

				o.normal = v.normal;

                return o;
            }

			float4 frag(Interpolators i) : SV_Target
			{
				/*float4 mixWithColor = float4(i.uv.xyx, 1) + _Color;
				return mixWithColor;*/

				/*float grayscale = (i.posObjCoords.x + i.posObjCoords.y + i.posObjCoords.z) / 3;
				return float4(grayscale, grayscale, grayscale, 1);*/

				/*float3 pureWhite = float3(1,1,1);
				float3 cmy = pureWhite - i.posObjCoords;
				return float4(cmy, 1);*/

				float H = 180.0 + degrees(atan2(i.posObjCoords.z, i.posObjCoords.x));
				float S = 2.0 * sqrt(i.posObjCoords.x * i.posObjCoords.x + i.posObjCoords.z * i.posObjCoords.z);
				float V = (i.posObjCoords.y + 1.0) / 2.0;
				return float4(H, S, V, 1);


				//return i.posObjCoords;

				/*float4 outside01 = i.uv.xxxx * 4;
				return frac(outside01);*/
            }
            ENDCG
        }
    }
}
