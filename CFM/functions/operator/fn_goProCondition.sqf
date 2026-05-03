/*
    Function: CFM_fnc_goProCondition
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

private _goProClassnames = missionNamespace getVariable "CFM_goProHelmets";
if (isNil "_goProClassnames") exitWith {false};
private _headgear = headgear _this;
_headgear in _goProClassnames;
