/*
    Function: CFM_fnc_getTurretIndex
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_t", ["_path", [0]]];

switch (_t) do {
	case "driver": {-1};
	case "turret": {
		private _pathIndex = _path#0;
		_pathIndex
	};
	default {
		private _i = TURRET_INDEX(_t);
		if (_i isEqualType 1) exitWith {_i};
		-2
	};
};
