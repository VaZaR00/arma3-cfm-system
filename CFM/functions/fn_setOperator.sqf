/*
	Name: CFM_fnc_setOperator

	Call: spawn

	Description: 
		Sets obj as operator

	Return: true os succes, false or any if not

	Arguments:
		1. _operator [object]
		2. _sides [Array[side], side] - defines sides of monitors which can connect to operator
		3. _turrets [array] - turrets params, check 'DefineTurretsParams' and 'setTurretParams' methods in Operator Class
		5. _hasTInNvg [array] - array of [bool, bool] if operator has nvg and ti
		6. _name [str] - name of camera
		7. _params [array]:
			1. canMoveCameraByDefault [bool] - if true, operator can move camera by default, if false, can't, if not set, it will be set based on turret params (def: false)
			2. smoothZoomDefault [bool] - if true, camera zooms smoothly by default, if false, it doesn't, if not set, it will be set based on turret params (def: false)

*/

#include "defines.hpp"

// for JIP sync
// OPERATORS INIT ONLY ON SERVER
if !(isServer) exitWith {false};

if !(canSuspend) exitWith {
	_this spawn CFM_fnc_setOperator;
};
waitUntil { !(isNil "CFM_inited") };

params [
	["_operator", objNull], 
	["_sides", []], 
	["_turrets", []], 
	["_hasTInNvg", [0, 0]], 
	["_name", ""], 
	["_params", []]
];
if (isNil "_operator") exitWith {false};

if (_operator isEqualType []) exitWith {
	private _mainArgs = [_sides, _turrets, _hasTInNvg, _name, _params];
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

if (!_reset && {(IS_VALID_OP(_operator)) && {((_operator getVariable ["CFM_operatorSet", false]) isEqualTo true)}}) exitWith {false};

["setOperator", _this] CALL_CLASS("DbHandler");