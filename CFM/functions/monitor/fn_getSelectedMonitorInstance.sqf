/*
    Function: CFM_fnc_getSelectedMonitorInstance
    Author: Vazar
    Description: Returns active monitor instance ID on _monitor for the local player (via intersection or Switch Monitor selection).
*/

#include "defines.hpp"

params [["_monitor", objNull]];
if !(IS_OBJ(_monitor)) exitWith {-1};
if !(_monitor getVariable ["CFM_isMonitorSet", false]) exitWith {-1};

private _plr = PLAYER_;
private _plrParent = objectParent _plr;
private _selCache = _monitor getVariable ["CFM_selInstCache", [-1, objNull, objNull, -1]];
if (
	((_selCache select 0) isEqualTo diag_frameNo) &&
	{(_selCache select 1) isEqualTo _plr} &&
	{(_selCache select 2) isEqualTo _plrParent}
) exitWith {
	_selCache select 3
};

private _available = [_monitor] call CFM_fnc_getAvailableMonitorInstances;
private _result = -1;

if !(_available isEqualTo []) then {
	if ((count _available) == 1) then {
		_result = _available select 0;
		if !((_monitor getVariable ["CFM_selectedMonitorInstance", -1]) isEqualTo _result) then {
			_monitor setVariable ["CFM_selectedMonitorInstance", _result];
		};
	} else {
		private _intersectInst = -1;
		if (missionNamespace getVariable ["CFM_detectMonitorByIntersect", false]) then {
			_intersectInst = [_monitor, _available] call CFM_fnc_getMonitorInstanceByIntersect;
		};
		if (_intersectInst in _available) then {
			_result = _intersectInst;
		} else {
			private _selected = _monitor getVariable ["CFM_selectedMonitorInstance", -1];
			if !(_selected in _available) then {
				_selected = _available select 0;
				_monitor setVariable ["CFM_selectedMonitorInstance", _selected];
			};
			_result = _selected;
		};
	};
};

_monitor setVariable ["CFM_selInstCache", [diag_frameNo, _plr, _plrParent, _result]];
if (_result > 0 && {!((_monitor getVariable ["CFM_lastUiSyncedInst", -1]) isEqualTo _result)} && {_monitor getVariable ["CFM_isMonitorHostCreated", false]}) then {
	["syncSelectedActionLabels", [_result]] CALL_OBJCLASS("MonitorHost", _monitor);
};
_result
