﻿Shader "Moein/VertexLit/Depth"
{
    Properties
    {
        [Space(10)]
        _CameraOffset ("Camera Offset", Float) = 1
        _SurfaceColor ("Surface Color", Color) = (1,1,1)
        _DepthColor ("Depth Color", Color) = (0,0,0)

        [Space(10)]
        _Color("Color", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}

        _Ambient("Ambient Intensity", Range(0, 1)) = 1
        _LightInt ("Light Intensity", Range(0, 1)) = 1        

        [Space(10)]
        [Toggle]
        _Rim ("Rim", Float) = 0
        _RimInt("Rim Intensity", Range(0, 1)) = 1
        _RimPow("Rim Power", Range(1,20)) = 1
        [HDR]_RimColor("Rim Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"

            #pragma multi_compile __ _RIM_ON


            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal: NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 diffuse : COLOR;
#if _RIM_ON
                float4 rimColor : COLOR1;
#endif
            };

            float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
        
            float _Ambient;
            float _LightInt;

            float _CameraOffset;
            float3 _SurfaceColor;
            float3 _DepthColor;

#if _RIM_ON
            float _RimInt;
            float _RimPow;
            float4 _RimColor;
#endif 

            float3 lambert_shading(float3 colorRefl, float lightInt, float3 normal, float3 lightDir)
            {
                return colorRefl * lightInt * max(0, dot(normal, lightDir));
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
            
                o.diffuse.rgb = UNITY_LIGHTMODEL_AMBIENT * _Ambient;;

                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                half3 diffuse = lambert_shading(_LightColor0.rgb, _LightInt, worldNormal, lightDir);
                o.diffuse.rgb *= diffuse;

#if _RIM_ON
                float3 viewDir = normalize(WorldSpaceViewDir(v.vertex));
                o.rimColor = pow(1- max(0, dot(viewDir, worldNormal)), _RimPow);
#endif

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float depth = (i.vertex.z / i.vertex.w) * _CameraOffset;
                i.diffuse.rgb += lerp(_DepthColor, _SurfaceColor, depth);;
                
#if _RIM_ON     
                i.diffuse.rgb += depth * i.rimColor * _RimColor * _RimInt;
#endif

                fixed4 col = tex2D(_MainTex, i.uv) * _Color;
                col.rgb *= i.diffuse;

                
                return col;
            }
            ENDCG
        }
    }
}