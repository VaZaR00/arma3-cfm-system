/*
    Function: CFM_fnc_checkupAllActiveOperators
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

{
	private _monitor = _x;
	private _operator = _monitor getVariable ["CFM_connectedOperator", objNull];
	if !(IS_OBJ(_operator)) then {continue};
	private _opCond = [_operator, _monitor] call CFM_fnc_operatorCondition;
	if !(_opCond) then {
		[_monitor, _monitor] call CFM_fnc_disconnectMonitorFromOperator;
	};
	_operator call CFM_fnc_checkOperatorTurrets;
} forEach (missionNamespace getVariable ["CFM_Monitors", []]);
