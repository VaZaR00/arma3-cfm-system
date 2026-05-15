#include "defines.hpp" 




// TEMP REB RECOMPILE
REB_fnc_disconectDrone = {
	if ((("lancet_tripod_launcher" in (typeOf vehicle player)) && dialog)) exitWith {
		closeDialog 1;
	};

	if !(_this getVariable ["REB_uavLostSignal", false]) then {
		_this setVariable ["REB_uavLostSignal", true, true];
	};

	player connectTerminalToUAV objNull; //disconnect from players terminal
	_noise ppEffectEnable false; //disable noise
	//delete drone ai crew so drone will fall, otherwise ai will try to hover on 
	_this remoteExec ["deleteVehicleCrew", 0];
	_this spawn {
		uiSleep REB_createUavCrewOnDisconectTime;
		_this remoteExec ["createVehicleCrew", 0];
		_this setVariable ["REB_uavLostSignal", false, true];
	};
};

REB_fnc_main = {
	params [["_freq", REB_freq], ["_random", REB_random], ["_noise", REB_noise], ["_uav", (vehicle (remoteControlled player))]];
	if (isNil {
		REB_isSuppressed = false;
		_noise ppEffectEnable false; 
		call REB_fnc_removeInputDelay;

		if !(missionNamespace getVariable ["REB_systemIsOn", true]) exitWith {};
		if (_uav getVariable ["REB_var_skipThis", false]) exitWith {};

		if (_uav getVariable ['ArmaFPV_EnableTI', false]) then {
			_uav disableTIEquipment false;
		};

		if (count REB_all_rebs == 0) exitWith {};

		private _isLancet = (("lancet_tripod_launcher" in (typeOf vehicle player)) && dialog);

		if !((_uav in allUnitsUAV) || _isLancet) exitWith {};

		if (_isLancet) then {
			_uav = uiNamespace getVariable ["lancet_currentProjectile", objNull];
		};

		if (_uav call REB_fnc_isInDeadzone) exitWith {
			_uav call REB_fnc_disconectDrone;
			false
		};

		private _activeRebStrength = _uav call REB_fnc_currentJammingRebStrength;

		if !(_activeRebStrength > 0) exitWith {};

		_uav disableTIEquipment true;

		if (_isLancet) then {
			false setCamUseTI 0;
		};

		_activeRebStrength call REB_fnc_suppress;
		if !(_uav getVariable ["REB_uavIsSuppressed", false]) then {
			_uav setVariable ["REB_uavIsSuppressed", true, true];
			_uav setVariable ["REB_uavActiveRebStrength", _activeRebStrength, true];
		};
		true
	}) then {
		if ((_uav getVariable ["REB_uavIsSuppressed", false]) && {(cameraOn isEqualTo _uav)}) then {
			_uav setVariable ["REB_uavIsSuppressed", false, true];
			_uav setVariable ["REB_uavActiveRebStrength", nil, true];
		};
	} else {

	};
};