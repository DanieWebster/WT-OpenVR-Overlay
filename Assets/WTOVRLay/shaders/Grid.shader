// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

shader "Unlit/GridOverlay"
{
	Properties
	{
 			_MainTex ("Base (RGB)", 2D) = "white" { }
      		_GridSize("Grid Size", Float) = 10  
      		_Grid2Size("Grid 2 Size", Float) = 160
			_Grid3Size("Grid 3 Size", Float) = 320
      		_Alpha ("Alpha", Range(0,1)) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100
		ZTest Always

		Pass
		{
         		Blend SrcAlpha OneMinusSrcAlpha
         		Offset -20, -20
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

         float _GridSize;
         float _Grid2Size;
         float _Grid3Size;
         float _Alpha;

	struct appdata
	{
		float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
	};

	struct v2f
	{
		float2 uv : TEXCOORD0;
		UNITY_FOG_COORDS(1)
		float4 vertex : SV_POSITION;
	};

    sampler2D _MainTex;
    float4 _MainTex_ST;
	
	v2f vert (appdata v)
	{
		
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = TRANSFORM_TEX(v.uv, _MainTex);
		UNITY_TRANSFER_FOG(o,o.vertex);
		return o;
	}



         float DrawGrid(float2 uv, float sz, float aa)
         {
            float aaThresh = aa;
            float aaMin = aa*0.1;

            float2 gUV = uv / sz + aaThresh;
             
            float2 fl = floor(gUV);
            gUV = frac(gUV);
            gUV -= aaThresh;
            gUV = smoothstep(aaThresh, aaMin, abs(gUV));
            float d = max(gUV.x, gUV.y);

            return d;
         }

			fixed4 frag (v2f i) : SV_Target
			{   
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
				fixed r = DrawGrid(i.uv, _GridSize, 0.03);
				fixed b = DrawGrid(i.uv, _Grid2Size, 0.005);
				fixed g = DrawGrid(i.uv, _Grid3Size, 0.002);
				return col + float4(0.8*r*_Alpha,0.8*g*_Alpha,0.8*b*_Alpha,(r+b+g)*_Alpha);
			}
			ENDCG
		}
	}
}
