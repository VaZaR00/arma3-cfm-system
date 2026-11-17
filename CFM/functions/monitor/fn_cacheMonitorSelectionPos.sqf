/*
    Function: CFM_fnc_cacheMonitorSelectionPos
    Author: Vazar
    Description: Caches model-space BoundingBox and center positions of a texture selection for ray-intersection monitor detection.
*/

#include "defines.hpp"

params [
	["_monitor", objNull],
	["_texSel", NO_TEXTURE_SELECTION],
	["_instId", -1]
];

if (!(IS_OBJ(_monitor)) || {_texSel < 0} || {_instId < 1}) exitWith {false};

private _hiddenSelections = getArray (configOf _monitor >> "hiddenSelections");
private _selName = _hiddenSelections param [_texSel, ""];
private _posMap = _monitor getVariable ["CFM_monitorSelectionPositions", createHashMap];

private _fnc_readLodBox = {
	params ["_lod"];
	private _bb = selectionPosition [_monitor, _selName, _lod, true, "BoundingBox"];
	private _center = selectionPosition [_monitor, _selName, _lod, true, "AveragePoint"];
	private _valid = !(_bb isEqualTo [[0, 0, 0], [0, 0, 0]]) || {!(_center isEqualTo [0, 0, 0])};
	if !(_valid) exitWith {[]};
	if (_bb isEqualTo [[0, 0, 0], [0, 0, 0]]) then {
		_bb = [_center, _center];
	};
	[_bb, _center]
};

private _resData = [];
private _pilotData = [];

if !(_selName isEqualTo "") then {
	private _lods = allLODs _monitor;
	private _pilotLodIdx = -1;
	private _resLodIdx = -1;
	{
		_x params ["_lodIdx", "_lodName"];
		private _upper = toUpper _lodName;
		if (_upper isEqualTo "VIEW_PILOT" && {_pilotLodIdx < 0}) then {
			_pilotLodIdx = _lodIdx;
		};
		if (_resLodIdx < 0 && {!(_upper in ["MEMORY", "GEOMETRY", "FIRE_GEOMETRY", "HITPOINTS", "VIEW_GEOMETRY", "LAND_CONTACT", "ROADWAY", "PATHS", "SHADOW_VOLUME", "WRECK", "VIEW_PILOT", "VIEW_CARGO", "VIEW_GUNNER"])}) then {
			_resLodIdx = _lodIdx;
		};
	} forEach _lods;

	if (_resLodIdx >= 0) then {
		_resData = [_resLodIdx] call _fnc_readLodBox;
	};
	if (_resData isEqualTo []) then {
		private _bbDef = _monitor selectionPosition _selName;
		if !(_bbDef isEqualTo [0, 0, 0]) then {
			_resData = [[_bbDef, _bbDef], _bbDef];
		};
	};
	if (_pilotLodIdx >= 0) then {
		_pilotData = [_pilotLodIdx] call _fnc_readLodBox;
	};
};

_posMap set [_instId, [_selName, _texSel, _resData, _pilotData]];
_monitor setVariable ["CFM_monitorSelectionPositions", _posMap];
true
