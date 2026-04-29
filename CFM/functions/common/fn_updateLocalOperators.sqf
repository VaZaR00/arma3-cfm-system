/*
    Function: CFM_fnc_updateLocalOperators
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

private _localOps = missionNamespace getVariable ["CFM_LocalActiveOperators", []];

private _localityChanged = false;
{
    if !(local _x) then {
        _localityChanged = true;
        continue
    };
	[_x] call CFM_fnc_updateOperator;
} forEach _localOps;

if (_localityChanged) then {
    publicVariable "CFM_ActiveOperators";
    call CFM_ActiveOperators_PublicEH;
};