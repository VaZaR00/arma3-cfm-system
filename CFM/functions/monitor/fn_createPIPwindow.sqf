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

waitUntil {
    private _lockScript = missionNamespace getVariable ["CFM_creatingPipDisplayScript", scriptNull];
    isNull _lockScript || {scriptDone _lockScript}
};
missionNamespace setVariable ["CFM_creatingPipDisplayScript", _thisScript];

if (
    !(MON_GVAR(_player, _instId, "CFM_feedActive", false)) ||
    {MON_GVAR(_player, _instId, "CFM_turnedOffLocal", false)} ||
    {MON_GVAR(_player, _instId, "CFM_isVehSeatTablet", false) && {!([_player, _instId] call CFM_fnc_inVehicleTabletSeatCondition)}}
) exitWith {
    missionNamespace setVariable ["CFM_creatingPipDisplayScript", scriptNull];
};

if (isNil {_player getVariable (MON_VAR_NAME("CFM_pipSlot", _instId))}) then {
    MON_SVAR(_player, _instId, "CFM_pipSlot", [_monPair] call CFM_fnc_getFreePipSlot);
};

private _otherMons = [_monPair] call CFM_fnc_getOtherPipMonitors;
private _usedLayers = [];
private _maxOtherLayer = -1;
private _minOtherLayer = 1e9;
{
    if ([_x] call CFM_fnc_isPipVisible) then {
        _x params ["_oMon", "_oId"];
        private _oLayer = MON_GVAR(_oMon, _oId, "CFM_currentRscLayer", -1);
        if (_oLayer isEqualType 0 && {_oLayer >= 0}) then {
            _usedLayers pushBackUnique _oLayer;
            if (_oLayer > _maxOtherLayer) then {_maxOtherLayer = _oLayer};
            if (_oLayer < _minOtherLayer) then {_minOtherLayer = _oLayer};
        };
    };
} forEach _otherMons;

private _isFullscreen = missionNamespace getVariable ["CFM_isInPIPFullScreen", false];
private _isVehMon = MON_GVAR(_player, _instId, "CFM_isVehSeatTablet", false);
private _isSelected = _isFullscreen || {
    ([_player, _instId] call CFM_fnc_isSelectedTablet) &&
    {!_isVehMon || {([_player] call CFM_fnc_getSelectedMonitorInstance) isEqualTo _instId}}
};

private _layerId = if (_usedLayers isNotEqualTo []) then {
    if (_isSelected) then {
        _maxOtherLayer + 1
    } else {
        private _cand = (_minOtherLayer - 1) max 1;
        while {_cand in _usedLayers} do {
            _cand = _cand + 1;
        };
        _cand
    }
} else {
    PIP_BASE_LAYER
};

uiNamespace setVariable ["RscTitleDisplayEmpty", displayNull];
_layerId cutRsc ["RscTitleDisplayEmpty", "PLAIN"];
waitUntil {!isNull (uiNamespace getVariable ["RscTitleDisplayEmpty", displayNull])};
private _display = uiNamespace getVariable "RscTitleDisplayEmpty";

MON_SVAR(_player, _instId, "CFM_currentRscLayer", _layerId);
MON_SVAR(_player, _instId, "CFM_currentDisplay", _display);
missionNamespace setVariable ["CFM_creatingPipDisplayScript", scriptNull];

([_monPair, _settings] call CFM_fnc_calcPipControlsPositions) params ["_bgPos", "_titlePos", "_picPos"];

private _background = _display ctrlCreate ["RscText", -1];
_background ctrlSetBackgroundColor [0, 0, 0, 1];
_background ctrlSetPosition _bgPos;
_background ctrlCommit 0;

private _title = _display ctrlCreate ["RscText", -1];
private _titleText = CFM_STR_CAMERA_FEED;
([_player, _instId] call CFM_fnc_getSeatPipOrdinal) params ["_pipOrd", "_pipTot"];
if (_pipOrd > 0 && {_pipTot > 1}) then {
    _titleText = format ["%1 [%2]", CFM_STR_CAMERA_FEED, _pipOrd];
};
_title ctrlSetText _titleText;
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
