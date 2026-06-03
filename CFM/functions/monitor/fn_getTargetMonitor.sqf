/*
    Function: CFM_fnc_getTargetMonitor
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

private _player = PLAYER_;
private _plrVeh = vehicle _player;
if !(_player isEqualTo _plrVeh) exitWith {
    private _playerActiveFeed = _player getVariable ["CFM_feedActive", false];
    if (_playerActiveFeed) then {
        _player
    } else {
        if (_plrVeh getVariable ["CFM_feedActive", false]) then {
            _plrVeh
        } else {
            objNull
        };
    };
};
private _watchingAtMonitor = [_player] call CFM_fnc_isWatchingAtMonitor;
if !(cameraOn isEqualTo _player) exitWith {objNull};
if (_watchingAtMonitor) exitWith {cursorObject};
if ((_player getVariable ["CFM_isHandMonitor", false]) isEqualTo true) exitWith {_player};
objNull