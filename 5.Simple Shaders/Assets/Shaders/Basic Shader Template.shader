Shader "Unlit/Basic Shader Template"
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
			
			ZWrite On
			
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
				
            };

			float InverseLerp(float a, float b, float v) {

				return (v - a) / (b - a);
			}

			Interpolators vert (MeshData v)
            {
				Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;


				o.normal = v.normal;

                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {

				return i.uv;

            }
            ENDCG
        }
    }
}
