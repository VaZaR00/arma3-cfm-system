/*
    Function: CFM_fnc_getTargetMonitor
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

private _player = PLAYER_;
private _plrVeh = vehicle _player;
private _mon = call {
    if !(_player isEqualTo _plrVeh) exitWith {
        private _playerActiveFeed = _player getVariable ["CFM_feedActive", false];
        if (_playerActiveFeed) then {
            _player
        } else {
            if ((_plrVeh getVariable ["CFM_feedActive", false]) && {[_plrVeh] call CFM_fnc_inVehicleTabletSeatCondition}) then {
                _plrVeh
            } else {
                objNull
            };
        };
    };
    private _watchingAtMonitor = [_player] call CFM_fnc_isWatchingAtMonitor;
    if !(cameraOn isEqualTo _player) exitWith {objNull};
    if (_watchingAtMonitor && {(cursorObject distance _player) <= ACTION_RADIUS} && {cursorObject getVariable ["CFM_feedActive", false]}) exitWith {cursorObject};
    if (((_player getVariable ["CFM_isHandMonitor", false]) isEqualTo true) && {_player getVariable ["CFM_feedActive", false]}) exitWith {_player};
    objNull
};
if (!isNull _mon && {!([_mon] call CFM_fnc_hasMonitorPasswordAccess)}) exitWith {objNull};
_mon
