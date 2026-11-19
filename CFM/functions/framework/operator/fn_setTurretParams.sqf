/*
    Function: CFM_fnc_setTurretParams
    Author: Vazar & Gemini
    Description:
        Initializes or updates a turret instance on an operator with the provided configuration parameters.
        Executes exclusively on the server (forwards via remote execution when called from a client).
        Wraps Operator::setTurretParams (PUBLIC SE - Config set).
    Parameters:
        0: _operator [Object] - Target operator object.
        1: _turretIndex [Number | Array] - Turret index or path (default -1).
        2+: Optional turret init parameters (turretObject, canMoveCamera, zoomTable, nvgAndTi, pointParams, etc.).
    Returns:
        [Boolean | Any] - Execution result on server, or false on invalid operator.
*/

#include "defines.hpp"

params [["_operator", objNull]];
if !(IS_OBJ(_operator)) exitWith {false};
private _args = _this select [1, (count _this - 1) max 0];
if (isServer) exitWith {
	["setTurretParams", _args] CALL_OBJCLASS("Operator", _operator);
};
["setTurretParams", _args, 2] REMOTE_EXEC_OBJCLASS("Operator", _operator);
