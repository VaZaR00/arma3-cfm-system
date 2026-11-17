/*
    Function: CFM_fnc_fixFeed
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_monitors", []], ["_doHint", true]];

if (IS_VALID_MON(_monitors)) then {
    _monitors = [_monitors];
} else {
    if (_monitors isEqualType objNull && {IS_OBJ(_monitors)}) then {
        private _targetObj = _monitors;
        private _active = missionNamespace getVariable ["CFM_ActiveMonitors", []];
        _monitors = _active select {(_x isEqualType []) && {((_x param [0, objNull]) isEqualTo _targetObj)}};
        if (_monitors isEqualTo []) then {
            private _selId = [_targetObj] call CFM_fnc_getSelectedMonitorInstance;
            if (_selId > 0) then {_monitors = [[_targetObj, _selId]]};
        };
    } else {
        if !(_monitors isEqualType []) then {
            _monitors = [];
        };
    };
};
if (_monitors isEqualTo []) then {
    _monitors = +(missionNamespace getVariable ["CFM_ActiveMonitors", []]);
};

private _fixed = false;
{
    (RESOLVE_MON(_x)) params ["_monObj", "_instId"];
    if (IS_OBJ(_monObj) && {_instId > 0} && {MON_GVAR(_monObj, _instId, "CFM_feedActive", false)}) then {
        [[_monObj, _instId]] spawn CFM_fnc_resetFeed;
        _fixed = true;
    };
} forEach _monitors;

if !(_fixed) exitWith {};

if (_doHint) then {
CFM_STR_RESET_FIX_HINT _HINT;
};