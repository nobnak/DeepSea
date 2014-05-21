Shader "Custom/DeepSea" {
	Properties {
		_MainTex ("Particle Texture", 2D) = "white" {}
		_InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0
		_TintColor ("Color", Color) = (1, 1, 1, 1)
	}
	SubShader {
		Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True" }
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off Lighting Off ZWrite Off Fog { Color (0,0,0,0) }
		
		Pass {
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _InvFade;
			fixed4 _TintColor;
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
				float fade = saturate (_InvFade * (sceneZ-partZ));
				
				float4 c = _TintColor;
				c.a *= fade;
				return c;
			}			
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
