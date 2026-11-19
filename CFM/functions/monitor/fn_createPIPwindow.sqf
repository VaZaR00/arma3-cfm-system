/*
    Function: CFM_fnc_createPIPwindow
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params [["_monArg", objNull], ["_renderTarget", "rendertarget0"], ["_settings", ""], ["_isUI", false]];

(RESOLVE_MON(_monArg)) params ["_player", "_instId"];
if (!(IS_OBJ(_player)) || {_instId < 1}) exitWith {};
private _monPair = [_player, _instId];

disableSerialization;

[_monPair, false] call CFM_fnc_closePIPwindow;
sleep 0.01;

if !(MON_GVAR(_player, _instId, "CFM_feedActive", false)) exitWith {};
if (MON_GVAR(_player, _instId, "CFM_turnedOffLocal", false)) exitWith {};
if (MON_GVAR(_player, _instId, "CFM_isVehSeatTablet", false) && {!([_player, _instId] call CFM_fnc_inVehicleTabletSeatCondition)}) exitWith {};

if (isNil {_player getVariable (MON_VAR_NAME("CFM_pipSlot", _instId))}) then {
    MON_SVAR(_player, _instId, "CFM_pipSlot", [_monPair] call CFM_fnc_getFreePipSlot);
};

private _otherMonPair = [_monPair] call CFM_fnc_getOtherTabletMonitor;
private _otherVisible = [_otherMonPair] call CFM_fnc_isPipVisible;
private _otherLayer = if (_otherVisible) then {
    MON_GVAR(_otherMonPair select 0, _otherMonPair select 1, "CFM_currentRscLayer", -1)
} else {-1};
private _isFullscreen = missionNamespace getVariable ["CFM_isInPIPFullScreen", false];
private _isSelected = _isFullscreen || {[_player, _instId] call CFM_fnc_isSelectedTablet};

private _layerId = if (_otherVisible && {_otherLayer isEqualType 0} && {_otherLayer >= 0}) then {
    if (_isSelected) then {
        _otherLayer + 1
    } else {
        (_otherLayer - 1) max 1
    }
} else {
    PIP_BASE_LAYER
};

waitUntil {
    private _lockScript = missionNamespace getVariable ["CFM_creatingPipDisplayScript", scriptNull];
    isNull _lockScript || {scriptDone _lockScript}
};
missionNamespace setVariable ["CFM_creatingPipDisplayScript", _thisScript];
uiNamespace setVariable ["RscTitleDisplayEmpty", displayNull];
_layerId cutRsc ["RscTitleDisplayEmpty", "PLAIN"];
waitUntil {!isNull (uiNamespace getVariable ["RscTitleDisplayEmpty", displayNull])};
private _display = uiNamespace getVariable "RscTitleDisplayEmpty";
missionNamespace setVariable ["CFM_creatingPipDisplayScript", scriptNull];

MON_SVAR(_player, _instId, "CFM_currentRscLayer", _layerId);
MON_SVAR(_player, _instId, "CFM_currentDisplay", _display);

([_monPair, _settings] call CFM_fnc_calcPipControlsPositions) params ["_bgPos", "_titlePos", "_picPos"];

private _background = _display ctrlCreate ["RscText", -1];
_background ctrlSetBackgroundColor [0, 0, 0, 1];
_background ctrlSetPosition _bgPos;
_background ctrlCommit 0;

private _title = _display ctrlCreate ["RscText", -1];
_title ctrlSetText CFM_STR_CAMERA_FEED;
_title ctrlSetTextColor [1, 1, 1, 1];
_title ctrlSetPosition _titlePos;
_title ctrlSetScale 0.85;
_title ctrlCommit 0;

private _pictureCtrl = _display ctrlCreate ["RscPicture", -1];
_pictureCtrl ctrlSetPosition _picPos;
_pictureCtrl ctrlCommit 0;

if (_isUI) then {
    private _dhId = MON_GVAR(_player, _instId, "CFM_displayHandlerId", -1);
    if (_dhId > 0) then {
        ["startRenderingUI", [true, _pictureCtrl]] SPAWN_DH_INST(_player, _dhId);
    };
} else {
    _pictureCtrl ctrlSetText (format ["#(argb,512,512,1)r2t(%1,1.0)", _renderTarget]);
    _pictureCtrl ctrlCommit 0;
    [_monPair, MON_GVAR(_player, _instId, "CFM_currentPiPEffect", 0), false] call CFM_fnc_setMonitorPiPEffect;
};

MON_SVAR(_player, _instId, "CFM_currentPictureCtrl", _pictureCtrl);
MON_SVAR(_player, _instId, "CFM_currentPipControls", [_background I _title I _pictureCtrl]);

private _prevWatchHndl = MON_GVAR(_player, _instId, "CFM_pipWatchHndl", scriptNull);
if (!isNull _prevWatchHndl && {!(scriptDone _prevWatchHndl)}) then {
    terminate _prevWatchHndl;
};
private _watchHndl = _monPair spawn {
    params ["_mon", "_id"];
    waitUntil {
        sleep 0.5;
        !(MON_GVAR(_mon, _id, "CFM_feedActive", false))
        || {MON_GVAR(_mon, _id, "CFM_turnedOffLocal", false)}
        || {(MON_GVAR(_mon, _id, "CFM_isVehSeatTablet", false)) && {!([_mon, _id] call CFM_fnc_inVehicleTabletSeatCondition)}}
    };
    [[_mon, _id]] call CFM_fnc_closePIPwindow;
};
MON_SVAR(_player, _instId, "CFM_pipWatchHndl", _watchHndl);

[_display, _pictureCtrl, _background, _title]
