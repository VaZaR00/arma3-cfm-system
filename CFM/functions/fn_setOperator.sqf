/*
	CFM_fnc_setOperator

	Sets obj as operator
*/

#include "defines.hpp"

params [
	["_operator", objNull], 
	["_sides", []], 
	["_turrets", []], 
	["_zoomParams", []], 
	["_hasTInNvg", [0, 0]], 
	["_params", []]

];
if (isNil "_operator") exitWith {false};

private _reset = if (isNil "_reset") then {true} else {_reset};

if (!_reset && {(IS_OBJ(_operator)) && {((_operator getVariable ["CFM_operatorSet", false]) isEqualTo true)}}) exitWith {false};

["setOperator", _this] CALL_CLASS("DbHandler");

true