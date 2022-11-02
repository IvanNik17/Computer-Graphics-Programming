Shader "Unlit/ParallaxMapping"
{
    Properties
    {
        _NormalTex ("Normal Texture", 2D) = "white" {}
		_ParallaxMap("Heightmap (in A)", 2D) = "black" {}
		_Parallax("Max Height", Float) = 0.01
		_MaxTexCoordOffset("Max Texture Coordinate Offset", Float) = 0.01
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
				float3 viewDirWorld : TEXCOORD5;
				float3 viewDirInScaledSurfaceCoords : TEXCOORD6;
            };

            sampler2D _NormalTex;
            float4 _NormalTex_ST;
			uniform sampler2D _ParallaxMap;
			uniform float4 _ParallaxMap_ST;
			uniform float _Parallax;
			uniform float _MaxTexCoordOffset;

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

				

				float3 binormal = cross(v.normal, v.tangent.xyz)
					* v.tangent.w;
				// appropriately scaled tangent and binormal 
				// to map distances from object space to texture space

				float3 viewDirInObjectCoords = mul(
					unity_WorldToObject, float4(_WorldSpaceCameraPos, 1.0)).xyz
					- v.vertex.xyz;
				float3x3 localSurface2ScaledObjectT =
					float3x3(v.tangent.xyz, binormal, v.normal);
				// vectors are orthogonal
				o.viewDirInScaledSurfaceCoords =
					mul(localSurface2ScaledObjectT, viewDirInObjectCoords);
				// we multiply with the transpose to multiply with 
				// the "inverse" (apart from the scaling)

				o.posWorld = mul(unity_ObjectToWorld, v.vertex);
				o.viewDirWorld = normalize(
					_WorldSpaceCameraPos - o.posWorld.xyz);


                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
				// parallax mapping: compute height and 
				// find offset in texture coordinates 
				// for the intersection of the view ray 
				// with the surface at this height

				float height = _Parallax
				* (-0.5 + tex2D(_ParallaxMap, _ParallaxMap_ST.xy
					* i.uv.xy + _ParallaxMap_ST.zw).x);

				float2 texCoordOffsets = clamp(height * i.viewDirInScaledSurfaceCoords.xy / i.viewDirInScaledSurfaceCoords.z,
						-_MaxTexCoordOffset, +_MaxTexCoordOffset);




				float4 encodedNormal = tex2D(_NormalTex,
				_NormalTex_ST.xy * (i.uv.xy + texCoordOffsets) + _NormalTex_ST.zw);
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
