/*
    Function: CFM_fnc_getOperatorName
    Author: Vazar & Gemini
    Description:
        Returns the display name of the operator, preferring a custom turret name if one is configured
        for the specified turret index, otherwise falling back to Operator::_operatorName.
        Wraps Operator::getOperatorName (PUBLIC LE GA - Config get).
    Parameters:
        0: _operator [Object] - Target operator object (default objNull).
        1: _turret [Number | Array] - Turret index or turret path (default -1).
    Returns:
        [String] - Operator or turret display name, or "" on invalid operator.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turret", -1]];
if !(IS_OBJ(_operator)) exitWith {""};
["getOperatorName", [_turret], ""] CALL_OBJCLASS("Operator", _operator);
