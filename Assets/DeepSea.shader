Shader "Custom/DeepSea" {
	Properties {
		_SkyColor ("Sky Color", Color) = (0, 0, 0, 0)
		_SeaColor ("Sea Color", Color) = (1, 1, 1, 1)
		_Absorb ("Absorption Facor", Float) = 1.0
	}
	SubShader {
		Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True" }
		Blend One OneMinusSrcAlpha
		Cull Off Lighting Off ZWrite Off Fog { Color (0,0,0,0) }
		
		Pass {
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			fixed4 _SkyColor;
			fixed4 _SeaColor;
			float _Absorb;
			sampler2D _CameraDepthTexture;

			struct vs {
				float4 vertex : POSITION;
			};
			
			struct vs2ps {
				float4 vertex : POSITION;
				float4 proj : TEXCOORD0;
			};
			
			vs2ps vert(vs IN) {
				vs2ps o;
				o.vertex = mul(UNITY_MATRIX_MVP, IN.vertex);
				o.proj = ComputeScreenPos(o.vertex);
				o.proj.z = -mul(UNITY_MATRIX_MV, IN.vertex).z;
				return o;
			}
			
			float4 frag(vs2ps IN) : COLOR {
				float sceneZ = LinearEyeDepth(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(IN.proj)).r);
				float partZ = IN.proj.z;
				float dist = (sceneZ-partZ);
				
				float4 c = _SeaColor;
				c.a *= saturate(1.0 - exp(-_Absorb * dist));
				c.rgb = c.rgb * c.a + _SkyColor;
				return c;
			}			
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
