/*
	Name: CFM_fnc_setOperator

	Description: 
		Sets obj as operator

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

if (_operator isEqualType []) exitWith {
	private _mainArgs = [_sides, _turrets, _hasTInNvg, _params];
	_operator apply {
		if (isNil "_x") then {continue};
		if (_x isEqualType []) then {
			private _args = +_x;
			for "_i" from 1 to (count _mainArgs) do {
				private _val = _args#_i;
				if (isNil "_val") then {
					_args set [_i, (_mainArgs select (_i - 1))];
				};
			};
			_args call CFM_fnc_setOperator;
		} else {
			private _args = [_x] + _mainArgs;
			_args call CFM_fnc_setOperator;
		};
	};
};

private _reset = if (isNil "_reset") then {true} else {_reset};

if (!_reset && {(IS_OBJ(_operator)) && {((_operator getVariable ["CFM_operatorSet", false]) isEqualTo true)}}) exitWith {false};

#ifdef SET_MON_OP_REMOTE_EXEC
// for JIP sync
if !(isServer) exitWith {false};

[_this, {
["setOperator", _this] CALL_CLASS("DbHandler");
}, 0, true, true] call CFM_fnc_remoteExec;
#endif 

#ifundef SET_MON_OP_REMOTE_EXEC
["setOperator", _this] CALL_CLASS("DbHandler");
#endif 