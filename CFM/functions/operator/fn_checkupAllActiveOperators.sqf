/*
    Function: CFM_fnc_checkupAllActiveOperators
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

{
	private _monitor = _x;
	if (_monitor getVariable ["CFM_isVehTablet", false]) then {
		private _seatInstances = _monitor getVariable ["CFM_seatTabletsInstances", createHashMap];
		{
			private _seatKey = _x;
			private _seatInstId = _y;
			private _operator = OIVAR(_monitor, "SeatTablet", _connectedOperator, _seatInstId, objNull);
			if (IS_OBJ(_operator)) then {
				private _opCond = [_operator, _monitor] call CFM_fnc_operatorCondition;
				if !(_opCond) then {
					["disconnect"] CALL_OBJINSTANCE("SeatTablet", _seatInstId, _monitor);
				} else {
					_operator call CFM_fnc_checkOperatorTurrets;
				};
			};
		} forEach _seatInstances;
		continue;
	};
	private _operator = _monitor getVariable ["CFM_connectedOperator", objNull];
	if !(IS_OBJ(_operator)) then {continue};
	private _opCond = [_operator, _monitor] call CFM_fnc_operatorCondition;
	if !(_opCond) then {
		[_monitor, _monitor] call CFM_fnc_disconnectMonitorFromOperator;
	};
	_operator call CFM_fnc_checkOperatorTurrets;
} forEach (missionNamespace getVariable ["CFM_Monitors", []]);
