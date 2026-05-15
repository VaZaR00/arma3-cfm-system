/*
    Function: CFM_fnc_fpv_handleTime
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

_thisArgs params ["_startTime", "_uav"];
private _timeElapsed = time - _startTime;

private _controlText = uiNameSpace getVariable ["ArmaFPV_OnTimeText", controlNull];
_controlText ctrlSetText ([_timeElapsed, "MM:SS"] call BIS_fnc_secondsToString);

// Обновляем сохраненное время
_uav setVariable ["DB_fpv_savedTime", _timeElapsed, true];

if !(missionNamespace getVariable ["ArmaFPV_isControl", false]) exitWith {
	removeMissionEventHandler ["EachFrame", _thisEventHandler];
};
