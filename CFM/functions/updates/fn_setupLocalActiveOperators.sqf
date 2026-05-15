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
		private _turretsParams = _x getVariable "CFM_turretsParams";
		if (isNil "_turretsParams" || {!(_turretsParams isEqualType createHashMap)}) exitWith {false};
		{
			if (_y getOrDefault ["IsTurretLocal", false]) exitWith {
				_hasTurrLocal = true;
			};
		} forEach _turretsParams;
		_hasTurrLocal
	}
};
CFM_LocalActiveOperators
