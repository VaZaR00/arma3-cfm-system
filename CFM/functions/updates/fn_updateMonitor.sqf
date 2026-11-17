/*
    Function: CFM_fnc_updateMonitor
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
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};

private _operator = MON_GVAR(_monitor, _instId, "CFM_connectedOperator", objNull);
private _signalFunc = MON_GVAR(_monitor, _instId, "CFM_currentOperatorSignalFunction", {1});

//--------------------- SIGNAL -----------------------
private _signal = [_monitor, _operator, _signalFunc] call CFM_fnc_signalFunc;
if ((isNil "_signal") || {!(_signal isEqualType 1)}) then {
    _signal = 1;
};

if (_signal isEqualTo SIGNAL_LOST) exitWith {false};
//-------------------------------------------------------

//----------------- UPDATE EFFECTS -----------------------
private _mainDisplay = MON_GVAR(_monitor, _instId, "CFM_mainDisplay", displayNull);
private _interfaceFunc = MON_GVAR(_monitor, _instId, "CFM_currentOperatorInterfaceFunction", {});
private _uiDisplayUniqueName = MON_GVAR(_monitor, _instId, "CFM_uiDisplayUniqueName", "");

[_monitor, _operator, _signal, _mainDisplay, _uiDisplayUniqueName, _interfaceFunc] call CFM_fnc_interfaceFunc;

private _effectsLayersControls = MON_GVAR(_monitor, _instId, "CFM_effectsLayersControls", []);
private _effectsFunc = MON_GVAR(_monitor, _instId, "CFM_currentOperatorEffectsFunction", {});

[_operator, _signal, _effectsLayersControls, _effectsFunc] call CFM_fnc_effectsFunc;
//-------------------------------------------------------

//----------------- UPDATE CAMERA -----------------------
[_monitor, _instId] call CFM_fnc_updateMonitorCamera;
//-------------------------------------------------------

//----------------- UPDATE DISPLAYS -----------------------
displayUpdate _mainDisplay;
//-------------------------------------------------------