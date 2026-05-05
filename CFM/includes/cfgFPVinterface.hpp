
class RscCFM_ArmaFPV_Dialog
{
    idd=1952;
    duration=9.9999997e+037;
    movingEnable="false";
    enableSimulation="true";
    class controls
    {
        class LeftLine: RscText
        {
            idc=-1;
            x="safeZoneXAbs";
            y="safeZoneY";
            w="(safeZoneW * 0.15)";
            h="(safeZoneH)";
            colorBackground[]={0,0,0,1};
        };
        class RightLine: LeftLine
        {
            x="safeZoneXAbs + safeZoneWAbs - (safeZoneW * 0.15)";
        };
        class CommunicationGroup: ctrlControlsGroupNoScrollBars
        {
            idc=-1;
            x="(safeZoneXAbs + (safeZoneW * 0.15)) + (safeZoneWAbs - 2*(safeZoneW * 0.15)) - ( 6 * ( pixelGridNoUIScale * pixelW * 2 )) - ( 2 * ( pixelGridNoUIScale * pixelW * 2 ))";
            y="(safeZoneY) + ( 6 * ( pixelGridNoUIScale * pixelH * 2 ))";
            w="( 6 * ( pixelGridNoUIScale * pixelW * 2 ))";
            h="( 2 * ( pixelGridNoUIScale * pixelH * 2 ))";
            class controls
            {
                class CommunicationPicture: ctrlStaticPicture
                {
                    idc=-1;
                    text="\fpv_ua\pictures\100.paa";
                    onLoad="uiNameSpace setVariable [""ArmaFPV_SignalPicture"", _this # 0];";
                    x=0;
                    y="0.0 + ( 2 * ( pixelGridNoUIScale * pixelH * 2 )) / 2 - ( 1 * ( pixelGridNoUIScale * pixelH * 2 )) / 2";
                    w="( 3 * ( pixelGridNoUIScale * pixelW * 2 )) / 2";
                    h="( 1 * ( pixelGridNoUIScale * pixelH * 2 ))";
                };
                class CommunicationText: ctrlStructuredText
                {
                    idc=-1;
                    onLoad="uiNameSpace setVariable [""ArmaFPV_SignalText"", _this # 0];";
                    class Attributes
                    {
                        font="VCROSDMono";
                        align="center";
                        shadow=1;
                    };
                    shadow=0;
                    size="( 1.8 * ( pixelGridNoUIScale * pixelH * 2 ))";
                    text="27";
                    x=0;
                    y=0;
                    w="( 6 * ( pixelGridNoUIScale * pixelW * 2 ))";
                    h="( 2 * ( pixelGridNoUIScale * pixelH * 2 ))";
                };
            };
        };
        class BatteryGroup: ctrlControlsGroupNoScrollBars
        {
            idc=-1;
            x="(safeZoneXAbs + (safeZoneW * 0.15)) + ( 2 * ( pixelGridNoUIScale * pixelW * 2 ))";
            y="(safeZoneY) + (safeZoneH) - ( 2 * ( pixelGridNoUIScale * pixelH * 2 )) - ( 8 * ( pixelGridNoUIScale * pixelH * 2 ))";
            w="( 8 * ( pixelGridNoUIScale * pixelW * 2 ))";
            h="( 2 * ( pixelGridNoUIScale * pixelH * 2 ))";
            class controls
            {
                class BatteryPicture: ctrlStaticPicture
                {
                    idc=-1;
                    onLoad="uiNameSpace setVariable [""ArmaFPV_BatteryPicture"", _this # 0];";
                    text="\fpv_ua\pictures\A100.paa";
                    x=0;
                    y=0;
                    w="( 1 * ( pixelGridNoUIScale * pixelW * 2 ))";
                    h="( 1.8 * ( pixelGridNoUIScale * pixelH * 2 ))";
                };
                class BatteryText: ctrlStructuredText
                {
                    idc=-1;
                    onLoad="uiNameSpace setVariable [""ArmaFPV_BatteryText"", _this # 0];";
                    class Attributes
                    {
                        font="VCROSDMono";
                        align="center";
                        shadow=1;
                    };
                    shadow=0;
                    size="( 1.3 * ( pixelGridNoUIScale * pixelH * 2 ))";
                    text="3.79 v";
                    x=0;
                    y="( 0.3 * ( pixelGridNoUIScale * pixelH * 2 ))";
                    w="( 8 * ( pixelGridNoUIScale * pixelW * 2 ))";
                    h="( 2 * ( pixelGridNoUIScale * pixelH * 2 ))";
                };
            };
        };
        class OnTime_Group: ctrlControlsGroupNoScrollBars
        {
            idc=-1;
            x="(safeZoneXAbs + (safeZoneW * 0.15)) + (safeZoneWAbs - 2*(safeZoneW * 0.15)) - ( 6 * ( pixelGridNoUIScale * pixelW * 2 )) - ( 2 * ( pixelGridNoUIScale * pixelW * 2 ))";
            y="(safeZoneY) + (safeZoneH) - ( 2 * ( pixelGridNoUIScale * pixelH * 2 )) - ( 8 * ( pixelGridNoUIScale * pixelH * 2 ))";
            w="( 10 * ( pixelGridNoUIScale * pixelW * 2 ))";
            h="( 2.5 * ( pixelGridNoUIScale * pixelH * 2 ))";
            class controls
            {
                class OnTime_Picture: ctrlStaticPicture
                {
                    idc=-1;
                    text="\fpv_ua\pictures\mn.paa";
                    x=0;
                    y=0;
                    w="( 6 * ( pixelGridNoUIScale * pixelW * 2 )) / 2";
                    h="( 2 * ( pixelGridNoUIScale * pixelH * 2 ))";
                };
                class OnTime_Text: ctrlStructuredText
                {
                    idc=-1;
                    onLoad="uiNameSpace setVariable [""ArmaFPV_OnTimeText"", _this # 0];";
                    class Attributes
                    {
                        font="VCROSDMono";
                        align="right";
                        shadow=1;
                    };
                    shadow=0;
                    size="( 1.4 * ( pixelGridNoUIScale * pixelH * 2 ))";
                    text="03:38";
                    x=0;
                    y="( 0.3 * ( pixelGridNoUIScale * pixelH * 2 ))";
                    w="( 6.5 * ( pixelGridNoUIScale * pixelW * 2 ))";
                    h="( 2 * ( pixelGridNoUIScale * pixelH * 2 ))";
                };
            };
        };
        class Center_target: ctrlStaticPicture
        {
            idc=-1;
            text="\fpv_ua\pictures\PRICEL.paa";
            x="0.5 - ( 2 * ( pixelGridNoUIScale * pixelW * 2 )) / 2";
            y="0.5 - ( 2 * ( pixelGridNoUIScale * pixelH * 2 )) / 2 + ( 1.25 * ( pixelGridNoUIScale * pixelH * 2 ))";
            w="( 2 * ( pixelGridNoUIScale * pixelW * 2 ))";
            h="( 2 * ( pixelGridNoUIScale * pixelH * 2 ))";
        };
        class V_Line_Left: ctrlStaticPicture
        {
            idc=-1;
            text="\fpv_ua\pictures\horiz_empty.paa";
            x="0.5 + ( 10 * ( pixelGridNoUIScale * pixelW * 2 ))";
            y="0.5 - ( 12 * ( pixelGridNoUIScale * pixelH * 2 )) / 2";
            w="( 1 * ( pixelGridNoUIScale * pixelW * 2 ))";
            h="( 12 * ( pixelGridNoUIScale * pixelH * 2 ))";
        };
        class V_Line_Right: V_Line_Left
        {
            x="0.5 - ( 10 * ( pixelGridNoUIScale * pixelW * 2 ))";
        };
        class MainText: ctrlStructuredText
        {
            idc=-1;
            class Attributes
            {
                font="VCROSDMono";
                align="center";
                shadow=1;
            };
            shadow=0;
            size="( 1.4 * ( pixelGridNoUIScale * pixelH * 2 ))";
            onLoad="uiNameSpace setVariable [""ArmaFPV_MainText"", _this # 0];";
            text="";
            x="(safeZoneXAbs + (safeZoneW * 0.15)) + (safeZoneWAbs - 2*(safeZoneW * 0.15)) / 2 - ( 20 * ( pixelGridNoUIScale * pixelW * 2 )) / 2";
            y="0.5 - ( 12 * ( pixelGridNoUIScale * pixelH * 2 )) / 2 - ( 1.6 * ( pixelGridNoUIScale * pixelH * 2 ))";
            w="( 20 * ( pixelGridNoUIScale * pixelW * 2 ))";
            h="( 1.6 * ( pixelGridNoUIScale * pixelH * 2 ))";
        };
        class AzimuthCompass: ctrlStaticPicture
        {
            idc=-1;
            text="\fpv_ua\pictures\vert.paa";
            x="(safeZoneXAbs + (safeZoneW * 0.15)) + ((safeZoneWAbs - 2 * (safeZoneW * 0.15)) / 2) - ((16 * (pixelGridNoUIScale * pixelW * 2)) / 2)";
            y="safeZoneY + (0.5 * (pixelGridNoUIScale * pixelH * 2))";
            w="(16 * (pixelGridNoUIScale * pixelW * 2))";
            h="(1.3 * (pixelGridNoUIScale * pixelH * 2))";
        };
    };
		class controlsBackground
		{
			class R2TPicture: RscPicture
			{
				idc = 1488;
				onLoad = "uiNamespace setVariable [""DB_fpv_r2tPicture"", _this # 0];";
				text = "";
				x = "safeZoneXAbs";
				y = "safeZoneY";
				w = "safeZoneWAbs";
				h = "safeZoneH";
				show = 1;
			};
			class EffectPicture1: R2TPicture
			{
				idc = 1489;
				onLoad = "uiNamespace setVariable [""DB_fpv_effectsPicture1"", _this # 0];";
				show = 0;
			};
			class EffectPicture2: R2TPicture
			{
				idc = 1490;
				onLoad = "uiNamespace setVariable [""DB_fpv_effectsPicture2"", _this # 0];";
				show = 0;
			};
		};
};