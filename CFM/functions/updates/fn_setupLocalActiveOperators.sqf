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
		private _isLocal = false;
		{
			_x params ["_id", "_obj"];
			SIVAR_S(_obj,"Turret",_isLocal,false);
			if (_isLocal) exitWith {
				_hasTurrLocal = true;
			};
		} forEach _turretsInstances;
		_hasTurrLocal
	}
};
CFM_LocalActiveOperators
