#define OBJCLASS(name) call { \
    private _fields = []; \
    private _classname = STR(name); \
    private _methods = []; \
    private _selfVar = ""; \


#define FIELD _fields pushBack


#define VOLATILE _fields pushBack true; FIELD


#define SET_SELF_VAR(name) _selfVar = name;


#define METHOD(name) \
    _methods pushBack name; _methods pushBack 


#define OBJCLASS_END \
    [_classname, _fields, _methods, _selfVar] call OOP_fnc_class }; \


#define CALL_OBJCLASS(name, obj) call { \
    _this params ["_method", ["_args", []], ["_def", nil]]; \
    [name, obj, _method, _args, NIL_DEF] call OOP_OBJ_CLASS_fnc_callClassInstance; \
} \


#define SPAWN_OBJCLASS(name, obj) call { \
    _this params ["_method", ["_args", []], ["_def", nil]]; \
    [name, obj, _method, _args, NIL_DEF] spawn OOP_OBJ_CLASS_fnc_callClassInstance; \
} \


#define REMOTE_EXEC_OBJCLASS(name, obj) call { \
    _this params ["_method", ["_args", []], ["_def", nil], ["_remoteExecParams", false]]; \
    [[name, obj, _method, _args, NIL_DEF], _remoteExecParams] call OOP_OBJ_CLASS_fnc_remoteExecClassInstance; \
} \


#define NEW_OBJINSTANCE_GLOBAL(name, global) call { \
	if (isNil "_this") exitWith {objNull}; \
	if !(_this isEqualType []) then {_this = [_this]}; \
	_this params [["_obj", objNull], ["_initArgs", []], ["_def", nil]]; \
    [name, _obj, _initArgs, global, NIL_DEF] call OOP_OBJ_CLASS_fnc_newInstance; \
} \


#define SPAWN_NEW_OBJINSTANCE_GLOBAL(name, global) call { \
	if (isNil "_this") exitWith {objNull}; \
	if !(_this isEqualType []) then {_this = [_this]}; \
	_this params [["_obj", objNull], ["_initArgs", []], ["_def", nil]]; \
    [name, _obj, _initArgs, global, NIL_DEF] spawn OOP_OBJ_CLASS_fnc_newInstance; \
} \


#define NEW_OBJINSTANCE(name) NEW_OBJINSTANCE_GLOBAL(name, false)
#define SPAWN_NEW_OBJINSTANCE(name) SPAWN_NEW_OBJINSTANCE_GLOBAL(name, false)


#define GLOBAL_SETTER _oopSetVarGlobal = true;
#define LOCAL_SETTER _oopSetVarGlobal = false;
#define SET_SELFVART(name, target) _self setVariable [STR(DOUBLE(PREFX,name)), name, target];
#define SET_SELFVAR(name) SET_SELFVART(name, _oopSetVarGlobal)
#define SET_SELFVARG(name) SET_SELFVART(name, true)
#define SET_SELFSVART(name, target) _self setVariable [SPREFX + name, call compile name, target];
#define SET_SELFSVAR(name) SET_SELFSVART(name, _oopSetVarGlobal)
#define SET_SELFSVARG(name) SET_SELFVART(name, true)

#define GET_SELFVAR(name) (_self getVariable [STR(DOUBLE(PREFX,name)), name])
#define SELFVAR(name) name = GET_SELFVAR(name); name

#define IVAR(instance, name, def) private name = instance getVariable [STR(DOUBLE(PREFX,name)), def];


#define SAVE_VARS _oopSaveVars = true;
#define DONT_SAVE_VARS _oopSaveVars = false;
#define SAVE_VARS_DEF _oopSaveVars = 0;

#define SAVE_VAR(name) _oopToSaveVars set [STR(name), true];
#define DONT_SAVE_VAR(name) _oopToSaveVars set [STR(name), nil];
#define SAVE_VAR_TARGET(name, target) _oopToSaveVarsParams set [STR(name), target];
#define SAVE_VAR_GLOBAL(name) SAVE_VAR_TARGET(name, true)
#define SAVE_VAR_LOCAL(name) SAVE_VAR_TARGET(name, false)
#define SAVE_VAR_DEF(name) SAVE_VAR_TARGET(name, nil)


#define NP_PARAMS call OOP_fnc_nonPrivateParams;