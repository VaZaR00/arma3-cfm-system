/*
    Function: CFM_fnc_handMonitorMenuActionCondition
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_target"];

private _isHandMonitor = _target getVariable ["CFM_isHandMonitor", false];
if !(_isHandMonitor) exitWith {false};
private _isVehTablet = _target getVariable ["CFM_isVehTablet", false];
if (_isVehTablet) exitWith {false};
if !(_target isEqualTo PLAYER_) exitWith {true};
if !([_target] call CFM_fnc_hasUAVterminal) exitWith {true};

if (call CFM_fnc_hasDualTabletMenu) exitWith {
	!([_target] call CFM_fnc_isSelectedTablet)
};

private _veh = objectParent _target;
if (!isNull _veh && {!(_veh isEqualTo _target)}) exitWith {false};
[_target] call CFM_fnc_isWatchingAtMonitor;
