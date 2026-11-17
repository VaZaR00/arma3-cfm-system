/*
    Function: CFM_fnc_switchMonitorKeybind
    Author: Vazar
    Description: Keybind handler for switching active monitor instance on target monitor object.
*/

#include "defines.hpp"

private _monPair = GET_MON;
_monPair params [["_monitor", objNull], ["_instId", -1]];
if !(IS_OBJ(_monitor)) then {
	private _plr = PLAYER_;
	private _veh = objectParent _plr;
	if (!isNull _veh && {!(_veh isEqualTo _plr)} && {_veh getVariable ["CFM_isMonitorSet", false]}) then {
		_monitor = _veh;
	} else {
		if (!isNull cursorObject && {cursorObject getVariable ["CFM_isMonitorSet", false]} && {(cursorObject distance _plr) <= (MONITOR_ACTION_RADIUS(cursorObject))}) then {
			_monitor = cursorObject;
		};
	};
};
if !([_monitor] call CFM_fnc_switchMonitorActionCondition) exitWith {};
[_monitor] call CFM_fnc_switchMonitor;
