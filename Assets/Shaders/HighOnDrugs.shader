Shader "Unlit/HighOnDrugs"
{
    Properties
    {
        _RimColor ("Highlight Color", Color) = (0,0.5,0,0)
        _TintColor("Base Color", Color) = (0,0.5,1,1)
        _GlitchFrequency("Glitch Frequency", Range(0.01,3.0)) = 1.0
        _WorldScale("Stripe count", Range(1,200)) = 20
        _HologramSpeed("Hologram Speed", Range(0.1, 5.0)) = 1.0
    }
	
    SubShader
    {
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType" = "Sphere" }
        Blend SrcAlpha OneMinusSrcAlpha 
        ColorMask RGB
        Cull Back 

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"

            float4 _TintColor;
            float4 _RimColor;

            struct appdata_t
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
                float2 texcoord : TEXCOORD0;
                float3 wpos : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
            };

            float _GlitchFrequency;
            float _OptTime;
            float _WorldScale;
            float _HologramSpeed;

            v2f vert(appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                _OptTime = sin(_Time.w * _GlitchFrequency);
                float glitchTime = step(0.99, _OptTime);
                float glitchPos = v.vertex.y + _SinTime.y;
                float glitchPosClamped = step(0, glitchPos) * step(glitchPos, 0.2);
                o.vertex.xz += glitchPosClamped * 0.1 * glitchTime * _SinTime.y;

                o.color = v.color;
                
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.wpos = worldPos;
                o.normalDir = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
                
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float4 text = _TintColor;
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.wpos);
                half rim = 1 - saturate(dot(viewDirection, i.normalDir));

                // Spiral effect
                float angle = atan2(i.wpos.z, i.wpos.x);
                float radius = length(i.wpos.xz);
                float fracSpiral = frac((radius * _WorldScale) - (_Time.y * _HologramSpeed + angle));
                float scanlines = step(fracSpiral, 0.5);

                float bigfracline = frac((i.wpos.y) - _Time.x * 4);

                fixed4 col = text + (bigfracline * 0.4 * _TintColor) + (rim * _RimColor);
                col.a = 0.8 * (scanlines + rim + bigfracline);

                return col;
            }
            ENDCG
        }
    }

    FallBack "Diffuse"
}

