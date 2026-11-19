/*
    Function: CFM_fnc_setOperatorName
    Author: Vazar & Gemini
    Description:
        Sets the display name of an operator (Operator::_operatorName, PUBLIC GLOBAL FIELD)
        via Operator::setOperatorName and updates operator info text on connected active monitors.
    Parameters:
        0: _operator [Object] - Target operator object (default objNull).
        1: _operatorName [String] - Operator display name string (default "").
        2: _target [Boolean | Number | Object | Array] - MP execution target (true = global, false = local) (default true).
    Returns:
        [Boolean | String] - true when executed locally, JIP ID if global, or false on invalid arguments.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_operatorName", ""], ["_target", true]];
if (!(IS_OBJ(_operator)) || {!(_operatorName isEqualType "")}) exitWith {false};
["setOperatorName", [_operatorName], _target, false] REMOTE_EXEC_OBJCLASS("Operator", _operator);
