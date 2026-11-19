/*
    Function: CFM_fnc_setOperatorCanSwitchTi
    Author: Vazar & Gemini
    Description:
        Sets whether monitors connected to this operator can cycle Thermal Imaging (TI) modes by default
        (Operator::_canSwitchTi, PUBLIC GLOBAL FIELD).
    Parameters:
        0: _operator [Object] - Target operator object (default objNull).
        1: _canSwitchTi [Boolean] - True to allow TI switching, false to disable (default false).
        2: _target [Boolean | Number | Object | Array] - MP sync target (true = global, false = local) (default true).
    Returns:
        [Boolean] - true if set successfully, false on invalid arguments.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_canSwitchTi", false], ["_target", true]];
if (!(IS_OBJ(_operator)) || {!(_canSwitchTi isEqualType false)}) exitWith {false};
private _syncTarget = RESOLVE_SVAR_TARGET(_target);
_operator setVariable ["CFM_canSwitchTi", _canSwitchTi, _syncTarget];
true
