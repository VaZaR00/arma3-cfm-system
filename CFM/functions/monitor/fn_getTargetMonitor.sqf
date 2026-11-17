/*
    Function: CFM_fnc_getTargetMonitor
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

private _player = PLAYER_;
private _plrVeh = vehicle _player;
private _handInst = (_player getVariable ["CFM_monitorInstancesMap", createHashMap]) getOrDefault [HAND_MONITOR_KEY, -1];
private _monPair = call {
    if !(_player isEqualTo _plrVeh) exitWith {
        private _playerActiveFeed = (_handInst > 0) && {MON_GVAR(_player, _handInst, "CFM_feedActive", false)};
        private _vehInst = [_plrVeh] call CFM_fnc_getSelectedMonitorInstance;
        private _vehActiveFeed = (_vehInst > 0) && {MON_GVAR(_plrVeh, _vehInst, "CFM_feedActive", false)} && {[_plrVeh, _vehInst] call CFM_fnc_inVehicleTabletSeatCondition};
        if (call CFM_fnc_hasDualTabletMenu) then {
            private _selected = _player getVariable ["CFM_selectedTablet", "veh"];
            if (_selected isEqualTo "veh") then {
                if (_vehActiveFeed) then {[_plrVeh, _vehInst]} else {if (_playerActiveFeed) then {[_player, _handInst]} else {[objNull, -1]}}
            } else {
                if (_playerActiveFeed) then {[_player, _handInst]} else {if (_vehActiveFeed) then {[_plrVeh, _vehInst]} else {[objNull, -1]}}
            }
        } else {
            if (_playerActiveFeed) then {
                [_player, _handInst]
            } else {
                if (_vehActiveFeed) then {
                    [_plrVeh, _vehInst]
                } else {
                    [objNull, -1]
                };
            };
        };
    };
    private _watchingAtMonitor = [_player] call CFM_fnc_isWatchingAtMonitor;
    if !(cameraOn isEqualTo _player) exitWith {[objNull, -1]};
    private _cursorInst = if (_watchingAtMonitor) then {[cursorObject] call CFM_fnc_getSelectedMonitorInstance} else {-1};
    if (
        _watchingAtMonitor &&
        {_cursorInst > 0} &&
        {(cursorObject distance _player) <= (MONITOR_ACTION_RADIUS(cursorObject))} &&
        {MON_GVAR(cursorObject, _cursorInst, "CFM_feedActive", false)}
    ) exitWith {[cursorObject, _cursorInst]};
    if (
        (_handInst > 0) &&
        {(MON_GVAR(_player, _handInst, "CFM_isHandMonitor", false)) isEqualTo true} &&
        {MON_GVAR(_player, _handInst, "CFM_feedActive", false)}
    ) exitWith {[_player, _handInst]};
    [objNull, -1]
};
if (IS_VALID_MON(_monPair) && {!([_monPair] call CFM_fnc_hasMonitorPasswordAccess)}) exitWith {[objNull, -1]};
_monPair
