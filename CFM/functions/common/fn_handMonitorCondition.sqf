/*
    Function: CFM_fnc_handMonitorCondition
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

private _monitorItem = missionNamespace getVariable "CFM_handMonitorItem";
if (isNil "_monitorItem") exitWith {
	_this call CFM_fnc_hasUAVterminal
};

if !(_monitorItem isEqualType "") exitWith {false};

[_this, _monitorItem] call BIS_fnc_hasItem;
