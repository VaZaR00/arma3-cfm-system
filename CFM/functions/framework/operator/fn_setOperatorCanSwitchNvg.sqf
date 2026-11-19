/*
    Function: CFM_fnc_setOperatorCanSwitchNvg
    Author: Vazar & Gemini
    Description:
        Sets whether monitors connected to this operator can toggle Night Vision (NVG) mode by default
        (Operator::_canSwitchNvg, PUBLIC GLOBAL FIELD).
    Parameters:
        0: _operator [Object] - Target operator object (default objNull).
        1: _canSwitchNvg [Boolean] - True to allow NVG switching, false to disable (default false).
        2: _target [Boolean | Number | Object | Array] - MP sync target (true = global, false = local) (default true).
    Returns:
        [Boolean] - true if set successfully, false on invalid arguments.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_canSwitchNvg", false], ["_target", true]];
if (!(IS_OBJ(_operator)) || {!(_canSwitchNvg isEqualType false)}) exitWith {false};
private _syncTarget = RESOLVE_SVAR_TARGET(_target);
_operator setVariable ["CFM_canSwitchNvg", _canSwitchNvg, _syncTarget];
true
