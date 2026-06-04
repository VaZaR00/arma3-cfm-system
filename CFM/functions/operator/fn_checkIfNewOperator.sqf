/*
    Function: CFM_fnc_checkIfNewOperator
    Author: Vazar
    Description: Check if object could be operator, if true init class
*/

#include "defines.hpp" 

params["_obj"];

if !(IS_OBJ(_obj)) exitWith {false};

if ((_obj getVariable ["CFM_operatorSet", false]) isEqualTo true) exitWith {true};

private _cls = _obj call CFM_fnc_getOperatorClass;
private _clssSetup = missionNamespace getVariable ["CFM_OperatorClasses", createHashMap];
private _clsArgs = _clssSetup get _cls;
if !(isNil "_clsArgs") exitWith {
	// obj class is operator so init operator
	if !(_clsArgs isEqualType []) then {
		_clsArgs = [_clsArgs];
	};
	private _args = [_obj] + _clsArgs;
	["CFM_setOperator", _args, 2] call CFM_fnc_remoteEvent;
	true
};
if ((MGVAR ["CFM_allUavsAreFeedingByDefault", false]) isEqualTo true) exitWith {
	if (_obj call CFM_fnc_isUAV) exitWith {
		["CFM_setOperator", [_obj], 2] call CFM_fnc_remoteEvent;
		true
	};
	false
};
false