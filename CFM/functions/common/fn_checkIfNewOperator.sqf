/*
    Function: CFM_fnc_checkIfNewOperator
    Author: Vazar
    Description: Check if object could be operator, if true init class
*/

#include "defines.hpp" 

params["_obj"];

if !(IS_OBJ(_obj)) exitWith {false};

private _cls = _obj call CFM_fnc_getOperatorClass;
private _clssSetup = missionNamespace getVariable ["CFM_OperatorClasses", createHashMap];
private _clsArgs = _clssSetup get _cls;
if !(isNil "_clsArgs") exitWith {
	// obj class is operator so init operator
	if !(_clsArgs isEqualType []) then {
		_clsArgs = [_clsArgs];
	};
	private _args = [_obj] + _clsArgs;
	[_args, {
		private _reset = false;
		_this call CFM_fnc_setOperator;
	}, 2, false, false] call CFM_fnc_remoteExec;
	true
};
false