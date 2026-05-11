
class CFM_Zala421_Interface_Driver
{
    duration=1e+010;
    movingEnable="false";
    enableSimulation="true";
    idd=2358;
    onLoad="uiNameSpace setVariable ['CFM_DB_zala421HUD_display_driver', _this # 0]";
    class controls
    {
        class CoordinateBox: InfoBox_Base
        {
            idc=825;
            x="( safeZoneX + ( 5 * ( pixelGridNoUIScale * pixelW * 2 )) ) + ( ( 2.5 * ( pixelGridNoUIScale * pixelW * 2 )) ) + ( 8 * ( pixelGridNoUIScale * pixelW * 2 )) + ( 1 * ( pixelGridNoUIScale * pixelW * 2 )) + ( 0.5 * ( pixelGridNoUIScale * pixelW * 2 ))";
            y="( safeZoneY + ( 2 * ( pixelGridNoUIScale * pixelH * 2 )) ) - ( ( 1.5 * ( pixelGridNoUIScale * pixelH * 2 )) )";
            w="( 12 * ( pixelGridNoUIScale * pixelW * 2 ))";
            class controls: controls
            {
                class WhiteBackGround: WhiteBackGround
                {
                    w="( 12 * ( pixelGridNoUIScale * pixelW * 2 ))";
                };
                class TopBackGround: TopBackGround
                {
                    w="( 12 * ( pixelGridNoUIScale * pixelW * 2 )) - 2*( ( 0.1 * ( pixelGridNoUIScale * pixelW * 2 )) )";
                };
                class MainText: MainText
                {
                    idc=825;
                    onLoad="uiNameSpace setVariable ['DB_zala421_HUD_coord_mainText', _this # 0]";
                    text="3535.85, 4887.42, 500";
                    w="( 12 * ( pixelGridNoUIScale * pixelW * 2 ))";
                };
            };
        };
        class BatteryBox: InfoBox_Base
        {
            idc=987;
            x="( safeZoneX + ( 5 * ( pixelGridNoUIScale * pixelW * 2 )) ) + ( ( 2.5 * ( pixelGridNoUIScale * pixelW * 2 )) ) + ( 8 * ( pixelGridNoUIScale * pixelW * 2 )) + ( 12 * ( pixelGridNoUIScale * pixelW * 2 )) + ( 1 * ( pixelGridNoUIScale * pixelW * 2 )) + 2*( 0.5 * ( pixelGridNoUIScale * pixelW * 2 ))";
            y="( safeZoneY + ( 2 * ( pixelGridNoUIScale * pixelH * 2 )) ) - ( ( 1.5 * ( pixelGridNoUIScale * pixelH * 2 )) )";
            w="( 8 * ( pixelGridNoUIScale * pixelW * 2 ))";
            class controls: controls
            {
                class WhiteBackGround: WhiteBackGround
                {
                    w="( 8 * ( pixelGridNoUIScale * pixelW * 2 ))";
                };
                class TopBackGround: TopBackGround
                {
                    w="( 8 * ( pixelGridNoUIScale * pixelW * 2 )) - 2*( ( 0.1 * ( pixelGridNoUIScale * pixelW * 2 )) )";
                };
                class MainText: MainText
                {
                    idc=987;
                    text="BATTERY: 100";
                    onLoad="uiNameSpace setVariable ['DB_zala421_HUD_fuel_mainText', _this # 0]";
                    w="( 8 * ( pixelGridNoUIScale * pixelW * 2 ))";
                };
            };
        };
        class AltitudeBox: InfoBox_Base
        {
            idc=956;
            x="( safeZoneX + ( 5 * ( pixelGridNoUIScale * pixelW * 2 )) ) + ( ( 2.5 * ( pixelGridNoUIScale * pixelW * 2 )) ) + 2*( 8 * ( pixelGridNoUIScale * pixelW * 2 )) + ( 12 * ( pixelGridNoUIScale * pixelW * 2 )) + ( 1 * ( pixelGridNoUIScale * pixelW * 2 )) + 3*( 0.5 * ( pixelGridNoUIScale * pixelW * 2 ))";
            y="( safeZoneY + ( 2 * ( pixelGridNoUIScale * pixelH * 2 )) ) - ( ( 1.5 * ( pixelGridNoUIScale * pixelH * 2 )) )";
            w="( 8 * ( pixelGridNoUIScale * pixelW * 2 ))";
            class controls: controls
            {
                class WhiteBackGround: WhiteBackGround
                {
                    w="( 8 * ( pixelGridNoUIScale * pixelW * 2 ))";
                };
                class TopBackGround: TopBackGround
                {
                    w="( 8 * ( pixelGridNoUIScale * pixelW * 2 )) - 2*( ( 0.1 * ( pixelGridNoUIScale * pixelW * 2 )) )";
                };
                class MainText: MainText
                {
                    idc=956;
                    text="ALT: 19";
                    onLoad="uiNameSpace setVariable ['DB_zala421_HUD_alt_mainText', _this # 0]";
                    w="( 8 * ( pixelGridNoUIScale * pixelW * 2 ))";
                };
            };
        };
        class StatusBox: InfoBox_Base
        {
            idc=125;
            x="( safeZoneX + ( 5 * ( pixelGridNoUIScale * pixelW * 2 )) ) + ( ( 2.5 * ( pixelGridNoUIScale * pixelW * 2 )) ) + 3*( 8 * ( pixelGridNoUIScale * pixelW * 2 )) + ( 12 * ( pixelGridNoUIScale * pixelW * 2 )) + ( 1 * ( pixelGridNoUIScale * pixelW * 2 )) + 4*( 0.5 * ( pixelGridNoUIScale * pixelW * 2 ))";
            y="( safeZoneY + ( 2 * ( pixelGridNoUIScale * pixelH * 2 )) ) - ( ( 1.5 * ( pixelGridNoUIScale * pixelH * 2 )) )";
            w="( 12 * ( pixelGridNoUIScale * pixelW * 2 ))";
            class controls: controls
            {
                class WhiteBackGround: WhiteBackGround
                {
                    w="( 12 * ( pixelGridNoUIScale * pixelW * 2 ))";
                };
                class TopBackGround: TopBackGround
                {
                    w="( 12 * ( pixelGridNoUIScale * pixelW * 2 )) - 2*( ( 0.1 * ( pixelGridNoUIScale * pixelW * 2 )) )";
                };
                class MainText: MainText
                {
                    idc=125;
                    text="STATUS: OPERATIONAL";
                    onLoad="uiNameSpace setVariable ['DB_zala421_HUD_status_mainText', _this # 0]";
                    w="( 12 * ( pixelGridNoUIScale * pixelW * 2 ))";
                };
            };
        };
        class DroneSpeedBox: InfoBox_Base
        {
            idc=127;
            x="( safeZoneX + ( 5 * ( pixelGridNoUIScale * pixelW * 2 )) ) + ( ( 2.5 * ( pixelGridNoUIScale * pixelW * 2 )) ) + ( 8 * ( pixelGridNoUIScale * pixelW * 2 )) + ( 1 * ( pixelGridNoUIScale * pixelW * 2 )) - ( 12 * ( pixelGridNoUIScale * pixelW * 2 ))";
            y="( safeZoneY + ( 2 * ( pixelGridNoUIScale * pixelH * 2 )) ) - ( ( 1.5 * ( pixelGridNoUIScale * pixelH * 2 )) )";
            w="( 12 * ( pixelGridNoUIScale * pixelW * 2 ))";
            class controls: controls
            {
                class WhiteBackGround: WhiteBackGround
                {
                    w="( 12 * ( pixelGridNoUIScale * pixelW * 2 ))";
                };
                class TopBackGround: TopBackGround
                {
                    w="( 12 * ( pixelGridNoUIScale * pixelW * 2 )) - 2*( ( 0.1 * ( pixelGridNoUIScale * pixelW * 2 )) )";
                };
                class MainText: MainText
                {
                    idc=127;
                    onLoad="uiNameSpace setVariable ['DB_zala421_HUD_droneSpeed_mainText', _this # 0]";
                    text="РЎРљРћР РћРЎРўР¬: 120 РљРњ/Р§";
                    w="( 12 * ( pixelGridNoUIScale * pixelW * 2 ))";
                };
            };
        };
        class PitchBox: InfoBox_Base
        {
            idc=121;
            x="( safeZoneX + ( 5 * ( pixelGridNoUIScale * pixelW * 2 )) ) + ( ( 2.5 * ( pixelGridNoUIScale * pixelW * 2 )) ) + ( 8 * ( pixelGridNoUIScale * pixelW * 2 )) + ( 1 * ( pixelGridNoUIScale * pixelW * 2 )) - ( 12 * ( pixelGridNoUIScale * pixelW * 2 ))";
            y="( safeZoneY + ( 2 * ( pixelGridNoUIScale * pixelH * 2 )) ) - ( ( 1.5 * ( pixelGridNoUIScale * pixelH * 2 )) )  + ( ( 1.5 * ( pixelGridNoUIScale * pixelH * 2 )) ) + ( 0.4 * ( pixelGridNoUIScale * pixelH * 2 ))";
            w="( 12 * ( pixelGridNoUIScale * pixelW * 2 ))";
            class controls: controls
            {
                class WhiteBackGround: WhiteBackGround
                {
                    w="( 12 * ( pixelGridNoUIScale * pixelW * 2 ))";
                };
                class TopBackGround: TopBackGround
                {
                    w="( 12 * ( pixelGridNoUIScale * pixelW * 2 )) - 2*( ( 0.1 * ( pixelGridNoUIScale * pixelW * 2 )) )";
                };
                class MainText: MainText
                {
                    idc=121;
                    text="РўРђРќР“РђР–: 75 Рі.";
                    onLoad="uiNameSpace setVariable ['DB_zala421_HUD_pitch_mainText', _this # 0]";
                    w="( 12 * ( pixelGridNoUIScale * pixelW * 2 ))";
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