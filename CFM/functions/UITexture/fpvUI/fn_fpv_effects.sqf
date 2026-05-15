/*
    Function: CFM_fnc_fpv_effects
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

if (call CFM_fnc_drone_checkRebEffect) exitWith {};

params[["_uav", objNull], ["_signal", 1], ["_ctrlsLayers", []]];

if (_uav getVariable ["ArmaFPV_effectOff", missionNamespace getVariable ["ArmaFPV_effectOff", false]]) exitWith {};

private _effectAdjust = _uav getVariable ["ArmaFPV_effectAdjust", missionNamespace getVariable ["ArmaFPV_effectAdjust", 1]];

if (_effectAdjust <= 0) exitWith {};

[_signal, _ctrlsLayers param [0, controlNull], _effectAdjust] call CFM_fnc_radioNoiseEffect;

private _serverTime = serverTime;
private _intX = _serverTime - (_serverTime - ((_serverTime mod 20)));
private _randInt1 = [_signal - 0.1, (-_intX - 1), -_signal, 220] call CFM_fnc_randInt;
(_ctrlsLayers param [1, controlNull]) ctrlSetText (format["#(rgb,8,8,3)color(1,0.4,0.1,%1)", (_randInt1 / 220) * 0.05]);
