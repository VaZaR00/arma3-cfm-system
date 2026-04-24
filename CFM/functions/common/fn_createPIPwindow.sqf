/*
    Function: CFM_fnc_createPIPwindow
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params [["_player", objNull], ["_renderTarget", "rendertarget0"], ["_settings", ""]];

disableSerialization;

[_player] call CFM_fnc_closePIPwindow;
sleep 0.01;

_renderTarget cutRsc ["RscTitleDisplayEmpty", "PLAIN"];
waitUntil {!(isNil {uiNamespace getVariable "RscTitleDisplayEmpty"})};
private _display = uiNamespace getVariable "RscTitleDisplayEmpty";

_player setVariable ["CFM_currentRscLayer", _renderTarget];
_player setVariable ["CFM_currentDisplay", _display];

_settings = if ((_settings isEqualType "") && {!(_settings isEqualTo "")}) then {
	_settings
} else {
	missionNamespace getVariable ["CFM_PIPsettings", DEFAULT_PIP_SETTINGS_STR];
};
private _settingsCompiled = call compile _settings;
if ((isNil "_settingsCompiled") || {!(_settingsCompiled isEqualType [])}) then {
	_settingsCompiled = DEFAULT_PIP_SETTINGS;
};
_settingsCompiled params [["_size", 0.2], ["_offsetX", 1], ["_offsetY", 0.8]];

private _w = _size;
private _h = _size;
if (_size isEqualType []) then {
	_w = _size#0;
	_h = _size#1;
};

private _totalW = _w * safeZoneW;
private _totalH = _h * safeZoneH;

private _bgX = safeZoneX + (safeZoneW - _totalW) * _offsetX;
private _bgY = safeZoneY + (safeZoneH - _totalH) * _offsetY;

private _borderSize = 0.004;
private _headerHeight = 0.03;

private _background = _display ctrlCreate ["RscText", -1];
_background ctrlSetBackgroundColor [0, 0, 0, 1];
_background ctrlSetPosition [_bgX, _bgY, _totalW, _totalH];
_background ctrlCommit 0;

private _title = _display ctrlCreate ["RscText", -1];
_title ctrlSetText "CAMERA FEED";
_title ctrlSetTextColor [1, 1, 1, 1];
_title ctrlSetPosition [
    _bgX,
    _bgY,
    _totalW,
    _headerHeight
];
_title ctrlSetScale 0.85;
_title ctrlCommit 0;

private _pictureCtrl = _display ctrlCreate ["RscPicture", -1];

private _picX = _bgX + _borderSize;
private _picY = _bgY + _headerHeight;
private _picW = _totalW - (_borderSize * 2);
private _picH = _totalH - _headerHeight - _borderSize;

_pictureCtrl ctrlSetPosition [_picX, _picY, _picW, _picH];
_pictureCtrl ctrlSetText (format ["#(argb,512,512,1)r2t(%1,1.0)", _renderTarget]);
_pictureCtrl ctrlCommit 0;

_player setVariable ["CFM_currentPictureCtrl", _pictureCtrl];

[_display, _pictureCtrl, _background, _title]
