/*
    Function: CFM_fnc_copyMenuActionsToObj
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_from", "_to"];

private _actions = _plr getVariable ["CFM_mainActions", []];

if (!(_actions isEqualType []) || {(_actions isEqualTo [])}) exitWith {
	"CAN'T COPY HAND MONITOR ACTIONS TO NEW CONTROLLED UNIT!" WARN;
	false
};

private _newActions = [];

{
	if !(_x isEqualType 1) then {continue};
	private _actionParams = _from actionParams _x;
	_actionParams deleteAt 10;
	_actionParams deleteAt 11;
	private _id = _to addAction _actionParams;
	_newActions pushBack _id;
} forEach _actions;

_unit setVariable ["CFM_copiedActions", _newActions];
_unit setVariable ["CFM_actionsSet", true];
true
