/*
    Function: CFM_fnc_zoomInActionCondition
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_target"];
HAND_MON_CONDITION
IS_MONITOR_ON
if !(_target getVariable ['CFM_feedActive', false]) exitWith {false};
if (_target getVariable ['CFM_maxZoomed', false]) exitWith {false};
if (_target getVariable ['CFM_currentCameraIsStatic', false]) exitWith {false};
if (_target getVariable ['CFM_canChangeZoom', false]) exitWith {false};
private _isDrone = _target getVariable ["CFM_currentOperatorIsDrone", false];
if !(_isDrone) exitWith {true};
missionNamespace getVariable ["CFM_canChangeZoomOnDrones", true]
