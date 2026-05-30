/*
    Function: CFM_fnc_updateActiveOperatorsLocalTurrets
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_ops", []]];

if !(_ops isEqualType []) then {
	_ops = [_ops];
};

private _activeOperators = (missionNamespace getVariable ["CFM_ActiveOperators", []]);
{
	_activeOperators pushBackUnique _x;
} forEach _ops;

private _localActiveOperators = _activeOperators select {
	if (IS_OBJ(_x)) then {
		((local _x) || {_x call CFM_fnc_checkTurretsLocality}) && {
			private _hasTurrLocal = false;
			private _turretsInstances = _x getVariable "CFM_turretsInstances";
			if (isNil "_turretsInstances" || {!(_turretsInstances isEqualType createHashMap)}) exitWith {false};
			{
				_y params [["_turretInstanceId", -1], ["_turretObject", objNull]];
				if (TURRET_VAR(_isLocal, false)) exitWith {
					_hasTurrLocal = true;
				};
			} forEach _turretsInstances;
			_hasTurrLocal
		}
	} else {
		false
	};
};
CFM_LocalActiveOperators = _localActiveOperators apply {
	private _obj = _x; 
	private _allTurerts = (allTurrets _obj) + [DRIVER_TURRET_PATH];
	private _localTurrets = _allTurerts select {_obj turretLocal _x};
	[_obj, _localTurrets]
};

CFM_LocalActiveOperators
