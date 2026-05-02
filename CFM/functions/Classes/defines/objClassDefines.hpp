#define OBJCLASS(name) \
    private _fields = []; \
    private _classname = STR(name); \
    private _methods = []; \
    private _selfVar = ""; \


#define FIELD _fields pushBack


#define VOLATILE FIELD


#define SET_SELF_VAR(name) _selfVar = name;


#define METHOD(name) \
    _methods pushBack name; _methods pushBack 


#define OBJCLASS_END \
    [_classname, _fields, _methods] call OOP_OBJ_CLASS_fnc_class \