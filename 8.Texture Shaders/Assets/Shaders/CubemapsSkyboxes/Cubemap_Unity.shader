Shader "Unlit/Cubemap_Unity"
{
    Properties
    {
		_Cube("Reflection Map", Cube) = "" {}
    }
    SubShader
    {
		Tags{ "Queue" = "Background" }

        Pass
        {
			
			ZWrite Off
			Cull Off
			
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

			samplerCUBE  _Cube;

            struct MeshData
            {
                float4 vertex : POSITION;
				float4 uv : TEXCOORD0;
				
            };

            struct Interpolators
            {
				float4 vertex : SV_POSITION;
				float3 viewDir : TEXCOORD1;

				float3 uv : TEXCOORD0;
            };

			Interpolators vert (MeshData v)
            {
				Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.viewDir = mul(unity_ObjectToWorld, v.vertex).xyz
					- _WorldSpaceCameraPos;

				o.uv = v.uv;
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
				
				return texCUBE(_Cube, i.uv);
            }
            ENDCG
        }
    }
		Fallback "Unlit/Texture"
}
