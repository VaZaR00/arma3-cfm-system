/*
    Function: CFM_fnc_updateMonitor
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_monitor", objNull]];

private _operator = _monitor getVariable ["CFM_connectedOperator", objNull];
private _signalFunc = _monitor getVariable ["CFM_currentOperatorSignalFunction", {1}];

//--------------------- SIGNAL -----------------------
private _signal = [_monitor, _operator] call _signalFunc;
if ((isNil "_signal") || {!(_signal isEqualType 1)}) then {
    _signal = 1;
};

if (_signal < SIGNAL_WEAK_CONNECTION_THREASHOLD) exitWith {
	_monitor call CFM_fnc_monitorWeakConnection;
	0
};
if (_signal isEqualTo SIGNAL_LOST) exitWith {false};
//-------------------------------------------------------

//----------------- UPDATE EFFECTS -----------------------
private _uiCtrlCurrentUIDisplay = _monitor getVariable ["CFM_uiCtrlCurrentUIDisplay", displayNull];
private _interfaceFunc = _monitor getVariable ["CFM_currentOperatorInterfaceFunction", {}];
private _monitorUid = _monitor getVariable ["CFM_monitorUid", ""];

[_monitor, _operator, _signal, _uiCtrlCurrentUIDisplay, _monitorUid] call _interfaceFunc;

private _effectsLayersControls = _monitor getVariable ["CFM_effectsLayersControls", []];
private _effectsFunc = _monitor getVariable ["CFM_currentOperatorEffectsFunction", {}];

[_signal, _effectsLayersControls] call _effectsFunc;
//-------------------------------------------------------

//----------------- UPDATE CAMERA -----------------------
_monitor call CFM_fnc_updateMonitorCamera;
//-------------------------------------------------------

//----------------- UPDATE DISPLAYS -----------------------
private _mainDisplay = _monitor getVariable ["CFM_mainDisplay", displayNull];
private _r2tDisplay = _monitor getVariable ["CFM_r2tDisplay", displayNull];
displayUpdate _r2tDisplay;
displayUpdate _mainDisplay;
displayUpdate _uiCtrlCurrentUIDisplay;
//-------------------------------------------------------