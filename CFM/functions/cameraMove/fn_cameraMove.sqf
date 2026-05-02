/*
    Function: CFM_fnc_cameraMove
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_operator", ["_turretIndex", -1], ["_direction", ""], ["_step", CAMERA_MOVE_STEP]];

private _axisAngles = switch (_direction) do {
	case "up": {
		[0, _step]
	};
	case "down": {
		[0, -_step]
	};
	case "right": {
		[-_step, 0]
	};
	case "left": {
		[_step, 0]
	};
	default {[0,0]};
};

if (_axisAngles isEqualTo [0,0]) exitWith {false};

["moveCamera", [_turretIndex, _axisAngles], false] CALL_OBJCLASS("Operator", _operator);
