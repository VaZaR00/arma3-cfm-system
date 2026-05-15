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

if (_isMavic) exitWith {
	["RscCFM_Mavic_Interface", MGVAR ["CFM_fnc_updateMavicInterface", {}], MGVAR ["CFM_fnc_initMavicInterface", {}]]
};
if (_isFPV) exitWith {
	["RscCFM_ArmaFPV_Dialog", MGVAR ["CFM_fnc_updateFPVInterface", {}], MGVAR ["CFM_fnc_initFPVInterface", {}]]
};
if ("zala" in _opClass) exitWith {
	switch (_turret) do {
		// case DRIVER_TURRET_IDX: {
		// 	['CFM_Zala421_Interface_Driver', MGVAR ["CFM_fnc_zala_drawHudDriver", {}], MGVAR ["CFM_fnc_initZalaInterfaceDriver", {}]]
		// };
		case GUNNER_TURRET_IDX: {
			['CFM_Zala421_Interface_Gunner', MGVAR ["CFM_fnc_zala_drawHudGunner", {}], MGVAR ["CFM_fnc_initZalaInterfaceGunner", {}]]
		};
		default {[]};
	};
};
if (_isDrone) exitWith {
	["RscDisplayR2TDisplayCFM", MGVAR ["CFM_fnc_drone_updateInterface", {}], MGVAR ["CFM_fnc_drone_initInterface", {}]]
};

[]
