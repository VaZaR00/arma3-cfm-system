/*
    Function: CFM_fnc_parseDynamicDisplayConfig
    Author: Vazar & Gemini
    Description:
        Recursively parses an arbitrary display/HUD config (RscTitles, RscInGameUI, Root, missionConfigFile),
        compiles all coordinate/size formulas, classifies telemetry widgets, strips incompatible
        or R2T-reserved/opaque-backdrop elements, and caches the resulting blueprint HashMap.
    Parameters:
        0: _displayClass [String | Config] - Display class name, config path string, or Config entry.
    Returns:
        [HashMap] - Cached display blueprint (or empty HashMap if invalid).
*/

#include "defines.hpp"

params [["_displayClass", "", ["", configNull]]];

([_displayClass] call CFM_fnc_resolveDisplayConfig) params [
	"_resolvedCfg",
	"_sourceType",
	"_cfgRootName",
	"_cfgPathArr",
	"_isNativeCfm"
];

if (isNull _resolvedCfg) exitWith {createHashMap};

private _cacheNs = if (_cfgRootName isEqualTo "missionConfigFile") then {missionNamespace} else {UI_CACHE_NAMESPACE};
private _cacheVar = if (_cfgRootName isEqualTo "missionConfigFile") then {"CFM_dynamicMissionDisplaysCache"} else {"CFM_dynamicDisplaysCache"};
private _cacheKey = toLower (format ["%1:%2", _cfgRootName, _cfgPathArr joinString "/"]);

private _allCache = _cacheNs getVariable _cacheVar;
if (!isNil "_allCache" && {_cacheKey in _allCache}) exitWith {
	_allCache get _cacheKey
};

private _fnc_getCfgNum = {
	params ["_cfg", "_propName", ["_def", 0]];
	private _prop = _cfg >> _propName;
	if (isNull _prop) exitWith {_def};
	if (isNumber _prop) exitWith {getNumber _prop};
	if !(isText _prop) exitWith {_def};
	private _txt = trim (getText _prop);
	if (_txt isEqualTo "") exitWith {_def};
	private _low = toLower _txt;
	if (_low isEqualTo "true") exitWith {1};
	if (_low isEqualTo "false") exitWith {0};
	if (_txt regexMatch "^[+-]?[0-9]+(?:\.[0-9]+)?$/") exitWith {parseNumber _txt};
	private _val = _def;
	isNil {
		private _c = call compile _txt;
		if (!isNil "_c") then {
			if (_c isEqualType true) then {
				_val = [0, 1] select _c;
			} else {
				if (_c isEqualType 0 && {finite _c}) then {
					_val = _c;
				};
			};
		};
	};
	_val
};

private _fnc_getCfgColor = {
	params ["_cfg", "_propName", ["_def", []]];
	private _prop = _cfg >> _propName;
	if (isNull _prop || {!(isArray _prop)}) exitWith {_def};
	private _raw = getArray _prop;
	if ((count _raw) < 4) exitWith {_def};
	private _out = [];
	private _ok = true;
	{
		if (_x isEqualType 0) then {
			_out pushBack _x;
		} else {
			if (_x isEqualType "") then {
				private _num = [_x] call {
					params ["_exprStr"];
					private _res = 0;
					private _t = trim _exprStr;
					if (_t regexMatch "^[+-]?[0-9]+(?:\.[0-9]+)?$/") exitWith {parseNumber _t};
					isNil {
						private _c = call compile _t;
						if (!isNil "_c" && {_c isEqualType 0} && {finite _c}) then {
							_res = _c;
						};
					};
					_res
				};
				_out pushBack _num;
			} else {
				_ok = false;
			};
		};
	} forEach (_raw select [0, 4]);
	if (!_ok || {(count _out) < 4}) exitWith {_def};
	_out
};

private _fnc_collectChildren = {
	params ["_ownerCfg", "_ownerPathArr", "_propName"];
	private _out = [];
	private _prop = _ownerCfg >> _propName;
	if (isArray _prop) then {
		private _hasSubContainer = isClass _prop;
		{
			if (_x isEqualType "" && {!(_x isEqualTo "")}) then {
				private _sub = _ownerCfg >> _x;
				private _subPath = _ownerPathArr + [_x];
				if (!(isClass _sub) && {_hasSubContainer}) then {
					_sub = _prop >> _x;
					_subPath = _ownerPathArr + [_propName, _x];
				};
				if (isClass _sub) then {
					_out pushBack [_sub, _subPath];
				};
			};
		} forEach (getArray _prop);
	} else {
		if (isClass _prop) then {
			private _subs = configProperties [_prop, "isClass _x", true];
			{
				_out pushBack [_x, _ownerPathArr + [_propName, configName _x]];
			} forEach _subs;
		};
	};
	_out
};

private _fnc_evalPreviewTuple = {
	params [["_tuple", []]];
	if (_tuple isEqualTo []) exitWith {0};
	_tuple params [["_valOrCode", 0], ["_isCfm", false]];
	if (_valOrCode isEqualType 0) exitWith {_valOrCode};
	private _resVal = 0;
	isNil {
		private _vSZX = -0.1667;
		private _vSZY = 0;
		private _vSZW = 1.3333;
		private _vSZH = 1;
		private _vPGrid = 12;
		private _vPW = 1.3333 / 1920;
		private _vPH = 1 / 1080;
		private _vGetRes = [1920, 1080, 1920, 1080, 1.7778, 0.7, 0.75, 1.3333, false, 1];
		private _res = DEFAULT_SCREEN_RESOLUTION;
		private _c = call _valOrCode;
		if (!isNil "_c" && {_c isEqualType 0} && {finite _c}) then {
			_resVal = _c;
		};
	};
	_resVal
};

private _iguiSkipNames = [
	"weaponinfocontrolsgroupright",
	"weaponinfocontrolsgroupleft",
	"ca_backgroundvehicle",
	"ca_backgroundvehicletitle",
	"ca_backgroundvehicletitledark",
	"ca_backgroundfuel",
	"ca_vehicle",
	"ca_vehiclerole",
	"ca_hitzones",
	"ca_vehicletogglesbackground",
	"ca_vehicletoggles",
	"stanceindicator",
	"ca_zeroing"
];
private _reservedBgNames = ["r2tpicture", "effectpicture", "effectpicture1", "effectpicture2"];

private _usedIdcs = createHashMapFromArray [[1488, true], [1489, true], [1490, true]];
private _nextSynthIdc = DYN_HUD_SYNTHETIC_IDC_BASE;

private _fnc_parseNodeList = {
	params ["_items", "_isBackground", "_parentName", "_parentUiVars"];
	private _nodes = [];
	{
		_x params ["_ctrlCfg", "_ctrlPathArr"];
		private _ctrlName = configName _ctrlCfg;
		private _lowName = toLower _ctrlName;

		if ((_sourceType isEqualTo "RscInGameUI") && {_parentName isEqualTo ""} && {_lowName in _iguiSkipNames}) then {
			continue;
		};

		private _origIdc = [_ctrlCfg, "idc", -1] call _fnc_getCfgNum;
		if (_isBackground && {_parentName isEqualTo ""} && {(_origIdc in [1488, 1489, 1490]) || {_lowName in _reservedBgNames}}) then {
			continue;
		};

		private _ctrlType = [_ctrlCfg, "type", 0] call _fnc_getCfgNum;
		if !(_ctrlType in DYN_HUD_ALLOWED_CTRL_TYPES) then {
			continue;
		};

		private _ctrlStyle = [_ctrlCfg, "style", 0] call _fnc_getCfgNum;
		private _typeNibble = ((floor (_ctrlStyle / 16)) mod 16) * 16;
		private _isPic = (_ctrlType isEqualTo 0) && {_typeNibble in [48, 144]};

		private _xTuple = [_ctrlCfg >> "x"] call CFM_fnc_parseDynamicControlFormula;
		private _yTuple = [_ctrlCfg >> "y"] call CFM_fnc_parseDynamicControlFormula;
		private _wTuple = [_ctrlCfg >> "w"] call CFM_fnc_parseDynamicControlFormula;
		private _hTuple = [_ctrlCfg >> "h"] call CFM_fnc_parseDynamicControlFormula;

		private _colorBg = [_ctrlCfg, "colorBackground", []] call _fnc_getCfgColor;
		if (_colorBg isEqualTo []) then {
			_colorBg = [_ctrlCfg, "colorBackGround", []] call _fnc_getCfgColor;
		};

		// Skip full-screen opaque solid backgrounds in controlsBackground so R2T video feed stays visible
		if (_isBackground && {_parentName isEqualTo ""} && {_ctrlType isEqualTo 0} && {!_isPic}) then {
			private _bgAlpha = _colorBg param [3, 0];
			if (_bgAlpha >= 0.95) then {
				private _prevW = [_wTuple] call _fnc_evalPreviewTuple;
				private _prevH = [_hTuple] call _fnc_evalPreviewTuple;
				if (_prevW >= 0.95 && {_prevH >= 0.95}) then {
					continue;
				};
			};
		};

		private _sizeTuple = if (_ctrlType isEqualTo 13) then {
			private _s = [_ctrlCfg >> "size"] call CFM_fnc_parseDynamicControlFormula;
			if (_s isEqualTo []) then {[_ctrlCfg >> "sizeEx"] call CFM_fnc_parseDynamicControlFormula} else {_s}
		} else {
			private _sEx = [_ctrlCfg >> "sizeEx"] call CFM_fnc_parseDynamicControlFormula;
			if (_sEx isEqualTo [] && {isText (_ctrlCfg >> "size") || {isNumber (_ctrlCfg >> "size")}}) then {
				[_ctrlCfg >> "size"] call CFM_fnc_parseDynamicControlFormula
			} else {
				_sEx
			}
		};

		private _assignedIdc = if (_origIdc >= 0 && {!(_origIdc in _usedIdcs)}) then {
			_origIdc
		} else {
			while {_nextSynthIdc in _usedIdcs} do {
				_nextSynthIdc = _nextSynthIdc + 1;
			};
			_nextSynthIdc
		};
		_usedIdcs set [_assignedIdc, true];

		private _onLoadRaw = if (isText (_ctrlCfg >> "onLoad")) then {trim (getText (_ctrlCfg >> "onLoad"))} else {""};
		private _uiVars = [];
		if !(_onLoadRaw isEqualTo "") then {
			private _matches = _onLoadRaw regexFind ["uiNamespace\s+setVariable\s*\[\s*['""]([^'""]+)['""]/gi"];
			{
				if ((count _x) >= 2) then {
					private _vName = (_x select 1) select 0;
					if !(_vName isEqualTo "") then {
						_uiVars pushBackUnique _vName;
					};
				};
			} forEach _matches;
			if (_uiVars isEqualTo [] && {"uinamespace" in (toLower _onLoadRaw)}) then {
				private _assignMatches = _onLoadRaw regexFind ["([A-Za-z0-9_]+)\s*=\s*_this/gi"];
				{
					if ((count _x) >= 2) then {
						private _vName = (_x select 1) select 0;
						if !(_vName isEqualTo "") then {
							_uiVars pushBackUnique _vName;
						};
					};
				} forEach _assignMatches;
			};
		};

		private _isSafeOnLoad = false;
		if (_onLoadRaw isEqualTo "") then {
			_isSafeOnLoad = true;
		} else {
			private _stripped = _onLoadRaw regexReplace ["uiNamespace\s+setVariable\s*\[\s*['""][^'""]+['""]\s*,\s*_this(?:\s*(?:#|select)\s*0)?\s*\]\s*;?/gi", ""];
			if ((trim _stripped) isEqualTo "") then {
				_isSafeOnLoad = true;
			};
		};

		private _initText = if (isText (_ctrlCfg >> "text")) then {getText (_ctrlCfg >> "text")} else {""};
		private _font = if (isText (_ctrlCfg >> "font")) then {getText (_ctrlCfg >> "font")} else {""};
		private _shadow = [_ctrlCfg, "shadow", -1] call _fnc_getCfgNum;
		private _fade = [_ctrlCfg, "fade", 0] call _fnc_getCfgNum;
		private _show = [_ctrlCfg, "show", 1] call _fnc_getCfgNum;
		private _colorText = [_ctrlCfg, "colorText", []] call _fnc_getCfgColor;

		private _attrs = [];
		private _attrsCfg = _ctrlCfg >> "Attributes";
		if (isClass _attrsCfg) then {
			private _aFont = if (isText (_attrsCfg >> "font")) then {getText (_attrsCfg >> "font")} else {_font};
			private _aColor = if (isText (_attrsCfg >> "color")) then {getText (_attrsCfg >> "color")} else {""};
			private _aAlign = if (isText (_attrsCfg >> "align")) then {getText (_attrsCfg >> "align")} else {""};
			private _aValign = if (isText (_attrsCfg >> "valign")) then {getText (_attrsCfg >> "valign")} else {""};
			private _aShadow = [_attrsCfg, "shadow", -1] call _fnc_getCfgNum;
			_attrs = [_aFont, _aColor, _aAlign, _aValign, _aShadow];
		};

		private _widget = if (_ctrlType isEqualTo 15) then {
			["", ""]
		} else {
			[_ctrlName, _parentName, _origIdc, _ctrlType, _ctrlStyle, _initText, _uiVars, _parentUiVars, _sourceType] call CFM_fnc_classifyHudControl
		};

		private _children = [];
		if (_ctrlType isEqualTo 15) then {
			private _childItems = [_ctrlCfg, _ctrlPathArr, "controls"] call _fnc_collectChildren;
			if !(_childItems isEqualTo []) then {
				_children = [_childItems, _isBackground, _ctrlName, _uiVars] call _fnc_parseNodeList;
			};
		};

		private _node = createHashMap;
		_node set ["className", _ctrlName];
		_node set ["cfgRoot", _cfgRootName];
		_node set ["cfgPath", _ctrlPathArr];
		_node set ["origIdc", _origIdc];
		_node set ["assignedIdc", _assignedIdc];
		_node set ["isGroup", _ctrlType isEqualTo 15];
		_node set ["ctrlType", _ctrlType];
		_node set ["ctrlStyle", _ctrlStyle];
		if !(_xTuple isEqualTo []) then {_node set ["x", _xTuple];};
		if !(_yTuple isEqualTo []) then {_node set ["y", _yTuple];};
		if !(_wTuple isEqualTo []) then {_node set ["w", _wTuple];};
		if !(_hTuple isEqualTo []) then {_node set ["h", _hTuple];};
		if !(_sizeTuple isEqualTo []) then {_node set ["size", _sizeTuple];};
		_node set ["fade", _fade];
		_node set ["show", _show];
		_node set ["uiVars", _uiVars];
		_node set ["isSafeOnLoad", _isSafeOnLoad];
		_node set ["fallbackProps", [_initText, _font, _shadow, _colorText, _colorBg, _attrs]];
		_node set ["widget", _widget];
		_node set ["children", _children];

		_nodes pushBack _node;
	} forEach _items;
	_nodes
};

private _bgItems = [_resolvedCfg, _cfgPathArr, "controlsBackground"] call _fnc_collectChildren;
private _fgItems = [_resolvedCfg, _cfgPathArr, "controls"] call _fnc_collectChildren;

private _bgNodes = [_bgItems, true, "", []] call _fnc_parseNodeList;
private _fgNodes = [_fgItems, false, "", []] call _fnc_parseNodeList;

private _blueprint = createHashMap;
_blueprint set ["displayClass", configName _resolvedCfg];
_blueprint set ["sourceType", _sourceType];
_blueprint set ["cfgRoot", _cfgRootName];
_blueprint set ["cfgPath", _cfgPathArr];
_blueprint set ["bgNodes", _bgNodes];
_blueprint set ["fgNodes", _fgNodes];

if (isNil "_allCache") then {
	_allCache = createHashMap;
};
_allCache set [_cacheKey, _blueprint];
_cacheNs setVariable [_cacheVar, _allCache];

_blueprint
