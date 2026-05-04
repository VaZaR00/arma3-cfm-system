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

if (_signal < SIGNAL_WEAK_CONNECTION_THREASHOLD) exitWith {
	_monitor call CFM_fnc_monitorWeakConnection;
	0
};
if (_signal isEqualTo SIGNAL_LOST) exitWith {false};
//-------------------------------------------------------

//----------------- UPDATE EFFECTS -----------------------
private _uiCtrlCurrentUIDisplay = _monitor getVariable ["CFM_uiCtrlCurrentUIDisplay", displayNull];
private _interfaceFunc = _monitor getVariable ["CFM_currentOperatorInterfaceFunction", {}];

[_monitor, _operator, _uiCtrlCurrentUIDisplay] call _interfaceFunc;
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