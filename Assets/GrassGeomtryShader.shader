// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Low Poly Shader developed as part of World of Zero: http://youtube.com/worldofzerodevelopment
// Based upon the example at: http://www.battlemaze.com/?p=153

Shader "Custom/GeomtryGrassShader" {
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
		_GrassHeight("GrassHeight" ,float) =0.5
		_GrassWidth("Grass Width" ,float) =0.5
		_CutOff("Alpha Cut Off" ,float) =0.5
		_WindStength("Wind strength" ,Range(0,2)) =0.09
		_WindSpeed("Wind speed" ,Range(0,100)) =1
	}
	SubShader{
		Tags { "RenderType" = "Opaque" }
		LOD 200
		cull off
		Pass
		{

			CGPROGRAM
			#include "UnityCG.cginc" 
			#pragma vertex vert
			#pragma fragment frag
			#pragma geometry geom

			// Use shader model 4.0 target, we need geometry shader support
			#pragma target 4.0

			sampler2D _MainTex;

			struct v2g
			{
				float4 pos : SV_POSITION;
				float3 norm : NORMAL;
				float2 uv : TEXCOORD0;
				float3 color : TEXCOORD1;
			};

			struct g2f
			{
				float4 pos : SV_POSITION;
				float3 norm : NORMAL;
				float2 uv : TEXCOORD0;
				float3 diffuseColor : TEXCOORD1;
				//float3 specularColor : TEXCOORD2;
			};

			half _Glossiness;
			half _Metallic;
			fixed4 _Color;
			float _GrassHeight;
			float _CutOff;
			float _GrassWidth;
			float _WindSpeed;
			float _WindStength;
			v2g vert(appdata_full v)
			{
				float3 v0 = v.vertex.xyz;

				v2g OUT;
				OUT.pos = v.vertex;
				OUT.norm = v.normal;
				OUT.uv = v.texcoord;
				OUT.color = tex2Dlod(_MainTex, v.texcoord).rgb;
				return OUT;
			}




			void buildQuad( inout TriangleStream<g2f>triStream ,float3 points[4] ,float3 color){
				g2f OUT;
				float3 faceNormal =cross(points[1]-points[0] ,points[2]-points[0]);
				for(int i=0;i<4;i++){
					OUT.pos = UnityObjectToClipPos(points[i]);
					OUT.norm = faceNormal;
					OUT.diffuseColor = color;
					OUT.uv = float2(i%2, (int)i/2);
					triStream.Append(OUT);
				}
				triStream.RestartStrip();
			}

			[maxvertexcount(12)]
			void geom(point v2g IN[1], inout TriangleStream<g2f> triStream)
			{
				float3 lightPosition = _WorldSpaceLightPos0;

				float3 perpendicularAngle = float3(0,0,1);
				float3 v0 = IN[0].pos.xyz;
				float3 v1 =IN[0].pos.xyz+IN[0].norm*_GrassHeight;

				
				float3 wind = float3(sin(_Time.x * _WindSpeed + v0.x) + sin(_Time.x * _WindSpeed + v0.z * 2) + sin(_Time.x * _WindSpeed * 0.1 + v0.x), 0,
				cos(_Time.x * _WindSpeed + v0.x * 2) + cos(_Time.x * _WindSpeed + v0.z));
				v1 += wind * _WindStength;

				float3 color = (IN[0].color);

				float sin30 = 0.5;
				float sin60 = 0.866f;
				float cos30 = sin60;
				float cos60 = sin30;
				float3 quad1[4] ={v0+perpendicularAngle*0.5*_GrassWidth
					,v0 - perpendicularAngle * 0.5 *_GrassWidth,
					v1+perpendicularAngle*0.5*_GrassWidth
				,v1 - perpendicularAngle * 0.5 *_GrassWidth};
				buildQuad(triStream ,quad1 ,color);

				float3 quad2[4] ={v0 + float3(sin60 ,0 ,-cos60) * 0.5 *_GrassWidth
					,v0 - float3(sin60 ,0 ,-cos60) * 0.5 *_GrassWidth,
					v1+float3(sin60 ,0 ,-cos60) * 0.5 *_GrassWidth
				,v1 - float3(sin60 ,0 ,-cos60) * 0.5 *_GrassWidth};
				buildQuad(triStream ,quad2 ,color);

				float3 quad3[4] ={v0 + float3(sin60 ,0 ,cos60) * 0.5 *_GrassWidth
					,v0 - float3(sin60 ,0 ,cos60) * 0.5 *_GrassWidth,
					v1+float3(sin60 ,0 ,cos60) * 0.5 *_GrassWidth
				,v1 - float3(sin60 ,0 ,cos60) * 0.5 *_GrassWidth};
				buildQuad(triStream ,quad3 ,color);
				
			}
			half4 frag(g2f IN) : COLOR
			{

				float4 c = tex2D(_MainTex ,IN.uv);
				clip(c.a -_CutOff);
				return c;
			}
			ENDCG
		}

	}
}
