/*
    Function: CFM_fnc_getAvailableMonitorInstances
    Author: Vazar
    Description: Returns sorted array of monitor instance IDs accessible to the local player on _monitor.
*/

#include "defines.hpp"

params [["_monitor", objNull]];
if !(IS_OBJ(_monitor)) exitWith {[]};
if !(_monitor getVariable ["CFM_isMonitorSet", false]) exitWith {[]};

private _keysMap = _monitor getVariable ["CFM_monitorInstanceKeysMap", createHashMap];
private _keysCount = count _keysMap;
if (_keysCount == 0) exitWith {[]};

private _plr = PLAYER_;
private _plrParent = objectParent _plr;
private _isPlrHandTablet = (_monitor isEqualTo _plr) && {[_plr] call CFM_fnc_hasHandTablet};

private _cache = _monitor getVariable ["CFM_availInstCache", [-1, objNull, objNull, -1, false, []]];
if (
	((_cache select 0) isEqualTo diag_frameNo) &&
	{(_cache select 1) isEqualTo _plr} &&
	{(_cache select 2) isEqualTo _plrParent} &&
	{(_cache select 3) isEqualTo _keysCount} &&
	{(_cache select 4) isEqualTo _isPlrHandTablet}
) exitWith {
	_cache select 5
};

private _inVeh = (_plr in _monitor) && {!(_monitor isEqualTo _plr)};
if (!_inVeh && {!_isPlrHandTablet} && {!(_monitor getVariable ["CFM_hasNonSeatMonitors", true])}) exitWith {
	_monitor setVariable ["CFM_availInstCache", [diag_frameNo, _plr, _plrParent, _keysCount, _isPlrHandTablet, []]];
	[]
};

private _curSeatKey = if (_inVeh) then {[_monitor, _plr] call CFM_fnc_getUnitVehicleSeatKey} else {""};

private _available = [];
{
	private _instId = _x;
	_y params [["_texSel", NO_TEXTURE_SELECTION], ["_seatKey", ""], ["_isVehSeat", false], ["_isHand", false], ["_seatKeys", []]];
	if (MON_GVAR(_monitor, _instId, "CFM_isMonitorInstanceSet", false)) then {
		if (_isHand) then {
			if (_isPlrHandTablet) then {
				_available pushBack _instId;
			};
		} else {
			if (_isVehSeat) then {
				if (_inVeh && {
					if (_seatKeys isNotEqualTo []) then {
						!(_curSeatKey isEqualTo "") && {_curSeatKey in _seatKeys}
					} else {
						(_seatKey isEqualTo "") || {_seatKey isEqualTo _curSeatKey}
					}
				}) then {
					_available pushBack _instId;
				};
			} else {
				_available pushBack _instId;
			};
		};
	};
} forEach _keysMap;

_available sort true;
_monitor setVariable ["CFM_availInstCache", [diag_frameNo, _plr, _plrParent, _keysCount, _isPlrHandTablet, _available]];
_available
