/*
    Function: CFM_fnc_setupNvgAndTI
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_operator"];

private _typeOp = _operator call CFM_fnc_getOperatorClass;
private _camType = _operator call CFM_fnc_cameraType;
private _canSwitchTi = _operator getVariable ["CFM_canSwitchTi", 0];
private _canSwitchNvg = _operator getVariable ["CFM_canSwitchNvg", 0];
private _tiTable = _operator getVariable ["CFM_tiTable", []];
private _nvgTable = _operator getVariable ["CFM_nvgTable", []];
if (!(_canSwitchTi isEqualTo false) && ((_tiTable isEqualTo []) && {!(_tiTable isEqualTo createHashMap)})) then {
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
};
if (!(_canSwitchNvg isEqualTo false) && (_nvgTable isEqualTo []) && {!(_nvgTable isEqualTo createHashMap)}) then {
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
};

if !(_canSwitchTi isEqualType true) then {
	_canSwitchTi = _canSwitchTi isEqualTo 1;
};
if !(_canSwitchNvg isEqualType true) then {
	_canSwitchNvg = _canSwitchNvg isEqualTo 1;
};

[_tiTable, _nvgTable, _canSwitchTi, _canSwitchNvg];
