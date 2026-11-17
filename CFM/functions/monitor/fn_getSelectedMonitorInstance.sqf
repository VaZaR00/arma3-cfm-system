/*
    Function: CFM_fnc_getSelectedMonitorInstance
    Author: Vazar
    Description: Returns active monitor instance ID on _monitor for the local player (via intersection or Switch Monitor selection).
*/

#include "defines.hpp"

params [["_monitor", objNull]];
if !(IS_OBJ(_monitor)) exitWith {-1};
if !(_monitor getVariable ["CFM_isMonitorSet", false]) exitWith {-1};

private _available = [_monitor] call CFM_fnc_getAvailableMonitorInstances;
if (_available isEqualTo []) exitWith {-1};
if ((count _available) == 1) exitWith {
	private _onlyInst = _available select 0;
	if !((_monitor getVariable ["CFM_selectedMonitorInstance", -1]) isEqualTo _onlyInst) then {
		_monitor setVariable ["CFM_selectedMonitorInstance", _onlyInst];
	};
	_onlyInst
};

private _intersectInst = -1;
if (missionNamespace getVariable ["CFM_detectMonitorByIntersect", false]) then {
	_intersectInst = [_monitor, _available] call CFM_fnc_getMonitorInstanceByIntersect;
};
if (_intersectInst in _available) exitWith {_intersectInst};

private _selected = _monitor getVariable ["CFM_selectedMonitorInstance", -1];
if !(_selected in _available) then {
	_selected = _available select 0;
	_monitor setVariable ["CFM_selectedMonitorInstance", _selected];
};
_selected
