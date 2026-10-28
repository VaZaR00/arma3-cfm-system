/*
    Function: CFM_fnc_calculateCameraMoves
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[
	["_currentMoves", [0,0,0,0], [[]]], 
	["_moves", [0,0], [[]]], 
	["_restrictions", [0,0,0,0], [[]]]
];

_moves params [["_horizontal", 0, [0]], ["_vertical", 0, [0]]];

private _proccessDirection = {
	params[
		["_currMove", 0, [0]], 
		["_restr", 0, [0]], 
		["_move", 0, [0]]
	];
	if (!finite _currMove) then {_currMove = 0};
	if (!finite _restr) then {_restr = 0};
	if (!finite _move) then {_move = 0};
	private _newMove = _currMove + _move;
	if (_restr == 0) then {
		_restr = 180;
	};
	if ((_newMove >= 180) && {_restr >= 180}) exitWith {
		_currMove
	};
	if ((_currMove < _restr) && {_newMove > _restr}) then {
		_newMove = _restr;
	};
	_newMove
};

private _vertUp = [_currentMoves param [0, 0, [0]], _restrictions param [0, 0, [0]], _vertical] call _proccessDirection;
private _vertDown = [_currentMoves param [1, 0, [0]], _restrictions param [1, 0, [0]], -_vertical] call _proccessDirection;
private _horizLeft = [_currentMoves param [2, 0, [0]], _restrictions param [2, 0, [0]], _horizontal] call _proccessDirection;
private _horizRight = [_currentMoves param [3, 0, [0]], _restrictions param [3, 0, [0]], -_horizontal] call _proccessDirection;

[_vertUp, _vertDown, _horizLeft, _horizRight]
