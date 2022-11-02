Shader "Unlit/ReflectionCubemap"
{
    Properties
    {
		_Cube("Reflection Map", Cube) = "" {}
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
				float3 reflectedDir = reflect(i.viewDir, normalize(i.normal));
				return texCUBE(_Cube, reflectedDir);
            }
            ENDCG
        }
    }
		Fallback "Unlit/Texture"
}
