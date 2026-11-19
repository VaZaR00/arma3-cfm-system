/*
    Function: CFM_fnc_setOperatorCanSwitchNvg
    Author: Vazar & Gemini
    Description:
        Sets whether monitors connected to this operator can toggle Night Vision (NVG) mode
        (Operator::_canSwitchNvg, PUBLIC GLOBAL FIELD) via Operator::setCanSwitchNvg and syncs connected monitors.
    Parameters:
        0: _operator [Object] - Target operator object (default objNull).
        1: _canSwitchNvg [Boolean] - True to allow NVG switching, false to disable (default false).
        2: _target [Boolean | Number | Object | Array] - MP execution target (true = global, false = local) (default true).
    Returns:
        [Boolean | String] - true when executed locally, JIP ID if global, or false on invalid arguments.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_canSwitchNvg", false], ["_target", true]];
if (!(IS_OBJ(_operator)) || {!(_canSwitchNvg isEqualType false)}) exitWith {false};
["setCanSwitchNvg", [_canSwitchNvg], _target, false] REMOTE_EXEC_OBJCLASS("Operator", _operator);
