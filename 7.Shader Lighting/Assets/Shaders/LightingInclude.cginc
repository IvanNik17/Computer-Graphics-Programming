#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

struct MeshData
{
	float4 vertex : POSITION;
	float3 normal : NORMAL;
};

struct Interpolators
{
	float4 wPos : TEXCOORD0;
	float3 normal : TEXCOORD1;
	float4 vertex : SV_POSITION;
};


float4 _Color;
float4 _SpecC;
float _Shininess;

Interpolators vert(MeshData v)
{
	Interpolators o;
	o.vertex = UnityObjectToClipPos(v.vertex);

	o.normal = UnityObjectToWorldNormal(v.normal);

	o.wPos = mul(unity_ObjectToWorld, v.vertex);

	return o;
}

float4 frag(Interpolators i) : SV_Target
{

	float3 ambientLighting =
	UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;



	float3 normalDirection = normalize(i.normal);


	float3 lightDirection;
	float attenuation;
	if (0.0 == _WorldSpaceLightPos0.w) { //directional Light

		lightDirection = normalize(_WorldSpaceLightPos0.xyz); //this we get from the Lighting.cginc
		attenuation = 1;
	}
	else {
		float3 vertexToLightSource = _WorldSpaceLightPos0.xyz - i.wPos.xyz;
		float distance = length(vertexToLightSource);
		attenuation = 1.0 / distance; // linear attenuation 

									  //attenuation = exp(-distance);// exponential attenuation
		lightDirection = normalize(vertexToLightSource);
	}



	float3 diffuseReflection = attenuation * _LightColor0.rgb * _Color.rgb //this we get from the Lighting.cginc
	* max(0.0, dot(normalDirection, lightDirection));


	/*Specular Part*/

	float3 viewDirection = normalize(_WorldSpaceCameraPos - i.wPos.xyz);

	float3 reflectedLightDirection = reflect(-lightDirection, normalDirection); //because we need the inverse light direction for the reflection

																				/*For Blinn-Phong specular*/
	float3 halfVector = normalize(lightDirection + viewDirection);

	float3 specularReflection;


	if (dot(normalDirection, lightDirection) < 0.0) {

		specularReflection = float3(0.0, 0.0, 0.0);
	}
	else {

		//specularReflection = attenuation * _LightColor0.rgb * _SpecC * pow(max(0.0, dot(reflectedLightDirection, viewDirection)), _Shininess);

		/*For Blinn-Phong specular*/
		specularReflection = attenuation * _LightColor0.rgb * _SpecC * pow(max(0.0, dot(halfVector, normalDirection)), _Shininess);
	}


	return float4(diffuseReflection
		+ specularReflection, 1.0);


}