/*
    Function: CFM_fnc_setOperatorName
    Author: Vazar & Gemini
    Description:
        Sets the display name of an operator (Operator::_operatorName, PUBLIC GLOBAL FIELD)
        shown in monitor selection menus and operator info hints.
    Parameters:
        0: _operator [Object] - Target operator object (default objNull).
        1: _operatorName [String] - Operator display name string (default "").
        2: _target [Boolean | Number | Object | Array] - MP sync target (true = global, false = local) (default true).
    Returns:
        [Boolean] - true if set successfully, false on invalid arguments.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_operatorName", ""], ["_target", true]];
if (!(IS_OBJ(_operator)) || {!(_operatorName isEqualType "")}) exitWith {false};
private _syncTarget = RESOLVE_SVAR_TARGET(_target);
_operator setVariable ["CFM_operatorName", _operatorName, _syncTarget];
true
