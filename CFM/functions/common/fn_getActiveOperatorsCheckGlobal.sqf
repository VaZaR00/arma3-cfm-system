/*
    Function: CFM_fnc_getActiveOperatorsCheckGlobal
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_monitor", objNull]];
private _objs = [];
if (missionNamespace getVariable ["CFM_checkGoPros", false]) then {
	_objs append allUnits;
};
if (missionNamespace getVariable ["CFM_checkUavsCams", false]) then {
	_objs append allUnitsUAV;
};
if (missionNamespace getVariable ["CFM_checkVehCams", false]) then {
	_objs append vehicles;
};
_objs select {
	([_x, _monitor] call CFM_fnc_operatorCondition)
}
