/*
    Function: CFM_fnc_isOperatorTurretDisabled
    Author: Vazar & Gemini
    Description:
        Checks whether the specified turret index is listed as disabled on the operator.
        Wraps Operator::isTurretDisabled (PUBLIC LE GA - State get).
    Parameters:
        0: _operator [Object] - Target operator object (default objNull).
        1: _turretIndex [Number | Array] - Turret index or turret path (default -1).
    Returns:
        [Boolean] - true if turret is disabled on the operator, false otherwise.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turretIndex", -1]];
if !(IS_OBJ(_operator)) exitWith {false};
["isTurretDisabled", [_turretIndex], false] CALL_OBJCLASS("Operator", _operator);
