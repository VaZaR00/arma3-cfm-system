/*
    Function: CFM_fnc_onEachFrameClient
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

if !(missionNamespace getVariable ["CFM_updateEachFrame", false]) exitWith {};


private _player = PLAYER_;
private _monitorsParams = missionNamespace getVariable ["CFM_ActiveMonitors", []];


// ----------- ACTIVE VIEWER -----------
if (_monitorsParams isEqualTo []) exitWith {
	if (_player getVariable ["CFM_isActiveViewer", false]) then {
		["removeActiveViewer", [_player]] CALL_CLASS("DbHandler");
	};
};
if !(_player getVariable ["CFM_isActiveViewer", false]) then {
	["addActiveViewer", [_player]] CALL_CLASS("DbHandler");
};
// -------------------------------------

// ---------- UPDATE MONITORS ----------
private _optimizeDistance = GET_OPTIMIZE_DIST;
private _doOptimize = _optimizeDistance > 0;
private ["_monitor", "_condition", "_isHandMonitor", "_dist", "_operator"];
private _remMonF = {CFM_ActiveMonitors = _monitorsParams - [_monitor]};
{
	_monitor = _x;
	_condition = _monitor call CFM_fnc_monitorFeedActive;
	if (_condition isEqualTo false) then {
		[_monitor] call CFM_fnc_stopOperatorFeed;
		call _remMonF;
		continue;
	};
	_isHandMonitor = _monitor getVariable ["CFM_isHandMonitor", false];
	if (!(_isHandMonitor) && {_doOptimize}) then {
		_dist = _player distance _monitor;
		if (_dist > _optimizeDistance) then {
			_operator = _monitor getVariable ["CFM_connectedOperator", objNull];
			[_monitor] call CFM_fnc_stopOperatorFeed;
			[_monitor, _operator, true] spawn CFM_fnc_syncState;
			call _remMonF;
			continue;
		};
	};
	if (_condition) then {
		_condition = if (_monitor getVariable ["CFM_currentFeedIsDisplay", false]) then {
			_monitor call CFM_fnc_updateMonitor;
		} else {
			_monitor call CFM_fnc_updateMonitorCamera;
		};
	};
} forEach _monitorsParams;

// -------------------------------------