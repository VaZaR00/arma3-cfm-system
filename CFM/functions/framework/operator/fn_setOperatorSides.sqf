/*
    Function: CFM_fnc_setOperatorSides
    Author: Vazar & Gemini
    Description:
        Sets the allowed sides list (Operator::_opSides) permitted to connect to this operator
        and broadcasts the change globally.
        Wraps Operator::setOperatorSides (PUBLIC GE GA - Config set).
    Parameters:
        0: _operator [Object] - Target operator object (default objNull).
        1: _sides [Side | Array] - Allowed side or array of sides (default civilian).
    Returns:
        [Boolean] - true if sides were valid and updated, false otherwise.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_sides", civilian]];
if !(IS_OBJ(_operator)) exitWith {false};
["setOperatorSides", [_sides, true], false] CALL_OBJCLASS("Operator", _operator);
