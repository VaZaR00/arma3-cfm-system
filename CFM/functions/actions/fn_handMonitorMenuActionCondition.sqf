/*
    Function: CFM_fnc_handMonitorMenuActionCondition
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_target"];

private _isHandMonitor = _target getVariable ["CFM_isHandMonitor", false];
if !(_isHandMonitor) exitWith {false};
if !(_target isEqualTo PLAYER_) exitWith {true};

[_target] call CFM_fnc_isWatchingAtMonitor;
