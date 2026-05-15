/*
    Function: CFM_fnc_updateMavicInterface
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_monitor", objNull], ["_operator", objNull], ["_signal", 1], ["_uiCtrlCurrentUIDisplay", displayNull], ["_uiDisplayUniqueName", ""]];

private _pilot = _monitor;
private _uav = _operator;

private _batteryPicture = uiNameSpace getVariable ["DB_mavic_batteryPicture" + _uiDisplayUniqueName, controlNull];
private _batteryText = uiNameSpace getVariable ["DB_mavic_batteryText" + _uiDisplayUniqueName, controlNull];

private _currentBattery = fuel _uav;
private _batteryPictureSet = "\mavik\interface\bat\25.paa";
private _textColor = [0.298039, 0.733334, 0.564706, 1];

switch (true) do {
	case (_currentBattery > 0.75): {
		_batteryPictureSet = "\mavik\interface\bat\100.paa";
		_textColor = [0.298039, 0.733334, 0.564706, 1];
	};
	case (_currentBattery > 0.5): {
		_batteryPictureSet = "\mavik\interface\bat\75.paa";
		_textColor = [0.298039, 0.733334, 0.564706, 1];
	};
	case (_currentBattery > 0.25): {
		_batteryPictureSet = "\mavik\interface\bat\50.paa";
		_textColor = [0.976471, 0.541177, 0.082353, 1];
	};
	default {
		_batteryPictureSet = "\mavik\interface\bat\25.paa";
		_textColor = [0.929412, 0.196078, 0.145098, 1];
	};
};

_batteryPicture ctrlSetText _batteryPictureSet;
_batteryText ctrlSetText str(floor (_currentBattery * 100));
_batteryText ctrlSetTextColor _textColor;


private _remainingTimeText = uiNameSpace getVariable ["DB_mavic_RemainingTimeText" + _uiDisplayUniqueName, controlNull];
private _maxFlightTime = 30;

private _remainingFlightTimeMinutes = _maxFlightTime * _currentBattery;
private _remainingFlightTimeSeconds = _remainingFlightTimeMinutes * 60;
private _minutes = floor(_remainingFlightTimeSeconds / 60);
private _seconds = floor(_remainingFlightTimeSeconds % 60);

private _formattedSeconds = [format ["%1", _seconds], format ["0%1", _seconds]] select (_seconds < 10);

_remainingTimeText ctrlSetText format ["%1'%2""", _minutes, _formattedSeconds];

private _signalControl = uiNameSpace getVariable ["DB_mavic_SignalText" + _uiDisplayUniqueName, controlNull];
private _signalPictureSet = "\mavik\interface\signal\0.paa";

switch (true) do {
	case (_signal > 0.8): {
		_signalPictureSet = "\mavik\interface\signal\100.paa";
	};
	case (_signal > 0.6): {
		_signalPictureSet = "\mavik\interface\signal\80.paa";
	};
	case (_signal > 0.4): {
		_signalPictureSet = "\mavik\interface\signal\60.paa";
	};
	case (_signal > 0.2): {
		_signalPictureSet = "\mavik\interface\signal\40.paa";
	};
	case (_signal > 0): {
		_signalPictureSet = "\mavik\interface\signal\20.paa";
	};
	default {
		_signalPictureSet = "\mavik\interface\signal\0.paa";
	};
};

_signalControl ctrlSetText _signalPictureSet;


private _satelitePicture = uiNameSpace getVariable ["DB_mavic_SatellitePicture" + _uiDisplayUniqueName, controlNull];

_satelitePicture ctrlSetText (["\mavik\interface\main\sat100.paa", "\mavik\interface\main\sat0.paa"] select (_signal < 0.6));


private _statusText = uiNameSpace getVariable ["DB_mavic_FlightStatus_Text" + _uiDisplayUniqueName, controlNull];

_statusText ctrlSetText ([localize "STR_mavic_flightStatus_Flight", localize "STR_mavic_flightStatus_Ground"] select (isTouchingGround _uav));


private _vSpeedText = uiNameSpace getVariable ["DB_mavic_VSpeed_control" + _uiDisplayUniqueName, controlNull];
private _hSpeedText = uiNameSpace getVariable ["DB_mavic_HSpeed_control" + _uiDisplayUniqueName, controlNull];

_vSpeedText ctrlSetText format ["%1 %2", floor((speed _uav) / 3.6), localize "STR_mavic_metersSeconds"];
_hSpeedText ctrlSetText format ["%1 %2", floor((velocityModelSpace _uav) # 2), localize "STR_mavic_metersSeconds"];

private _heightText = uiNameSpace getVariable ["DB_mavic_Height_control" + _uiDisplayUniqueName, controlNull];
_heightText ctrlSetText format["%1 %2", floor(_uav call CBA_fnc_realHeight), localize "STR_mavic_meters"];

private _distanceText = uiNameSpace getVariable ["DB_mavic_Distance_control" + _uiDisplayUniqueName, controlNull];
_distanceText ctrlSetText format["%1 %2", floor(_pilot distance _uav), localize "STR_mavic_meters"];


private _zoomText = uiNameSpace getVariable ["DB_mavic_Zoom_Text" + _uiDisplayUniqueName, controlNull];
private _maxFov = getNumber (configFile >> "CfgVehicles" >> (typeOf _uav) >> "PilotCamera" >> "OpticsIn" >> "Wide" >> "maxFov");
private _currentFov = getObjectFov _uav;
if (_currentFov == 0) then {_currentFov == 1};
private _zoom = floor(_maxFov/_currentFov);
_zoomText ctrlSetText format ["%1x", _zoom];

// if !(isNil "DB_PP_dynamic") then { DB_PP_dynamic ppEffectEnable false; };

// switch true do {
// 	case (_zoom < 7): {
// 		DB_PP_dynamic = ppEffectCreate ["DynamicBlur",500];
// 		DB_PP_dynamic ppEffectEnable true;
// 		DB_PP_dynamic ppEffectAdjust [0.1];
// 		DB_PP_dynamic ppEffectCommit 0;
// 	};

// 	case (_zoom < 14): {
// 		DB_PP_dynamic = ppEffectCreate ["DynamicBlur",500];
// 		DB_PP_dynamic ppEffectEnable true;
// 		DB_PP_dynamic ppEffectAdjust [0.3];
// 		DB_PP_dynamic ppEffectCommit 0;
// 	};

// 	case (_zoom <= 28): {
// 		DB_PP_dynamic = ppEffectCreate ["DynamicBlur",500];
// 		DB_PP_dynamic ppEffectEnable true;
// 		DB_PP_dynamic ppEffectAdjust [0.5];
// 		DB_PP_dynamic ppEffectCommit 0;
// 	};
// };
