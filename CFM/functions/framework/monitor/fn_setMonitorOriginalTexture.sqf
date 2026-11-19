/*
    Function: CFM_fnc_setMonitorOriginalTexture
    Author: Vazar & Gemini
    Description:
        Sets the fallback original texture path (Monitor::_originalTexture, PUBLIC GLOBAL FIELD) restored
        on the monitor selection when the video feed stops.
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _originalTexture [String] - Texture path or procedural color string (default "").
        2: _target [Boolean | Number | Object | Array] - MP sync target (true = global, false = local) (default true).
    Returns:
        [Boolean] - true if set successfully, false on invalid arguments.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_originalTexture", ""], ["_target", true]];
if !(_originalTexture isEqualType "") exitWith {false};
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
private _syncTarget = RESOLVE_SVAR_TARGET(_target);
MON_SVARG(_monitor, _instId, "CFM_originalTexture", _originalTexture, _syncTarget);
true
