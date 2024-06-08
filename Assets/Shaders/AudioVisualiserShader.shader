Shader "Unlit/AudioVisualiserShader"

{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Displacement ("Displacement", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float _Displacement;

            // Declaração dos dados do espectro de áudio
            float _SpectrumData0;
            float _SpectrumData1;
            float _SpectrumData2;
            float _SpectrumData3;
            float _SpectrumData4;
            float _SpectrumData5;
            float _SpectrumData6;
            float _SpectrumData7;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(appdata v)
            {
                v2f o;
                // Uso dos dados do espectro para modificar a posição dos vértices
                float displacement = (_SpectrumData0 + _SpectrumData1 + _SpectrumData2 + _SpectrumData3 + _SpectrumData4 + _SpectrumData5 + _SpectrumData6 + _SpectrumData7) * _Displacement;
                v.vertex.y += displacement; // Ajuste a direção conforme necessário
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}

