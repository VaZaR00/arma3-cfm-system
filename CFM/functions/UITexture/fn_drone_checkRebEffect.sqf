/*
    Function: CFM_fnc_drone_checkRebEffect
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_uav", objNull], ["_signal", 1], ["_ctrlsLayers", []]];

private _rebStrenght = _uav getVariable ["REB_uavActiveRebStrength", 0];

if !((_uav getVariable ["REB_uavIsSuppressed", false]) || {
	private _lastTimeChecked = _uav getVariable ["CFM_REB_suppressedCheckLastTime", 0];
	if ((diag_tickTime - _lastTimeChecked) > 1) then {
		_uav setVariable ["CFM_REB_suppressedCheckLastTime", diag_tickTime];
		_rebStrenght = _uav call REB_fnc_currentJammingRebStrength;
	};
	_uav setVariable ["REB_uavActiveRebStrength", _rebStrenght];
	_rebStrenght > 0
}) exitWith {
	if (_uav getVariable ["CFM_REB_uavIsSuppressed", false]) then {
		// turn off effect
		[1, _ctrlsLayers param [0, controlNull], 0] call CFM_fnc_radioNoiseEffect;
	};
	_uav setVariable ["CFM_REB_uavIsSuppressed", false];
	false
};
_uav setVariable ["CFM_REB_uavIsSuppressed", true];

private _signal = (1 - _rebStrenght) / 20;

[_signal, _ctrlsLayers param [0, controlNull], 1] call CFM_fnc_radioNoiseEffect;
true
