Shader "Unlit/DitherTransparency"
{
	Properties
	{
		_Color("Albedo Color", Color) = (1,1,1,1)
		_DitherStrength ("Dither Strength", Range(0,1)) = 1
	}
	SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		Pass
		{
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

			#include "UnityCG.cginc"


			float4 _Color;
			float _DitherStrength;


			struct MeshData
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct Interpolators
			{
				
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 scrPos : TEXCOORD1;
				
			};

			Interpolators vert(MeshData v)
			{
				Interpolators o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				o.scrPos = ComputeScreenPos(o.vertex); // Gives the vertex coordinates in Screen space without being devided by the 4th component W

				o.uv = v.uv;
				return o;
			}

			

			float4 frag(Interpolators i) : SV_Target
			{
				
				float4 col = _Color;


				float4x4 thresholdMatrix =
				{ 1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0,
					13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0,
					4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,
					16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0
				};

				float2 pixelPos = i.scrPos / i.scrPos.w; // divide by 4th component
				pixelPos *= _ScreenParams.xy; // transform into pixel level Screen coordinates

				float2 uvPos = i.uv; // texture coordinates
				uvPos *= _ScreenParams.xy; //texture to pixel coordinates

				//Dithering in Texture Coordinate Space
				clip(_DitherStrength - thresholdMatrix[uvPos.x % 4][uvPos.y % 4]);

				//Dithering in Vertex Screen Coordinate Space
				//clip(_DitherStrength - thresholdMatrix[pixelPos.x % 4][pixelPos.y % 4]);

				return col;


			}
			ENDCG
		}
	}
}
