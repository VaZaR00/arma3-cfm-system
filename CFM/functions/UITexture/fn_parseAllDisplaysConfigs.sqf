/*
    Function: CFM_fnc_parseAllDisplaysConfigs
    Author: Vazar
    Description:
        Parses all CFM UI display configs and caches their control parameter formulas.
        Called during preStart (and in DEV mode on mission init).
*/

#include "defines.hpp"

private _displayClasses = [
	"RscDisplayR2TDisplayCFM",
	"RscCFM_Mavic_Interface",
	"RscCFM_ArmaFPV_Dialog",
	"CFM_Zala421_Interface_Driver",
	"CFM_Zala421_Interface_Gunner"
];

{
	[_x] call CFM_fnc_parseDisplayConfig;
} forEach _displayClasses;

true
