/*
    Function: CFM_fnc_getMonitorScreenResolution
    Author: Vazar & Gemini
    Description:
        Returns the active screen resolution parameters ([width, height, scaleParams])
        for the given monitor object, [monitor, instId] pair, display, control, or raw resolution array.
        Resolves from display cache, instance variable, monitor variable, or class defaults.
    Parameters:
        0: _context [Object | Array | Display | Control] - Target monitor context (default objNull).
    Returns:
        [Array] - Resolution array [width, height, [scaleX, scaleY, offsetX, offsetY]].
*/

#include "defines.hpp"

params [["_context", objNull]];

if (isNil "_context") exitWith {+DEFAULT_SCREEN_RESOLUTION};

private _display = displayNull;
private _monitor = objNull;
private _instId = -1;

if (_context isEqualType []) then {
	if ((count _context >= 2) && {(_context select 0) isEqualType 0} && {(_context select 1) isEqualType 0}) exitWith {};
	if (IS_VALID_MON(_context)) then {
		_monitor = _context select 0;
		_instId = _context select 1;
	} else {
		_context = _context param [0, displayNull];
	};
};

if ((_context isEqualType []) && {count _context >= 2} && {(_context select 0) isEqualType 0} && {(_context select 1) isEqualType 0}) exitWith {
	+_context
};

if !(IS_OBJ(_monitor)) then {
	if (_context isEqualType controlNull) then {
		_context = ctrlParent _context;
	};

	if (_context isEqualType displayNull) then {
		_display = _context;
		if !(isNull _display) then {
			private _dispMon = _display getVariable ["CFM_monitor", [objNull, -1]];
			if (_dispMon isEqualType []) then {
				_monitor = _dispMon param [0, objNull];
				_instId = _dispMon param [1, -1];
			} else {
				_monitor = _dispMon;
			};
			if !(IS_OBJ(_monitor)) then {
				private _uiDisplaysMap = uiNamespace getVariable ["CFM_uiDisplayMonitorsMap", createHashMap];
				{
					if ((findDisplay _x) isEqualTo _display) exitWith {
						if (_y isEqualType []) then {
							_monitor = _y param [0, objNull];
							_instId = _y param [1, -1];
						} else {
							_monitor = _y;
						};
						_display setVariable ["CFM_monitor", if (_instId > 0) then {[_monitor, _instId]} else {_monitor}];
					};
				} forEach _uiDisplaysMap;
			};
			if !(IS_OBJ(_monitor)) then {
				private _creatingMon = uiNamespace getVariable ["CFM_creatingUiMonitor", [objNull, -1]];
				if (_creatingMon isEqualType []) then {
					_monitor = _creatingMon param [0, objNull];
					_instId = _creatingMon param [1, -1];
				} else {
					_monitor = _creatingMon;
				};
				if (IS_OBJ(_monitor)) then {
					_display setVariable ["CFM_monitor", if (_instId > 0) then {[_monitor, _instId]} else {_monitor}];
				};
			};
		} else {
			private _creatingMon = uiNamespace getVariable ["CFM_creatingUiMonitor", [objNull, -1]];
			if (_creatingMon isEqualType []) then {
				_monitor = _creatingMon param [0, objNull];
				_instId = _creatingMon param [1, -1];
			} else {
				_monitor = _creatingMon;
			};
		};
	} else {
		if (_context isEqualType objNull) then {
			_monitor = _context;
			if (IS_OBJ(_monitor)) then {
				_instId = [_monitor] call CFM_fnc_getSelectedMonitorInstance;
			};
		};
	};
};

private _dispRes = if !(isNull _display) then {_display getVariable "CFM_screenResolution"} else {nil};
if (!isNil "_dispRes" && {_dispRes isEqualType []} && {count _dispRes >= 2}) exitWith {
	+_dispRes
};

if !(IS_OBJ(_monitor)) exitWith {+DEFAULT_SCREEN_RESOLUTION};

private _res = if (_instId > 0) then {
	_monitor getVariable (MON_VAR_NAME("CFM_screenResolution", _instId))
} else {
	_monitor getVariable "CFM_screenResolution"
};
if (isNil "_res") then {
	_res = _monitor getVariable "CFM_screenResolution";
};
if (!isNil "_res" && {_res isEqualType ""}) then {
	_res = [_res, _monitor] call CFM_fnc_parseScreenResolution;
};

if (!isNil "_res" && {_res isEqualType []} && {count _res >= 2}) exitWith {
	if (_instId > 0) then {
		MON_SVAR(_monitor, _instId, "CFM_screenResolution", _res);
	} else {
		_monitor setVariable ["CFM_screenResolution", _res];
	};
	if !(isNull _display) then {
		_display setVariable ["CFM_screenResolution", _res];
	};
	+_res
};

_res = [_monitor] call CFM_fnc_getDefaultScreenResolution;
if (_instId > 0) then {
	MON_SVAR(_monitor, _instId, "CFM_screenResolution", _res);
} else {
	_monitor setVariable ["CFM_screenResolution", _res];
};
if !(isNull _display) then {
	_display setVariable ["CFM_screenResolution", _res];
};
+_res
