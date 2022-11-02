Shader "Unlit/RefractionCubemap"
{
    Properties
    {
		_Cube("Reflection Map", Cube) = "" {}
		_RefractionCoeff("Refraction coefficient", float) = 1.5
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

			samplerCUBE  _Cube;
			float _RefractionCoeff;

            struct MeshData
            {
                float4 vertex : POSITION;
				float3 normal : NORMAL;
            };

            struct Interpolators
            {
				float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
				float3 viewDir : TEXCOORD1;
            };

			Interpolators vert (MeshData v)
            {
				Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.viewDir = mul(unity_ObjectToWorld, v.vertex).xyz
					- _WorldSpaceCameraPos;
				o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
				float3 refractedDir = refract(normalize(i.viewDir),
					normalize(i.normal), 1.0 / _RefractionCoeff);
				return texCUBE(_Cube, refractedDir);
            }
            ENDCG
        }
    }
		Fallback "Unlit/Texture"
}
