
class CFM_Zala421_Interface_Gunner
{
    idd=2357;
    duration=1e+010;
    onLoad="uiNameSpace setVariable ['CFM_DB_zala421HUD_display_gunner', _this # 0]";
    class controls
    {
        class Square_X: Zala16_UI_BaseBox
        {
            onLoad="uiNameSpace setVariable [""DB_zala421_squareX_HUD"", _this # 0]";
            idc=237;
            x="safeZoneX + ( 1.5 * ( pixelGridNoUIScale * pixelW * 2 ))";
            y="safeZoneY + ( 1.2 * ( pixelGridNoUIScale * pixelH * 2 ))";
            w="( 8 * ( pixelGridNoUIScale * pixelW * 2 ))";
            class controls: controls
            {
                class BackGround: BackGround
                {
                    w="( 8 * ( pixelGridNoUIScale * pixelW * 2 ))";
                };
                class Text: Text
                {
                    text="РљР’ X";
                    w="( 8 * ( pixelGridNoUIScale * pixelW * 2 ))";
                };
            };
        };
        class Square_Y: Zala16_UI_BaseBox
        {
            onLoad="uiNameSpace setVariable [""DB_zala421_squareY_HUD"", _this # 0]";
            idc=825;
            x="safeZoneX + ( 1.5 * ( pixelGridNoUIScale * pixelW * 2 ))";
            y="safeZoneY + ( 1.2 * ( pixelGridNoUIScale * pixelH * 2 )) + ( ( 1.4 * ( pixelGridNoUIScale * pixelH * 2 )) )";
            w="( 8 * ( pixelGridNoUIScale * pixelW * 2 ))";
            class controls: controls
            {
                class BackGround: BackGround
                {
                    w="( 8 * ( pixelGridNoUIScale * pixelW * 2 ))";
                };
                class Text: Text
                {
                    text="РљР’ Y";
                    w="( 8 * ( pixelGridNoUIScale * pixelW * 2 ))";
                };
            };
        };
        class Laser: Zala16_UI_BaseBox
        {
            onLoad="uiNameSpace setVariable [""DB_zala421_laser_HUD"", _this # 0]";
            idc=836;
            x="safeZoneX + ( 1.5 * ( pixelGridNoUIScale * pixelW * 2 ))";
            y="safeZoneY + ( 1.2 * ( pixelGridNoUIScale * pixelH * 2 )) + 2*( ( 1.4 * ( pixelGridNoUIScale * pixelH * 2 )) )";
            w="( 8 * ( pixelGridNoUIScale * pixelW * 2 ))";
            class controls: controls
            {
                class BackGround: BackGround
                {
                    w="( 8 * ( pixelGridNoUIScale * pixelW * 2 ))";
                };
                class Text: Text
                {
                    text="Р›РђР—Р•Р ";
                    w="( 8 * ( pixelGridNoUIScale * pixelW * 2 ))";
                };
            };
        };
        class Speed: Zala16_UI_BaseBox
        {
            onLoad="uiNameSpace setVariable [""DB_zala421_speed_HUD"", _this # 0]";
            idc=369;
            x="safeZoneX + ( 1.5 * ( pixelGridNoUIScale * pixelW * 2 ))";
            y="safeZoneY + ( 1.2 * ( pixelGridNoUIScale * pixelH * 2 )) + 3*( ( 1.4 * ( pixelGridNoUIScale * pixelH * 2 )) )";
            w="( 8 * ( pixelGridNoUIScale * pixelW * 2 ))";
            class controls: controls
            {
                class BackGround: BackGround
                {
                    w="( 8 * ( pixelGridNoUIScale * pixelW * 2 ))";
                };
                class Text: Text
                {
                    text="РЎРљРћР ";
                    w="( 8 * ( pixelGridNoUIScale * pixelW * 2 ))";
                };
            };
        };
        class Height: Zala16_UI_BaseBox
        {
            onLoad="uiNameSpace setVariable [""DB_zala421_height_HUD"", _this # 0]";
            idc=241;
            x="safeZoneX + ( 1.5 * ( pixelGridNoUIScale * pixelW * 2 ))";
            y="safeZoneY + ( 1.2 * ( pixelGridNoUIScale * pixelH * 2 )) + 4*( ( 1.4 * ( pixelGridNoUIScale * pixelH * 2 )) )";
            w="( 6 * ( pixelGridNoUIScale * pixelW * 2 ))";
            class controls: controls
            {
                class BackGround: BackGround
                {
                    w="( 6 * ( pixelGridNoUIScale * pixelW * 2 ))";
                };
                class Text: Text
                {
                    text="Р’Р«РЎ";
                    w="( 6 * ( pixelGridNoUIScale * pixelW * 2 ))";
                };
            };
        };
        class Direction: Zala16_UI_BaseBox
        {
            onLoad="uiNameSpace setVariable [""DB_zala421_direction_HUD"", _this # 0]";
            idc=398;
            x="safeZoneX + ( 1.5 * ( pixelGridNoUIScale * pixelW * 2 ))";
            y="safeZoneY + ( 1.2 * ( pixelGridNoUIScale * pixelH * 2 )) + 5*( ( 1.4 * ( pixelGridNoUIScale * pixelH * 2 )) )";
            w="( 6 * ( pixelGridNoUIScale * pixelW * 2 ))";
            class controls: controls
            {
                class BackGround: BackGround
                {
                    w="( 6 * ( pixelGridNoUIScale * pixelW * 2 ))";
                };
                class Text: Text
                {
                    text="РљРЈР РЎ";
                    w="( 6 * ( pixelGridNoUIScale * pixelW * 2 ))";
                };
            };
        };
        class Temperature: Zala16_UI_BaseBox
        {
            onLoad="uiNameSpace setVariable [""DB_zala421_temperature_HUD"", _this # 0]";
            idc=375;
            x="safeZoneX + ( 1.5 * ( pixelGridNoUIScale * pixelW * 2 ))";
            y="safeZoneY + ( 1.2 * ( pixelGridNoUIScale * pixelH * 2 )) + 6*( ( 1.4 * ( pixelGridNoUIScale * pixelH * 2 )) )";
            w="( 4 * ( pixelGridNoUIScale * pixelW * 2 ))";
            class controls: controls
            {
                class BackGround: BackGround
                {
                    w="( 4 * ( pixelGridNoUIScale * pixelW * 2 ))";
                };
                class Text: Text
                {
                    text="Рў";
                    w="( 4 * ( pixelGridNoUIScale * pixelW * 2 ))";
                };
            };
        };
        class Date: Zala16_UI_BaseBox
        {
            onLoad="uiNameSpace setVariable [""DB_zala421_date_HUD"", _this # 0]";
            idc=203;
            x="safeZoneX + ( 1.5 * ( pixelGridNoUIScale * pixelW * 2 ))";
            y="safeZoneY + ( 1.2 * ( pixelGridNoUIScale * pixelH * 2 )) + 6*( ( 1.4 * ( pixelGridNoUIScale * pixelH * 2 )) )  + ( 4 * ( pixelGridNoUIScale * pixelH * 2 ))";
            w="( 6.5 * ( pixelGridNoUIScale * pixelW * 2 ))";
            class controls: controls
            {
                class BackGround: BackGround
                {
                    w="( 6.5 * ( pixelGridNoUIScale * pixelW * 2 ))";
                };
                class Text: Text
                {
                    text="14/05/19";
                    w="( 6.5 * ( pixelGridNoUIScale * pixelW * 2 ))";
                };
            };
        };
        class Time: Zala16_UI_BaseBox
        {
            onLoad="uiNameSpace setVariable [""DB_zala421_time_HUD"", _this # 0]";
            idc=265;
            x="safeZoneX + ( 1.5 * ( pixelGridNoUIScale * pixelW * 2 ))";
            y="safeZoneY + ( 1.2 * ( pixelGridNoUIScale * pixelH * 2 )) + 7*( ( 1.4 * ( pixelGridNoUIScale * pixelH * 2 )) )  + ( 4 * ( pixelGridNoUIScale * pixelH * 2 ))";
            w="( 6.5 * ( pixelGridNoUIScale * pixelW * 2 ))";
            class controls: controls
            {
                class BackGround: BackGround
                {
                    w="( 6.5 * ( pixelGridNoUIScale * pixelW * 2 ))";
                };
                class Text: Text
                {
                    text="02:22:41";
                    w="( 6.5 * ( pixelGridNoUIScale * pixelW * 2 ))";
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
			x = "safeZoneXAbs";
			y = "safeZoneY";
			w = "safeZoneWAbs";
			h = "safeZoneH";
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