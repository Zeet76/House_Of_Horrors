Shader "Hidden/DoNotEnter"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        [Header(Red)]
        _RedX ("Offset X", Range(-0.5, 0.5)) = 0.0
        _RedY ("Offset Y", Range(-0.5, 0.5)) = 0.0

        [Header(Green)]
        _GreenX ("Offset X", Range(-0.5, 0.5)) = 0.0
        _GreenY ("Offset Y", Range(-0.5, 0.5)) = 0.0

        [Header(Blue)]
        _BlueX ("Offset X", Range(-0.5, 0.5)) = 0.0
        _BlueY ("Offset Y", Range(-0.5, 0.5)) = 0.0
        
        _BlurAmount ("Blur Amount", Range(0.0, 1.0)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;

            float _RedX;
            float _RedY;
            float _GreenX;
            float _GreenY;
            float _BlueX;
            float _BlueY;
            float _BlurAmount;

            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 red_uv = i.uv + float2(_RedX, _RedY);
                float2 green_uv = i.uv + float2(_GreenX, _GreenY);
                float2 blue_uv = i.uv + float2(_BlueX, _BlueY);

                fixed4 col;
                col.r = tex2D(_MainTex, red_uv).r;
                col.g = tex2D(_MainTex, green_uv).g;
                col.b = tex2D(_MainTex, blue_uv).b;
                col.a = tex2D(_MainTex, i.uv).a;

                // Gaussian blur effect
                fixed4 blur_col = fixed4(0.0, 0.0, 0.0, 0.0);
                float2 offsets[9] = {float2(-1, -1), float2(0, -1), float2(1, -1),
                                     float2(-1,  0), float2(0,  0), float2(1,  0),
                                     float2(-1,  1), float2(0,  1), float2(1,  1)};
                float weights[9] = {0.075, 0.125, 0.075,
                                    0.125, 0.200, 0.125,
                                    0.075, 0.125, 0.075};
                
                for (int j = 0; j < 9; j++)
                {
                    float2 blur_uv = i.uv + offsets[j] * _BlurAmount * 0.01; // Adjust the scale of the blur
                    blur_col += tex2D(_MainTex, blur_uv) * weights[j];
                }

                // Combine the glitch and blur effect
                col.rgb = lerp(col.rgb, blur_col.rgb, _BlurAmount);

                return col;
            }
            ENDCG
        }
    }
}







