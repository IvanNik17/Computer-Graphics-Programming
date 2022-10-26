Shader "Unlit/Basic Test shader"
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

				float4 posObjCoords: TEXCOORD2;
				
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

				o.posObjCoords = v.vertex;

				o.normal = v.normal;

				//o.normal = UnityObjectToWorldNormal(v.normal);


                return o;
            }

			float4 frag(Interpolators i) : SV_Target
			{
				/*float4 mixWithColor = float4(i.uv.xyx, 1) + _Color;
				return mixWithColor;*/

				/*if (i.posObjCoords.y > 0.0)
				{
					discard;
				}*/

				/*float maskDiscard = i.posObjCoords.y < 0.0;

				clip(maskDiscard - 0.000001);*/

				return float4(i.normal,1);

				/*float4 outside01 = i.uv.xxxx * 4;
				return frac(outside01);*/
            }
            ENDCG
        }
    }
}
