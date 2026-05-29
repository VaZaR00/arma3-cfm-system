/*
    Function: CFM_fnc_zala_drawHudGunner
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_monitor", objNull], ["_uav", objNull], ["_signal", 1], ["_uiCtrlCurrentUIDisplay", displayNull], ["_uiDisplayUniqueName", ""]];

private _positionATL = getPosATLVisual _uav;

// SQUARE X
private _controlsGroup = uiNameSpace getVariable ["DB_zala421_squareX_HUD" + _uiDisplayUniqueName, controlNull];
private _text = _controlsGroup controlsGroupCtrl 101;

_text ctrlSetStructuredText parseText format ["%1: <t align='right'>%2</t>", localize "STR_zala421_squareX", floor((_positionATL # 0) / 100)];

// SQUARE Y
private _controlsGroup = uiNameSpace getVariable ["DB_zala421_squareY_HUD" + _uiDisplayUniqueName, controlNull];
private _text = _controlsGroup controlsGroupCtrl 101;

_text ctrlSetStructuredText parseText format ["%1: <t align='right'>%2</t>", localize "STR_zala421_squareY", floor((_positionATL # 1) / 100)];

// LASER
private _controlsGroup = uiNameSpace getVariable ["DB_zala421_laser_HUD" + _uiDisplayUniqueName, controlNull];
private _text = _controlsGroup controlsGroupCtrl 101;

_text ctrlSetStructuredText parseText format ["%1: <t align='right'>%2</t>", localize "STR_zala421_laser", [localize "STR_zala421_off", localize "STR_zala421_on"] select (isLaserOn _uav)];

// HEIGHT
private _controlsGroup = uiNameSpace getVariable ["DB_zala421_height_HUD" + _uiDisplayUniqueName, controlNull];
private _text = _controlsGroup controlsGroupCtrl 101;

_text ctrlSetStructuredText parseText format ["%1: <t align='right'>%2</t>", localize "STR_zala421_altitude", floor(_uav call CBA_fnc_realHeight)];

// SPEED
private _controlsGroup = uiNameSpace getVariable ["DB_zala421_speed_HUD" + _uiDisplayUniqueName, controlNull];
private _text = _controlsGroup controlsGroupCtrl 101;

_text ctrlSetStructuredText parseText format ["%1: <t align='right'>%2</t>", localize "STR_zala421_speed", floor(speed _uav)];

// DIRECTION
private _controlsGroup = uiNameSpace getVariable ["DB_zala421_direction_HUD" + _uiDisplayUniqueName, controlNull];
private _text = _controlsGroup controlsGroupCtrl 101;
private _direction = getDirVisual _uav;

_text ctrlSetStructuredText parseText format ["%1: <t align='right'>%2</t>", localize "STR_zala421_course", floor _direction];

// TEMPERATURE
private _controlsGroup = uiNameSpace getVariable ["DB_zala421_temperature_HUD" + _uiDisplayUniqueName, controlNull];
private _text = _controlsGroup controlsGroupCtrl 101;

_text ctrlSetStructuredText parseText format ["%1: <t align='right'>%2°C</t>", localize "STR_zala421_t", floor(ambientTemperature # 0)];

// DATE
private _controlsGroup = uiNameSpace getVariable ["DB_zala421_date_HUD" + _uiDisplayUniqueName, controlNull];
private _text = _controlsGroup controlsGroupCtrl 101;
private _date = date;

_text ctrlSetText format ["%1/%2/%3", _date # 2, _date # 1, _date # 0];

// TIME
private _controlsGroup = uiNameSpace getVariable ["DB_zala421_time_HUD" + _uiDisplayUniqueName, controlNull];
private _text = _controlsGroup controlsGroupCtrl 101;
private _time = [dayTime, "HH:MM:SS"] call BIS_fnc_timeToString;

_text ctrlSetText _time;
