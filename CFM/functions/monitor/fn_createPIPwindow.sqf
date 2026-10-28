/*
    Function: CFM_fnc_createPIPwindow
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params [["_player", objNull], ["_renderTarget", "rendertarget0"], ["_settings", ""], ["_isUI", false]];

if !(IS_OBJ(_player)) exitWith {};

disableSerialization;

[_player, false] call CFM_fnc_closePIPwindow;
sleep 0.01;

if !(_player getVariable ["CFM_feedActive", false]) exitWith {};
if (_player getVariable ["CFM_turnedOffLocal", false]) exitWith {};
if ((_player getVariable ["CFM_isVehTablet", false]) && {!([_player] call CFM_fnc_inVehicleTabletSeatCondition)}) exitWith {};

if (isNil {_player getVariable "CFM_pipSlot"}) then {
    _player setVariable ["CFM_pipSlot", [_player] call CFM_fnc_getFreePipSlot];
};

private _otherMon = [_player] call CFM_fnc_getOtherTabletMonitor;
private _otherVisible = [_otherMon] call CFM_fnc_isPipVisible;
private _otherLayer = if (_otherVisible) then {_otherMon getVariable ["CFM_currentRscLayer", -1]} else {-1};
private _isFullscreen = missionNamespace getVariable ["CFM_isInPIPFullScreen", false];
private _isSelected = _isFullscreen || {[_player] call CFM_fnc_isSelectedTablet};

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

_player setVariable ["CFM_currentRscLayer", _layerId];
_player setVariable ["CFM_currentDisplay", _display];

([_player, _settings] call CFM_fnc_calcPipControlsPositions) params ["_bgPos", "_titlePos", "_picPos"];

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
    ["startRenderingUI", [true, _pictureCtrl]] SPAWN_OBJCLASS("DisplayHandler", _player);
} else {
    _pictureCtrl ctrlSetText (format ["#(argb,512,512,1)r2t(%1,1.0)", _renderTarget]);
    _pictureCtrl ctrlCommit 0;
    [_player, _player getVariable ["CFM_currentPiPEffect", 0]] call CFM_fnc_setMonitorPiPEffect;
};

_player setVariable ["CFM_currentPictureCtrl", _pictureCtrl];
_player setVariable ["CFM_currentPipControls", [_background, _title, _pictureCtrl]];

private _prevWatchHndl = _player getVariable ["CFM_pipWatchHndl", scriptNull];
if (!isNull _prevWatchHndl && {!(scriptDone _prevWatchHndl)}) then {
    terminate _prevWatchHndl;
};
private _watchHndl = _player spawn {
    waitUntil {
        sleep 0.5;
        !(_this getVariable ["CFM_feedActive", false])
        || {_this getVariable ["CFM_turnedOffLocal", false]}
        || {(_this getVariable ["CFM_isVehTablet", false]) && {!([_this] call CFM_fnc_inVehicleTabletSeatCondition)}}
    };
    [_this] call CFM_fnc_closePIPwindow;
};
_player setVariable ["CFM_pipWatchHndl", _watchHndl];

[_display, _pictureCtrl, _background, _title]
