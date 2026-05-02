#include "defines.hpp" 



#define INIT "init"



// EXCEPTIONS
#define EXCEPTION(code) ([code, _NIL(_this), _NIL(_className), _NIL(_class), NIL_DEF] call OOP_OBJ_CLASS_fnc_raiseException)

#define EXCEPTION_CLASS_DONT_EXISTS 0
#define EXCEPTION_NON_OBJ 1
#define EXCEPTION_NO_CLASSNAME 2
#define EXCEPTION_NO_FIELDS 3
#define EXCEPTION_NO_METHODS 4
#define EXCEPTION_METHOD_DONT_EXISTS 4
#define EXCEPTION_METHOD_FUNC_DONT_EXISTS 5
#define EXCEPTION_SELF_VAR_NOT_STRING 6

#define NIL_DEF _NIL(_def)

OOP_OBJ_CLASS_fnc_class = {
    params ["_className", "_fields", "_methods", ["_selfVar", ""]];

    private _classRegistryName = [_className] call OOP_OBJ_CLASS_fnc_classRegistryName;

    private _fieldsCompiled = [];
    {
        private _fieldName = _x select 0;
        private _fieldDef = _x select 1;
        private _fieldType = _x params [2, _fieldDef];
        private _fieldNameFull = format["%1%2", _prefix, _fieldName];
        _fieldsCompiled pushBack [_fieldName, [_fieldNameFull, _fieldDef, _fieldType]];
    } forEach _fields;

    private _fieldsMap = createHashMapFromArray _fieldsCompiled;

    private _methodsCompiled = [];
    for "_i" from 0 to ((count _methods) - 1) step 2 do {
        private _methodName = _methods select _i;
        private _method = _methods select (_i + 1);
		private _methodStr = str _method;
        private _methodSelfFields = _fieldsCompiled select {(_x#0) in _methodStr};
        _methodsCompiled pushBack [_methodName, [_method, _methodSelfFields]];
    };

    private _methodsMap = createHashMapFromArray _methodsCompiled;

    private _classMap = createHashMap;
    _classMap set ["fields", _fieldsMap];
    _classMap set ["methods", _methodsMap];
    _classMap set ["classname", _classRegistryName];

	private _selfVar = if (!(_selfVar isEqualType "") || {(_selfVar isEqualTo "")}) then {"_self"} else {_selfVar};
    _classMap set ["selfvar", _selfVar];

    missionNamespace setVariable [_classRegistryName, _classMap];
    _classMap
};

OOP_OBJ_CLASS_fnc_newInstance = {
    params ["_className", "_obj", ["_initArgs", []], ["_global", false], ["_def", nil]];

    if !(IS_OBJ(_obj)) exitWith {EXCEPTION(EXCEPTION_NON_OBJ)};

    private _class = [_className] call OOP_OBJ_CLASS_fnc_classExists;

	if (_class isEqualTo false) exitWith {EXCEPTION(EXCEPTION_CLASS_DONT_EXISTS)};

    private _classRegistryName = _class getOrDefaultCall ["classname", {EXCEPTION(EXCEPTION_NO_CLASSNAME); ""}];

    private _fields = _class getOrDefaultCall ["fields", {EXCEPTION(EXCEPTION_NO_FIELDS); createHashMap}];
    {
        _obj setVariable [_y select 0, _y select 1, _global];
    } forEach _fields;

    private _methods = _class getOrDefaultCall ["methods", {EXCEPTION(EXCEPTION_NO_METHODS); createHashMap}];
    {
        _obj setVariable [format["%1_%2", _classRegistryName, (_y select 0)], _y select 1, _global];
    } forEach _methods;

    private _selfVar = _class getOrDefault ["selfvar", "_self"];
	_selfVar = if (!(_selfVar isEqualType "") || {(_selfVar isEqualTo "")}) then {"_self"} else {_selfVar};
    _obj setVariable [format["%1_selfVar", _classRegistryName], _selfVar, _global];

    _obj setVariable [format["%1_instance", _classRegistryName], _class, _global];

    private _instances = _obj getVariable ["OOP_OBJ_CLASS_objClassInstances", []];
    _instances pushBackUnique _classRegistryName;
    _obj setVariable ["OOP_OBJ_CLASS_objClassInstances", _instances, _global];

    private _initResult = [INIT, _initArgs, _obj, _obj] call _classFunc;
    if (isNil "_initResult") then {NIL_DEF} else {_initResult};
};

OOP_OBJ_CLASS_fnc_callClassInstance = {
	params["_classname", "_obj", ["_methodName", INIT], ["_args", []], ["_def", nil]];

    if !(IS_OBJ(_obj)) exitWith {EXCEPTION(EXCEPTION_NON_OBJ)};

    private _classRegistryName = [_className] call OOP_OBJ_CLASS_fnc_classRegistryName;
	private _methodParams = _obj getVariable format["%1_%2", _classRegistryName, _methodName];
	if (isNil "_methodParams") exitWith {
		EXCEPTION(EXCEPTION_METHOD_DONT_EXISTS)
	};
	private _method = _methodParams param [0, {EXCEPTION(EXCEPTION_METHOD_FUNC_DONT_EXISTS)}];
	private _methodSelfFields = _methodParams param [1, []];
	if !(_methodSelfFields isEqualType []) then {_methodSelfFields = []};
	_methodSelfFields = _methodSelfFields select {_x isEqualType ""};

	private _methodSelfFields;
	{
		_x params ["_fieldName", ["_fieldParams", []]];
		if (_fieldName isEqualTo "") then {continue};
		_fieldParams params ["_fieldNameFull", ["_fieldDef", nil], ["_fieldType", []]];
		call compile (format["%1 = _obj getVariable [%2, _fieldDef]; %1 = [%1, _fieldType, _fieldDef] call OOP_OBJ_CLASS_fnc_validateFieldType", _fieldName, _fieldNameFull])
	} forEach _methodSelfFields;

	private _selfVar = _obj getVariable [format["%1_selfVar", _classRegistryName], "_self"];
	if !(_selfVar isEqualType "") then {
		_selfVar = "_self";
		EXCEPTION(EXCEPTION_SELF_VAR_NOT_STRING)
	};
	private [_selfVar];
	private _self = _obj;
	call compile (format["%1 = _obj", _selfVar]);

	_args call _method
};

OOP_OBJ_CLASS_fnc_validateFieldType = {
	params["_var", ["_types", []], ["_def", nil]];
	if (_types isEqualTo []) exitWith {_var};
	if !(_types isEqualType []) then {_types = [_types]};
	private _valid = false;
	{
		if (_var isEqualType _x) exitWith {_valid = true};
	} forEach _types;
	if !(_valid) exitWith {NIL_DEF};
	_var
};

OOP_OBJ_CLASS_fnc_classRegistryName = {
	params["_className"];
    private _prefix = if (isNil "ADDON_PREFX") then {PREFX} else {ADDON_PREFX};
	_prefix = if (_prefix == "") then {_prefix} else {_prefix + "_"};
    format["OOP_OBJ_CLASS_%1%2", _prefix, _className];
};

OOP_OBJ_CLASS_fnc_classExists = {
	params["_classname"];
    private _classRegistryName = [_className] call OOP_OBJ_CLASS_fnc_classRegistryName;
	private _class = missionNamespace getVariable _classRegistryName;
	if (isNil "_class") exitWith {false};
	if (_class isEqualType createHashMap) exitWith {false};
	private _classParam = _class get "classname";
	if (isNil "_classParam") exitWith {false};
	_class
};

OOP_OBJ_CLASS_fnc_raiseException = {
	_this DLOG;
	_this param [2, nil];
};