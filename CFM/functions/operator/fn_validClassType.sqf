/*
    Function: CFM_fnc_validClassType
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_cls"];

if (_cls isEqualTo DUMMY_CLASSNAME) exitWith {TYPE_STATIC};

private _isVeh = isClass (configFile >> "CfgVehicles" >> _cls);
if (_isVeh && {(getNumber (configFile >> "CfgVehicles" >> _cls >> "isUav")) isEqualTo 1}) exitWith {TYPE_UAV};
if (_isVeh && {_cls isKindOf "Man"}) exitWith {TYPE_UNIT};
if (_isVeh) exitWith {TYPE_VEH};
private _isWeap = isClass (configFile >> "CfgWeapons" >> _cls);
if (_isWeap && {
	private _parents = [configFile >> "CfgWeapons" >> _cls >> "ItemInfo", true] call BIS_fnc_returnParents;
	"headgearItem" in _parents
}) exitWith {TYPE_HELM};
if (_isWeap) exitWith {TYPE_WEAP};

""
