
class CFM_Zala421_Interface_Driver
{
    duration=1e+010;
    movingEnable="false";
    enableSimulation="true";
    idd=2358;
    onLoad="uiNameSpace setVariable ['CFM_DB_zala421HUD_display_driver', _this # 0]; [_this select 0, 'CFM_Zala421_Interface_Driver'] call (missionNamespace getVariable ['CFM_fnc_repositionControls', {}]);";
    class controls
    {
        class CoordinateBox: InfoBox_Base
        {
            idc=825;
            x=EVAL_UI((STATIC_SZ_X + fnc_width(5)) + fnc_width(2.5) + fnc_width(8) + fnc_width(1) + fnc_width(0.5));
            y=EVAL_UI((STATIC_SZ_Y + fnc_height(2)) - fnc_height(1.5));
            w=EVAL_UI(fnc_width(12));
            class controls: controls
            {
                class WhiteBackGround: WhiteBackGround
                {
                    idc=1825;
                    w=EVAL_UI(fnc_width(12));
                };
                class TopBackGround: TopBackGround
                {
                    idc=2825;
                    w=EVAL_UI(fnc_width(12) - 2 * fnc_width(0.1));
                };
                class MainText: MainText
                {
                    idc=3825;
                    onLoad="uiNameSpace setVariable ['DB_zala421_HUD_coord_mainText', _this # 0]";
                    text="3535.85, 4887.42, 500";
                    w=EVAL_UI(fnc_width(12));
                };
            };
        };
        class BatteryBox: InfoBox_Base
        {
            idc=987;
            x=EVAL_UI((STATIC_SZ_X + fnc_width(5)) + fnc_width(2.5) + fnc_width(8) + fnc_width(12) + fnc_width(1) + 2 * fnc_width(0.5));
            y=EVAL_UI((STATIC_SZ_Y + fnc_height(2)) - fnc_height(1.5));
            w=EVAL_UI(fnc_width(8));
            class controls: controls
            {
                class WhiteBackGround: WhiteBackGround
                {
                    idc=1987;
                    w=EVAL_UI(fnc_width(8));
                };
                class TopBackGround: TopBackGround
                {
                    idc=2987;
                    w=EVAL_UI(fnc_width(8) - 2 * fnc_width(0.1));
                };
                class MainText: MainText
                {
                    idc=3987;
                    text="BATTERY: 100";
                    onLoad="uiNameSpace setVariable ['DB_zala421_HUD_fuel_mainText', _this # 0]";
                    w=EVAL_UI(fnc_width(8));
                };
            };
        };
        class AltitudeBox: InfoBox_Base
        {
            idc=956;
            x=EVAL_UI((STATIC_SZ_X + fnc_width(5)) + fnc_width(2.5) + 2 * fnc_width(8) + fnc_width(12) + fnc_width(1) + 3 * fnc_width(0.5));
            y=EVAL_UI((STATIC_SZ_Y + fnc_height(2)) - fnc_height(1.5));
            w=EVAL_UI(fnc_width(8));
            class controls: controls
            {
                class WhiteBackGround: WhiteBackGround
                {
                    idc=1956;
                    w=EVAL_UI(fnc_width(8));
                };
                class TopBackGround: TopBackGround
                {
                    idc=2956;
                    w=EVAL_UI(fnc_width(8) - 2 * fnc_width(0.1));
                };
                class MainText: MainText
                {
                    idc=3956;
                    text="ALT: 19";
                    onLoad="uiNameSpace setVariable ['DB_zala421_HUD_alt_mainText', _this # 0]";
                    w=EVAL_UI(fnc_width(8));
                };
            };
        };
        class StatusBox: InfoBox_Base
        {
            idc=125;
            x=EVAL_UI((STATIC_SZ_X + fnc_width(5)) + fnc_width(2.5) + 3 * fnc_width(8) + fnc_width(12) + fnc_width(1) + 4 * fnc_width(0.5));
            y=EVAL_UI((STATIC_SZ_Y + fnc_height(2)) - fnc_height(1.5));
            w=EVAL_UI(fnc_width(12));
            class controls: controls
            {
                class WhiteBackGround: WhiteBackGround
                {
                    idc=1125;
                    w=EVAL_UI(fnc_width(12));
                };
                class TopBackGround: TopBackGround
                {
                    idc=2125;
                    w=EVAL_UI(fnc_width(12) - 2 * fnc_width(0.1));
                };
                class MainText: MainText
                {
                    idc=3125;
                    text="STATUS: OPERATIONAL";
                    onLoad="uiNameSpace setVariable ['DB_zala421_HUD_status_mainText', _this # 0]";
                    w=EVAL_UI(fnc_width(12));
                };
            };
        };
        class DroneSpeedBox: InfoBox_Base
        {
            idc=127;
            x=EVAL_UI((STATIC_SZ_X + fnc_width(5)) + fnc_width(2.5) + fnc_width(8) + fnc_width(1) - fnc_width(12));
            y=EVAL_UI((STATIC_SZ_Y + fnc_height(2)) - fnc_height(1.5));
            w=EVAL_UI(fnc_width(12));
            class controls: controls
            {
                class WhiteBackGround: WhiteBackGround
                {
                    idc=1127;
                    w=EVAL_UI(fnc_width(12));
                };
                class TopBackGround: TopBackGround
                {
                    idc=2127;
                    w=EVAL_UI(fnc_width(12) - 2 * fnc_width(0.1));
                };
                class MainText: MainText
                {
                    idc=3127;
                    onLoad="uiNameSpace setVariable ['DB_zala421_HUD_droneSpeed_mainText', _this # 0]";
                    text="СКОРОСТЬ: 120 КМ/Ч";
                    w=EVAL_UI(fnc_width(12));
                };
            };
        };
        class PitchBox: InfoBox_Base
        {
            idc=121;
            x=EVAL_UI((STATIC_SZ_X + fnc_width(5)) + fnc_width(2.5) + fnc_width(8) + fnc_width(1) - fnc_width(12));
            y=EVAL_UI((STATIC_SZ_Y + fnc_height(2)) - fnc_height(1.5) + fnc_height(1.5) + fnc_height(0.4));
            w=EVAL_UI(fnc_width(12));
            class controls: controls
            {
                class WhiteBackGround: WhiteBackGround
                {
                    idc=1121;
                    w=EVAL_UI(fnc_width(12));
                };
                class TopBackGround: TopBackGround
                {
                    idc=2121;
                    w=EVAL_UI(fnc_width(12) - 2 * fnc_width(0.1));
                };
                class MainText: MainText
                {
                    idc=3121;
                    text="ТАНГАЖ: 75 г.";
                    onLoad="uiNameSpace setVariable ['DB_zala421_HUD_pitch_mainText', _this # 0]";
                    w=EVAL_UI(fnc_width(12));
                };
            };
        };
    };
	class controlsBackground
	{
		class R2TPicture: RscPicture
		{
			idc = 1488;
			onLoad = "uiNamespace setVariable [""DB_zala_r2tPicture"", _this # 0];";
			text = "";
			x = EVAL_UI(STATIC_SZ_X);
			y = EVAL_UI(STATIC_SZ_Y);
			w = EVAL_UI(STATIC_SZ_W);
			h = EVAL_UI(STATIC_SZ_H);
			show = 1;
		};
		class EffectPicture: R2TPicture
		{
			idc = 1489;
			onLoad = "uiNamespace setVariable [""DB_zala_effectPicture"", _this # 0];";
			show = 0;
		};
	};
};
