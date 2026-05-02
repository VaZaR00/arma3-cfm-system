#define NEW_OBJINSTANCE_GLOBAL(name, global) call { \
	if (isNil "_this") exitWith {objNull}; \
	if !(_this isEqualType []) then {_this = [_this]}; \
	_this params [["_self", objNull], ["_args", []], ["_def", nil]]; \
	if !(IS_OBJ(_self)) exitWith {objNull}; \
	private _classFuncExists = CLASSNAME_EXISTS_STR(name); \
	if !(_classFuncExists select 0) exitWith {objNull}; \
	private _classFunc = _classFuncExists select 1; \
	private _ooClassname = _CLASSNAMESTR(name); \
	SET_THIS_OBJINSTANCE_GLOBAL(name, _self, _classFunc, global) \
	private _objClasses = _self getVariable ["OOP_this_classes", []];\
	_objClasses pushBackUnique _ooClassname; \
	_self setVariable ["OOP_this_classes", _objClasses, global]; \
	private _ooInitResult = ["Init", _args, _self, _self] call _classFunc; \
	if (isNil "_ooInitResult") then {NILDEF(_def, _self)} else {_ooInitResult}; \
};
#define NEW_OBJINSTANCE(name) NEW_OBJINSTANCE_GLOBAL(name, false)
#define SPAWN_NEW_OBJINSTANCE(name) call {[_this, name] spawn {params[["_this", []], ["_name", ""]]; _this NEW_OBJINSTANCE_GLOBAL(_name, false)};};
#define NEW_INSTANCE(name) call {["Init", _this] call (missionNamespace getVariable [_CLASSNAMESTR(name), {}])};
#define CLASSNAME_EXISTS(name) (call { \
	private _classFunc = (missionNamespace getVariable [STR(name), {}]) \
	if !(IS_FUNC(_classFunc)) then { \
		_classFunc = (missionNamespace getVariable [STR(_CLASSNAME(name)), {}]) \
		[IS_FUNC(_classFunc), _classFunc] \
	}; \
	[true, _classFunc] \
})
#define CLASSNAME_EXISTS_STR(name) (call { \
	private _classFunc = (missionNamespace getVariable [name, {}]); \
	if !(IS_FUNC(_classFunc)) then { \
		_classFunc = (missionNamespace getVariable [_CLASSNAMESTR(name), {}]); \
		[IS_FUNC(_classFunc), _classFunc] \
	}; \
	[true, _classFunc] \
})

#define _CLASSNAME(name) OOP_##PREFX##_Class_##name
#define _CLASSNAMESTR(name) format["OOP_%1_Class_%2", STR(PREFX), name]

#define METHODS switch (_method) do {

#define SET_SELF_VAR(name) private name = _self;

#define CLASS_MIDDLEWARE private _ooLastVar = 0; \
private _ooLastVarDef = 0; \
private _ooAllVars = createHashMap; \

#define OBJCLASS(name) _CLASSNAME(name) = {\
	params[["_method", "Init"], ["_args", []], ["_self", if !(isNil '_self') then {_self} else {objNull}]];\
	private _this = _args; \
	private _ooClassname = STR(_CLASSNAME(name)); \
	CLASS_MIDDLEWARE \

#define CLASS(name) _CLASSNAME(name) = {\
	params[["_method", "Init"], ["_args", []], ["_self", STR(_CLASSNAME(name))]];\
	private _this = _args; \
	private _ooClassname = STR(_CLASSNAME(name)); \
	CLASS_MIDDLEWARE \

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
	if (_doInit) then { \
		[_copyObj] NEW_OBJINSTANCE(_ooClassname) \
	} else { \
		private _classFunc = (missionNamespace getVariable [_ooClassname, {}]); \
		if !(_classFunc isEqualType {}) exitWith {}; \
		if (_classFunc isEqualTo {}) exitWith {}; \
		SET_THIS_OBJINSTANCE(_ooClassname, _copyObj, _classFunc) \
	}; \
	true \
}; \
default{}};};

#define THIS_INSTANCE(name, obj) (obj getVariable [THIS_INSTANCE_VARNAME(name), {CALL_PARAMS_OBJCLASS; _NIL(_def)}])
#define THIS_INSTANCE_VARNAME(name) (if ("_thisInstance" in name) then {name} else {format["OOP_%1_%2_thisInstance", SPREFX, name]})
#define SET_THIS_OBJINSTANCE_GLOBAL(name, obj, func, global) obj setVariable [THIS_INSTANCE_VARNAME(name), func, global];
#define SET_THIS_OBJINSTANCE(name, obj, func) SET_THIS_OBJINSTANCE_GLOBAL(name, obj, func, false)

#define OO_VAR_NAME(name) format["%1%2", SPREFX, STR(name)]

#define OBJ_VARIABLE_BASE(name, def) private name = _self getVariable [OO_VAR_NAME(name), def]; \
_ooAllVars set [OO_VAR_NAME(name), def]; \
_self setVariable ["CFM_ooAllVars", _ooAllVars];

#define OBJ_VARIABLE(name, def) OBJ_VARIABLE_BASE(name, def)\
CHECK_TYPE(name, def, def);

#define TYPE_OBJ_VARIABLE(name, def, type) OBJ_VARIABLE_BASE(name, def) CHECK_TYPE(name, def, type)

#define CHECK_TYPE(name, def, type) private _types = type; \
if !(_types isEqualType []) then {_types = [_types]}; \
if ((_types findIf {name isEqualType _x}) == -1) then {name = def};


#define CLASS_METHOD(name) case name: 

#define _NIL(var) (if !(isNil STR(var)) then {var})
#define NILDEF(var, def) (if !(isNil STR(var)) then {var} else {def})

#define CALL_PARAMS_OBJCLASS _this params [["_m", -1], ["_a", []], ["_self", objNull], ["_def", nil]];
#define CALL_PARAMS_CLASS _this params [["_m", -1], ["_a", []], ["_self", ""], ["_def", nil]];

#define CALL_OBJCLASS(name, obj) call { \
	private _self = obj;  \
	private _ooCallResult = _this call THIS_INSTANCE(name, obj); \
	if (isNil "_ooCallResult") then {CALL_PARAMS_OBJCLASS; _NIL(_def)} else {_ooCallResult}; \
}
#define CALL_CLASS(name) call { \
	private _classFuncExists = CLASSNAME_EXISTS_STR(name); \
	if !(_classFuncExists select 0) exitWith {_this call {CALL_PARAMS_CLASS; _NIL(_def)}}; \
	private _ooCallResult = _this call (_classFuncExists select 1); \
	if (isNil "_ooCallResult") then {CALL_PARAMS_CLASS; _NIL(_def)} else {_ooCallResult}; \
}
#define SPAWN_OBJCLASS(name, obj) call { \
	[_this, name, obj] spawn { \
		params["_this", "_name", "_obj"]; \
		private _self = _obj;  \
		_this call THIS_INSTANCE(_name, _obj); \
		if (isNil "_ooCallResult") then {CALL_PARAMS_OBJCLASS; _NIL(_def)} else {_ooCallResult}; \
	} \
}
#define SPAWN_CLASS(name) [name] spawn { \
	params["_name"]; \
	private _classFuncExists = CLASSNAME_EXISTS_STR(_name); \
	if !(_classFuncExists select 0) exitWith {_this call {CALL_PARAMS_CLASS; _NIL(_def)}}; \
	private _ooCallResult = _this call (_classFuncExists select 1); \
	if (isNil "_ooCallResult") then {CALL_PARAMS_CLASS; _NIL(_def)} else {_ooCallResult}; \
}