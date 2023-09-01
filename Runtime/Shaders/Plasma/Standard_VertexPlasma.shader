// Upgrade NOTE: upgraded instancing buffer 'Props' to new syntax.

Shader "Moein/Standard/VertexPlasma"
{
    Properties
    {
        _Color("Tint Color", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}

        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Smoothness ("Smoothness", Range(0,1)) = 0.5
        

        [Space(20)]
        [Header(Plasma Fields)]
        [Space(10)]
        _Speed("Speed", Float) = 10
        _Plasma("Wieght", Range(0, 1)) = 10
		_Scale1("Vertical Scale", Float) = 2
		_Scale2("Horizontal Scale", Float) = 2
		_Scale3("Diagonal Scale", Float) = 2
		_Scale4("Circular Scale", Float) = 2

        [Enum(UnityEngine.Rendering.CullMode)]
        _Cull("Cull", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}
        Cull [_Cull]
       
        CGPROGRAM
        #pragma surface surf Standard vertex:vert fullforwardshadows
        #pragma target 3.0
        // #pragma vertex vert
        
        #include "UnityCG.cginc"
        #include "UnityLightingCommon.cginc"

        float plasma(float2 pos, float t, float verticalScale, float horizontalScale, float diagonalScale, float circularScale){
                        
            //vertical
            float c = sin((pos.x + t) * verticalScale);

            // horizontal
            c += sin((pos.y + t) * horizontalScale);

            // diagonal
            c += sin(diagonalScale * ((sin(t/2.0) * pos.x + cos(t/3) * pos.y) + t));

            // circular
            float c1 = pow(pos.x + .5 * sin(t/5), 2);
            float c2 = pow(pos.y + .5 * cos(t/5), 2);
            c += sin(sqrt(circularScale * (c1 + c2 + t)));

            return c;
        }

        struct Input{
            float2 uv_MainTex;
        };
        
        // struct appdata
        // {
        //     float4 vertex : POSITION;
        //     float2 uv : TEXCOORD0;
        //     float4 normal : NORMAL;
        // };

        // struct v2f
        // {
        //     float4 vertex : POSITION;
        //     float2 uv : TEXCOORD0;
        //     float4 color : COLOR;
        //     float plasma : COLOR1;
        // };
        
        float4 _Color;
        sampler2D _MainTex;
        // float4 _MainTex_ST;

        half _Smoothness, _Metallic;

        float _Speed, _Plasma;
        float _Scale1,_Scale2,_Scale3,_Scale4;        

        void vert (inout appdata_full v)
        {
            // v2f o;
            float t = _Time.x * _Speed;

            float p = abs(plasma(v.vertex.xy, t, _Scale1, _Scale2, _Scale3, _Scale4));
            v.vertex.xyz += v.normal * p * _Plasma;
            // o.vertex = UnityObjectToClipPos(v.vertex);
            // o.uv = TRANSFORM_TEX(v.uv, _MainTex);

            // return o;
        }
        
    
        void surf(Input IN, inout SurfaceOutputStandard o){
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Smoothness;
            o.Alpha = c.a;
        }

        ENDCG
       

    }
    Fallback "Diffuse"
}