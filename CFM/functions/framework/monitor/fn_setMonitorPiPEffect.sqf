/*
    Function: CFM_fnc_setMonitorPiPEffect
    Author: Vazar & Gemini
    Description:
        Sets the PiP visual effect (normal, NVG, TI) on a monitor instance render target.
        Supports local-only execution or targeted/global multiplayer synchronization (LE).
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _pipEffect [Number] - PiP effect index (0 = Normal, 1 = NVG, 2+ = TI modes) (default 0).
        2: _target [Boolean | Number | Object | Array] - MP target (true = global, false = local, clientOwner/object/array) (default true).
    Returns:
        [Boolean] - true if applied/synced, false on invalid arguments.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_pipEffect", 0], ["_target", true]];
if !(_pipEffect isEqualType 0) exitWith {false};
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
if (!isMultiplayer || {_target in [false, clientOwner]}) exitWith {
	private _renderTarget = MON_GVAR(_monitor, _instId, "CFM_monitorR2Tid", "rendertarget0");
	_renderTarget setPiPEffect [_pipEffect];
	MON_SVAR(_monitor, _instId, "CFM_currentPiPEffect", _pipEffect);
	true
};
private _isLocal = MON_GVAR(_monitor, _instId, "CFM_isLocal", false);
private _syncTarget = if (_isLocal) then {false} else {RESOLVE_SVAR_TARGET(_target)};
MON_SVARG(_monitor, _instId, "CFM_currentPiPEffect", _pipEffect, _syncTarget);
MON_SVARG(_monitor, _instId, "CFM_doUpdatePip", true, _syncTarget);
MON_SVARG(_monitor, _instId, "CFM_isInNvg", _pipEffect isEqualTo 1, _syncTarget);
true
