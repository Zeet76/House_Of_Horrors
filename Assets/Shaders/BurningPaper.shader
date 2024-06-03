Shader "Custom/BurningPaper"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Glossiness ("Burned Scale", Range(-0.1000,1)) = 0.5
        _SpecGlossMap ("Roughness Map (also used for the Burned Effect)", 2D) = "white" { }
        _BumpMap ("Normal Map", 2D) = "bump" { }
        _BurnMap ("Burn Map", 2D) = "white" { }
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
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

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
            fixed4 specGloss = tex2D(_SpecGlossMap, IN.uv_MainTex);
            fixed4 burn = tex2D(_BurnMap, IN.uv_MainTex) * specGloss * tex2D(_BumpMap, IN.uv_MainTex);
            o.Metallic = specGloss.g * 0; 

            // Dissolve effect
            float noise = burn.r;
            fixed steppedNoise = step(_Glossiness, noise);

            if (steppedNoise < 1.0)
            {
                discard;
            }

            // Edge detection for burn effect
            float outlineWidth = 0.01;
            float outlineStep1 = step(_Glossiness + outlineWidth, noise);
            float outlineStep2 = step(_Glossiness + 2 * outlineWidth, noise);
            fixed4 orange = float4(1, 0.2, 0, 1);
            fixed4 grey = float4(0.2, 0.2, 0.2, 0.2);
            
            // Blinking effect
            float blinkSpeed = 5.0;
            float blinkIntensity = 1;
            float blink = (sin(_Time.y * blinkSpeed) + 1.0) * 0.5 * blinkIntensity;

            if (steppedNoise > outlineStep1 && steppedNoise > outlineStep2)
            {
                o.Albedo = orange;
                o.Emission = orange * blink; 
                o.Alpha = c.a * 0.9;
            }
            else if (steppedNoise > outlineStep2)
            {
                o.Albedo = grey * c;
                o.Alpha = c.a;
            }
            else
            {
                o.Albedo = c.rgb;
                o.Emission = float3(0, 0, 0);
                o.Alpha = c.a;
            }
            o.Smoothness = specGloss.r * _Glossiness; 
        }
        ENDCG
    }
    FallBack "Diffuse"
}
