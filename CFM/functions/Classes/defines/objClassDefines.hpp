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
