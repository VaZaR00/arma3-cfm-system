/*
    Function: CFM_fnc_getTurretPPParam
    Author: Vazar & Gemini
    Description:
        Retrieves a specific pointParams value (PP_POS, PP_DIR, PP_UP, PP_MEMPOINT, PP_ADDARR, PP_SETARR, PP_LOD)
        directly from a Turret class instance.
        Wraps Turret::getPPParam (PUBLIC LE GA LOCAL - Config get).
    Parameters:
        0: _operator [Object | Array] - Operator object or [operatorObject, turretIndex] pair.
        1: _turret [Number | Array] - Turret index or turret path (default -1).
        2: _ppParam [String] - Point parameter constant to query.
        3: _def [Any] - Default fallback value if parameter or turret is missing (default nil).
    Returns:
        [Any] - Stored point parameter value or _def.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turret", -1], ["_ppParam", ""], ["_def", nil]];
(RESOLVE_TURRET(_operator, _turret)) params ["_turretObject", "_turretInstanceId"];
if (!(IS_OBJ(_turretObject)) || {_turretInstanceId < 1}) exitWith {_NIL(_def)};
["getPPParam", [_ppParam, _NIL(_def)], _NIL(_def)] CALL_OBJINSTANCE("Turret", _turretInstanceId, _turretObject);
