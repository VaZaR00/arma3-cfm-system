/*
    Function: CFM_fnc_zala_drawHudDriver
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_monitor", objNull], ["_uav", objNull], ["_signal", 1], ["_uiCtrlCurrentUIDisplay", displayNull], ["_uiDisplayUniqueName", ""]];

private _positionATL = getPosATLVisual _uav;

// ALT
private _altMainText = uiNameSpace getVariable ["DB_zala421_HUD_alt_mainText" + _uiDisplayUniqueName, controlNull];
_altMainText ctrlSetText format ["%1: %2", localize "STR_zala421_altitude", floor(_uav call CBA_fnc_realHeight)];

// COORDINATES
private _coordMainText = uiNameSpace getVariable ["DB_zala421_HUD_coord_mainText" + _uiDisplayUniqueName, controlNull];
_coordMainText ctrlSetText format ["%1: %2 %3", localize "STR_zala421_square", floor((_positionATL # 0) / 100), floor((_positionATL # 1) / 100)];

// FUEL
private _fuelMainText = uiNameSpace getVariable ["DB_zala421_HUD_fuel_mainText" + _uiDisplayUniqueName, controlNull];
_fuelMainText ctrlSetText format ["%1: %2", localize "STR_zala421_fuel", floor (fuel _uav * 100)];

// STATUS
private _statusMainText = uiNameSpace getVariable ["DB_zala421_HUD_status_mainText" + _uiDisplayUniqueName, controlNull];
_statusMainText ctrlSetText format ["%1: %2", localize "STR_zala421_condition", [localize "STR_zala421_controllable", localize "STR_zala421_damaged"] select (damage _uav >= 0.33)];


// DRONE SPEED
private _droneSpeedMainText = uiNameSpace getVariable ["DB_zala421_HUD_droneSpeed_mainText" + _uiDisplayUniqueName, controlNull];
_droneSpeedMainText ctrlSetText format ["%1: %2 KM/H", localize "STR_zala421_speed", (floor speed _uav)];

// PITCH
private _pitchMainText = uiNameSpace getVariable ["DB_zala421_HUD_pitch_mainText" + _uiDisplayUniqueName, controlNull];
_pitchMainText ctrlSetText format ["%1: %2 °", localize "STR_zala421_pitch", floor((_uav call BIS_fnc_getPitchBank) # 0)];
