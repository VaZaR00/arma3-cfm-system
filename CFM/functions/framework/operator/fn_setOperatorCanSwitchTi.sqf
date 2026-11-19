/*
    Function: CFM_fnc_setOperatorCanSwitchTi
    Author: Vazar & Gemini
    Description:
        Sets whether monitors connected to this operator can cycle Thermal Imaging (TI) modes
        (Operator::_canSwitchTi, PUBLIC GLOBAL FIELD) via Operator::setCanSwitchTi and syncs connected monitors.
    Parameters:
        0: _operator [Object] - Target operator object (default objNull).
        1: _canSwitchTi [Boolean] - True to allow TI switching, false to disable (default false).
        2: _target [Boolean | Number | Object | Array] - MP execution target (true = global, false = local) (default true).
    Returns:
        [Boolean | String] - true when executed locally, JIP ID if global, or false on invalid arguments.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_canSwitchTi", false], ["_target", true]];
if (!(IS_OBJ(_operator)) || {!(_canSwitchTi isEqualType false)}) exitWith {false};
["setCanSwitchTi", [_canSwitchTi], _target, false] REMOTE_EXEC_OBJCLASS("Operator", _operator);
