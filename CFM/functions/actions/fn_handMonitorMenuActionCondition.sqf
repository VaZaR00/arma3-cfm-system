/*
    Function: CFM_fnc_handMonitorMenuActionCondition
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_target", ["_instId", -1]];

if (_instId < 1) then {
	_instId = [_target] call CFM_fnc_getSelectedMonitorInstance;
};
if (_instId < 1) exitWith {true};

private _isHandMonitor = MON_GVAR(_target, _instId, "CFM_isHandMonitor", false);
if !(_isHandMonitor) exitWith {false};
private _isVehSeatTablet = MON_GVAR(_target, _instId, "CFM_isVehSeatTablet", false);
if (_isVehSeatTablet) exitWith {false};
if !(_target isEqualTo PLAYER_) exitWith {true};
if !([_target] call CFM_fnc_hasUAVterminal) exitWith {true};

if (call CFM_fnc_hasDualTabletMenu) exitWith {
	!([_target, _instId] call CFM_fnc_isSelectedTablet)
};

private _veh = objectParent _target;
if (!isNull _veh && {!(_veh isEqualTo _target)}) exitWith {false};
[_target] call CFM_fnc_isWatchingAtMonitor;
