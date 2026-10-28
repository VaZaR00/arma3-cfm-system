/*
    Function: CFM_fnc_closePIPwindow
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params [["_player", PLAYER_], ["_terminateCreate", true]];

if !(IS_OBJ(_player)) exitWith {};

if (_terminateCreate) then {
	private _createHndl = _player getVariable ["CFM_createPipHndl", scriptNull];
	if (!isNull _createHndl && {!(scriptDone _createHndl)}) then {
		terminate _createHndl;
	};
};

private _rscLayer = _player getVariable ["CFM_currentRscLayer", ""];
if ((_rscLayer isEqualType "" && {_rscLayer isNotEqualTo ""}) || {_rscLayer isEqualType 0 && {_rscLayer >= 0}}) then {
	_rscLayer cutFadeOut 0;
};
private _prevDisplay = _player getVariable ["CFM_currentDisplay", displayNull];
if (!isNull _prevDisplay) then {
	_prevDisplay closeDisplay 1;
};
private _prevMainDisplay = _player getVariable ["CFM_mainDisplay", displayNull];
if (!isNull _prevMainDisplay) then {
	_prevMainDisplay closeDisplay 1;
};
_player setVariable ["CFM_currentRscLayer", -1];
_player setVariable ["CFM_currentDisplay", displayNull];
_player setVariable ["CFM_currentPipControls", []];
