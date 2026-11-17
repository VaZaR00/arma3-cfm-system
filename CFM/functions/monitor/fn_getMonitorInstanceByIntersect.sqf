/*
    Function: CFM_fnc_getMonitorInstanceByIntersect
    Author: Vazar
    Description: Experimental detection of targeted monitor instance using camera look ray intersection and cached selection positions.
*/

#include "defines.hpp"

params [
	["_monitor", objNull],
	["_available", []]
];

if (!(IS_OBJ(_monitor)) || {_available isEqualTo []}) exitWith {-1};

// Per-frame cache: conditions are evaluated many times per frame for every addAction
private _cache = _monitor getVariable ["CFM_intersectCache", [-1, -1]];
if ((_cache select 0) isEqualTo diag_frameNo) exitWith {
	private _cachedId = _cache select 1;
	if (_cachedId in _available) then {_cachedId} else {-1}
};

private _posMap = _monitor getVariable ["CFM_monitorSelectionPositions", createHashMap];
private _plr = PLAYER_;
private _inVehicle = _plr in _monitor;
private _usePilotLod = _inVehicle && {cameraView isEqualTo "INTERNAL"};
private _maxDist = (MONITOR_ACTION_RADIUS(_monitor)) max 8;

private _camBeg = positionCameraToWorld [0, 0, 0];
private _camFwd = positionCameraToWorld [0, 0, 1];
private _begASL = AGLToASL _camBeg;
private _endASL = AGLToASL (positionCameraToWorld [0, 0, _maxDist]);

private _hits = lineIntersectsSurfaces [_begASL, _endASL, _plr, objNull, true, 4, "VIEW", "GEOM", true];
private _monHit = (_hits select {((_x select 2) isEqualTo _monitor) || {(_x select 3) isEqualTo _monitor}}) param [0, []];

private _resultInst = -1;

// Collect candidate texture instances with their best LOD box for current view
private _candidates = [];
{
	private _instId = _x;
	private _entry = _posMap getOrDefault [_instId, []];
	if !(_entry isEqualTo []) then {
		_entry params [["_selName", ""], ["_texSel", -1], ["_resData", []], ["_pilotData", []]];
		if (_texSel >= 0) then {
			private _data = if (_usePilotLod && {!(_pilotData isEqualTo [])}) then {_pilotData} else {_resData};
			_candidates pushBack [_instId, toLower _selName, _texSel, _data];
		};
	};
} forEach _available;

if !(_candidates isEqualTo []) then {
	if !(_monHit isEqualTo []) then {
		private _hitPosASL = _monHit select 0;
		private _hitSelNames = (_monHit param [4, []]) apply {toLower _x};
		private _hitModel = _monitor worldToModelVisual (ASLToAGL _hitPosASL);

		// 1. Direct intersected LOD selection name match
		if !(_hitSelNames isEqualTo []) then {
			{
				_x params ["_instId", "_selName"];
				if (!(_selName isEqualTo "") && {_selName in _hitSelNames}) exitWith {
					_resultInst = _instId;
				};
			} forEach _candidates;
		};

		// 2. Closest cached BoundingBox / center distance to hit point in model space
		if (_resultInst < 0) then {
			private _bestDist = 1e9;
			{
				_x params ["_instId", "", "", "_data"];
				if !(_data isEqualTo []) then {
					_data params ["_bb", "_center"];
					_bb params ["_bMin", "_bMax"];
					private _clamped = [
						((_hitModel select 0) max (_bMin select 0)) min (_bMax select 0),
						((_hitModel select 1) max (_bMin select 1)) min (_bMax select 1),
						((_hitModel select 2) max (_bMin select 2)) min (_bMax select 2)
					];
					private _dBox = _hitModel distance _clamped;
					private _dCenter = _hitModel distance _center;
					private _score = _dBox + (_dCenter * 0.05);
					if (_score < _bestDist) then {
						_bestDist = _score;
						_resultInst = _instId;
					};
				};
			} forEach _candidates;
		};

		// 3. Fallback: horizontal boundingBoxReal split if model lacks selection coordinates
		if (_resultInst < 0 && {(count _candidates) > 1}) then {
			private _bbr = boundingBoxReal _monitor;
			private _minX = (_bbr select 0) select 0;
			private _maxX = (_bbr select 1) select 0;
			private _span = _maxX - _minX;
			if (_span > 0.05) then {
				private _ratio = (((_hitModel select 0) - _minX) / _span) max 0 min 0.9999;
				private _idx = floor (_ratio * (count _candidates));
				_resultInst = (_candidates select _idx) select 0;
			};
		};
	} else {
		// Fallback for cockpit/internal meshes lacking ViewGeometry/FireGeometry surfaces
		private _rayOrigin = _monitor worldToModelVisual _camBeg;
		private _rayDir = vectorNormalized ((_monitor worldToModelVisual _camFwd) vectorDiff _rayOrigin);
		private _bestPerp = 0.22;
		{
			_x params ["_instId", "", "", "_data"];
			if !(_data isEqualTo []) then {
				private _center = _data select 1;
				private _toCenter = _center vectorDiff _rayOrigin;
				private _proj = _toCenter vectorDotProduct _rayDir;
				if (_proj > 0 && {_proj <= _maxDist}) then {
					private _closestPt = _rayOrigin vectorAdd (_rayDir vectorMultiply _proj);
					private _perp = _center distance _closestPt;
					if (_perp < _bestPerp) then {
						_bestPerp = _perp;
						_resultInst = _instId;
					};
				};
			};
		} forEach _candidates;
	};
};

_monitor setVariable ["CFM_intersectCache", [diag_frameNo, _resultInst]];
_resultInst
