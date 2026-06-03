

class RscCFM_Mavic_Interface
{
	idd = 1589;
	duration = 2;
	class controls
	{
		class Camera_Button: ctrlStaticPicture
		{
			idc = -1;
			text = "\mavik\interface\main\camera.paa";
			x = EVAL_UI(STATIC_SZ_X + STATIC_SZ_W - ( 3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) / 2 - ( 2.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 ))/2 - ( ( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ));
			y = EVAL_UI(STATIC_SZ_Y + STATIC_SZ_H - ( 2.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) - ( ( 1.3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) ));
			w = EVAL_UI(( 2.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
			h = EVAL_UI(( 2.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
		};
		class Settings_Button: ctrlStaticPicture
		{
			idc = -1;
			text = "\mavik\interface\main\dots.paa";
			x = EVAL_UI(STATIC_SZ_X + STATIC_SZ_W - ( 3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) / 2 - ( 2.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 ))/2 - ( ( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ));
			y = EVAL_UI(STATIC_SZ_Y + ( ( 1.3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) ));
			w = EVAL_UI(( 2.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
			h = EVAL_UI(( 2.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
		};
		class Exit_Button: ctrlStaticPicture
		{
			idc = -1;
			text = "\mavik\interface\main\triangle.paa";
			x = EVAL_UI(STATIC_SZ_X + ( ( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ));
			y = EVAL_UI(STATIC_SZ_Y + ( ( 1.3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) ));
			w = EVAL_UI(( 2.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
			h = EVAL_UI(( 2.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
		};
		class FlightMode_Text: ctrlStructuredText
		{
			idc = -1;
			text = "$STR_mavic_fligtMode";
			x = EVAL_UI(STATIC_SZ_X + ( ( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ) + ( 2.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + ( 3.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
			y = EVAL_UI(STATIC_SZ_Y + ( ( 1.3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) )  + ( 0.3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
			w = EVAL_UI(( 5.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
			h = EVAL_UI(( 2.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
			size = EVAL_UI(( 1.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
			class Attributes
			{
				font = "PuristaMedium";
			};
		};
		class FlightStatus_Text: FlightMode_Text
		{
			idc = 824;
			text = "In Flight";
			onLoad = "uiNameSpace setVariable ['DB_mavic_FlightStatus_Text', _this # 0];";
			x = EVAL_UI(STATIC_SZ_X + ( ( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ) + ( 2.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + ( 3.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + 2*( 3.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
		};
		class Cross: ctrlStaticPicture
		{
			idc = -1;
			text = "\mavik\interface\main\kross.paa";
			x = EVAL_UI(0.5 - ( 5.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) / 2);
			y = EVAL_UI(0.5 - ( 5.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) / 2);
			w = EVAL_UI(( 5.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
			h = EVAL_UI(( 5.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
		};
		class MapTriangle_Button: ctrlStaticPicture
		{
			idc = -1;
			text = "\mavik\interface\main\maptriangle.paa";
			x = EVAL_UI(STATIC_SZ_X + ( ( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ));
			y = EVAL_UI(0.5 - ( 2.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
			w = EVAL_UI(( 2.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
			h = EVAL_UI(( 2.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
		};
		class RTH_Button: ctrlStaticPicture
		{
			idc = -1;
			text = "\mavik\interface\main\arrow.paa";
			x = EVAL_UI(STATIC_SZ_X + ( ( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ));
			y = EVAL_UI(0.5 + ( 2.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
			w = EVAL_UI(( 2.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
			h = EVAL_UI(( 2.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
		};
		class Record_Button: ctrlStaticPicture
		{
			idc = -1;
			text = "\mavik\interface\main\redcircle.paa";
			x = EVAL_UI(STATIC_SZ_X + STATIC_SZ_W - ( 3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) - ( ( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ));
			y = EVAL_UI(0.5 - ( 3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) / 2);
			w = EVAL_UI(( 3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
			h = EVAL_UI(( 3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
		};
		class Play_Button: ctrlStaticPicture
		{
			idc = -1;
			text = "\mavik\interface\main\play.paa";
			x = EVAL_UI(STATIC_SZ_X + STATIC_SZ_W - ( 3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) / 2 - ( 2.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 ))/2 - ( ( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ));
			y = EVAL_UI(0.5 - ( 2.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) / 2 + ( 3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) + ( ( 1.3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) ));
			w = EVAL_UI(( 2.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
			h = EVAL_UI(( 2.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
		};
		class Galery_Button: ctrlStaticPicture
		{
			idc = -1;
			text = "\mavik\interface\main\galery.paa";
			x = EVAL_UI(STATIC_SZ_X + STATIC_SZ_W - ( 3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) / 2 - ( 2.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 ))/2 - ( ( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ));
			y = EVAL_UI(0.5 - ( 2.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) / 2 - ( 3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) - ( ( 1.3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) ));
			w = EVAL_UI(( 2.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
			h = EVAL_UI(( 2.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
		};
		class Zoom_Display: ctrlStaticPicture
		{
			idc = -1;
			text = "\mavik\interface\zoom\zoom.paa";
			x = EVAL_UI(STATIC_SZ_X + STATIC_SZ_W - ( 3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) - ( 2.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) - 2*( ( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ));
			y = EVAL_UI(0.5 - ( 2.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) / 2);
			w = EVAL_UI(( 2.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
			h = EVAL_UI(( 2.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
		};
		class Zoom_Text: ctrlStructuredText
		{
			idc = 278;
			text = "4x";
			onLoad = "uiNameSpace setVariable ['DB_mavic_Zoom_Text', _this # 0];";
			x = EVAL_UI(STATIC_SZ_X + STATIC_SZ_W - ( 3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) - ( 2.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) - 2*( ( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ));
			y = EVAL_UI(0.5 - ( 2.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) / 2 + ( 0.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
			w = EVAL_UI(( 2.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
			h = EVAL_UI(( 2.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
			size = EVAL_UI(( 1.1 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
			class Attributes
			{
				align = "center";
				font = "PuristaSemiBold";
			};
		};
		class MemoryPicture: ctrlStaticPicture
		{
			idc = -1;
			text = "\mavik\interface\main\memory.paa";
			x = EVAL_UI(STATIC_SZ_X + STATIC_SZ_W - ( 3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) - ( 2.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) - 2*( ( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ));
			y = EVAL_UI(STATIC_SZ_Y + STATIC_SZ_H - ( 2.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) - ( ( 1.3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) ));
			w = EVAL_UI(( 2.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
			h = EVAL_UI(( 2.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
		};
		class AF_Button: ctrlStaticPicture
		{
			idc = -1;
			text = "\mavik\interface\zoom\AF.paa";
			x = EVAL_UI(STATIC_SZ_X + STATIC_SZ_W - ( 3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) - ( 2.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) - 2*( ( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ));
			y = EVAL_UI(0.5 - ( 2.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) / 2 + ( 2.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) + ( 0.05 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
			w = EVAL_UI(( 2.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
			h = EVAL_UI(( 2.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
		};
		class Binoc_Button: ctrlStaticPicture
		{
			idc = -1;
			text = "\mavik\interface\zoom\binocular.paa";
			x = EVAL_UI(STATIC_SZ_X + STATIC_SZ_W - ( 3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) - ( 2.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) - 2*( ( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ));
			y = EVAL_UI(0.5 - ( 2.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) / 2 - ( 2.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) - ( 0.3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
			w = EVAL_UI(( 2.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
			h = EVAL_UI(( 2.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
		};
		class UAVInfo_Group: ctrlControlsGroupNoScrollBars
		{
			idc = -1;
			x = EVAL_UI(STATIC_SZ_X + ( 0.8 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
			y = EVAL_UI(safezoneY + STATIC_SZ_H - ( 3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) - ( 0.4 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
			w = EVAL_UI(( 15 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
			h = EVAL_UI(( 3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
			class controls
			{
				class Map_Picture: ctrlStaticPicture
				{
					idc = -1;
					text = "\mavik\interface\main\map.paa";
					x = 0;
					y = 0;
					w = EVAL_UI(( 3.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
					h = EVAL_UI(( 3.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
				};
				class H_Text: ctrlStructuredText
				{
					idc = -1;
					x = EVAL_UI(( 3.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + ( 0.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
					y = EVAL_UI(( 3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) - ( 1.4 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
					w = EVAL_UI(( 1.4 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
					h = EVAL_UI(( 1.4 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
					text = "H";
					size = EVAL_UI(( 1.4 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
					class Attributes
					{
						color = "#ccc5c5";
						font = "PuristaMedium";
					};
				};
				class VSpeed: ctrlStructuredText
				{
					idc = 375;
					onLoad = "uiNameSpace setVariable ['DB_mavic_VSpeed_control', _this # 0];";
					x = EVAL_UI(( 3.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + ( 1.4 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + ( 0.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
					y = EVAL_UI(( 0.7 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
					w = EVAL_UI(( 6 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
					h = EVAL_UI(( 3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) - ( 0.7 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
					text = "0.0 km/h";
					size = EVAL_UI(( 0.9 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
					class Attributes
					{
						font = "PuristaMedium";
					};
				};
				class Height: VSpeed
				{
					idc = 214;
					onLoad = "uiNameSpace setVariable ['DB_mavic_Height_control', _this # 0];";
					y = EVAL_UI(( 3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) - ( 1.3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) - ( 0.1 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
					h = EVAL_UI(( 1.3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
					text = "0.0 ft";
					size = EVAL_UI(( 1.3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
				};
				class D_Text: H_Text
				{
					idc = -1;
					x = EVAL_UI(( 3.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + 4*( 1.4 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + ( 1.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) - ( 1.4 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
					text = "D";
				};
				class HSpeed: ctrlStructuredText
				{
					idc = 952;
					onLoad = "uiNameSpace setVariable ['DB_mavic_HSpeed_control', _this # 0];";
					x = EVAL_UI(( 3.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + 4*( 1.4 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + ( 1.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
					y = EVAL_UI(( 0.7 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
					w = EVAL_UI(( 6 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
					h = EVAL_UI(( 3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) - ( 0.7 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
					text = "0.0 km/h";
					size = EVAL_UI(( 0.9 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
					class Attributes
					{
						font = "PuristaMedium";
					};
				};
				class Distance: HSpeed
				{
					idc = 458;
					onLoad = "uiNameSpace setVariable ['DB_mavic_Distance_control', _this # 0];";
					y = EVAL_UI(( 3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) - ( 1.3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) - ( 0.1 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
					h = EVAL_UI(( 1.3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
					text = "0.0 ft";
					size = EVAL_UI(( 1.3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
				};
			};
		};
		class StatusInfo_Group: ctrlControlsGroupNoScrollBars
		{
			idc = -1;
			x = EVAL_UI(STATIC_SZ_X + STATIC_SZ_W - ( 5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) - ( 11.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
			y = EVAL_UI(STATIC_SZ_Y + ( ( 1.3 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) ));
			w = EVAL_UI(( 15 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
			h = EVAL_UI(( 2.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
			class controls
			{
				class Battery: ctrlStaticPicture
				{
					idc = 689;
					onLoad = "uiNameSpace setVariable [""DB_mavic_batteryPicture"", _this # 0]";
					text = "\mavik\interface\bat\100.paa";
					x = 0;
					y = 0;
					w = EVAL_UI(( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
					h = EVAL_UI(( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
				};
				class BatteryText: ctrlStructuredText
				{
					idc = 635;
					onLoad = "uiNameSpace setVariable [""DB_mavic_batteryText"", _this # 0]";
					text = "99";
					x = 0;
					y = EVAL_UI(( 0.8 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) / 2 - ( 0.08 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
					w = EVAL_UI(( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
					h = EVAL_UI(( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) - ( 0.8 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
					size = EVAL_UI(( 0.8 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
					class Attributes
					{
						color = "#4cbb90";
						font = "PuristaMedium";
						align = "center";
					};
				};
				class RemainingTime: ctrlStructuredText
				{
					idc = 653;
					onLoad = "uiNameSpace setVariable [""DB_mavic_RemainingTimeText"", _this # 0]";
					text = "00'00""";
					size = EVAL_UI(( 1.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
					class Attributes
					{
						font = "PuristaMedium";
					};
					x = EVAL_UI(( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + ( 0.1 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
					y = 0;
					w = EVAL_UI(( 4 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
					h = EVAL_UI(( 2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
				};
				class Signal: ctrlStaticPicture
				{
					idc = 624;
					onLoad = "uiNameSpace setVariable [""DB_mavic_SignalText"", _this # 0]";
					text = "\mavik\interface\signal\100.paa";
					x = EVAL_UI(( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + ( 3.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + ( 0.1 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
					y = EVAL_UI(( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) / 2 - ( 1.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) / 2);
					w = EVAL_UI(( 1.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
					h = EVAL_UI(( 1.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
				};
				class Sensor: ctrlStaticPicture
				{
					idc = -1;
					text = "\mavik\interface\main\sensor.paa";
					x = EVAL_UI(( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + ( 3.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + ( 1.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + 4*( 0.1 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
					y = EVAL_UI(( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) / 2 - ( 1.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) / 2);
					w = EVAL_UI(( 1.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
					h = EVAL_UI(( 1.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
				};
				class Satellite: ctrlStaticPicture
				{
					idc = 385;
					onLoad = "uiNameSpace setVariable [""DB_mavic_SatellitePicture"", _this # 0]";
					text = "\mavik\interface\main\sat0.paa";
					x = EVAL_UI(( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + ( 3.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + ( 1.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + 4*( 0.1 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + ( 1.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + ( 0.1 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
					y = EVAL_UI(( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) / 2 - ( 1.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) / 2);
					w = EVAL_UI(( 1.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
					h = EVAL_UI(( 1.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
				};
				class Datchik: ctrlStaticPicture
				{
					idc = -1;
					text = "\mavik\interface\main\datchik.paa";
					x = EVAL_UI(( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + ( 3.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + ( 1.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + 5*( 0.1 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + 2*( 1.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) + ( 0.1 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
					y = EVAL_UI(( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) / 2 - ( 1.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) / 2);
					w = EVAL_UI(( 1.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
					h = EVAL_UI(( 1.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
				};
			};
		};
		class DetachGrenade: ctrlControlsGroupNoScrollBars
		{
			idc = 552;
			fade = 1;
			onLoad = "uiNameSpace setVariable [""DB_DetachGrenade_group"", _this # 0]";
			x = EVAL_UI(0.5 - ( 11 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) / 2);
			y = EVAL_UI(0.5 - ( 6 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) / 2);
			w = EVAL_UI(( 11 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
			h = EVAL_UI(( 6 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
			class controls
			{
				class BackGround: ctrlStaticPicture
				{
					idc = -1;
					text = "\mavik\interface\detach\big.paa";
					x = 0;
					y = 0;
					w = EVAL_UI(( 11 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
					h = EVAL_UI(( 6 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
				};
				class Text: ctrlStructuredText
				{
					idc = -1;
					class Attributes
					{
						align = "center";
						font = "PuristaMedium";
					};
					size = EVAL_UI(( 0.9 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
					text = "$STR_mavic_dropMessage";
					x = 0;
					y = EVAL_UI(( 6 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) - ( 1 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) - ( 0.9 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
					w = EVAL_UI(( 11 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )));
					h = EVAL_UI(( 1 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
				};
			};
		};
	};
	class controlsBackground
	{
		class R2TPicture: RscPicture
		{
			idc = 1488;
			onLoad = "uiNamespace setVariable [""DB_mvc_r2tPicture"", _this # 0];";
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
			onLoad = "uiNamespace setVariable [""DB_mvc_effectPicture"", _this # 0];";
			show = 1;
		};
		class Gradient: ctrlStaticPicture
		{
			idc = -1;
			onLoad = "uiNamespace setVariable [""DB_gradient_control"", _this # 0];";
			text = "\mavik\interface\signal\gradient.paa";
			x = EVAL_UI(STATIC_SZ_X);
			y = EVAL_UI(STATIC_SZ_Y);
			w = EVAL_UI(STATIC_SZ_W);
			h = EVAL_UI(STATIC_SZ_H);
			show = 0;
		};
	};
};