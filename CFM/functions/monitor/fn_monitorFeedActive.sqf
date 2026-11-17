/*
    Function: CFM_fnc_monitorFeedActive
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_monitor", objNull], ["_instId", -1]];
if (_monitor isEqualType []) then {
	_monitor params [["_mObj", objNull], ["_mId", -1]];
	_monitor = _mObj;
	if (_instId < 1) then {_instId = _mId};
};
CHECK_EX(!(IS_OBJ(_monitor)) || {_instId < 1});

private _operator = MON_GVAR(_monitor, _instId, "CFM_connectedOperator", objNull);
private _cam = MON_GVAR(_monitor, _instId, "CFM_currentFeedCam", objNull);

CHECK_EX(!IS_OBJ(_operator));
CHECK_EX(!IS_OBJ(_cam));

private _opType = _operator getVariable ["CFM_cameraType", GOPRO];

CHECK_EX(!(_opType isEqualTo GOPRO) && {_operator call CFM_fnc_goProCondition});

private _active = MON_GVAR(_monitor, _instId, "CFM_feedActive", false);

CHECK_EX(!_active);

private _isVehSeatTablet = MON_GVAR(_monitor, _instId, "CFM_isVehSeatTablet", false);
if (_isVehSeatTablet) exitWith {
    private _texSel = MON_GVAR(_monitor, _instId, "CFM_textureSelection", NO_TEXTURE_SELECTION);
    if (_texSel >= 0 && {missionNamespace getVariable ["CFM_renderSeatTextureOutOfSeat", true]}) exitWith {true};
    [_monitor, _instId] call CFM_fnc_inVehicleTabletSeatCondition
};

private _isHandMonitor = MON_GVAR(_monitor, _instId, "CFM_isHandMonitor", false);
if (_isHandMonitor && {!(_monitor call CFM_fnc_handMonitorCondition)}) exitWith {false};

true
