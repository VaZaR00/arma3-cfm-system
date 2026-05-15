/*
    Function: CFM_fnc_updateFPVInterface
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_monitor", objNull], ["_operator", objNull], ["_signal", 1], ["_uiCtrlCurrentUIDisplay", displayNull], ["_uiDisplayUniqueName", ""]];

private _OnTimeTextCtrl = uiNameSpace getVariable ["ArmaFPV_OnTimeText" + _uiDisplayUniqueName, controlNull];
private _SignalPictureCtrl = uiNameSpace getVariable ["ArmaFPV_SignalPicture" + _uiDisplayUniqueName, controlNull];
private _SignalTextCtrl = uiNameSpace getVariable ["ArmaFPV_SignalText" + _uiDisplayUniqueName, controlNull];
private _BatteryPictureCtrl = uiNameSpace getVariable ["ArmaFPV_BatteryPicture" + _uiDisplayUniqueName, controlNull];
private _BatteryTextCtrl = uiNameSpace getVariable ["ArmaFPV_BatteryText" + _uiDisplayUniqueName, controlNull];

[_operator, _BatteryPictureCtrl, _BatteryTextCtrl] call CFM_fnc_fpv_handleBattery;
[_operator, _signal, _SignalPictureCtrl, _SignalTextCtrl] call CFM_fnc_fpv_handleSignal;
