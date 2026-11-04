/*
    Function: CFM_fnc_cameraTurnRightKeybind
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params [["_isDown", true, [true]], ["_keyArgs", []]];

if (MGVAR ["CFM_continuousCameraMove", false]) exitWith {
    ["right", _isDown, _keyArgs] call CFM_fnc_handleContinuousCameraMove;
};

if (!_isDown) exitWith {false};

[GET_MON] call CFM_fnc_monitorCameraTurnRight;
