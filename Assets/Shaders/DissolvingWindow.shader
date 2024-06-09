Shader "Custom/DissolvingWindow"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,0)
        _Glossiness ("Burned Scale", Range(-0.1,1)) = 0.0
        _SpecGlossMap ("Roughness Map (also used for the Burned Effect)", 2D) = "white" { }
        _BumpMap ("Normal Map", 2D) = "bump" { }
        _BurnMap ("Burn Map", 2D) = "white" { }
    }
    SubShader
    {
        Tags { "RenderType"="Fade" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows alpha
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _SpecGlossMap;
        sampler2D _BumpMap;
        sampler2D _BurnMap;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        fixed4 _Color;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            o.Normal = -UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
            fixed4 specGloss = tex2D(_SpecGlossMap, IN.uv_MainTex);
            fixed4 burn = tex2D(_BurnMap, IN.uv_MainTex) * specGloss * tex2D(_BumpMap, IN.uv_MainTex);
            o.Metallic = specGloss.g * 0; 

            // Dissolve effect
            float noise = burn.r;
            fixed steppedNoise = step(-_Glossiness, -noise);

            if (steppedNoise > 0.0)
            {
                discard;
            }

            o.Albedo = c.rgb;
            o.Alpha = 0.66;            
            o.Smoothness = specGloss; 
        }
        ENDCG
        
    }
    FallBack "Diffuse"
}
