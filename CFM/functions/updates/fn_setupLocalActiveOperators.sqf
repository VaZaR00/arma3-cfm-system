/*
    Function: CFM_fnc_setupLocalActiveOperators
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

private _activeOperators = missionNamespace getVariable ["CFM_ActiveOperators", []];
CFM_LocalActiveOperators = _activeOperators select {
	(local _x) && {
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
};
CFM_LocalActiveOperators
