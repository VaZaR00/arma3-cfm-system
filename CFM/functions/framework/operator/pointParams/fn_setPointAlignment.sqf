/*
    Function: CFM_fnc_setPointAlignment
    Author: Vazar & Gemini
    Description:
        Sets the camera point alignment parameters for an operator turret and updates its compiled pointParams.
        Wraps Operator::setPointParams (PUBLIC GE GA - Config set).
    Parameters:
        0: _operator [Object] - Target operator object (default objNull).
        1: _turretIndex [Number | Array] - Turret index or path (default -1).
        2: _params [Array | Number] - Point alignment params array or -1 to reset to class default (default []).
        3: _ppType [Number] - Legacy point params type parameter (unused by Operator::setPointParams) (default -2).
        4: _setVar [Boolean] - Legacy set variable flag (default true).
    Returns:
        [Array | Boolean] - Updated compiled pointParams array, or false on invalid operator.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turretIndex", -1], ["_params", []], ["_ppType", -2], ["_setVar", true]];
if !(IS_OBJ(_operator)) exitWith {false};
["setPointParams", [_turretIndex, _params, _ppType, _setVar]] CALL_OBJCLASS("Operator", _operator);
