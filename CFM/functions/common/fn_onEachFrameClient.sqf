/*
    Function: CFM_fnc_onEachFrameClient
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

if !(missionNamespace getVariable ["CFM_updateEachFrame", false]) exitWith {};

private _monitors = missionNamespace getVariable ["CFM_ActiveMonitors", []];
private _optimizeDistance = missionNamespace getVariable ["CFM_optimizeByDistance", OPTIMIZE_MONITOR_FEED_DIST];
if !(_optimizeDistance isEqualType "") then {
	_optimizeDistance = str _optimizeDistance;
	missionNamespace setVariable ["CFM_optimizeByDistance", _optimizeDistance];
};
_optimizeDistance = parseNumber _optimizeDistance;
private _doOptimize = _optimizeDistance > 0;
{
	private _monitor = _x;
	private _condition = _monitor call CFM_fnc_monitorFeedActive;
	private _isHandMonitor = _monitor getVariable ["CFM_isHandMonitor", false];
	if (!(_isHandMonitor) && {_doOptimize}) then {
		private _dist = PLAYER_ distance _monitor;
		if (_dist > _optimizeDistance) then {
			private _operator = _monitor getVariable ["CFM_connectedOperator", objNull];
			[_monitor] call CFM_fnc_stopOperatorFeed;
			[_monitor, _operator, true] spawn CFM_fnc_syncState;
			continue;
		};
	};
	if (_condition) then {
		[_monitor] call CFM_fnc_updateMonitor;
	} else {
		[_monitor] call CFM_fnc_stopOperatorFeed;
	};
} forEach _monitors;

// upd actions to remote controlled units
private _plr = PLAYER_;
private _isHandMonitor = _plr getVariable ["CFM_isHandMonitor", false];
if (_isHandMonitor) then {
	private _unit = focusOn;
	if !(_unit isEqualTo _plr) then {
		private _unitIsSet = _unit getVariable ["CFM_actionsSet", false];
		if (_unitIsSet) exitWith {};
		[_plr, _unit] call CFM_fnc_copyMenuActionsToObj;
	};
};
