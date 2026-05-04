#include "defines.hpp" 



#define INIT "Init"



// EXCEPTIONS
#define EXCEPTION(code) ([code, _NIL(_this), _NIL(_className), _NIL(_class), NIL_DEF] call OOP_fnc_raiseException)

#define EXCEPTION_CLASS_DONT_EXISTS 0
#define EXCEPTION_NON_OBJ 1
#define EXCEPTION_NO_CLASSNAME 2
#define EXCEPTION_NO_FIELDS 3
#define EXCEPTION_NO_METHODS 4
#define EXCEPTION_METHOD_DONT_EXISTS 4
#define EXCEPTION_METHOD_FUNC_DONT_EXISTS 5
#define EXCEPTION_SELF_VAR_NOT_STRING 6

#define NIL_DEF _NIL(_def)

OOP_fnc_class = {
    params ["_className", "_fields", "_methods", ["_selfVar", ""]];

    private _prefix = if (isNil "_ADDON_PREFX") then {SPREFX} else {_ADDON_PREFX};
    private _classRegistryName = [_className] call OOP_fnc_classRegistryName;

    private _fieldsCompiled = [];
    private _isVolatile = false;
    {
        if (_x isEqualTo true) then {
            // next var is volatile
            _isVolatile = true;
            continue
        };
        if !(_x isEqualType []) then {continue};
        private _fieldName = _x select 0;
        private _fieldDef = _x select 1;
        private _fieldType = _x select 2;
        _fieldType = if (isNil "_fieldType") then {
            if (_isVolatile) then {[]} else {
                if (_fieldDef isEqualType []) then {
                    [[]]
                } else {
                    _fieldDef
                };
            };
        } else {_fieldType};
        private _fieldNameFull = format["%1%2", _prefix, _fieldName];
        _fieldsCompiled pushBack [_fieldName, [_fieldNameFull, _fieldDef, _fieldType]];
        _isVolatile = false;
    } forEach _fields;

    private _fieldsMap = createHashMapFromArray _fieldsCompiled;

    private _methodsCompiled = [];
    private _skipI = [];
    for "_i" from 0 to ((count _methods) - 1) do {
        if (_i in _skipI) then {continue};
        private _methodName = _methods select _i;
        private _method = _methods select (_i + 1);
        _skipI pushBack (_i + 1);
		private _methodStr = str _method;
        private _methodSelfFields = _fieldsCompiled select {(_x#0) in _methodStr};
		private _methodNameFull = format["%1_%2", _classRegistryName, _methodName];
        missionNamespace setVariable [_methodNameFull, _method];
        _methodsCompiled pushBack [_methodName, [_methodNameFull, _method, _methodSelfFields]];
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

    private _class = [_className] call OOP_fnc_classExists;

	if (_class isEqualTo false) exitWith {EXCEPTION(EXCEPTION_CLASS_DONT_EXISTS)};

    private _classRegistryName = _class getOrDefaultCall ["classname", {EXCEPTION(EXCEPTION_NO_CLASSNAME); ""}];

    private _fields = _class getOrDefaultCall ["fields", {EXCEPTION(EXCEPTION_NO_FIELDS); createHashMap}];
    {
        _y params ["_varname", "_def", ["_type", []]];
        if (call {
            private _prevVal = _obj getVariable _varname;
            if (isNil "_prevVal") exitWith {true};
            private _prevValValid = [_prevVal, _type, _NIL(_def)] call OOP_fnc_validateFieldType;
            if (isNil "_prevValValid") exitWith {true};
            if (_prevValValid isEqualTo _def) exitWith {true};
            // variable already set and is valid then dont set
            false
        }) then {
            _obj setVariable [_varname, _def, _global];
        };
    } forEach _fields;

    private _methods = _class getOrDefaultCall ["methods", {EXCEPTION(EXCEPTION_NO_METHODS); createHashMap}];
    {
        // _y = [_methodVarNameFull, _methodScript, _methodSelfFields]
        // for network optimisation we set only method variable name (_y select 2) not full script
        _obj setVariable [format["%1_%2", _classRegistryName, _x], [_y select 0, _y select 2], _global];
    } forEach _methods;

    private _selfVar = _class getOrDefault ["selfvar", "_self"];
	_selfVar = if (!(_selfVar isEqualType "") || {(_selfVar isEqualTo "")}) then {"_self"} else {_selfVar};
    _obj setVariable [format["%1_selfVar", _classRegistryName], _selfVar, _global];

    _obj setVariable [format["%1_instance", _classRegistryName], _class, _global];

    private _instances = _obj getVariable ["OOP_OBJ_CLASS_objClassInstances", []];
    _instances pushBackUnique _classRegistryName;
    _obj setVariable ["OOP_OBJ_CLASS_objClassInstances", _instances, _global];

    private _initResult = [_className, _obj, INIT, _initArgs, NIL_DEF] call OOP_OBJ_CLASS_fnc_callClassInstance;
    if (isNil "_initResult") then {NIL_DEF} else {_initResult};
};

OOP_OBJ_CLASS_fnc_callClassInstance = {
	params["_classname", "_obj", ["_methodName", INIT], ["_args", []], ["_def", nil]];

    if !(IS_OBJ(_obj)) exitWith {EXCEPTION(EXCEPTION_NON_OBJ)};

    private _classRegistryName = [_className] call OOP_fnc_classRegistryName;
	private _methodParams = _obj getVariable format["%1_%2", _classRegistryName, _methodName];
	if (isNil "_methodParams") exitWith {
		EXCEPTION(EXCEPTION_METHOD_DONT_EXISTS)
	};
	private _methodVarName = _methodParams param [0, "", [""]];
	private _method = missionNamespace getVariable [_methodVarName, {EXCEPTION(EXCEPTION_METHOD_FUNC_DONT_EXISTS)}];
	private _methodSelfFields = _methodParams param [1, [], [[], ""]];
	if !(_methodSelfFields isEqualType []) then {_methodSelfFields = []};
	_methodSelfFields = _methodSelfFields select {(_x#0) isEqualType ""};

    private _methodSelfFieldsVars = _methodSelfFields apply {_x#0};
    if (_methodSelfFieldsVars isEqualTo []) then {_methodSelfFieldsVars = ["_tempp"]};
	private _methodSelfFieldsVars;
	{
		_x params ["_fieldName", ["_fieldParams", []]];
		if (_fieldName isEqualTo "") then {continue};
		_fieldParams params ["_fieldNameFull", ["_fieldDef", nil], ["_fieldType", []]];
		call compile (format["%1 = _obj getVariable ['%2', _fieldDef]; %1 = [if (isNil '%1') then {nil} else {%1}, _fieldType, _fieldDef] call OOP_fnc_validateFieldType", _fieldName, _fieldNameFull])
	} forEach _methodSelfFields;

	private _selfVar = _obj getVariable [format["%1_selfVar", _classRegistryName], "_self"];
	if !(_selfVar isEqualType "") then {
		_selfVar = "_self";
		EXCEPTION(EXCEPTION_SELF_VAR_NOT_STRING)
	};
	private [_selfVar];
	private _self = _obj;
	call compile (format["%1 = _obj", _selfVar]);

    _this = _args;
    _this call _method;
};

OOP_OBJ_CLASS_fnc_remoteExecClassInstance = {
	params[["_callArgs", []], ["_remoteExecParams", false]];

    if (_remoteExecParams isEqualTo false) exitWith {
        _callArgs call OOP_OBJ_CLASS_fnc_callClassInstance;
    };

    private _jip = false;
    if (_remoteExecParams isEqualTo true) then {
        _jip = true;
    };
    if !(_remoteExecParams isEqualType []) then {
        _remoteExecParams = [_remoteExecParams];
    };
    _remoteExecParams params [["_targets", 0], ["_jip", _jip], ["_call", false, [false]]];
    [_this, {
        _this call OOP_OBJ_CLASS_fnc_callClassInstance;
    }, _targets, _jip, _call] call OOP_fnc_remoteExec;
};

OOP_fnc_validateFieldType = {
	params["_var", ["_types", []], ["_def", nil]];
	if (isNil "_var") exitWith {nil};
	if (_types isEqualTo []) exitWith {_var};
	if !(_types isEqualType []) then {_types = [_types]};
	private _valid = false;
	{
		if (_var isEqualType _x) exitWith {_valid = true};
	} forEach _types;
	if !(_valid) exitWith {NIL_DEF};
	_var
};

OOP_fnc_classRegistryName = {
	params["_className"];
    private _prefix = if (isNil "_ADDON_PREFX") then {SPREFX} else {_ADDON_PREFX};
	_prefix = if (_prefix == "") then {_prefix} else {_prefix + "_"};
    format["OOP_OBJ_CLASS_%1%2", _prefix, _className];
};

OOP_fnc_classExists = {
	params["_classname"];
    private _classRegistryName = [_className] call OOP_fnc_classRegistryName;
	private _class = missionNamespace getVariable _classRegistryName;
	if (isNil "_class") exitWith {false};
	if !(_class isEqualType createHashMap) exitWith {false};
	private _classParam = _class get "classname";
	if (isNil "_classParam") exitWith {false};
	_class
};

OOP_fnc_raiseException = {
	_this DLOG;
	_this param [2, nil];
};

OOP_fnc_remoteExec = {
    params[["_args", []], ["_func", "call"], ["_targets", 0], ["_jip", true], ["_call", false, [false]]];

    if (_func isEqualType {}) then {
        _args = [_args, _func];
        _func = if (_call) then {"call"} else {"spawn"};
    };
    if !(_func isEqualType "") exitWith {format["OOP_fnc_remoteExec ERROR: func not str or code. Func type: %1. Func value: %2", typeName _func, _func] WARN};

    if (_targets isEqualType true) then {
        if (_targets isEqualTo true) then {
            _targets = 0;
        } else {
            _targets = false;
        };
    };
    if (_jip isEqualType objNull) then {
        private _netid = netId _jip;
        private _idArr = (_netid splitString ":");
        private _id = "0";
        if (count _idArr > 1) then {
            _id = trim (_idArr#1);
            if !(_id isEqualType "") then {
                _id = str _id;
            };
        };
        _jip = "CFM_jip_remote_exec_id_" + _id;
    };

    if (!isMultiplayer || {(_targets in [PLAYER_, false, clientOwner])}) exitWith {
        if (_func isEqualTo "call") exitWith {
            (_args#0) call (_args#1)
        };
        if (_func isEqualTo "spawn") exitWith {
            (_args#0) spawn (_args#1)
        };
        private _func = missionNamespace getVariable [_func, {format["OOP_fnc_remoteExec ERROR: func '%1' not found!", _func] WARN}];
        if (_call) then {
            _args call _func
        } else {
            _args spawn _func
        };
    };
    if (_call isEqualTo true) then {
        _args remoteExecCall [_func, _targets, _jip];
    } else {
        _args remoteExec [_func, _targets, _jip];
    };

};