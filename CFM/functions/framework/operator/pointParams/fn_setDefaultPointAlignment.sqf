/*
    Function: CFM_fnc_setDefaultPointAlignment
    Author: Vazar & Gemini
    Description:
        Resets point alignment parameters on all turrets of an operator back to their default class presets.
        Wraps Operator::setDefaultPointAlignment (PUBLIC GE GA - Config set).
    Parameters:
        0: _operator [Object] - Target operator object (default objNull).
    Returns:
        [Boolean | Any] - false on invalid operator, otherwise method result.
*/

#include "defines.hpp"

params [["_operator", objNull]];
if !(IS_OBJ(_operator)) exitWith {false};
["setDefaultPointAlignment", []] CALL_OBJCLASS("Operator", _operator);
