/*
    Function: CFM_fnc_setMonitorTextureSelection
    Author: Vazar & Gemini
    Description:
        Sets the texture selection index (Monitor::_textureSelection, PUBLIC GLOBAL FIELD) via Monitor::setTextureSelection,
        updating textures, DisplayHandler binding, selection bounds cache, labels, and active feeds.
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _textureSelection [Number] - Texture selection index (default NO_TEXTURE_SELECTION).
        2: _target [Boolean | Number | Object | Array] - MP execution target (true = global, false = local) (default true).
    Returns:
        [Boolean | String] - true when executed locally, JIP ID if global, or false on invalid arguments.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_textureSelection", NO_TEXTURE_SELECTION], ["_target", true]];
if !(_textureSelection isEqualType 0) exitWith {false};
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
if (_target isNotEqualTo false && {MON_GVAR(_monitor, _instId, "CFM_isLocal", false)}) then {_target = false};
["setTextureSelection", [_textureSelection], _target, false] REMOTE_EXEC_OBJINSTANCE("Monitor", _instId, _monitor);
