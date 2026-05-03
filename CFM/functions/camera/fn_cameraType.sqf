/*
    Function: CFM_fnc_cameraType
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_obj"];

if !(IS_OBJ(_obj)) exitWith {""};

private _type = _obj getVariable ["CFM_cameraType", ""];

if !(IS_STR(_type)) then {
	_type = "";
};

if !(_type isEqualTo "") exitWith {_type};

private _cls = typeOf _obj;
private _classType = [_cls] call CFM_fnc_validClassType;

if (_cls isEqualTo DUMMY_CLASSNAME) exitWith {
	TYPE_STATIC
};
if ((_obj isKindOf "Man") || {_classType isEqualTo TYPE_UNIT}) exitWith {
	GOPRO
};
if (_classType isEqualTo TYPE_HELM) exitWith {
	GOPRO
};
if (_classType isEqualTo TYPE_UAV) exitWith {
	DRONETYPE
};
if (_classType isEqualTo TYPE_VEH) exitWith {
	TYPE_VEH
};
_classType
