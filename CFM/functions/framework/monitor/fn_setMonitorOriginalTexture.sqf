/*
    Function: CFM_fnc_setMonitorOriginalTexture
    Author: Vazar & Gemini
    Description:
        Sets the fallback original texture path (Monitor::_originalTexture, PUBLIC GLOBAL FIELD) via Monitor::setOriginalTexture,
        updating DisplayHandler and physically applying the texture if the feed is inactive.
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _originalTexture [String] - Texture path or procedural color string (default "").
        2: _target [Boolean | Number | Object | Array] - MP execution target (true = global, false = local) (default true).
    Returns:
        [Boolean | String] - true when executed locally, JIP ID if global, or false on invalid arguments.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_originalTexture", ""], ["_target", true]];
if !(_originalTexture isEqualType "") exitWith {false};
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
if (_target isNotEqualTo false && {MON_GVAR(_monitor, _instId, "CFM_isLocal", false)}) then {_target = false};
["setOriginalTexture", [_originalTexture], _target, false] REMOTE_EXEC_OBJINSTANCE("Monitor", _instId, _monitor);
