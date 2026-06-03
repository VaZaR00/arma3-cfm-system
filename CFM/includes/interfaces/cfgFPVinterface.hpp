
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
            x=EVAL_UI(STATIC_SZ_X);
            y=EVAL_UI(STATIC_SZ_Y);
            w=EVAL_UI((STATIC_SZ_W * 0.15));
            h=EVAL_UI((STATIC_SZ_H));
            colorBackground[]={0,0,0,1};
        };
        class RightLine: LeftLine
        {
            x=EVAL_UI(STATIC_SZ_X + STATIC_SZ_W - (STATIC_SZ_W * 0.15));
        };
        class CommunicationGroup: ctrlControlsGroupNoScrollBars
        {
            idc=-1;
            x=EVAL_UI((STATIC_SZ_X + (STATIC_SZ_W * 0.15)) + (STATIC_SZ_W - 2*(STATIC_SZ_W * 0.15)) - ( 6 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) - ( 2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
            y=EVAL_UI((STATIC_SZ_Y) + ( 6 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
            w=EVAL_UI(( 6 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
            h=EVAL_UI(( 2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
            class controls
            {
                class CommunicationPicture: ctrlStaticPicture
                {
                    idc=825;
                    text="\fpv_ua\pictures\100.paa";
                    onLoad="uiNameSpace setVariable [""ArmaFPV_SignalPicture"", _this # 0];";
                    x=0;
                    y=EVAL_UI(0.0 + ( 2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) / 2 - ( 1 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) / 2);
                    w=EVAL_UI(( 3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) / 2);
                    h=EVAL_UI(( 1 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
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
                    size=EVAL_UI(( 1.8 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
                    text="27";
                    x=0;
                    y=0;
                    w=EVAL_UI(( 6 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
                    h=EVAL_UI(( 2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
                };
            };
        };
        class BatteryGroup: ctrlControlsGroupNoScrollBars
        {
            idc=-1;
            x=EVAL_UI((STATIC_SZ_X + (STATIC_SZ_W * 0.15)) + ( 2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
            y=EVAL_UI((STATIC_SZ_Y) + (STATIC_SZ_H) - ( 2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) - ( 8 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
            w=EVAL_UI(( 8 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
            h=EVAL_UI(( 2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
            class controls
            {
                class BatteryPicture: ctrlStaticPicture
                {
                    idc=241;
                    onLoad="uiNameSpace setVariable [""ArmaFPV_BatteryPicture"", _this # 0];";
                    text="\fpv_ua\pictures\A100.paa";
                    x=0;
                    y=0;
                    w=EVAL_UI(( 1 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
                    h=EVAL_UI(( 1.8 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
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
                    size=EVAL_UI(( 1.3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
                    text="3.79 v";
                    x=0;
                    y=EVAL_UI(( 0.3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
                    w=EVAL_UI(( 8 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
                    h=EVAL_UI(( 2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
                };
            };
        };
        class OnTime_Group: ctrlControlsGroupNoScrollBars
        {
            idc=-1;
            x=EVAL_UI((STATIC_SZ_X + (STATIC_SZ_W * 0.15)) + (STATIC_SZ_W - 2*(STATIC_SZ_W * 0.15)) - ( 6 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) - ( 2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
            y=EVAL_UI((STATIC_SZ_Y) + (STATIC_SZ_H) - ( 2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) - ( 8 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
            w=EVAL_UI(( 10 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
            h=EVAL_UI(( 2.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
            class controls
            {
                class OnTime_Picture: ctrlStaticPicture
                {
                    idc=-1;
                    text="\fpv_ua\pictures\mn.paa";
                    x=0;
                    y=0;
                    w=EVAL_UI(( 6 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) / 2);
                    h=EVAL_UI(( 2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
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
                    size=EVAL_UI(( 1.4 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
                    text="03:38";
                    x=0;
                    y=EVAL_UI(( 0.3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
                    w=EVAL_UI(( 6.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
                    h=EVAL_UI(( 2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
                };
            };
        };
        class Center_target: ctrlStaticPicture
        {
            idc=-1;
            text="\fpv_ua\pictures\PRICEL.paa";
            x=EVAL_UI(0.5 - ( 2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) / 2);
            y=EVAL_UI(0.5 - ( 2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) / 2 + ( 1.25 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
            w=EVAL_UI(( 2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
            h=EVAL_UI(( 2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
        };
        class V_Line_Left: ctrlStaticPicture
        {
            idc=-1;
            text="\fpv_ua\pictures\horiz_empty.paa";
            x=EVAL_UI(0.5 + ( 10 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
            y=EVAL_UI(0.5 - ( 12 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) / 2);
            w=EVAL_UI(( 1 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
            h=EVAL_UI(( 12 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
        };
        class V_Line_Right: V_Line_Left
        {
            x=EVAL_UI(0.5 - ( 10 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
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
            size=EVAL_UI(( 1.4 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
            onLoad="uiNameSpace setVariable [""ArmaFPV_MainText"", _this # 0];";
            text="";
            x=EVAL_UI((STATIC_SZ_X + (STATIC_SZ_W * 0.15)) + (STATIC_SZ_W - 2*(STATIC_SZ_W * 0.15)) / 2 - ( 20 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) / 2);
            y=EVAL_UI(0.5 - ( 12 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) / 2 - ( 1.6 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
            w=EVAL_UI(( 20 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
            h=EVAL_UI(( 1.6 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
        };
        class AzimuthCompass: ctrlStaticPicture
        {
            idc=-1;
            text="\fpv_ua\pictures\vert.paa";
            x=EVAL_UI((STATIC_SZ_X + (STATIC_SZ_W * 0.15)) + ((STATIC_SZ_W - 2 * (STATIC_SZ_W * 0.15)) / 2) - ((16 * (STATIC_GRID_SCALE * STATIC_PIXEL_W * 2)) / 2));
            y=EVAL_UI(STATIC_SZ_Y + (0.5 * (STATIC_GRID_SCALE * STATIC_PIXEL_H * 2)));
            w=EVAL_UI((16 * (STATIC_GRID_SCALE * STATIC_PIXEL_W * 2)));
            h=EVAL_UI((1.3 * (STATIC_GRID_SCALE * STATIC_PIXEL_H * 2)));
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