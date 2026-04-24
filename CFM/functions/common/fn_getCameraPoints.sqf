/*
    Function: CFM_fnc_getCameraPoints
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 


params ["_vehicle", ["_turretPath", DRIVER_TURRET_PATH], ["_camType", ""]];

private _vehType = toLower (typeOf _vehicle);
_turretPath = TURRET_INDEX(_turretPath);

if ("mavik" in _vehType) exitWith {
	[["pos_pilotcamera", [], [-1,0,-1]], "pos_pilotcamera_dir"]
};
if ("uav_01" in _vehType) exitWith {
	if (_turretPath in DRIVER_TURRET_PATH) exitWith {
		[["pip_pilot_pos", [], [-1,0,-1]], "pip_pilot_dir"]
	};
	[["pip0_pos", [], [-1,0,-1]], "pip0_dir"]
};

private _camTypeRes = switch (_camType) do {
	case TYPE_VEH: {
		// private _name = "gunnerview";
		// private _name = "zamerny";
		private _name = "konec hlavne";
		// private _name = "otocvez";
		if ((["bmp"] findIf {_x in _vehType}) != -1) then {
			_name = "mainturret";
		};
		private _dirParamsDef = [_name, [-0.3, 0.0, 0.2]];
		[_name, _dirParamsDef]
	};
	default { };
};
if !(isNil "_camTypeRes") exitWith {_camTypeRes};

private _camPos = "uavCameraGunnerPos";
private _camDir = "uavCameraGunnerDir";

if (_turretPath isEqualTo -1) then {
    if ("mavik" in _vehType) exitWith {};
    _camPos = "uavCameraDriverPos";
    _camDir = "uavCameraDriverDir";
};

private _config = configFile >> "CfgVehicles" >> typeOf _vehicle;
private _posPoint = getText (_config >> _camPos);
private _dirPoint = getText (_config >> _camDir);
if (_posPoint == "") then {
    {
        private _testPos = _vehicle selectionPosition _x;
        if (!(_testPos isEqualTo [0,0,0])) exitWith {_posPoint = _x;};
    } forEach ["PiP0_pos", "PiP1_pos", "pip0_pos", "pip1_pos", "pip_pilot_pos"];
};
if (_dirPoint == "") then {
    {
        private _testDir = _vehicle selectionPosition _x;
        if (!(_testDir isEqualTo [0,0,0])) exitWith {_dirPoint = _x;};
    } forEach ["PiP0_dir", "PiP1_dir", "pip0_dir", "pip1_dir", "flir", "pip_pilot_dir"];
};
[_posPoint, _dirPoint]
