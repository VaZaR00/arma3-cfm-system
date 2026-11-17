/*
    Function: CFM_fnc_playHandTabletAnim

    Author: Vazar

    Description:
        Plays the inventory access animation on the unit holding the HandTablet
        when entering fullscreen mode, with multiplayer synchronization.

    Parameters:
        0: OBJECT - Monitor / Tablet entity (usually the unit itself)

    Returns:
        BOOL - True if animation was triggered, false otherwise
*/

#include "defines.hpp"

if !(missionNamespace getVariable ["CFM_blockMovementInFullscreen", false]) exitWith {};

params [["_monArg", objNull]];
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];

if !(IS_OBJ(_monitor) && {_instId > 0}) exitWith { false };

private _isHandMonitor = MON_GVAR(_monitor, _instId, "CFM_isHandMonitor", false);
private _isVehSeatTablet = MON_GVAR(_monitor, _instId, "CFM_isVehSeatTablet", false);

if (!_isHandMonitor || {_isVehSeatTablet}) exitWith { false };

// Определяем юнит: если монитор сам является пехотинцем (Man), берем его, иначе PLAYER_
private _unit = if (_monitor isKindOf "Man") then { _monitor } else { PLAYER_ };

if !(IS_OBJ(_unit) && {alive _unit}) exitWith { false };

// Юнит должен быть пешим (не внутри техники)
if !(isNull objectParent _unit) exitWith { false };

// Воспроизводим анимацию инвентаря ("Gear") с учетом MP compatibility:
// playActionNow имеет Global Effect (транслируется по сети всем клиентам),
// но Argument Local (должна вызываться там, где юнит локален).
if (local _unit) then {
    _unit playActionNow "Gear";
} else {
    [_unit, "Gear"] remoteExecCall ["playActionNow", _unit];
};

true
