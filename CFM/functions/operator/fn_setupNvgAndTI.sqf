/*
    Function: CFM_fnc_setupNvgAndTI
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_operator"];

private _typeOp = _operator call CFM_fnc_getOperatorClass;
private _camType = _operator call CFM_fnc_cameraType;
private _canSwitchTi = false;
private _canSwitchNvg = false;
private _tiTable = [];
private _nvgTable = [];

// ------- TI --------
	private _tiTurret = getArray (configFile >> "CfgVehicles" >> _typeOp >> "Turrets" >> "MainTurret" >> "OpticsIn" >> "Wide" >> "thermalMode");
	private _tiPilot = if (_camType in [DRONETYPE]) then {
		getArray (configFile >> "CfgVehicles" >> _typeOp >> "PilotCamera" >> "OpticsIn" >> "Wide" >> "thermalMode");
	} else {_tiTurret};

	private _tiModesTable = missionNamespace getVariable ["CFM_tiModesTable", createHashMap];

	_tiPilot = _tiPilot apply {
		_tiModesTable getOrDefault [_x, 2]
	};
	_tiTurret = _tiTurret apply {
		_tiModesTable getOrDefault [_x, 2]
	};

	_tiTable = if ((_tiPilot isEqualTo []) && {(_tiTurret isEqualTo [])}) then {
		createHashMap
	} else {
		_canSwitchTi = true;
		createHashMapFromArray [[-1, _tiPilot], [0, _tiTurret]];
	};
	_operator setVariable ["CFM_tiTable", _tiTable];
	_operator setVariable ["CFM_canSwitchTi", _canSwitchTi];
// -------------------

// ------- NVG --------
	private _nvgTurret = "NVG" in (getArray (configFile >> "CfgVehicles" >> _typeOp >> "Turrets" >> "MainTurret" >> "OpticsIn" >> "Wide" >> "visionMode"));
	private _nvgPilot = if (_camType in [DRONETYPE]) then {
		"NVG" in (getArray (configFile >> "CfgVehicles" >> _typeOp >> "PilotCamera" >> "OpticsIn" >> "Wide" >> "visionMode"));
	} else {_nvgTurret};

	_nvgTable = if (!_nvgPilot && !_nvgTurret) then {
		createHashMap
	} else {
		_canSwitchNvg = true;
		createHashMapFromArray [[-1, _nvgPilot], [0, _nvgTurret]];
	};
	_operator setVariable ["CFM_nvgTable", _nvgTable];
	_operator setVariable ["CFM_canSwitchNvg", _canSwitchNvg];
// -------------------

[_tiTable, _nvgTable, _canSwitchTi, _canSwitchNvg];
