Shader "Unlit/Section-Reveal" 
{
    Properties {
        _MainTex ("Outside Texture", 2D) = "white" {}
        _Color2 ("Section color", Color) = (1.0, 1.0, 1.0, 1.0)
        _EdgeWidth ("Edge width", Range(0.1, 0.9)) = 0.9
        _Val ("Height value", float) = 0
    }

    SubShader {
        Tags { "Queue"="Geometry" }

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata_t {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float _Val;
            float4 _Color2;
            float _EdgeWidth;

            v2f vert(appdata_t v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                if (i.worldPos.y > _Val)
                    discard;

                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }

    FallBack "Diffuse"
}
