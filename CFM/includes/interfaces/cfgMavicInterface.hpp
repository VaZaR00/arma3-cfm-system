

class RscCFM_Mavic_Interface
{
	idd = 1589;
	duration = 2;
	onLoad = "[_this select 0, 'RscCFM_Mavic_Interface'] call (missionNamespace getVariable ['CFM_fnc_repositionControls', {}]);";
	class controls
	{
		class Camera_Button: ctrlStaticPicture
		{
			idc = 1001;
			text = "\mavik\interface\main\camera.paa";
			x = EVAL_UI(STATIC_SZ_X + STATIC_SZ_W - fnc_width(3) / 2 - fnc_width(2.0) / 2 - fnc_width(1.5));
			y = EVAL_UI(STATIC_SZ_Y + STATIC_SZ_H - fnc_height(2.0) - fnc_height(1.3));
			w = EVAL_UI(fnc_width(2.0));
			h = EVAL_UI(fnc_height(2.0));
		};
		class Settings_Button: ctrlStaticPicture
		{
			idc = 1002;
			text = "\mavik\interface\main\dots.paa";
			x = EVAL_UI(STATIC_SZ_X + STATIC_SZ_W - fnc_width(3) / 2 - fnc_width(2.0) / 2 - fnc_width(1.5));
			y = EVAL_UI(STATIC_SZ_Y + fnc_height(1.3));
			w = EVAL_UI(fnc_width(2.0));
			h = EVAL_UI(fnc_height(2.0));
		};
		class Exit_Button: ctrlStaticPicture
		{
			idc = 1003;
			text = "\mavik\interface\main\triangle.paa";
			x = EVAL_UI(STATIC_SZ_X + fnc_width(1.5));
			y = EVAL_UI(STATIC_SZ_Y + fnc_height(1.3));
			w = EVAL_UI(fnc_width(2.0));
			h = EVAL_UI(fnc_height(2.0));
		};
		class FlightMode_Text: ctrlStructuredText
		{
			idc = 1004;
			text = "$STR_mavic_fligtMode";
			x = EVAL_UI(STATIC_SZ_X + fnc_width(1.5) + fnc_width(2.0) + fnc_width(3.0));
			y = EVAL_UI(STATIC_SZ_Y + fnc_height(1.3) + fnc_height(0.3));
			w = EVAL_UI(fnc_width(5.0));
			h = EVAL_UI(fnc_height(2.0));
			size = EVAL_UI(fnc_height(1.2));
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
			x = EVAL_UI(STATIC_SZ_X + fnc_width(1.5) + fnc_width(2.0) + fnc_width(3.0) + 2 * fnc_width(3.0));
		};
		class Cross: ctrlStaticPicture
		{
			idc = 1005;
			text = "\mavik\interface\main\kross.paa";
			x = EVAL_UI(0.5 - fnc_width(5.0) / 2);
			y = EVAL_UI(0.5 - fnc_height(5.0) / 2);
			w = EVAL_UI(fnc_width(5.0));
			h = EVAL_UI(fnc_height(5.0));
		};
		class MapTriangle_Button: ctrlStaticPicture
		{
			idc = 1006;
			text = "\mavik\interface\main\maptriangle.paa";
			x = EVAL_UI(STATIC_SZ_X + fnc_width(1.5));
			y = EVAL_UI(0.5 - fnc_height(2.0));
			w = EVAL_UI(fnc_width(2.0));
			h = EVAL_UI(fnc_height(2.0));
		};
		class RTH_Button: ctrlStaticPicture
		{
			idc = 1007;
			text = "\mavik\interface\main\arrow.paa";
			x = EVAL_UI(STATIC_SZ_X + fnc_width(1.5));
			y = EVAL_UI(0.5 + fnc_height(2.0));
			w = EVAL_UI(fnc_width(2.0));
			h = EVAL_UI(fnc_height(2.0));
		};
		class Record_Button: ctrlStaticPicture
		{
			idc = 1008;
			text = "\mavik\interface\main\redcircle.paa";
			x = EVAL_UI(STATIC_SZ_X + STATIC_SZ_W - fnc_width(3) - fnc_width(1.5));
			y = EVAL_UI(0.5 - fnc_height(3) / 2);
			w = EVAL_UI(fnc_width(3));
			h = EVAL_UI(fnc_height(3));
		};
		class Play_Button: ctrlStaticPicture
		{
			idc = 1009;
			text = "\mavik\interface\main\play.paa";
			x = EVAL_UI(STATIC_SZ_X + STATIC_SZ_W - fnc_width(3) / 2 - fnc_width(2.0) / 2 - fnc_width(1.5));
			y = EVAL_UI(0.5 - fnc_height(2.0) / 2 + fnc_height(3) + fnc_height(1.3));
			w = EVAL_UI(fnc_width(2.0));
			h = EVAL_UI(fnc_height(2.0));
		};
		class Galery_Button: ctrlStaticPicture
		{
			idc = 1010;
			text = "\mavik\interface\main\galery.paa";
			x = EVAL_UI(STATIC_SZ_X + STATIC_SZ_W - fnc_width(3) / 2 - fnc_width(2.0) / 2 - fnc_width(1.5));
			y = EVAL_UI(0.5 - fnc_height(2.0) / 2 - fnc_height(3) - fnc_height(1.3));
			w = EVAL_UI(fnc_width(2.0));
			h = EVAL_UI(fnc_height(2.0));
		};
		class Zoom_Display: ctrlStaticPicture
		{
			idc = 1011;
			text = "\mavik\interface\zoom\zoom.paa";
			x = EVAL_UI(STATIC_SZ_X + STATIC_SZ_W - fnc_width(3) - fnc_width(2.2) - 2 * fnc_width(1.5));
			y = EVAL_UI(0.5 - fnc_height(2.2) / 2);
			w = EVAL_UI(fnc_width(2.2));
			h = EVAL_UI(fnc_height(2.2));
		};
		class Zoom_Text: ctrlStructuredText
		{
			idc = 278;
			text = "4x";
			onLoad = "uiNameSpace setVariable ['DB_mavic_Zoom_Text', _this # 0];";
			x = EVAL_UI(STATIC_SZ_X + STATIC_SZ_W - fnc_width(3) - fnc_width(2.2) - 2 * fnc_width(1.5));
			y = EVAL_UI(0.5 - fnc_height(2.2) / 2 + fnc_height(0.5));
			w = EVAL_UI(fnc_width(2.2));
			h = EVAL_UI(fnc_height(2.2));
			size = EVAL_UI(fnc_height(1.1));
			class Attributes
			{
				align = "center";
				font = "PuristaSemiBold";
			};
		};
		class MemoryPicture: ctrlStaticPicture
		{
			idc = 1012;
			text = "\mavik\interface\main\memory.paa";
			x = EVAL_UI(STATIC_SZ_X + STATIC_SZ_W - fnc_width(3) - fnc_width(2.2) - 2 * fnc_width(1.5));
			y = EVAL_UI(STATIC_SZ_Y + STATIC_SZ_H - fnc_height(2.0) - fnc_height(1.3));
			w = EVAL_UI(fnc_width(2.0));
			h = EVAL_UI(fnc_height(2.0));
		};
		class AF_Button: ctrlStaticPicture
		{
			idc = 1013;
			text = "\mavik\interface\zoom\AF.paa";
			x = EVAL_UI(STATIC_SZ_X + STATIC_SZ_W - fnc_width(3) - fnc_width(2.2) - 2 * fnc_width(1.5));
			y = EVAL_UI(0.5 - fnc_height(2.2) / 2 + fnc_height(2.2) + fnc_height(0.05));
			w = EVAL_UI(fnc_width(2.2));
			h = EVAL_UI(fnc_height(2.2));
		};
		class Binoc_Button: ctrlStaticPicture
		{
			idc = 1014;
			text = "\mavik\interface\zoom\binocular.paa";
			x = EVAL_UI(STATIC_SZ_X + STATIC_SZ_W - fnc_width(3) - fnc_width(2.2) - 2 * fnc_width(1.5));
			y = EVAL_UI(0.5 - fnc_height(2.2) / 2 - fnc_height(2.2) - fnc_height(0.3));
			w = EVAL_UI(fnc_width(2.2));
			h = EVAL_UI(fnc_height(2.2));
		};
		class UAVInfo_Group: ctrlControlsGroupNoScrollBars
		{
			idc = 1015;
			x = EVAL_UI(STATIC_SZ_X + fnc_width(0.8));
			y = EVAL_UI(STATIC_SZ_Y + STATIC_SZ_H - fnc_height(3) - fnc_height(0.4));
			w = EVAL_UI(fnc_width(15));
			h = EVAL_UI(fnc_height(3));
			class controls
			{
				class Map_Picture: ctrlStaticPicture
				{
					idc = 1016;
					text = "\mavik\interface\main\map.paa";
					x = 0;
					y = 0;
					w = EVAL_UI(fnc_width(3.0));
					h = EVAL_UI(fnc_height(3.0));
				};
				class H_Text: ctrlStructuredText
				{
					idc = 1017;
					x = EVAL_UI(fnc_width(3.0) + fnc_width(0.2));
					y = EVAL_UI(fnc_height(3) - fnc_height(1.4));
					w = EVAL_UI(fnc_width(1.4));
					h = EVAL_UI(fnc_height(1.4));
					text = "H";
					size = EVAL_UI(fnc_height(1.4));
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
					x = EVAL_UI(fnc_width(3.0) + fnc_width(1.4) + fnc_width(0.2));
					y = EVAL_UI(fnc_height(0.7));
					w = EVAL_UI(fnc_width(6));
					h = EVAL_UI(fnc_height(3) - fnc_height(0.7));
					text = "0.0 km/h";
					size = EVAL_UI(fnc_height(0.9));
					class Attributes
					{
						font = "PuristaMedium";
					};
				};
				class Height: VSpeed
				{
					idc = 214;
					onLoad = "uiNameSpace setVariable ['DB_mavic_Height_control', _this # 0];";
					y = EVAL_UI(fnc_height(3) - fnc_height(1.3) - fnc_height(0.1));
					h = EVAL_UI(fnc_height(1.3));
					text = "0.0 ft";
					size = EVAL_UI(fnc_height(1.3));
				};
				class D_Text: H_Text
				{
					idc = 1018;
					x = EVAL_UI(fnc_width(3.0) + 4 * fnc_width(1.4) + fnc_width(1.0) - fnc_width(1.4));
					text = "D";
				};
				class HSpeed: ctrlStructuredText
				{
					idc = 952;
					onLoad = "uiNameSpace setVariable ['DB_mavic_HSpeed_control', _this # 0];";
					x = EVAL_UI(fnc_width(3.0) + 4 * fnc_width(1.4) + fnc_width(1.0));
					y = EVAL_UI(fnc_height(0.7));
					w = EVAL_UI(fnc_width(6));
					h = EVAL_UI(fnc_height(3) - fnc_height(0.7));
					text = "0.0 km/h";
					size = EVAL_UI(fnc_height(0.9));
					class Attributes
					{
						font = "PuristaMedium";
					};
				};
				class Distance: HSpeed
				{
					idc = 458;
					onLoad = "uiNameSpace setVariable ['DB_mavic_Distance_control', _this # 0];";
					y = EVAL_UI(fnc_height(3) - fnc_height(1.3) - fnc_height(0.1));
					h = EVAL_UI(fnc_height(1.3));
					text = "0.0 ft";
					size = EVAL_UI(fnc_height(1.3));
				};
			};
		};
		class StatusInfo_Group: ctrlControlsGroupNoScrollBars
		{
			idc = 1019;
			x = EVAL_UI(STATIC_SZ_X + STATIC_SZ_W - fnc_width(5) - fnc_width(11.2));
			y = EVAL_UI(STATIC_SZ_Y + fnc_height(1.3));
			w = EVAL_UI(fnc_width(15));
			h = EVAL_UI(fnc_height(2.0));
			class controls
			{
				class Battery: ctrlStaticPicture
				{
					idc = 689;
					onLoad = "uiNameSpace setVariable [""DB_mavic_batteryPicture"", _this # 0]";
					text = "\mavik\interface\bat\100.paa";
					x = 0;
					y = 0;
					w = EVAL_UI(fnc_width(1.5));
					h = EVAL_UI(fnc_height(1.5));
				};
				class BatteryText: ctrlStructuredText
				{
					idc = 635;
					onLoad = "uiNameSpace setVariable [""DB_mavic_batteryText"", _this # 0]";
					text = "99";
					x = 0;
					y = EVAL_UI(fnc_height(0.8) / 2 - fnc_height(0.08));
					w = EVAL_UI(fnc_width(1.5));
					h = EVAL_UI(fnc_height(1.5) - fnc_height(0.8));
					size = EVAL_UI(fnc_height(0.8));
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
					size = EVAL_UI(fnc_height(1.2));
					class Attributes
					{
						font = "PuristaMedium";
					};
					x = EVAL_UI(fnc_width(1.5) + fnc_width(0.1));
					y = 0;
					w = EVAL_UI(fnc_width(4));
					h = EVAL_UI(fnc_height(2));
				};
				class Signal: ctrlStaticPicture
				{
					idc = 624;
					onLoad = "uiNameSpace setVariable [""DB_mavic_SignalText"", _this # 0]";
					text = "\mavik\interface\signal\100.paa";
					x = EVAL_UI(fnc_width(1.5) + fnc_width(3.2) + fnc_width(0.1));
					y = EVAL_UI(fnc_height(1.5) / 2 - fnc_height(1.2) / 2);
					w = EVAL_UI(fnc_width(1.2));
					h = EVAL_UI(fnc_height(1.2));
				};
				class Sensor: ctrlStaticPicture
				{
					idc = 1020;
					text = "\mavik\interface\main\sensor.paa";
					x = EVAL_UI(fnc_width(1.5) + fnc_width(3.2) + fnc_width(1.2) + 4 * fnc_width(0.1));
					y = EVAL_UI(fnc_height(1.5) / 2 - fnc_height(1.2) / 2);
					w = EVAL_UI(fnc_width(1.2));
					h = EVAL_UI(fnc_height(1.2));
				};
				class Satellite: ctrlStaticPicture
				{
					idc = 385;
					onLoad = "uiNameSpace setVariable [""DB_mavic_SatellitePicture"", _this # 0]";
					text = "\mavik\interface\main\sat0.paa";
					x = EVAL_UI(fnc_width(1.5) + fnc_width(3.2) + fnc_width(1.2) + 4 * fnc_width(0.1) + fnc_width(1.2) + fnc_width(0.1));
					y = EVAL_UI(fnc_height(1.5) / 2 - fnc_height(1.2) / 2);
					w = EVAL_UI(fnc_width(1.2));
					h = EVAL_UI(fnc_height(1.2));
				};
				class Datchik: ctrlStaticPicture
				{
					idc = 1021;
					text = "\mavik\interface\main\datchik.paa";
					x = EVAL_UI(fnc_width(1.5) + fnc_width(3.2) + fnc_width(1.2) + 5 * fnc_width(0.1) + 2 * fnc_width(1.2) + fnc_width(0.1));
					y = EVAL_UI(fnc_height(1.5) / 2 - fnc_height(1.2) / 2);
					w = EVAL_UI(fnc_width(1.2));
					h = EVAL_UI(fnc_height(1.2));
				};
			};
		};
		class DetachGrenade: ctrlControlsGroupNoScrollBars
		{
			idc = 552;
			fade = 1;
			onLoad = "uiNameSpace setVariable [""DB_DetachGrenade_group"", _this # 0]";
			x = EVAL_UI(0.5 - fnc_width(11) / 2);
			y = EVAL_UI(0.5 - fnc_height(6) / 2);
			w = EVAL_UI(fnc_width(11));
			h = EVAL_UI(fnc_height(6));
			class controls
			{
				class BackGround: ctrlStaticPicture
				{
					idc = 1022;
					text = "\mavik\interface\detach\big.paa";
					x = 0;
					y = 0;
					w = EVAL_UI(fnc_width(11));
					h = EVAL_UI(fnc_height(6));
				};
				class Text: ctrlStructuredText
				{
					idc = 1023;
					class Attributes
					{
						align = "center";
						font = "PuristaMedium";
					};
					size = EVAL_UI(fnc_height(0.9));
					text = "$STR_mavic_dropMessage";
					x = 0;
					y = EVAL_UI(fnc_height(6) - fnc_height(1) - fnc_height(0.9));
					w = EVAL_UI(fnc_width(11));
					h = EVAL_UI(fnc_height(1));
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
			idc = 1490;
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
