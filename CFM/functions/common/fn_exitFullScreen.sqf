/*
    Function: CFM_fnc_exitFullScreen
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

if !(missionNamespace getVariable ["CFM_isInFullScreen", false]) exitWith {};

private _monitor = missionNamespace getVariable ["CFM_currentFullScreenMonitor", objNull];
private _exited = if (IS_OBJ(_monitor)) then {
	["monitorExitFullScreen", [_monitor], _monitor, false] CALL_OBJCLASS("Monitor", _monitor);
} else {false};

if (!(isNil "_exited") && {(_exited isEqualTo true)}) exitWith {};

CLEAR_HINT
cutText ["", "PLAIN"];
false setCamUseTI 0;
camUseNVG false;
private _currCam = missionNamespace getVariable ["CFM_currentFullScreenCam", objNull];
if !(IS_OBJ(_currCam)) exitWith {
	private _currCamData = (allCameras select {(_x#3) isEqualTo "Internal"})#0;
	if (isNil "_currCamData") exitWith {
		"ERROR CFM_fnc_exitFullScreen: cant find current Internal camera!" WARN;
	};
	_currCam = _currCamData#0;
	_currCam cameraEffect ["Terminate", "back"];
	PLAYER_ switchCamera "INTERNAL";
};
private _r2t = missionNamespace getVariable ["CFM_r2tOfFullScreenCam", ""];
missionNamespace setVariable ["CFM_currentFullScreenMonitor", nil];
missionNamespace setVariable ["CFM_currentFullScreenCam", nil];
missionNamespace setVariable ["CFM_r2tOfFullScreenCam", nil];
missionNamespace setVariable ["CFM_isInFullScreen", false];
if !(IS_VALID_R2T(_r2t)) exitWith {
	_currCam cameraEffect ["Terminate", "back"];
	PLAYER_ switchCamera "INTERNAL";
};
_currCam cameraEffect ["Internal", "back", _r2t];
PLAYER_ switchCamera "INTERNAL";
