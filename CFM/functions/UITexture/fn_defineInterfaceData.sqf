/*
    Function: CFM_fnc_defineInterfaceData
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

// returns [_interfaceClass, _interfaceFuncNameDef, _interfaceInitFuncNameDef]
params["_operator", ["_turret", -1], ["_opClass", ""], ["_isMavic", false], ["_isFPV", false], ["_isDrone", false]];

if !(IS_STR(_opClass)) then {
	_opClass = toLower typeOf _operator;
};

private _presetHud = [_operator, _turret, _opClass, _isDrone, true] call CFM_fnc_detectOperatorHudConfig;
if !(_presetHud isEqualTo []) exitWith {_presetHud};

private _dynHud = [_operator, _turret, _opClass, _isDrone] call CFM_fnc_detectOperatorHudConfig;
if !(_dynHud isEqualTo []) exitWith {_dynHud};

if (_isDrone) exitWith {
	["RscDisplayR2TDisplayCFM", MGVAR ["CFM_fnc_drone_updateInterface", {}], MGVAR ["CFM_fnc_drone_initInterface", {}]]
};

[]
