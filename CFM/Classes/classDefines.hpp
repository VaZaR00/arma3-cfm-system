#include "./defines.hpp"

#define _CLASSNAME(name) OOP_##PREFX##_Class_##name

#define METHODS switch (_method) do {

#define SET_SELF_VAR(name) private name = _self;

#define CLASS_MIDDLEWARE private _ooLastVar = 0; \
private _ooLastVarDef = 0; \
private _ooAllVars = createHashMap; \

#define OBJCLASS(name) _CLASSNAME(name) = {\
	params[["_method", "init"], ["_args", []], ["_self", if !(isNil '_self') then {_self} else {objNull}]];\
	CLASS_MIDDLEWARE \
	_this = _args; \

#define CLASS(name) _CLASSNAME(name) = {\
	params[["_method", "init"], ["_args", []], ["_selfName", STR(_CLASSNAME(name))]];\
	CLASS_MIDDLEWARE \
	_this = _args; \

#define CLASS_END default{}};};


#define OO_VAR_NAME(name) format["%1%2", SPREFX, STR(name)]

#define VARIABLE(name, def) private name = _self getVariable [OO_VAR_NAME(name), def]; \
CHECK_TYPE(name, def, def);

#define TYPE_VARIABLE(name, def, type) VARIABLE(name, def) CHECK_TYPE(name, def, type)

#define CHECK_TYPE(name, def, type) private _types = type; \
if !(_types isEqualType []) then {_types = [_types]}; \
if ((_types findIf {name isEqualType _x}) == -1) then {name = def};


#define METHOD(name) case name: 


#define CALL_OBJCLASS(obj) call {private _self = obj; _this call (obj getVariable [format["OOP_%1_thisInstance", SPREFX], {_this params [["_m", -1], ["_a", []], ["_self", objNull], ["_def", nil]]; _def}])}

#define CALL_CLASS(name) call {_this call (missionNamespace getVariable [format["%1_Instance", _CLASSNAME(name)], {_this params [["_m", -1], ["_a", []], ["_self", ""], ["_def", nil]]; _def}])}