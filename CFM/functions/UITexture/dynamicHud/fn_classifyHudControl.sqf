/*
    Function: CFM_fnc_classifyHudControl
    Author: Vazar & Gemini
    Description:
        Classifies a HUD display control into a live telemetry widget binding [widgetKind, widgetMeta]
        based on RscInGameUI CA_* standards, control IDC, config/onLoad variable names,
        and stepped .paa icon files. Returns ["", ""] for purely static decorations.
    Parameters:
        0: _ctrlName [String] - Control config class name.
        1: _parentName [String] - Parent controlsGroup class name (or "").
        2: _origIdc [Number] - Original config IDC (-1 if none).
        3: _ctrlType [Number] - Control type constant.
        4: _ctrlStyle [Number] - Control style flags integer.
        5: _initText [String] - Initial text/texture path from config.
        6: _uiVars [Array] - uiNamespace variable names parsed from control onLoad.
        7: _parentUiVars [Array] - uiNamespace variable names parsed from parent onLoad.
        8: _sourceType [String] - Display config source ("RscInGameUI", "RscTitles", "Root").
    Returns:
        [Array] - [_widgetKind, _widgetMeta]
*/

#include "defines.hpp"

params [
	["_ctrlName", "", [""]],
	["_parentName", "", [""]],
	["_origIdc", -1, [0]],
	["_ctrlType", 0, [0]],
	["_ctrlStyle", 0, [0]],
	["_initText", "", [""]],
	["_uiVars", [], [[]]],
	["_parentUiVars", [], [[]]],
	["_sourceType", "Root", [""]]
];

if (_ctrlType isEqualTo 15) exitWith {["", ""]};

private _typeNibble = ((floor (_ctrlStyle / 16)) mod 16) * 16;
private _isPic = (_ctrlType isEqualTo 0) && {_typeNibble in [48, 144]};
private _isGeomOnly = (_ctrlType isEqualTo 0) && {_typeNibble in [64, 128, 176]};
if (_isGeomOnly) exitWith {["", ""]};

private _lowCtrlName = toLower _ctrlName;

// Branch A: Vanilla / Modded RscInGameUI standard CA_* optics & HUD controls
private _iguiMatched = if (_sourceType isEqualTo "RscInGameUI") then {
	switch (true) do {
		case ((_lowCtrlName isEqualTo "ca_heading") || {_origIdc in [156, 148]}): {["igui_heading", ""]};
		case ((_lowCtrlName in ["ca_opticszoom", "opticszoom"]) || {_origIdc in [180, 192]}): {["igui_zoom", ""]};
		case ((_lowCtrlName isEqualTo "ca_visionmode") || {_origIdc in [152, 179]}): {["igui_vision", ""]};
		case ((_lowCtrlName isEqualTo "ca_flirmode") || {_origIdc isEqualTo 153}): {["igui_flir", ""]};
		case ((_lowCtrlName isEqualTo "ca_laser") || {_origIdc isEqualTo 158}): {["laser", _isPic]};
		case ((_lowCtrlName in ["ca_distance", "ca_range"]) || {_origIdc in [151, 183, 198]}): {["slant_range", ""]};
		case ((_lowCtrlName in ["ca_alt", "ca_valuealt"]) || {_origIdc isEqualTo 184}): {["altitude", ["", "", false]]};
		case ((_lowCtrlName isEqualTo "ca_speed") || {_origIdc in [188, 120]}): {["speed", ["", "", false]]};
		case ((_lowCtrlName in ["ca_opticspitch", "ca_elev", "ca_turretelevation"]) || {_origIdc in [175, 174, 382]}): {["pitch", ["", "°"]]};
		case ((_lowCtrlName in ["ca_ownposition", "ca_grid"]) || {_origIdc in [189, 171]}): {["own_grid", ""]};
		case ((_lowCtrlName isEqualTo "ca_targetposition") || {_origIdc isEqualTo 190}): {["tgt_grid", ""]};
		case ((_lowCtrlName in ["ca_time", "ca_valuetime"]) || {_origIdc isEqualTo 193}): {["clock_time", ""]};
		case ((_lowCtrlName in ["ca_valuefuel", "ca_fuel"]) || {_origIdc isEqualTo 122}): {
			if (_ctrlType isEqualTo 8) then {["prog_battery", ""]} else {["battery_text", ["", "%", false]]}
		};
		default {["", ""]};
	}
} else {
	["", ""]
};
if !((_iguiMatched select 0) isEqualTo "") exitWith {_iguiMatched};

// Branch B: Modded RscTitles / Root HUDs
// Static guard: controls without IDC and without uiNamespace bindings in self or parent are decorative
if ((_origIdc < 0) && {_uiVars isEqualTo []} && {_parentUiVars isEqualTo []}) exitWith {["", ""]};

private _key = toLower ((_uiVars joinString "_") + "_" + (_parentUiVars joinString "_") + "_" + _ctrlName + "_" + _parentName);

// Picture controls
if (_isPic) exitWith {
	if (("laser" in _key) || {"lsr" in _key}) exitWith {["laser", true]};

	private _m = _initText regexFind ["^(.*?)([0-9]+)(\.paa)$/i"];
	if (_m isEqualTo [] || {(count (_m select 0)) < 4}) exitWith {["", ""]};

	private _grp = _m select 0;
	private _prefix = (_grp select 1) select 0;
	private _suffix = (_grp select 3) select 0;

	private _foundPaths = [];
	{
		private _candPath = format ["%1%2%3", _prefix, _x, _suffix];
		if !(_candPath isEqualTo "") then {
			private _exists = if ((_candPath select [0, 1]) isEqualTo "\") then {
				(fileExists _candPath) || {fileExists (_candPath select [1])}
			} else {
				fileExists _candPath
			};
			if (_exists) then {
				_foundPaths pushBack [_x, _candPath];
			};
		};
	} forEach [0, 1, 2, 3, 4, 5, 10, 20, 25, 30, 40, 50, 60, 70, 75, 80, 90, 100];

	if ((count _foundPaths) < 2) exitWith {["", ""]};

	if (("bat" in _key) || {"fuel" in _key} || {"accum" in _key}) exitWith {["pic_battery", _foundPaths]};
	if (("sat" in _key) || {"gps" in _key}) exitWith {["pic_sat", _foundPaths]};
	if (("sig" in _key) || {"comm" in _key} || {"rssi" in _key} || {"link" in _key} || {"ant" in _key}) exitWith {["pic_signal", _foundPaths]};

	["", ""]
};

// Progress bar controls
if (_ctrlType isEqualTo 8) exitWith {
	if (("sig" in _key) || {"rssi" in _key} || {"comm" in _key}) exitWith {["prog_signal", ""]};
	if (("bat" in _key) || {"fuel" in _key} || {"pwr" in _key}) exitWith {["prog_battery", ""]};
	["", ""]
};

// Text & StructuredText controls
if !(_ctrlType in [0, 13]) exitWith {["", ""]};

private _locInit = _initText;
if ((_initText select [0, 1]) isEqualTo "$") then {
	private _locStr = localize (_initText select [1]);
	if !(_locStr isEqualTo "") then {
		_locInit = _locStr;
	};
};
private _lowInit = toLower _locInit;

private _labelPrefix = "";
private _colonIdx = _locInit find ":";
if (_colonIdx > 0) then {
	private _candLabel = trim (_locInit select [0, _colonIdx]);
	if (!(_candLabel isEqualTo "") && {!(_candLabel regexMatch "[0-9]+/")}) then {
		_labelPrefix = _candLabel + ": ";
	};
};

if (("vspeed" in _key) || {"vertspeed" in _key} || {"climb" in _key}) exitWith {
	["vspeed", [_labelPrefix, " m/s"]]
};
if (("hspeed" in _key) || {"dronespeed" in _key} || {"groundspeed" in _key} || {"speed" in _key}) exitWith {
	private _isMs = ("m/s" in _lowInit) || {"hspeed" in _key};
	private _unit = if (_isMs) then {
		" m/s"
	} else {
		if (("km" in _lowInit) || {"км" in _lowInit}) then {" km/h"} else {""}
	};
	["speed", [_labelPrefix, _unit, _isMs]]
};
if (("bat" in _key) || {"fuel" in _key} || {"volt" in _key} || {"accum" in _key}) exitWith {
	private _isVolts = (" v" in _lowInit) || {"volt" in _key};
	private _unit = if (_isVolts) then {" v"} else {if ("%" in _lowInit) then {"%"} else {""}};
	["battery_text", [_labelPrefix, _unit, _isVolts]]
};
if (("sig" in _key) || {"comm" in _key} || {"rssi" in _key} || {"link" in _key}) exitWith {
	["signal_text", [_labelPrefix, if ("%" in _lowInit) then {"%"} else {""}]]
};
if (("remainingtime" in _key) || {"remaintime" in _key}) exitWith {
	["rem_time", ("'" in _lowInit)]
};
if (("ontime" in _key) || {"flighttime" in _key} || {"flytime" in _key}) exitWith {
	["on_time", ("'" in _lowInit)]
};
if ("date" in _key) exitWith {
	["date_text", ""]
};
if (("time" in _key) || {"clock" in _key}) exitWith {
	["clock_time", ""]
};
if (("squarex" in _key) || {"gridx" in _key}) exitWith {
	["square_x", _labelPrefix]
};
if (("squarey" in _key) || {"gridy" in _key}) exitWith {
	["square_y", _labelPrefix]
};
if (("coord" in _key) || {"grid" in _key} || {"mgrs" in _key}) exitWith {
	["own_grid", _labelPrefix]
};
if (("height" in _key) || {"alt" in _key} || {"agl" in _key} || {"asl" in _key}) exitWith {
	private _unit = if (_labelPrefix isEqualTo "") then {" m"} else {if (("m" in _lowInit) || {"м" in _lowInit}) then {" m"} else {""}};
	["altitude", [_labelPrefix, _unit, "asl" in _key]]
};
if (("dist" in _key) || {"range" in _key}) exitWith {
	if (("target" in _key) || {"laser" in _key} || {"slant" in _key}) exitWith {
		["slant_range", _labelPrefix]
	};
	private _unit = if (_labelPrefix isEqualTo "") then {" m"} else {if (("m" in _lowInit) || {"м" in _lowInit}) then {" m"} else {""}};
	["op_distance", [_labelPrefix, _unit]]
};
if (("zoom" in _key) || {"fov" in _key} || {"mag" in _key}) exitWith {
	["igui_zoom", _labelPrefix]
};
if (("heading" in _key) || {"azimuth" in _key} || {"direction" in _key} || {"course" in _key} || {"bearing" in _key} || {"yaw" in _key}) exitWith {
	["heading_deg", _labelPrefix]
};
if (("pitch" in _key) || {"elev" in _key} || {"tangazh" in _key}) exitWith {
	["pitch", [_labelPrefix, "°"]]
};
if (("bank" in _key) || {"roll" in _key} || {"kren" in _key}) exitWith {
	["bank", [_labelPrefix, "°"]]
};
if (("laser" in _key) || {"lsr" in _key}) exitWith {
	["laser", false]
};
if (("vision" in _key) || {"flir" in _key} || {"camtype" in _key}) exitWith {
	["igui_vision", ""]
};
if ("temp" in _key) exitWith {
	["temperature", _labelPrefix]
};
if (("flightstatus" in _key) || {"status" in _key}) exitWith {
	["flight_status", _labelPrefix]
};

["", ""]
