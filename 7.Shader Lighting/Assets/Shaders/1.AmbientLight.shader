Shader "Unlit/AmbientLight"
{
    Properties
    {
		_Color("Diffuse Material Color", Color) = (1,1,1,1)

		
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
		Tags{ "LightMode" = "ForwardBase" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

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
			

			Interpolators vert (MeshData v)
            {
				Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);

				float3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.rgb * _Color;

				o.col = float4(ambientColor, 1);

                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                
                return i.col;
            }
            ENDCG
        }
    }
}
