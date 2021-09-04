Shader "Hidden/HolisticBarracuda/Visualizer"
{
    CGINCLUDE

    #include "UnityCG.cginc"

    StructuredBuffer<float4> _Vertices;
    float2 _uiScale;

    void VertexFace(uint vid : SV_VertexID,
                    float2 uv : TEXCOORD0,
                    out float4 outVertex : SV_Position)
    {
        float2 p = (2 * _Vertices[vid].xy - 1) * _uiScale / _ScreenParams.xy;
        outVertex = float4(p, 0, 1);
    }

    float4 FragmentFaceDebug(float4 position : SV_Position) : SV_Target
    {
        return float4(1, 1, 1, 0.8);
    }


    void VertexEye(uint vid : SV_VertexID,
                   out float4 position : SV_Position,
                   out float4 color : COLOR)
    {
        if (vid < 32)
        {
            const int indices[] =
            {
                0,  1,  1,  2,  2,  3,  3,  4,  4,  5,  5,  6,  6, 7, 7, 8,
                8, 15, 15, 14, 14, 13, 13, 12, 12, 11, 11, 10, 10, 9, 9, 0
            };

            float2 p = (2 * _Vertices[indices[vid] + 5].xy - 1) * _uiScale / _ScreenParams.xy;
            position = float4(p, 0, 1);//UnityObjectToClipPos(mul(_XForm, float4(p, 0, 1)));
            color = float4(0, 1, 1, 1);
        }
        else
        {
            float2 c = _Vertices[0].xy;
            float r = distance(_Vertices[1].xy, _Vertices[3].xy) / 2;

            float phi = UNITY_PI * 2 * (vid / 2 + (vid & 1) - 16) / 15;
            float2 p = c + float2(cos(phi), sin(phi)) * r;
            p = (2 * p - 1) * _uiScale / _ScreenParams.xy;

            position = float4(p, 0, 1);//UnityObjectToClipPos(mul(_XForm, float4(p, 0, 1)));
            color = float4(1, 1, 0, 1);
        }
    }

    float4 FragmentEyeDebug(float4 position : SV_Position,
                            float4 color : COLOR) : SV_Target
    {
        return color;
    }

    ENDCG

    SubShader
    {
        Tags { "Queue" = "Overlay" }
        Cull Off Blend SrcAlpha OneMinusSrcAlpha
        Pass
        {
            CGPROGRAM
            #pragma vertex VertexFace
            #pragma fragment FragmentFaceDebug
            ENDCG
        }
        Pass
        {
            ZTest Always
            CGPROGRAM
            #pragma vertex VertexEye
            #pragma fragment FragmentEyeDebug
            ENDCG
        }
    }
}