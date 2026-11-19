/*
    Function: CFM_fnc_setMonitorTextureSelection
    Author: Vazar & Gemini
    Description:
        Sets the texture selection index (Monitor::_textureSelection, PUBLIC GLOBAL FIELD) on a monitor instance.
        Values >= 0 target a 3D object texture selection; NO_TEXTURE_SELECTION (-1) indicates a PiP/overlay monitor.
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _textureSelection [Number] - Texture selection index (default NO_TEXTURE_SELECTION).
        2: _target [Boolean | Number | Object | Array] - MP sync target (true = global, false = local) (default true).
    Returns:
        [Boolean] - true if set successfully, false on invalid arguments.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_textureSelection", NO_TEXTURE_SELECTION], ["_target", true]];
if !(_textureSelection isEqualType 0) exitWith {false};
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
private _syncTarget = RESOLVE_SVAR_TARGET(_target);
MON_SVARG(_monitor, _instId, "CFM_textureSelection", _textureSelection, _syncTarget);
true
