Shader "Unlit/SuperPowa"
{
    // Define the properties that can be set in the material inspector
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
            // Define the vertex and fragment shaders
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _USE_NORMAL_MAP

            #include "UnityCG.cginc"

            // Define the input data from the vertex shader
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float3 tangent : TANGENT;
            };

            // Define the output data to the fragment shader
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
                float3 tangent : TEXCOORD3;
                float3 bitangent : TEXCOORD4;
            };

            // Define the textures and properties used in the shader
            sampler2D _BaseTex;
            sampler2D _DistortionTex;
            sampler2D _NormalMap;

            float4 _BaseTex_ST;
            float4 _OuterGlowColor;
            float4 _InnerGlowColor;

            float _OuterGlowPower;
            float _OuterGlowExponent;
            float _DistortionStrength;
            float _InnerGlowExponent;
            float _InnerGlowPower;

            // Vertex shader
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);

                // If normal map is used, calculate the tangent and bitangent
                #if _USE_NORMAL_MAP
                    o.tangent = UnityObjectToWorldDir(v.tangent);
                    o.bitangent = cross(o.tangent, o.normal);
                #endif

                o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
                o.uv = TRANSFORM_TEX(v.uv, _BaseTex);
                return o;
            }

            // Fragment shader
            fixed4 frag (v2f i) : SV_Target
            {
                // Calculate the distortion value
                float distortionValue = tex2D(_DistortionTex, i.uv + _Time.xx).r;

                float3 finalNormal = i.normal;
                // If normal map is used, calculate the final normal
                #if _USE_NORMAL_MAP
                    float3 normalMap = UnpackNormal(tex2D(_NormalMap, i.uv));
                    finalNormal = normalMap.r * i.tangent + normalMap.g * i.bitangent + normalMap.b * i.normal;
                #endif

                // Calculate the outer glow
                float outerGlowAmount = 1 - max(0, dot(finalNormal, i.viewDir));
                outerGlowAmount *= distortionValue * _DistortionStrength;
                outerGlowAmount = pow(outerGlowAmount, _OuterGlowExponent) * _OuterGlowPower;
                float3 outerGlowColor = outerGlowAmount * _OuterGlowColor;

                // Calculate the inner glow
                float innerGlowAmount = max(0, dot(finalNormal, i.viewDir));
                innerGlowAmount *= distortionValue * _DistortionStrength;
                innerGlowAmount = pow(innerGlowAmount, _InnerGlowExponent) * _InnerGlowPower;
                float3 innerGlowColor = innerGlowAmount * _InnerGlowColor;

                // Combine the outer and inner glow to get the final color
                float3 finalColor = outerGlowColor + innerGlowColor;
                return fixed4(finalColor, 1);
            }
            ENDCG
        }
    }
}
