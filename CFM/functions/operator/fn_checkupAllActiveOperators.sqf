/*
    Function: CFM_fnc_checkupAllActiveOperators
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

{
	_x params [["_monitor", objNull], ["_instId", -1]];
	if (!(IS_OBJ(_monitor)) || {_instId < 1}) then {continue};
	private _monPair = [_monitor, _instId];
	private _operator = MON_GVAR(_monitor, _instId, "CFM_connectedOperator", objNull);
	if !(IS_OBJ(_operator)) then {continue};
	_operator call CFM_fnc_checkOperatorTurrets;
	private _opCond = [_operator, _monPair] call CFM_fnc_operatorCondition;
	if !(_opCond) then {
		[_monPair, _monPair] call CFM_fnc_disconnectMonitorFromOperator;
	};
} forEach (+(missionNamespace getVariable ["CFM_Monitors", []]));
