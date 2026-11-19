/*
    Function: CFM_fnc_setPPTurret
    Author: Vazar & Gemini
    Description:
        Updates a single pointParams field (PP_POS, PP_DIR, PP_UP, PP_MEMPOINT, PP_ADDARR, PP_SETARR, PP_LOD)
        on the specified operator turret and synchronizes changes to active viewers.
        Wraps Operator::setPPTurret (PUBLIC GE GA - Config set).
    Parameters:
        0: _operator [Object] - Target operator object (default objNull).
        1: _turretIndex [Number | Array] - Turret index or path (default -1).
        2: _ppParam [String] - Point parameter constant (PP_POS, PP_DIR, PP_UP, PP_MEMPOINT, PP_ADDARR, PP_SETARR, PP_LOD).
        3: _value [Any] - New value for the specified point parameter.
    Returns:
        [Boolean] - true if updated and synced, false otherwise.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turretIndex", -1], ["_ppParam", ""], ["_value", nil]];
if !(IS_OBJ(_operator)) exitWith {false};
["setPPTurret", [_turretIndex, _ppParam, _NIL(_value)]] CALL_OBJCLASS("Operator", _operator);
