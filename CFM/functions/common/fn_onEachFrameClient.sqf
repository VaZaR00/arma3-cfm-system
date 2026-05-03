/*
    Function: CFM_fnc_onEachFrameClient
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

if !(missionNamespace getVariable ["CFM_updateEachFrame", false]) exitWith {};

private _monitorsParams = missionNamespace getVariable ["CFM_ActiveMonitors", []];
private _optimizeDistance = missionNamespace getVariable ["CFM_optimizeByDistance", OPTIMIZE_MONITOR_FEED_DIST];
if !(_optimizeDistance isEqualType "") then {
	_optimizeDistance = str _optimizeDistance;
	missionNamespace setVariable ["CFM_optimizeByDistance", _optimizeDistance];
};
_optimizeDistance = parseNumber _optimizeDistance;
private _doOptimize = _optimizeDistance > 0;
private ["_monitor", "_condition", "_isHandMonitor", "_dist", "_operator", "_monitorParams"];
{
	// _monitor = _x param [0, objNull];
	// _monitorParams = _x param [1, []];
	_monitor = _x;
	_monitorParams = _x;
	_condition = _monitor call CFM_fnc_monitorFeedActive;
	_isHandMonitor = _monitor getVariable ["CFM_isHandMonitor", false];
	if (!(_isHandMonitor) && {_doOptimize}) then {
		_dist = PLAYER_ distance _monitor;
		if (_dist > _optimizeDistance) then {
			_operator = _monitor getVariable ["CFM_connectedOperator", objNull];
			[_monitor] call CFM_fnc_stopOperatorFeed;
			[_monitor, _operator, true] spawn CFM_fnc_syncState;
			continue;
		};
	};
	if (_condition) then {
		_condition = _monitorParams call CFM_fnc_updateMonitor;
	};
	if (_condition isEqualTo false) then {
		[_monitor] call CFM_fnc_stopOperatorFeed;
	};
} forEach _monitorsParams;
