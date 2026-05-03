/*
    Function: CFM_fnc_monitorFeedActive
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

private _monitor = _this;
private _operator = _monitor getVariable ["CFM_connectedOperator", objNull];
private _cam = _monitor getVariable ["CFM_currentFeedCam", objNull];

CHECK_EX(!IS_OBJ(_operator));
CHECK_EX(!IS_OBJ(_cam));

private _opType = _operator getVariable ["CFM_cameraType", GOPRO];

CHECK_EX(!(_opType isEqualTo GOPRO) && {_operator call CFM_fnc_goProCondition});

private _active = _monitor getVariable ["CFM_feedActive", false];

CHECK_EX(!_active);

private _isHandMonitor = _monitor getVariable ["CFM_isHandMonitor", false];
if (_isHandMonitor && {!(_monitor call CFM_fnc_handMonitorCondition)}) exitWith {false};

true
