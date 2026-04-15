/*
	Name: CFM_fnc_setOperator

	Description: 
		Sets obj as operator
		SHOULD BE EXECUTED GLOBALY AND JIP!

	Return: true os succes, false or any if not

	Arguments:
		1. _operator [object]
		2. _sides [Array[side], side] - defines sides of monitors which can connect to operator
		3. _turrets [array] - turrets params, check 'DefineTurretsParams' and 'setTurretParams' methods in Operator Class
		5. _hasTInNvg [array] - array of [bool, bool] if operator has nvg and ti
		6. _params [array] - other
*/

#include "defines.hpp"

params [
	["_operator", objNull], 
	["_sides", []], 
	["_turrets", []], 
	["_hasTInNvg", [0, 0]], 
	["_params", []]
];
if (isNil "_operator") exitWith {false};

private _reset = if (isNil "_reset") then {true} else {_reset};

if (!_reset && {(IS_OBJ(_operator)) && {((_operator getVariable ["CFM_operatorSet", false]) isEqualTo true)}}) exitWith {false};

["setOperator", _this] CALL_CLASS("DbHandler");