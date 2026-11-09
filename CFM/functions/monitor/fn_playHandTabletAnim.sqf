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

params [["_monitor", objNull, [objNull]]];

if !(IS_OBJ(_monitor)) exitWith { false };

// Проверяем, что это именно ХендТаблет (ручной планшет и НЕ планшет техники)
private _isHandMonitor = _monitor getVariable ["CFM_isHandMonitor", false];
private _isVehTablet = _monitor getVariable ["CFM_isVehTablet", false];

if (!_isHandMonitor || {_isVehTablet}) exitWith { false };

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
