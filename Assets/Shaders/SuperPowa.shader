Shader "Unlit/SuperPowa"
{
    Properties
    {
        _BaseTex ("Base Texture", 2D) = "white" {}
        _DistortionTex ("Distortion Texture", 2D) = "white" {}
        _DistortionStrength ("Distortion Strength", Range(0,10)) = 0

        _OuterGlowColor ("Outer Glow Color", Color) = (1,1,1,1)
        _OuterGlowPower ("Outer Glow Power", Range(0,10)) = 0
        _OuterGlowExponent ("Outer Glow Exponent", Range(0,10)) = 0

        _InnerGlowColor ("Inner Glow Color", Color) = (1,1,1,1)
        _InnerGlowPower ("Inner Glow Power", Range(0,10)) = 0
        _InnerGlowExponent ("Inner Glow Exponent", Range(0,10)) = 0

        _DissolveMap ("Dissolve Map", 2D) = "white" {}
        _DissolveThreshold ("Dissolve Threshold", Range(0,1)) = 0

        [Toggle] _UseNormalMap ("Use Normal Map", float) = 0
        _NormalMap ("Normal Map", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Blend SrcAlpha One
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _USE_NORMAL_MAP

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float3 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
                float3 tangent : TEXCOORD3;
                float3 bitangent : TEXCOORD4;
            };

            sampler2D _BaseTex;
            sampler2D _DistortionTex;
            sampler2D _DissolveMap;
            sampler2D _NormalMap;

            float4 _BaseTex_ST;
            float4 _OuterGlowColor;
            float4 _InnerGlowColor;

            float _OuterGlowPower;
            float _OuterGlowExponent;
            float _DistortionStrength;
            float _InnerGlowExponent;
            float _InnerGlowPower;
            float _DissolveThreshold;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);

                #if _USE_NORMAL_MAP
                    o.tangent = UnityObjectToWorldDir(v.tangent);
                    o.bitangent = cross(o.tangent, o.normal);
                #endif

                o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
                o.uv = TRANSFORM_TEX(v.uv, _BaseTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float dissolveValue = tex2D(_DissolveMap, i.uv).r;
                float mask = step(dissolveValue, _DissolveThreshold);

                float distortionValue = tex2D(_DistortionTex, i.uv + _Time.xx).r;

                float3 finalNormal = i.normal;
                #if _USE_NORMAL_MAP
                    float3 normalMap = UnpackNormal(tex2D(_NormalMap, i.uv));
                    finalNormal = normalMap.r * i.tangent + normalMap.g * i.bitangent + normalMap.b * i.normal;
                #endif

                float outerGlowAmount = 1 - max(0, dot(finalNormal, i.viewDir));
                outerGlowAmount *= distortionValue * _DistortionStrength;
                outerGlowAmount = pow(outerGlowAmount, _OuterGlowExponent) * _OuterGlowPower;
                float3 outerGlowColor = outerGlowAmount * _OuterGlowColor;

                float innerGlowAmount = max(0, dot(finalNormal, i.viewDir));
                innerGlowAmount *= distortionValue * _DistortionStrength;
                innerGlowAmount = pow(innerGlowAmount, _InnerGlowExponent) * _InnerGlowPower;
                float3 innerGlowColor = innerGlowAmount * _InnerGlowColor;

                float3 finalColor = outerGlowColor + innerGlowColor;
                return fixed4(finalColor * mask, mask);
            }
            ENDCG
        }
    }
}

