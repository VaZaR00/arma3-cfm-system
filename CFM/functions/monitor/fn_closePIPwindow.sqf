/*
    Function: CFM_fnc_closePIPwindow
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params [["_monArg", PLAYER_], ["_terminateCreate", true]];

(RESOLVE_MON(_monArg)) params ["_player", "_instId"];
if (!(IS_OBJ(_player))) exitWith {};
if (_instId < 1) then {
	_instId = (_player getVariable ["CFM_monitorInstancesMap", createHashMap]) getOrDefault [HAND_MONITOR_KEY, 1];
};
if (_instId < 1) exitWith {};

if (_terminateCreate) then {
	private _createHndl = MON_GVAR(_player, _instId, "CFM_createPipHndl", scriptNull);
	if (!isNull _createHndl && {!(scriptDone _createHndl)}) then {
		terminate _createHndl;
	};
};

private _rscLayer = MON_GVAR(_player, _instId, "CFM_currentRscLayer", "");
if ((_rscLayer isEqualType "" && {_rscLayer isNotEqualTo ""}) || {_rscLayer isEqualType 0 && {_rscLayer >= 0}}) then {
	_rscLayer cutFadeOut 0;
};
private _prevDisplay = MON_GVAR(_player, _instId, "CFM_currentDisplay", displayNull);
if (!isNull _prevDisplay) then {
	_prevDisplay closeDisplay 1;
};
MON_SVAR(_player, _instId, "CFM_currentRscLayer", -1);
MON_SVAR(_player, _instId, "CFM_currentDisplay", displayNull);
MON_SVAR(_player, _instId, "CFM_currentPipControls", []);
