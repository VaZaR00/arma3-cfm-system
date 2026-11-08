
class CFM_Zala421_Interface_Gunner
{
    idd=2357;
    duration=1e+010;
    onLoad="uiNameSpace setVariable ['CFM_DB_zala421HUD_display_gunner', _this # 0]; [_this select 0, 'CFM_Zala421_Interface_Gunner'] call (missionNamespace getVariable ['CFM_fnc_repositionControls', {}]);";
    class controls
    {
        class Square_X: Zala16_UI_BaseBox
        {
            onLoad="uiNameSpace setVariable [""DB_zala421_squareX_HUD"", _this # 0]";
            idc=237;
            x=EVAL_UI(STATIC_SZ_X + fnc_width(1.5));
            y=EVAL_UI(STATIC_SZ_Y + fnc_height(1.2));
            w=EVAL_UI(fnc_width(8));
            class controls: controls
            {
                class BackGround: BackGround
                {
                    idc=1237;
                    w=EVAL_UI(fnc_width(8));
                };
                class Text: Text
                {
                    idc=2237;
                    text="РљР’ X";
                    w=EVAL_UI(fnc_width(8));
                };
            };
        };
        class Square_Y: Zala16_UI_BaseBox
        {
            onLoad="uiNameSpace setVariable [""DB_zala421_squareY_HUD"", _this # 0]";
            idc=825;
            x=EVAL_UI(STATIC_SZ_X + fnc_width(1.5));
            y=EVAL_UI(STATIC_SZ_Y + fnc_height(1.2) + fnc_height(1.4));
            w=EVAL_UI(fnc_width(8));
            class controls: controls
            {
                class BackGround: BackGround
                {
                    idc=1825;
                    w=EVAL_UI(fnc_width(8));
                };
                class Text: Text
                {
                    idc=2825;
                    text="РљР’ Y";
                    w=EVAL_UI(fnc_width(8));
                };
            };
        };
        class Laser: Zala16_UI_BaseBox
        {
            onLoad="uiNameSpace setVariable [""DB_zala421_laser_HUD"", _this # 0]";
            idc=836;
            x=EVAL_UI(STATIC_SZ_X + fnc_width(1.5));
            y=EVAL_UI(STATIC_SZ_Y + fnc_height(1.2) + 2 * fnc_height(1.4));
            w=EVAL_UI(fnc_width(8));
            class controls: controls
            {
                class BackGround: BackGround
                {
                    idc=1836;
                    w=EVAL_UI(fnc_width(8));
                };
                class Text: Text
                {
                    idc=2836;
                    text="Р›РђР—Р•Р ";
                    w=EVAL_UI(fnc_width(8));
                };
            };
        };
        class Speed: Zala16_UI_BaseBox
        {
            onLoad="uiNameSpace setVariable [""DB_zala421_speed_HUD"", _this # 0]";
            idc=369;
            x=EVAL_UI(STATIC_SZ_X + fnc_width(1.5));
            y=EVAL_UI(STATIC_SZ_Y + fnc_height(1.2) + 3 * fnc_height(1.4));
            w=EVAL_UI(fnc_width(8));
            class controls: controls
            {
                class BackGround: BackGround
                {
                    idc=1369;
                    w=EVAL_UI(fnc_width(8));
                };
                class Text: Text
                {
                    idc=2369;
                    text="РЎРљРћР ";
                    w=EVAL_UI(fnc_width(8));
                };
            };
        };
        class Height: Zala16_UI_BaseBox
        {
            onLoad="uiNameSpace setVariable [""DB_zala421_height_HUD"", _this # 0]";
            idc=241;
            x=EVAL_UI(STATIC_SZ_X + fnc_width(1.5));
            y=EVAL_UI(STATIC_SZ_Y + fnc_height(1.2) + 4 * fnc_height(1.4));
            w=EVAL_UI(fnc_width(6));
            class controls: controls
            {
                class BackGround: BackGround
                {
                    idc=1241;
                    w=EVAL_UI(fnc_width(6));
                };
                class Text: Text
                {
                    idc=2241;
                    text="Р’Р«РЎ";
                    w=EVAL_UI(fnc_width(6));
                };
            };
        };
        class Direction: Zala16_UI_BaseBox
        {
            onLoad="uiNameSpace setVariable [""DB_zala421_direction_HUD"", _this # 0]";
            idc=398;
            x=EVAL_UI(STATIC_SZ_X + fnc_width(1.5));
            y=EVAL_UI(STATIC_SZ_Y + fnc_height(1.2) + 5 * fnc_height(1.4));
            w=EVAL_UI(fnc_width(6));
            class controls: controls
            {
                class BackGround: BackGround
                {
                    idc=1398;
                    w=EVAL_UI(fnc_width(6));
                };
                class Text: Text
                {
                    idc=2398;
                    text="РљРЈР РЎ";
                    w=EVAL_UI(fnc_width(6));
                };
            };
        };
        class Temperature: Zala16_UI_BaseBox
        {
            onLoad="uiNameSpace setVariable [""DB_zala421_temperature_HUD"", _this # 0]";
            idc=375;
            x=EVAL_UI(STATIC_SZ_X + fnc_width(1.5));
            y=EVAL_UI(STATIC_SZ_Y + fnc_height(1.2) + 6 * fnc_height(1.4));
            w=EVAL_UI(fnc_width(4));
            class controls: controls
            {
                class BackGround: BackGround
                {
                    idc=1375;
                    w=EVAL_UI(fnc_width(4));
                };
                class Text: Text
                {
                    idc=2375;
                    text="Рў";
                    w=EVAL_UI(fnc_width(4));
                };
            };
        };
        class Date: Zala16_UI_BaseBox
        {
            onLoad="uiNameSpace setVariable [""DB_zala421_date_HUD"", _this # 0]";
            idc=203;
            x=EVAL_UI(STATIC_SZ_X + fnc_width(1.5));
            y=EVAL_UI(STATIC_SZ_Y + fnc_height(1.2) + 6 * fnc_height(1.4) + fnc_height(4));
            w=EVAL_UI(fnc_width(6.5));
            class controls: controls
            {
                class BackGround: BackGround
                {
                    idc=1203;
                    w=EVAL_UI(fnc_width(6.5));
                };
                class Text: Text
                {
                    idc=2203;
                    text="14/05/19";
                    w=EVAL_UI(fnc_width(6.5));
                };
            };
        };
        class Time: Zala16_UI_BaseBox
        {
            onLoad="uiNameSpace setVariable [""DB_zala421_time_HUD"", _this # 0]";
            idc=265;
            x=EVAL_UI(STATIC_SZ_X + fnc_width(1.5));
            y=EVAL_UI(STATIC_SZ_Y + fnc_height(1.2) + 7 * fnc_height(1.4) + fnc_height(4));
            w=EVAL_UI(fnc_width(6.5));
            class controls: controls
            {
                class BackGround: BackGround
                {
                    idc=1265;
                    w=EVAL_UI(fnc_width(6.5));
                };
                class Text: Text
                {
                    idc=2265;
                    text="02:22:41";
                    w=EVAL_UI(fnc_width(6.5));
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
