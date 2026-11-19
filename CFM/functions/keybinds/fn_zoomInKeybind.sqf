/*
    Function: CFM_fnc_zoomInKeybind
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params [["_isDown", true, [true]], ["_keyArgs", []]];

if (MGVAR ["CFM_continuousCameraZoom", false]) exitWith {
    [1, _isDown, _keyArgs] call CFM_fnc_handleContinuousZoom;
};

if (!_isDown) exitWith {false};

private _monPair = GET_MON;
if !(IS_VALID_MON(_monPair)) exitWith {};
if !(_monPair call CFM_fnc_canControlMonitorSeat) exitWith {};
[_monPair, 1] call CFM_fnc_zoom;
