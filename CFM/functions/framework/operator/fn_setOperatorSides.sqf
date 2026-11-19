/*
    Function: CFM_fnc_setOperatorSides
    Author: Vazar & Gemini
    Description:
        Sets the allowed sides list (Operator::_opSides) permitted to connect to this operator
        via Operator::setOperatorSides and distributes execution via CFM remoteEvent (REMOTE_EXEC_OBJCLASS).
    Parameters:
        0: _operator [Object] - Target operator object (default objNull).
        1: _sides [Side | Array] - Allowed side or array of sides (default civilian).
        2: _target [Boolean | Number | Object | Array] - MP execution target (true = global, false = local) (default true).
    Returns:
        [Boolean | String] - true when executed locally, JIP ID if global, or false on invalid arguments.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_sides", civilian], ["_target", true]];
if !(IS_OBJ(_operator)) exitWith {false};
["setOperatorSides", [_sides, false], _target, false] REMOTE_EXEC_OBJCLASS("Operator", _operator);
