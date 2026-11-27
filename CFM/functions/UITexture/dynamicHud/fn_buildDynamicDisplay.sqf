/*
    Function: CFM_fnc_buildDynamicDisplay
    Author: Vazar & Gemini
    Description:
        Builds a dynamic HUD display inside CFM's procedural RscDisplayR2TDisplayCFM canvas
        from a parsed display blueprint, isolates uiNamespace variables per monitor, merges
        optional declarative custom bindings, and scales controls via ScreenResolution.
    Parameters:
        0: _monPair [Array] - [monitorObject, instanceId] pair.
        1: _display [Display] - Target RscDisplayR2TDisplayCFM display instance.
        2: _displayClass [String | Config] - Source HUD display class name or config path.
        3: _uiDisplayUniqueName [String] - Unique display name suffix for uiNamespace scoping.
        4: _forceBuild [Boolean] - Force build even if CFM_enableDynamicHud is false (explicit Turret HUD).
    Returns:
        [Array] - [_r2tPictureCtrl, [_effectCtrl1, _effectCtrl2]]
*/

#include "defines.hpp"

params [
	["_monPair", [], [[]]],
	["_display", displayNull, [displayNull]],
	["_displayClass", "", ["", configNull]],
	["_uiDisplayUniqueName", "", [""]],
	["_forceBuild", false, [false]]
];

if (isNull _display) exitWith {[controlNull, []]};

// Ensure R2T picture and both effect layers exist underneath all dynamic HUD controls
private _r2tCtrl = _display displayCtrl 1488;
private _eff1 = _display displayCtrl 1489;
private _eff2 = _display displayCtrl 1490;
if (isNull _eff2) then {
	_eff2 = _display ctrlCreate ["RscPicture", 1490];
};

[_display, "RscDisplayR2TDisplayCFM"] call CFM_fnc_repositionControls;
private _vpPos = if !(isNull _r2tCtrl) then {ctrlPosition _r2tCtrl} else {[0, 0, 1, 1]};
{
	if !(isNull _x) then {
		_x ctrlSetPosition _vpPos;
		if !(_x isEqualTo _r2tCtrl) then {
			_x ctrlSetText "";
		};
		_x ctrlShow true;
		_x ctrlCommit 0;
	};
} forEach [_r2tCtrl, _eff1, _eff2];

if (!_forceBuild && {!(missionNamespace getVariable ["CFM_enableDynamicHud", true])}) exitWith {
	_display setVariable ["CFM_hudControlsList", []];
	_display setVariable ["CFM_hudActiveBindings", []];
	[_r2tCtrl, [_eff1, _eff2]]
};

private _blueprint = [_displayClass] call CFM_fnc_parseDynamicDisplayConfig;
if (_blueprint isEqualTo createHashMap) exitWith {
	_display setVariable ["CFM_hudControlsList", []];
	_display setVariable ["CFM_hudActiveBindings", []];
	[_r2tCtrl, [_eff1, _eff2]]
};

private _createdList = [];
private _ctrlsByIdc = createHashMap;
private _ctrlsByClass = createHashMap;
private _ctrlsByVar = createHashMap;
private _activeBindings = [];

private _fnc_resolveNodeCfg = {
	params ["_cfgRootName", "_cfgPathArr"];
	private _cfg = if (_cfgRootName isEqualTo "missionConfigFile") then {missionConfigFile} else {configFile};
	{
		_cfg = _cfg >> _x;
		if (isNull _cfg) exitWith {};
	} forEach _cfgPathArr;
	_cfg
};

private _fnc_formatStructText = {
	params ["_textStr", "_attrs"];
	if ((_textStr find "<t") >= 0 || {(_textStr find "<img") >= 0}) exitWith {parseText _textStr};
	_attrs params [["_aFont", ""], ["_aColor", ""], ["_aAlign", ""], ["_aValign", ""], ["_aShadow", -1]];
	private _attrParts = [];
	if !(_aFont isEqualTo "") then {_attrParts pushBack format ["font='%1'", _aFont];};
	if !(_aColor isEqualTo "") then {_attrParts pushBack format ["color='%1'", _aColor];};
	if !(_aAlign isEqualTo "") then {_attrParts pushBack format ["align='%1'", _aAlign];};
	if (_aShadow >= 0) then {_attrParts pushBack format ["shadow='%1'", _aShadow];};
	if (_attrParts isEqualTo []) exitWith {parseText _textStr};
	parseText format ["<t %1>%2</t>", _attrParts joinString " ", _textStr]
};

private _fnc_spawnNodes = {
	params ["_nodes", "_parentGrp"];
	private _isTopLevel = isNull _parentGrp;
	{
		private _node = _x;
		private _className = _node getOrDefault ["className", ""];
		private _cfgRootName = _node getOrDefault ["cfgRoot", "configFile"];
		private _cfgPathArr = _node getOrDefault ["cfgPath", []];
		private _origIdc = _node getOrDefault ["origIdc", -1];
		private _assignedIdc = _node getOrDefault ["assignedIdc", -1];
		private _isGroup = _node getOrDefault ["isGroup", false];
		private _ctrlType = _node getOrDefault ["ctrlType", 0];
		private _ctrlStyle = _node getOrDefault ["ctrlStyle", 0];
		private _fade = _node getOrDefault ["fade", 0];
		private _show = _node getOrDefault ["show", 1];
		private _uiVars = _node getOrDefault ["uiVars", []];
		private _isSafeOnLoad = _node getOrDefault ["isSafeOnLoad", false];
		private _fallbackProps = _node getOrDefault ["fallbackProps", ["", "", -1, [], [], []]];
		private _widget = _node getOrDefault ["widget", ["", nil]];

		private _typeNibble = ((floor (_ctrlStyle / 16)) mod 16) * 16;
		private _keepAspect = ((floor (_ctrlStyle / 2048)) mod 2) isEqualTo 1;
		private _safeClass = switch (_ctrlType) do {
			case 15: {"RscControlsGroupNoScrollbars"};
			case 13: {"RscStructuredText"};
			case 8: {"RscProgress"};
			case 100;
			case 101: {"RscMapControlEmpty"};
			case 11: {"RscActiveText"};
			default {
				if (_typeNibble in [48, 144]) then {
					if (_keepAspect) then {"RscPictureKeepAspect"} else {"RscPicture"}
				} else {
					if (_typeNibble isEqualTo 16) then {"RscTextMulti"} else {"RscText"}
				}
			};
		};

		private _ctrl = controlNull;
		private _usedFallback = false;

		if (_isGroup) then {
			_ctrl = if (_isTopLevel) then {
				_display ctrlCreate ["RscControlsGroupNoScrollbars", _assignedIdc]
			} else {
				_display ctrlCreate ["RscControlsGroupNoScrollbars", _assignedIdc, _parentGrp]
			};
		} else {
			if (_isSafeOnLoad) then {
				private _ctrlCfg = [_cfgRootName, _cfgPathArr] call _fnc_resolveNodeCfg;
				if (!(isNull _ctrlCfg) && {isClass _ctrlCfg}) then {
					private _savedUi = _uiVars apply {[_x, uiNamespace getVariable _x]};
					_ctrl = if (_isTopLevel) then {
						_display ctrlCreate [_ctrlCfg, _assignedIdc]
					} else {
						_display ctrlCreate [_ctrlCfg, _assignedIdc, _parentGrp]
					};
					{
						_x params ["_vName", "_vPrev"];
						if (isNil "_vPrev") then {
							uiNamespace setVariable [_vName, nil];
						} else {
							uiNamespace setVariable [_vName, _vPrev];
						};
					} forEach _savedUi;
				};
			};

			if (isNull _ctrl) then {
				_usedFallback = true;
				_ctrl = if (_isTopLevel) then {
					_display ctrlCreate [_safeClass, _assignedIdc]
				} else {
					_display ctrlCreate [_safeClass, _assignedIdc, _parentGrp]
				};
			};
		};

		if (isNull _ctrl) then {continue};

		_fallbackProps params [["_initText", ""], ["_font", ""], ["_shadow", -1], ["_colorText", []], ["_colorBg", []], ["_attrs", []]];
		private _structAttrs = if (_usedFallback && {_ctrlType isEqualTo 13} && {!(_attrs isEqualTo [])}) then {_attrs} else {[]};

		if (_usedFallback && {!_isGroup}) then {
			if !(_colorBg isEqualTo []) then {
				_ctrl ctrlSetBackgroundColor _colorBg;
			};
			if !(_colorText isEqualTo []) then {
				_ctrl ctrlSetTextColor _colorText;
			};
			if !(_font isEqualTo "") then {
				_ctrl ctrlSetFont _font;
			};
			if (_shadow >= 0) then {
				_ctrl ctrlSetShadow _shadow;
			};
			if !(_initText isEqualTo "") then {
				private _resolvedText = _initText;
				if ((_initText select [0, 1]) isEqualTo "$") then {
					private _loc = localize (_initText select [1]);
					if !(_loc isEqualTo "") then {
						_resolvedText = _loc;
					};
				};
				if (_ctrlType isEqualTo 13) then {
					_ctrl ctrlSetStructuredText ([_resolvedText, _structAttrs] call _fnc_formatStructText);
				} else {
					_ctrl ctrlSetText _resolvedText;
				};
			};
		};

		if (_fade > 0) then {
			_ctrl ctrlSetFade _fade;
			_ctrl ctrlCommit 0;
		};
		if (_show isEqualTo 0) then {
			_ctrl ctrlShow false;
		};
		_ctrl ctrlEnable false;

		{
			uiNamespace setVariable [_x + _uiDisplayUniqueName, _ctrl];
			_ctrlsByVar set [toLower _x, _ctrl];
		} forEach _uiVars;

		_createdList pushBack [_ctrl, _node, _isTopLevel];
		_ctrlsByIdc set [_assignedIdc, _ctrl];
		if (_origIdc >= 0 && {!(_origIdc in _ctrlsByIdc)}) then {
			_ctrlsByIdc set [_origIdc, _ctrl];
		};
		if !(_className isEqualTo "") then {
			private _lowCls = toLower _className;
			if !(_lowCls in _ctrlsByClass) then {
				_ctrlsByClass set [_lowCls, _ctrl];
			};
		};

		_widget params [["_wKind", ""], ["_wMeta", nil]];
		if !(_wKind isEqualTo "") then {
			_activeBindings pushBack [_ctrl, _wKind, _wMeta, _ctrlType, _structAttrs];
		};

		if (_isGroup) then {
			private _children = _node getOrDefault ["children", []];
			if !(_children isEqualTo []) then {
				[_children, _ctrl] call _fnc_spawnNodes;
			};
		};
	} forEach _nodes;
};

[_blueprint getOrDefault ["bgNodes", []], controlNull] call _fnc_spawnNodes;
[_blueprint getOrDefault ["fgNodes", []], controlNull] call _fnc_spawnNodes;

// Merge optional declarative preset bindings (override or disable auto-detected bindings)
private _customBindings = _display getVariable ["CFM_hudCustomBindings", []];
if (!(_customBindings isEqualTo []) && {_customBindings isEqualType []}) then {
	{
		if !(_x isEqualType []) then {continue};
		_x params [["_targetKey", ""], ["_customKind", ""], ["_customMeta", nil]];
		private _targetCtrl = controlNull;
		if (_targetKey isEqualType 0) then {
			_targetCtrl = _ctrlsByIdc getOrDefault [_targetKey, controlNull];
		} else {
			if (_targetKey isEqualType "") then {
				private _lowKey = toLower _targetKey;
				_targetCtrl = _ctrlsByVar getOrDefault [_lowKey, _ctrlsByClass getOrDefault [_lowKey, controlNull]];
			};
		};
		if (isNull _targetCtrl) then {continue};

		private _existingIdx = _activeBindings findIf {(_x select 0) isEqualTo _targetCtrl};
		if (_customKind isEqualTo "") then {
			if (_existingIdx >= 0) then {
				_activeBindings deleteAt _existingIdx;
			};
		} else {
			private _prevStructAttrs = if (_existingIdx >= 0) then {(_activeBindings select _existingIdx) param [4, []]} else {[]};
			private _newEntry = [_targetCtrl, _customKind, _customMeta, ctrlType _targetCtrl, _prevStructAttrs];
			if (_existingIdx >= 0) then {
				_activeBindings set [_existingIdx, _newEntry];
			} else {
				_activeBindings pushBack _newEntry;
			};
		};
	} forEach _customBindings;
};

_display setVariable ["CFM_hudControlsList", _createdList];
_display setVariable ["CFM_hudCtrlsByIdc", _ctrlsByIdc];
_display setVariable ["CFM_hudCtrlsByClass", _ctrlsByClass];
_display setVariable ["CFM_hudCtrlsByVar", _ctrlsByVar];
_display setVariable ["CFM_hudActiveBindings", _activeBindings];

[_display] call CFM_fnc_repositionDynamicControls;

[_r2tCtrl, [_eff1, _eff2]]
