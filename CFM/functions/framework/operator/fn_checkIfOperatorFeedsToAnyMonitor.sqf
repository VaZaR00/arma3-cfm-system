/*
    Function: CFM_fnc_checkIfOperatorFeedsToAnyMonitor
    Author: Vazar & Gemini
    Description:
        Checks whether any turret on the operator is currently streaming to at least one monitor.
        Wraps Operator::checkIfFeedsToAnyMonitor (PUBLIC GE GA - State get).
    Parameters:
        0: _operator [Object] - Target operator object (default objNull).
    Returns:
        [Boolean] - true if feeding to at least one monitor, false otherwise.
*/

#include "defines.hpp"

params [["_operator", objNull]];
if !(IS_OBJ(_operator)) exitWith {false};
["checkIfFeedsToAnyMonitor", [], false] CALL_OBJCLASS("Operator", _operator);
