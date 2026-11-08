
class RscCFM_ArmaFPV_Dialog
{
    idd=1952;
    duration=9.9999997e+037;
    movingEnable="false";
    enableSimulation="true";
    onLoad="[_this select 0, 'RscCFM_ArmaFPV_Dialog'] call (missionNamespace getVariable ['CFM_fnc_repositionControls', {}]);";
    class controls
    {
        class LeftLine: RscText
        {
            idc=1101;
            x=EVAL_UI(STATIC_SZ_X);
            y=EVAL_UI(STATIC_SZ_Y);
            w=EVAL_UI((STATIC_SZ_W * 0.15));
            h=EVAL_UI((STATIC_SZ_H));
            colorBackground[]={0,0,0,1};
        };
        class RightLine: LeftLine
        {
            idc=1102;
            x=EVAL_UI(STATIC_SZ_X + STATIC_SZ_W - (STATIC_SZ_W * 0.15));
        };
        class CommunicationGroup: ctrlControlsGroupNoScrollBars
        {
            idc=1103;
            x=EVAL_UI((STATIC_SZ_X + (STATIC_SZ_W * 0.15)) + (STATIC_SZ_W - 2 * (STATIC_SZ_W * 0.15)) - fnc_width(6) - fnc_width(2));
            y=EVAL_UI((STATIC_SZ_Y) + fnc_height(6));
            w=EVAL_UI(fnc_width(6));
            h=EVAL_UI(fnc_height(2));
            class controls
            {
                class CommunicationPicture: ctrlStaticPicture
                {
                    idc=825;
                    text="\fpv_ua\pictures\100.paa";
                    onLoad="uiNameSpace setVariable [""ArmaFPV_SignalPicture"", _this # 0];";
                    x=0;
                    y=EVAL_UI(0.0 + fnc_height(2) / 2 - fnc_height(1) / 2);
                    w=EVAL_UI(fnc_width(3) / 2);
                    h=EVAL_UI(fnc_height(1));
                };
                class CommunicationText: ctrlStructuredText
                {
                    idc=836;
                    onLoad="uiNameSpace setVariable [""ArmaFPV_SignalText"", _this # 0];";
                    class Attributes
                    {
                        font="VCROSDMono";
                        align="center";
                        shadow=1;
                    };
                    shadow=0;
                    size=EVAL_UI(fnc_height(1.8));
                    text="27";
                    x=0;
                    y=0;
                    w=EVAL_UI(fnc_width(6));
                    h=EVAL_UI(fnc_height(2));
                };
            };
        };
        class BatteryGroup: ctrlControlsGroupNoScrollBars
        {
            idc=1104;
            x=EVAL_UI((STATIC_SZ_X + (STATIC_SZ_W * 0.15)) + fnc_width(2));
            y=EVAL_UI((STATIC_SZ_Y) + (STATIC_SZ_H) - fnc_height(2) - fnc_height(8));
            w=EVAL_UI(fnc_width(8));
            h=EVAL_UI(fnc_height(2));
            class controls
            {
                class BatteryPicture: ctrlStaticPicture
                {
                    idc=241;
                    onLoad="uiNameSpace setVariable [""ArmaFPV_BatteryPicture"", _this # 0];";
                    text="\fpv_ua\pictures\A100.paa";
                    x=0;
                    y=0;
                    w=EVAL_UI(fnc_width(1));
                    h=EVAL_UI(fnc_height(1.8));
                };
                class BatteryText: ctrlStructuredText
                {
                    idc=369;
                    onLoad="uiNameSpace setVariable [""ArmaFPV_BatteryText"", _this # 0];";
                    class Attributes
                    {
                        font="VCROSDMono";
                        align="center";
                        shadow=1;
                    };
                    shadow=0;
                    size=EVAL_UI(fnc_height(1.3));
                    text="3.79 v";
                    x=0;
                    y=EVAL_UI(fnc_height(0.3));
                    w=EVAL_UI(fnc_width(8));
                    h=EVAL_UI(fnc_height(2));
                };
            };
        };
        class OnTime_Group: ctrlControlsGroupNoScrollBars
        {
            idc=1105;
            x=EVAL_UI((STATIC_SZ_X + (STATIC_SZ_W * 0.15)) + (STATIC_SZ_W - 2 * (STATIC_SZ_W * 0.15)) - fnc_width(6) - fnc_width(2));
            y=EVAL_UI((STATIC_SZ_Y) + (STATIC_SZ_H) - fnc_height(2) - fnc_height(8));
            w=EVAL_UI(fnc_width(10));
            h=EVAL_UI(fnc_height(2.5));
            class controls
            {
                class OnTime_Picture: ctrlStaticPicture
                {
                    idc=1106;
                    text="\fpv_ua\pictures\mn.paa";
                    x=0;
                    y=0;
                    w=EVAL_UI(fnc_width(6) / 2);
                    h=EVAL_UI(fnc_height(2));
                };
                class OnTime_Text: ctrlStructuredText
                {
                    idc=237;
                    onLoad="uiNameSpace setVariable [""ArmaFPV_OnTimeText"", _this # 0];";
                    class Attributes
                    {
                        font="VCROSDMono";
                        align="right";
                        shadow=1;
                    };
                    shadow=0;
                    size=EVAL_UI(fnc_height(1.4));
                    text="03:38";
                    x=0;
                    y=EVAL_UI(fnc_height(0.3));
                    w=EVAL_UI(fnc_width(6.5));
                    h=EVAL_UI(fnc_height(2));
                };
            };
        };
        class Center_target: ctrlStaticPicture
        {
            idc=1107;
            text="\fpv_ua\pictures\PRICEL.paa";
            x=EVAL_UI(0.5 - fnc_width(2) / 2);
            y=EVAL_UI(0.5 - fnc_height(2) / 2 + fnc_height(1.25));
            w=EVAL_UI(fnc_width(2));
            h=EVAL_UI(fnc_height(2));
        };
        class V_Line_Left: ctrlStaticPicture
        {
            idc=1108;
            text="\fpv_ua\pictures\horiz_empty.paa";
            x=EVAL_UI(0.5 + fnc_width(10));
            y=EVAL_UI(0.5 - fnc_height(12) / 2);
            w=EVAL_UI(fnc_width(1));
            h=EVAL_UI(fnc_height(12));
        };
        class V_Line_Right: V_Line_Left
        {
            idc=1109;
            x=EVAL_UI(0.5 - fnc_width(10));
        };
        class MainText: ctrlStructuredText
        {
            idc=1110;
            class Attributes
            {
                font="VCROSDMono";
                align="center";
                shadow=1;
            };
            shadow=0;
            size=EVAL_UI(fnc_height(1.4));
            onLoad="uiNameSpace setVariable [""ArmaFPV_MainText"", _this # 0];";
            text="";
            x=EVAL_UI((STATIC_SZ_X + (STATIC_SZ_W * 0.15)) + (STATIC_SZ_W - 2 * (STATIC_SZ_W * 0.15)) / 2 - fnc_width(20) / 2);
            y=EVAL_UI(0.5 - fnc_height(12) / 2 - fnc_height(1.6));
            w=EVAL_UI(fnc_width(20));
            h=EVAL_UI(fnc_height(1.6));
        };
        class AzimuthCompass: ctrlStaticPicture
        {
            idc=1111;
            text="\fpv_ua\pictures\vert.paa";
            x=EVAL_UI((STATIC_SZ_X + (STATIC_SZ_W * 0.15)) + ((STATIC_SZ_W - 2 * (STATIC_SZ_W * 0.15)) / 2) - (fnc_width(16) / 2));
            y=EVAL_UI(STATIC_SZ_Y + fnc_height(0.5));
            w=EVAL_UI(fnc_width(16));
            h=EVAL_UI(fnc_height(1.3));
        };
    };
		class controlsBackground
		{
			class R2TPicture: RscPicture
			{
				idc = 1488;
				onLoad = "uiNamespace setVariable [""DB_fpv_r2tPicture"", _this # 0];";
				text = "";
				x = EVAL_UI(STATIC_SZ_X);
				y = EVAL_UI(STATIC_SZ_Y);
				w = EVAL_UI(STATIC_SZ_W);
				h = EVAL_UI(STATIC_SZ_H);
				show = 1;
			};
			class EffectPicture1: R2TPicture
			{
				idc = 1489;
				onLoad = "uiNamespace setVariable [""DB_fpv_effectsPicture1"", _this # 0];";
				show = 1;
			};
			class EffectPicture2: R2TPicture
			{
				idc = 1490;
				onLoad = "uiNamespace setVariable [""DB_fpv_effectsPicture2"", _this # 0];";
				show = 1;
			};
		};
};
