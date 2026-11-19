/*
    Function: CFM_fnc_setOperatorCanFeed
    Author: Vazar & Gemini
    Description:
        Enables or disables an operator's ability to stream video feeds (Operator::_canFeed, PUBLIC GLOBAL FIELD)
        via Operator::setCanFeed, stopping active feeds on connected monitors if disabled.
    Parameters:
        0: _operator [Object] - Target operator object (default objNull).
        1: _canFeed [Boolean] - True to allow feeding, false to suspend/disallow feeding (default false).
        2: _target [Boolean | Number | Object | Array] - MP execution target (true = global, false = local) (default true).
    Returns:
        [Boolean | String] - true when executed locally, JIP ID if global, or false on invalid arguments.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_canFeed", false], ["_target", true]];
if (!(IS_OBJ(_operator)) || {!(_canFeed isEqualType false)}) exitWith {false};
["setCanFeed", [_canFeed], _target, false] REMOTE_EXEC_OBJCLASS("Operator", _operator);
