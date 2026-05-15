/*
    Function: CFM_fnc_defineSignalEffectFunc
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

// returns [signalFunc, effectFunc]
params["_operator", ["_turret", -1], ["_opClass", ""], ["_isMavic", false], ["_isFPV", false], ["_isDrone", false]];

if (_isFPV) exitWith {
	[MGVAR ["CFM_fnc_fpv_getSignal", {1}], MGVAR ["CFM_fnc_fpv_effects", {}]]
};
if (_isDrone) exitWith {
	[MGVAR ["CFM_fnc_drone_getSignal", {1}], MGVAR ["CFM_fnc_drone_effects", {}]]
};

[]
