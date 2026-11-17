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
if ((count _keysMap) == 0) exitWith {[]};

private _plr = PLAYER_;
private _isPlrHandTablet = (_monitor isEqualTo _plr) && {[_plr] call CFM_fnc_hasHandTablet};
private _inVeh = (_plr in _monitor) && {_monitor isKindOf "AllVehicles"};
private _curSeatKey = if (_inVeh) then {[_monitor, _plr] call CFM_fnc_getUnitVehicleSeatKey} else {""};

private _available = [];
{
	private _instId = _x;
	_y params [["_texSel", NO_TEXTURE_SELECTION], ["_seatKey", ""], ["_isVehSeat", false], ["_isHand", false]];
	if (MON_GVAR(_monitor, _instId, "CFM_isMonitorInstanceSet", false)) then {
		if (_isHand) then {
			if (_isPlrHandTablet) then {
				_available pushBack _instId;
			};
		} else {
			if (_isVehSeat) then {
				if (_inVeh && {(_seatKey isEqualTo "") || {_seatKey isEqualTo _curSeatKey}}) then {
					_available pushBack _instId;
				};
			} else {
				_available pushBack _instId;
			};
		};
	};
} forEach _keysMap;

_available sort true;
_available
