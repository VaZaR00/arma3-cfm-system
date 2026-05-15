/*
    Function: CFM_fnc_calculateCameraMoves
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_currentMoves", [0,0,0,0], [[]], 4], ["_moves", [0,0], [[]], 2], ["_restrictions", [0,0,0,0], [[]], 4]];

_moves params [["_horizontal", 0], ["_vertical", 0]];

private _proccessDirection = {
	params["_currMove", "_restr", "_move"];
	private _newMove = _currMove + _move;
	if (_restr == 0) then {
		_restr = 180
	};
	if ((_newMove >= 180) && {_restr >= 180}) exitWith {
	};
	if ((_currMove < _restr) && {_newMove > _restr}) then {
		_newMove = _restr;
	};
	_newMove
};

private _vertUp = [(_currentMoves#0), (_restrictions#0), _vertical] call _proccessDirection;
private _vertDown = [(_currentMoves#1), (_restrictions#1), -_vertical] call _proccessDirection;
private _horizLeft = [(_currentMoves#2), (_restrictions#2), _horizontal] call _proccessDirection;
private _horizRight = [(_currentMoves#3), (_restrictions#3), -_horizontal] call _proccessDirection;

[_vertUp, _vertDown, _horizLeft, _horizRight]
