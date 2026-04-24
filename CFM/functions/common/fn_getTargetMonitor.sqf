/*
    Function: CFM_fnc_getTargetMonitor
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

private _watchingAtMonitor = [PLAYER_] call CFM_fnc_isWatchingAtMonitor;
if (_watchingAtMonitor) exitWith {cursorObject};
if ((player getVariable ["CFM_isHandMonitor", false]) isEqualTo true) exitWith {player};
objNull
