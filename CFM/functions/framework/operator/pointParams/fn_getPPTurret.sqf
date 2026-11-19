/*
    Function: CFM_fnc_getPPTurret
    Author: Vazar & Gemini
    Description:
        Retrieves a specific pointParams value (PP_POS, PP_DIR, PP_UP, PP_MEMPOINT, PP_ADDARR, PP_SETARR, PP_LOD)
        from the specified operator turret.
        Wraps Operator::getPPTurret (PUBLIC GE GA - Config get).
    Parameters:
        0: _operator [Object] - Target operator object (default objNull).
        1: _turretIndex [Number | Array] - Turret index or path (default -1).
        2: _ppParam [String] - Point parameter constant to query.
        3: _def [Any] - Default fallback value if parameter or turret is missing (default nil).
    Returns:
        [Any] - Stored point parameter value or _def.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turretIndex", -1], ["_ppParam", ""], ["_def", nil]];
if !(IS_OBJ(_operator)) exitWith {_NIL(_def)};
["getPPTurret", [_turretIndex, _ppParam, _NIL(_def)], _NIL(_def)] CALL_OBJCLASS("Operator", _operator);
