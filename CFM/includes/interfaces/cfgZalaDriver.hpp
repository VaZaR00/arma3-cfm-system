
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
            x=EVAL_UI(( STATIC_SZ_X + ( 5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ) + ( ( 2.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ) + ( 8 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + ( 1 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + ( 0.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
            y=EVAL_UI(( STATIC_SZ_Y + ( 2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) ) - ( ( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) ));
            w=EVAL_UI(( 12 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
            class controls: controls
            {
                class WhiteBackGround: WhiteBackGround
                {
                    w=EVAL_UI(( 12 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
                };
                class TopBackGround: TopBackGround
                {
                    w=EVAL_UI(( 12 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) - 2*( ( 0.1 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ));
                };
                class MainText: MainText
                {
                    idc=825;
                    onLoad="uiNameSpace setVariable ['DB_zala421_HUD_coord_mainText', _this # 0]";
                    text="3535.85, 4887.42, 500";
                    w=EVAL_UI(( 12 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
                };
            };
        };
        class BatteryBox: InfoBox_Base
        {
            idc=987;
            x=EVAL_UI(( STATIC_SZ_X + ( 5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ) + ( ( 2.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ) + ( 8 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + ( 12 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + ( 1 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + 2*( 0.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
            y=EVAL_UI(( STATIC_SZ_Y + ( 2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) ) - ( ( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) ));
            w=EVAL_UI(( 8 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
            class controls: controls
            {
                class WhiteBackGround: WhiteBackGround
                {
                    w=EVAL_UI(( 8 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
                };
                class TopBackGround: TopBackGround
                {
                    w=EVAL_UI(( 8 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) - 2*( ( 0.1 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ));
                };
                class MainText: MainText
                {
                    idc=987;
                    text="BATTERY: 100";
                    onLoad="uiNameSpace setVariable ['DB_zala421_HUD_fuel_mainText', _this # 0]";
                    w=EVAL_UI(( 8 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
                };
            };
        };
        class AltitudeBox: InfoBox_Base
        {
            idc=956;
            x=EVAL_UI(( STATIC_SZ_X + ( 5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ) + ( ( 2.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ) + 2*( 8 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + ( 12 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + ( 1 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + 3*( 0.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
            y=EVAL_UI(( STATIC_SZ_Y + ( 2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) ) - ( ( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) ));
            w=EVAL_UI(( 8 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
            class controls: controls
            {
                class WhiteBackGround: WhiteBackGround
                {
                    w=EVAL_UI(( 8 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
                };
                class TopBackGround: TopBackGround
                {
                    w=EVAL_UI(( 8 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) - 2*( ( 0.1 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ));
                };
                class MainText: MainText
                {
                    idc=956;
                    text="ALT: 19";
                    onLoad="uiNameSpace setVariable ['DB_zala421_HUD_alt_mainText', _this # 0]";
                    w=EVAL_UI(( 8 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
                };
            };
        };
        class StatusBox: InfoBox_Base
        {
            idc=125;
            x=EVAL_UI(( STATIC_SZ_X + ( 5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ) + ( ( 2.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ) + 3*( 8 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + ( 12 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + ( 1 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + 4*( 0.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
            y=EVAL_UI(( STATIC_SZ_Y + ( 2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) ) - ( ( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) ));
            w=EVAL_UI(( 12 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
            class controls: controls
            {
                class WhiteBackGround: WhiteBackGround
                {
                    w=EVAL_UI(( 12 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
                };
                class TopBackGround: TopBackGround
                {
                    w=EVAL_UI(( 12 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) - 2*( ( 0.1 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ));
                };
                class MainText: MainText
                {
                    idc=125;
                    text="STATUS: OPERATIONAL";
                    onLoad="uiNameSpace setVariable ['DB_zala421_HUD_status_mainText', _this # 0]";
                    w=EVAL_UI(( 12 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
                };
            };
        };
        class DroneSpeedBox: InfoBox_Base
        {
            idc=127;
            x=EVAL_UI(( STATIC_SZ_X + ( 5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ) + ( ( 2.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ) + ( 8 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + ( 1 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) - ( 12 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
            y=EVAL_UI(( STATIC_SZ_Y + ( 2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) ) - ( ( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) ));
            w=EVAL_UI(( 12 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
            class controls: controls
            {
                class WhiteBackGround: WhiteBackGround
                {
                    w=EVAL_UI(( 12 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
                };
                class TopBackGround: TopBackGround
                {
                    w=EVAL_UI(( 12 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) - 2*( ( 0.1 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ));
                };
                class MainText: MainText
                {
                    idc=127;
                    onLoad="uiNameSpace setVariable ['DB_zala421_HUD_droneSpeed_mainText', _this # 0]";
                    text="СКОРОСТЬ: 120 КМ/Ч";
                    w=EVAL_UI(( 12 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
                };
            };
        };
        class PitchBox: InfoBox_Base
        {
            idc=121;
            x=EVAL_UI(( STATIC_SZ_X + ( 5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ) + ( ( 2.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ) + ( 8 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + ( 1 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) - ( 12 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
            y=EVAL_UI(( STATIC_SZ_Y + ( 2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) ) - ( ( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) )  + ( ( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) ) + ( 0.4 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
            w=EVAL_UI(( 12 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
            class controls: controls
            {
                class WhiteBackGround: WhiteBackGround
                {
                    w=EVAL_UI(( 12 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
                };
                class TopBackGround: TopBackGround
                {
                    w=EVAL_UI(( 12 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) - 2*( ( 0.1 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ));
                };
                class MainText: MainText
                {
                    idc=121;
                    text="ТАНГАЖ: 75 г.";
                    onLoad="uiNameSpace setVariable ['DB_zala421_HUD_pitch_mainText', _this # 0]";
                    w=EVAL_UI(( 12 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
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