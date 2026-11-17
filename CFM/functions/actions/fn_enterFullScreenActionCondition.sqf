/*
    Function: CFM_fnc_enterFullScreenActionCondition
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_target", ["_instId", -1]];
RESOLVE_ACTION_INST
HAND_MON_CONDITION
private _isHandMonitor = MON_GVAR(_target, _instId, 'CFM_isHandMonitor', false);
if (!_isHandMonitor && {!(missionNamespace getVariable ['CFM_canFullscreen', true])}) exitWith {false};
if (_isHandMonitor && {!(missionNamespace getVariable ['CFM_canFullscreenHandMonitors', true])}) exitWith {false};
if (missionNamespace getVariable ['CFM_isInPIPFullScreen', false]) exitWith {false};
if !(MON_GVAR(_target, _instId, 'CFM_feedActive', false)) exitWith {false};
if !(MON_GVAR(_target, _instId, 'CFM_canFullScreen', false)) exitWith {false};
// private _connectedOperator = MON_GVAR(_target, _instId, 'CFM_connectedOperator', objNull);
// if (_connectedOperator getVariable ['CFM_hasGoPro', false]) exitWith {false};
IS_MONITOR_ON
if (
	_isHandMonitor &&
	{(MON_GVAR(_target, _instId, 'CFM_isHandMonitorDisplay', false)) ||
	{MGVAR ["CFM_allHandMonitorsAreDisplays", false]}}
) exitWith {false};
focusOn == PLAYER_
