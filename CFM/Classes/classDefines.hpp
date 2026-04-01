#include "./defines.hpp"

#define NEW_OBJINSTANCE_GLOBAL(name, global) call { \
	if (isNil "_this") exitWith {}; \
	if !(_this isEqualType []) then {_this = [_this]}; \
	private _self = _this#0; \
	if !(IS_OBJ(_self)) exitWith {}; \
	_this = ["init", _this, _self]; \
	private _classFunc = CLASSNAME_EXISTS_STR(name); \
	if !(_classFunc#0) exitWith {}; \
	_self setVariable [format["OOP_%1_thisInstance", SPREFX], _classFunc, global]; \
	_self setVariable [format["OOP_%1_class", SPREFX], _CLASSNAMESTR(name), global]; \
	_this call _classFunc \
};
#define NEW_OBJINSTANCE(name) NEW_OBJINSTANCE_GLOBAL(name, false)
#define NEW_INSTANCE(name) call {["init", _this] call (missionNamespace getVariable [_CLASSNAMESTR(name), {}])};
#define CLASSNAME_EXISTS(name) (name call { \
	private _classFunc = (missionNamespace getVariable [name, {}]) \
	if (!(_classFunc isEqualType {}) || (_classFunc isEqualTo {})) then { \
		_classFunc = (missionNamespace getVariable [_CLASSNAME(name), {}]) \
		[(!(_classFunc isEqualType {}) || (_classFunc isEqualTo {})), _classFunc] \
	}; \
	[true, _classFunc] \
})
#define CLASSNAME_EXISTS_STR(name) (name call { \
	private _classFunc = (missionNamespace getVariable [name, {}]) \
	if (!(_classFunc isEqualType {}) || (_classFunc isEqualTo {})) then { \
		_classFunc = (missionNamespace getVariable [_CLASSNAMESTR(name), {}]) \
		[((_classFunc isEqualType {}) && !(_classFunc isEqualTo {})), _classFunc] \
	}; \
	[true, _classFunc] \
})

#define _CLASSNAME(name) OOP_##PREFX##_Class_##name
#define _CLASSNAMESTR(name) format["OOP_%1_Class_%2", PREFX, name]

#define METHODS switch (_method) do {

#define SET_SELF_VAR(name) private name = _self;

#define CLASS_MIDDLEWARE private _ooLastVar = 0; \
private _ooLastVarDef = 0; \

#define OBJCLASS(name) _CLASSNAME(name) = {\
	params[["_method", "init"], ["_args", []], ["_self", if !(isNil '_self') then {_self} else {objNull}]];\
	_this = _args; \
	CLASS_MIDDLEWARE \
	OBJ_VARIABLE(_ooAllVars, createHashMap);

#define CLASS(name) _CLASSNAME(name) = {\
	params[["_method", "init"], ["_args", []], ["_self", STR(_CLASSNAME(name))]];\
	_this = _args; \
	CLASS_MIDDLEWARE \
	VARIABLE(_ooAllVars, createHashMap);

#define CLASS_END \
if (_method isEqualTo "oopCopySelf") exitWith { \
	_args params [["_copyObj", objNull], ["_doInit", false], ["_global", false]]; \
	if !(IS_OBJ(_copyObj)) exitWith {false}; \
	if !(IS_OBJ(_self)) exitWith {false}; \
	_ooAllVars apply { \
		private _name = _x; \
		private _def = _y; \
		private _val = _self getVariable [_name, _def]; \
		_copyObj setVariable [_name, _val, _global]; \
	}; \
	private _classname = _CLASSNAMESTR(name); \
	if (_doInit) then { \
		[_copyObj] NEW_OBJINSTANCE(name) \
	} else { \
		private _classFunc = (missionNamespace getVariable [_classname, {}]) \
		if !(_classFunc isEqualType {}) exitWith {}; \
		if (_classFunc isEqualTo {}) exitWith {}; \
		_copyObj setVariable [format["OOP_%1_thisInstance", SPREFX], _classFunc, _global]; \
		_copyObj setVariable [format["OOP_%1_class", SPREFX], _classname, _global]; \
	}; \
	true \
}; \
default{}};};


#define OO_VAR_NAME(name) format["%1%2", SPREFX, STR(name)]

#define OBJ_VARIABLE(name, def) private name = _self getVariable [OO_VAR_NAME(name), def]; \
_ooAllVars set [OO_VAR_NAME(name), def]\
CHECK_TYPE(name, def, def);

#define TYPE_OBJ_VARIABLE(name, def, type) OBJ_VARIABLE(name, def) CHECK_TYPE(name, def, type)

#define CHECK_TYPE(name, def, type) private _types = type; \
if !(_types isEqualType []) then {_types = [_types]}; \
if ((_types findIf {name isEqualType _x}) == -1) then {name = def};


#define METHOD(name) case name: 


#define CALL_PARAMS_OBJCLASS _this params [["_m", -1], ["_a", []], ["_self", objNull], ["_def", nil]];
#define CALL_PARAMS_CLASS _this params [["_m", -1], ["_a", []], ["_self", ""], ["_def", nil]];
#define CALL_CLASS_FUNC(obj, paramsClass) call { \
	private _self = obj;  \
	private _res = _this call (obj getVariable [format["OOP_%1_thisInstance", SPREFX], { \
		paramsClass; _def \
	}]); \
	if (isNil "_res") then {paramsClass; _def} else {_res};
}
#define CALL_OBJCLASS(obj) CALL_CLASS_FUNC(obj, CALL_PARAMS_OBJCLASS)
#define CALL_CLASS(obj) CALL_CLASS_FUNC(obj, CALL_PARAMS_CLASS)
