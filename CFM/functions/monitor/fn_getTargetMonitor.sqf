/*
    Function: CFM_fnc_getTargetMonitor
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

private _plr = PLAYER_;
private _watchingAtMonitor = [_plr] call CFM_fnc_isWatchingAtMonitor;
if !(cameraOn isEqualTo _plr) exitWith {objNull};
if (_watchingAtMonitor) exitWith {cursorObject};
if ((_plr getVariable ["CFM_isHandMonitor", false]) isEqualTo true) exitWith {_plr};
objNull
