/*
    Function: CFM_fnc_enterFullScreenActionCondition
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_target"];
HAND_MON_CONDITION
if !(missionNamespace getVariable ['CFM_canFullscreen', true]) exitWith {false};
if !(_target getVariable ['CFM_feedActive', false]) exitWith {false};
if !(_target getVariable ['CFM_canFullScreen', false]) exitWith {false};
// private _connectedOperator = _target getVariable ['CFM_connectedOperator', objNull];
// if (_connectedOperator getVariable ['CFM_hasGoPro', false]) exitWith {false};
IS_MONITOR_ON
if (
	(_target getVariable ['CFM_isHandMonitor', false]) &&
	{(_target getVariable ['CFM_isHandMonitorDisplay', false]) ||
	{MGVAR ["CFM_allHandMonitorsAreDisplays", false]}}
) exitWith {false};
focusOn == PLAYER_
