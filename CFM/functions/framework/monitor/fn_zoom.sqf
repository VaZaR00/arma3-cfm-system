/*
    Function: CFM_fnc_zoom
    Author: Vazar & Gemini
    Description:
        Adjusts, sets, or resets the camera zoom level on a monitor instance.
        Supports discrete step changes, explicit zoom level, "reset", "op", and continuous frame updates.
        Wraps Monitor::zoom (PUBLIC GE GA - State set).
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _zoomAdd [Number | String] - Relative zoom delta, or "reset" / "op" mode string (default 0).
        2: _zoomSet [Number] - Explicit target zoom level when >= 1, or -1 to use _zoomAdd (default -1).
        3: _isContinuous [Boolean] - True when invoked per-frame during continuous zoom hold (default false).
    Returns:
        [Number | String | Boolean] - New zoom value/mode, or false on invalid monitor.
*/

#include "defines.hpp"

params [["_monArg", 0], ["_zoomAdd", 0], ["_zoomSet", -1], ["_isContinuous", false]];
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
["zoom", [_zoomAdd, _zoomSet, _isContinuous]] CALL_MON_INST(_monitor, _instId);
