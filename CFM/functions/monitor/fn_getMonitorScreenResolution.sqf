/*
    Function: CFM_fnc_getMonitorScreenResolution
    Author: Vazar
    Description:
        Returns the active [width, height] screen resolution for the given monitor object,
        display, control, or [width, height] resolution array.
*/

#include "defines.hpp"

params [["_context", objNull]];

if (isNil "_context") exitWith {+DEFAULT_SCREEN_RESOLUTION};

if (_context isEqualType []) then {
	if ((count _context >= 2) && {(_context select 0) isEqualType 0} && {(_context select 1) isEqualType 0}) exitWith {};
	_context = _context param [0, displayNull];
};

if ((_context isEqualType []) && {count _context >= 2} && {(_context select 0) isEqualType 0} && {(_context select 1) isEqualType 0}) exitWith {
	+_context
};

if (_context isEqualType controlNull) then {
	_context = ctrlParent _context;
};

private _display = displayNull;
private _monitor = objNull;

if (_context isEqualType displayNull) then {
	_display = _context;
	if !(isNull _display) then {
		_monitor = _display getVariable ["CFM_monitor", objNull];
		if !(IS_OBJ(_monitor)) then {
			private _uiDisplaysMap = uiNamespace getVariable ["CFM_uiDisplayMonitorsMap", createHashMap];
			{
				if ((findDisplay _x) isEqualTo _display) exitWith {
					_monitor = _y;
					_display setVariable ["CFM_monitor", _monitor];
				};
			} forEach _uiDisplaysMap;
		};
		if !(IS_OBJ(_monitor)) then {
			private _creatingMon = uiNamespace getVariable ["CFM_creatingUiMonitor", objNull];
			if (IS_OBJ(_creatingMon)) then {
				_monitor = _creatingMon;
				_display setVariable ["CFM_monitor", _monitor];
			};
		};
	} else {
		_monitor = uiNamespace getVariable ["CFM_creatingUiMonitor", objNull];
	};
} else {
	if (_context isEqualType objNull) then {
		_monitor = _context;
	};
};

private _dispRes = if !(isNull _display) then {_display getVariable "CFM_screenResolution"} else {nil};
if (!isNil "_dispRes" && {_dispRes isEqualType []} && {count _dispRes >= 2}) exitWith {
	+_dispRes
};

if !(IS_OBJ(_monitor)) exitWith {+DEFAULT_SCREEN_RESOLUTION};

private _res = _monitor getVariable "CFM_screenResolution";
if (!isNil "_res" && {_res isEqualType ""}) then {
	_res = [_res] call CFM_fnc_parseScreenResolution;
};

if (!isNil "_res" && {_res isEqualType []} && {count _res >= 2}) exitWith {
	_monitor setVariable ["CFM_screenResolution", _res];
	if !(isNull _display) then {
		_display setVariable ["CFM_screenResolution", _res];
	};
	+_res
};

_res = [_monitor] call CFM_fnc_getDefaultScreenResolution;
_monitor setVariable ["CFM_screenResolution", _res];
if !(isNull _display) then {
	_display setVariable ["CFM_screenResolution", _res];
};
+_res
