/*
    Function: CFM_fnc_repositionDynamicControls
    Author: Vazar & Gemini
    Description:
        Evaluates all dynamic HUD control coordinate and font-size formulas against the monitor's
        ScreenResolution (virtual safeZone/pixelGrid mapping + {scaleX, scaleY, offsetX, offsetY})
        and positions/resizes all controls on the display in parent-first order.
    Parameters:
        0: _display [Display] - Target display containing CFM_hudControlsList.
    Returns:
        [Boolean] - true on success, false if display invalid or empty.
*/

#include "defines.hpp"

params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {false};

private _entries = _display getVariable ["CFM_hudControlsList", []];
if (_entries isEqualTo []) exitWith {false};

private _res = [_display] call CFM_fnc_getMonitorScreenResolution;
private _resW = (_res param [0, DEFAULT_UI_SIZE_W]) max 1;
private _resH = (_res param [1, DEFAULT_UI_SIZE_H]) max 1;

private _scaleArr = _res param [2, DEFAULT_UI_SCALE];
if (!(_scaleArr isEqualType []) || {(count _scaleArr) < 2}) then {
	_scaleArr = DEFAULT_UI_SCALE;
};
_scaleArr params [["_sx", 1], ["_sy", 1], ["_ox", 0], ["_oy", 0]];
if !(_sx isEqualType 0) then {_sx = 1;};
if !(_sy isEqualType 0) then {_sy = 1;};
if !(_ox isEqualType 0) then {_ox = 0;};
if !(_oy isEqualType 0) then {_oy = 0;};
if (_sx isEqualTo 0) then {_sx = 1;};
if (_sy isEqualTo 0) then {_sy = 1;};

private _absX = abs _sx;
private _absY = abs _sy;
private _offsetX = if !(_ox isEqualTo 0) then {
	if (_ox < 0) then {1 - _absX + _ox} else {_ox}
} else {
	if (_sx < 0) then {1 - _absX} else {0}
};
private _offsetY = if !(_oy isEqualTo 0) then {
	if (_oy < 0) then {1 - _absY + _oy} else {_oy}
} else {
	if (_sy < 0) then {1 - _absY} else {0}
};

// Virtual 1080p-based safeZone & pixelGrid metrics matching monitor's physical aspect and ScreenResolution scale
private _aspect = _resW / _resH;
private _resScale = _resH / DEFAULT_UI_SIZE_H;
private _vResH = (1080 * _resScale) max 1;
private _vResW = (_vResH * _aspect) max 1;
private _vSZH = 1.0;
private _vSZW = _aspect * 0.75;
private _vSZX = 0.5 - (_vSZW * 0.5);
private _vSZY = 0.0;
private _vPGrid = 12;
private _vPW = _vSZW / _vResW;
private _vPH = _vSZH / _vResH;
private _vGetRes = [_vResW, _vResH, _vResW, _vResH, _aspect, 0.7, 0.75, 0.75 * _aspect, false, 1];
(_display getVariable ["CFM_uiTexResolution", [1024, 1024]]) params [["_texW", 1024], ["_texH", 1024]];
private _texAspect = (_texW max 1) / (_texH max 1);
private _fontScale = ((_absX * _texAspect * 0.75) / _vSZW) min (_absY / _vSZH);

private _fnc_evalDim = {
	params [["_tuple", []], "_fallback", "_isPos", "_origin", "_span"];
	if (_tuple isEqualTo []) exitWith {_fallback};
	_tuple params [["_valOrCode", 0], ["_isCfmMarker", false]];
	private _raw = if (_valOrCode isEqualType 0) then {
		_valOrCode
	} else {
		private _c = call _valOrCode;
		if (!isNil "_c" && {_c isEqualType 0} && {finite _c}) then {_c} else {0}
	};
	if (_isCfmMarker) exitWith {_raw};
	if (_isPos) exitWith {(_raw - _origin) / _span};
	_raw / _span
};

private _fnc_reapplyStructText = {
	params ["_ctrl", "_textStr", "_attrs"];
	private _resolved = _textStr;
	if ((_resolved select [0, 1]) isEqualTo "$") then {
		private _loc = localize (_resolved select [1]);
		if !(_loc isEqualTo "") then {_resolved = _loc;};
	};
	if ((_resolved find "<t") >= 0 || {(_resolved find "<img") >= 0}) exitWith {
		_ctrl ctrlSetStructuredText (parseText _resolved);
	};
	if !(_attrs isEqualTo []) exitWith {
		_attrs params [["_aFont", ""], ["_aColor", ""], ["_aAlign", ""], ["_aValign", ""], ["_aShadow", -1]];
		private _attrParts = [];
		if !(_aFont isEqualTo "") then {_attrParts pushBack format ["font='%1'", _aFont];};
		if !(_aColor isEqualTo "") then {_attrParts pushBack format ["color='%1'", _aColor];};
		if !(_aAlign isEqualTo "") then {_attrParts pushBack format ["align='%1'", _aAlign];};
		if (_aShadow >= 0) then {_attrParts pushBack format ["shadow='%1'", _aShadow];};
		if (_attrParts isEqualTo []) then {
			_ctrl ctrlSetStructuredText (parseText _resolved);
		} else {
			_ctrl ctrlSetStructuredText (parseText format ["<t %1>%2</t>", _attrParts joinString " ", _resolved]);
		};
	};
	_ctrl ctrlSetStructuredText (parseText _resolved);
};

{
	_x params ["_ctrl", "_node", "_isTopLevel", ["_structAttrs", []]];
	if (isNull _ctrl) then {continue};

	(ctrlPosition _ctrl) params [["_curX", 0], ["_curY", 0], ["_curW", 0], ["_curH", 0]];

	private _xOrigin = if (_isTopLevel) then {_vSZX} else {0};
	private _yOrigin = if (_isTopLevel) then {_vSZY} else {0};

	private _normX = [_node getOrDefault ["x", []], _curX, _isTopLevel, _xOrigin, _vSZW] call _fnc_evalDim;
	private _normY = [_node getOrDefault ["y", []], _curY, _isTopLevel, _yOrigin, _vSZH] call _fnc_evalDim;
	private _normW = [_node getOrDefault ["w", []], _curW, false, 0, _vSZW] call _fnc_evalDim;
	private _normH = [_node getOrDefault ["h", []], _curH, false, 0, _vSZH] call _fnc_evalDim;

	private _finalX = if (_isTopLevel) then {_offsetX + (_normX * _absX)} else {_normX * _absX};
	private _finalY = if (_isTopLevel) then {_offsetY + (_normY * _absY)} else {_normY * _absY};
	private _finalW = _normW * _absX;
	private _finalH = _normH * _absY;

	private _ctrlType = _node getOrDefault ["ctrlType", 0];
	private _ctrlStyle = _node getOrDefault ["ctrlStyle", 0];
	private _typeNibble = ((floor (_ctrlStyle / 16)) mod 16) * 16;
	private _isPic = (_ctrlType isEqualTo 0) && {_typeNibble in [48, 144]};

	if (_ctrlType in [100, 101]) then {
		_ctrl ctrlMapSetPosition [_finalX, _finalY, _finalW, _finalH];
	} else {
		_ctrl ctrlSetPosition [_finalX, _finalY, _finalW, _finalH];
	};

	private _sizeTuple = _node getOrDefault ["size", []];
	if (!_isPic && {!(_sizeTuple isEqualTo [])}) then {
		_sizeTuple params [["_sValOrCode", 0], ["_isCfmSize", false]];
		private _rawSize = if (_sValOrCode isEqualType 0) then {
			_sValOrCode
		} else {
			private _sc = call _sValOrCode;
			if (!isNil "_sc" && {_sc isEqualType 0} && {finite _sc}) then {_sc} else {0}
		};
		private _finalSize = if (_isCfmSize) then {_rawSize * (_absX min _absY)} else {_rawSize * _fontScale};
		if (_finalSize > 0) then {
			_ctrl ctrlSetFontHeight _finalSize;
			if (_ctrlType isEqualTo 13) then {
				private _initText = (_node getOrDefault ["fallbackProps", []]) param [0, ""];
				if !(_initText isEqualTo "") then {
					[_ctrl, _initText, _structAttrs] call _fnc_reapplyStructText;
				};
			};
		};
	};

	_ctrl ctrlCommit 0;
} forEach _entries;

true
