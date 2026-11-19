/*
    Function: CFM_fnc_setDefaultPointAlignment
    Author: Vazar & Gemini
    Description:
        Resets point alignment parameters on all turrets of an operator back to their default class presets
        via Operator::setDefaultPointAlignment and distributes via CFM remoteEvent (REMOTE_EXEC_OBJCLASS).
    Parameters:
        0: _operator [Object] - Target operator object (default objNull).
        1: _target [Boolean | Number | Object | Array] - MP execution target (true = global, false = local) (default true).
    Returns:
        [Boolean | String] - true when executed locally, JIP ID if global, or false on invalid operator.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_target", true]];
if !(IS_OBJ(_operator)) exitWith {false};
["setDefaultPointAlignment", [], _target, false] REMOTE_EXEC_OBJCLASS("Operator", _operator);
