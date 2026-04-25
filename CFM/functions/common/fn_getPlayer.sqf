/*
    Function: CFM_fnc_getPlayer
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_target", objNull]];

private _playerVeh = cameraOn;
if (_playerVeh isEqualTo _target) exitWith {PLAYER_};

_target