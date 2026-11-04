#include "defines.hpp" 

#ifndef FINAL
#define CFUNC(f) FUNC(f)
#endif

CFUNC(checkTurretsLocality) = {
	params [["_operator", objNull], ["_turretPath", []]];
	
	private _turrets = if (_turretPath isEqualTo []) then {
		allTurrets _operator
	} else {
		[_turretPath]
	};
	private _hasLocalTurret = false;
	{
		_hasLocalTurret = _operator turretLocal _x;
		if (_hasLocalTurret) exitWith {break};
	} forEach _turrets;
	_hasLocalTurret
};
#define LOCAL_ACTIVE_OPERATORS_VAR CFM_LocalActiveOperators
#define LOCAL_ACTIVE_OPERATORS_VAR_STR STR(LOCAL_ACTIVE_OPERATORS_VAR)
CFUNC(addLocalTurretOperator) = {
	params [["_operator", objNull], ["_turretPath", []]];
	
	private _localOps = (missionNamespace getVariable [LOCAL_ACTIVE_OPERATORS_VAR_STR, []]);
	private _operatorInLocalOps = (_localOps findIf {(_x select 0) isEqualTo _operator});
	if (_operatorInLocalOps < 0) then {
		_localOps pushBack [_operator, [_turretPath]];
	} else {
		private _turrets = (_localOps param [_operatorInLocalOps, [objNull, []]]) param [1, []];
		_turrets pushBackUnique _turretPath;
		_localOps set [_operatorInLocalOps, [_operator, _turrets]];
	};
	LOCAL_ACTIVE_OPERATORS_VAR = _localOps;
	LOCAL_ACTIVE_OPERATORS_VAR
};
CFUNC(removeLocalTurretOperator) = {
	params [["_operator", objNull], ["_turretPath", []]];
	
	private _localOps = (missionNamespace getVariable [LOCAL_ACTIVE_OPERATORS_VAR_STR, []]);
	private _operatorInLocalOps = (_localOps findIf {(_x select 0) isEqualTo _operator});
	if (_operatorInLocalOps < 0) exitWith {_localOps}; // operator not found, nothing to remove

	private _turrets = (_localOps param [_operatorInLocalOps, [objNull, []]]) param [1, []];
	_turrets = _turrets - [_turretPath];
	
	if (_turrets isEqualTo []) then {
		_localOps deleteAt _operatorInLocalOps;
	} else {
		_localOps set [_operatorInLocalOps, [_operator, _turrets]];
	};
	LOCAL_ACTIVE_OPERATORS_VAR = _localOps;
	LOCAL_ACTIVE_OPERATORS_VAR
};
CFUNC(setupDefPointAlignments) = {
	private _pointSetDef = parsingNamespace getVariable ["CFM_classesPointAlignmentSet", createHashMap];
	if (_pointSetDef isEqualTo createHashMap) then {
		[] call FUNC(initDefaultPointsAlignment);
		_pointSetDef = parsingNamespace getVariable ["CFM_classesPointAlignmentSet", createHashMap];
		missionNamespace setVariable ["CFM_classesPointAlignmentSet", _pointSetDef];
	} else {
		missionNamespace setVariable ["CFM_classesPointAlignmentSet", _pointSetDef];
	};
	CFM_initDefPointAlignmentsSet = true;
	_pointSetDef
};

CFUNC(getCrewSeatKey) = {
	params [["_crewEntry", []]];
	if (_crewEntry isEqualType objNull) then {
		private _veh = objectParent _crewEntry;
		_crewEntry = if (IS_OBJ(_veh)) then {
			((fullCrew [_veh, "", false]) select {(_x select 0) isEqualTo _crewEntry}) param [0, []]
		} else {[]};
	};
	if (!(_crewEntry isEqualType []) || {_crewEntry isEqualTo []}) exitWith {""};
	_crewEntry params ["", ["_role", ""], ["_cargoIdx", -1], ["_turretPath", []]];
	_role = toLower _role;
	if (_role isEqualTo "driver") exitWith {"driver"};
	if !(_turretPath isEqualTo []) exitWith {format ["turret_%1", _turretPath]};
	if (_cargoIdx >= 0) exitWith {format ["cargo_%1", _cargoIdx]};
	""
};

CFUNC(getUnitVehicleSeatKey) = {
	params [["_veh", objNull], ["_unit", PLAYER_]];
	if !(IS_OBJ(_veh)) exitWith {""};
	if !(_unit in _veh) exitWith {""};
	private _crew = (fullCrew [_veh, "", false]) select {(_x select 0) isEqualTo _unit};
	if (_crew isEqualTo []) exitWith {""};
	[_crew select 0] call FUNC(getCrewSeatKey)
};

CFUNC(isCrewSeatAllowed) = {
	params ["_veh", ["_crewEntry", objNull]];
	if (_crewEntry isEqualTo objNull) exitWith {false};
	if (_crewEntry isEqualTo []) exitWith {false};
	private _vehMonSeats = _veh getVariable ["CFM_vehicleTabletSeats", []];
	if (_vehMonSeats isEqualTo []) exitWith {true};
	if (_crewEntry isEqualType objNull) then {
		_crewEntry = PLAYER_CREW_ROLE(_veh);
	};
	if (_crewEntry isEqualTo []) exitWith {false};
	_crewEntry params [["_unit", objNull], ["_role", ""], ["_cargoIdx", -1], ["_turretPath", []]];
	_role = toLower _role;
	if (IS_OBJ(_unit) && {(_unit in _veh) && {(assignedVehicleRole _unit) in _vehMonSeats}}) exitWith {true};
	(_role in _vehMonSeats) ||
	{([_role] in _vehMonSeats)} ||
	{([_role, _turretPath] in _vehMonSeats)} ||
	{([_role, _cargoIdx] in _vehMonSeats)} ||
	{(!(_turretPath isEqualTo []) && {(["turret", _turretPath] in _vehMonSeats) || {(_turretPath in _vehMonSeats)}})} ||
	{((_role isEqualTo "driver") && {(["turret", [-1]] in _vehMonSeats) || {([-1] in _vehMonSeats)} || {(-1 in _vehMonSeats)}})}
};

CFUNC(getOrCreateSeatTabletId) = {
	params [["_monitor", objNull], ["_seatKey", ""]];
	if (!(IS_OBJ(_monitor)) || {_seatKey isEqualTo ""}) exitWith {-1};
	private _seatInstances = _monitor getVariable ["CFM_seatTabletsInstances", createHashMap];
	private _instId = _seatInstances getOrDefault [_seatKey, -1];
	if (_instId > 0) exitWith {_instId};
	["setSeatTablet", [_seatKey], -1] CALL_OBJCLASS("Monitor", _monitor)
};

CFUNC(isVehTabletUsingOperator) = {
	params ["_monitor", "_operator", ["_turretIdx", nil]];
	if !(_monitor getVariable ["CFM_isVehTablet", false]) exitWith {false};
	private _seatInstances = _monitor getVariable ["CFM_seatTabletsInstances", createHashMap];
	private _used = false;
	{
		private _seatInstId = _y;
		private _op = OIVAR(_monitor, "SeatTablet", _connectedOperator, _seatInstId, objNull);
		if (_op isEqualTo _operator) then {
			if (isNil "_turretIdx") exitWith { _used = true; };
			private _turr = OIVAR(_monitor, "SeatTablet", _currentTurret, _seatInstId, DRIVER_TURRET_PATH);
			if (TURRET_INDEX(_turr) isEqualTo TURRET_INDEX(_turretIdx)) exitWith { _used = true; };
		};
		if (_used) exitWith {};
	} forEach _seatInstances;
	_used
};

CFUNC(inVehicleTabletSeatCondition) = {
	params ["_target"];
	if !(_target getVariable ["CFM_isVehTablet", false]) exitWith {true};
	private _plr = PLAYER_;
	if !(_plr in _target) exitWith {false};
	private _roleInfo = (fullCrew [_target, "", false]) select {(_x select 0) isEqualTo _plr};
	if (_roleInfo isEqualTo []) exitWith {false};
	[_target, _roleInfo select 0] call FUNC(isCrewSeatAllowed)
};

CFUNC(hasHandTablet) = {
	params [["_plr", PLAYER_]];
	if !(IS_OBJ(_plr)) exitWith {false};
	(_plr getVariable ["CFM_isMonitorSet", false]) &&
	{(_plr getVariable ["CFM_isHandMonitor", false])} &&
	{!(_plr getVariable ["CFM_isVehTablet", false])} &&
	{[_plr] call FUNC(hasUAVterminal)}
};

CFUNC(hasDualTabletMenu) = {
	private _plr = PLAYER_;
	if !([_plr] call FUNC(hasHandTablet)) exitWith {false};
	private _veh = objectParent _plr;
	if (isNull _veh || {_veh isEqualTo _plr}) exitWith {false};
	if !(_veh getVariable ["CFM_isMonitorSet", false]) exitWith {false};
	if !(_veh getVariable ["CFM_isVehTablet", false]) exitWith {false};
	[_veh] call FUNC(inVehicleTabletSeatCondition)
};

CFUNC(isSelectedTablet) = {
	params [["_monitor", objNull]];
	if !(IS_OBJ(_monitor)) exitWith {false};
	if !(call FUNC(hasDualTabletMenu)) exitWith {true};
	private _selected = PLAYER_ getVariable ["CFM_selectedTablet", "veh"];
	if (_monitor getVariable ["CFM_isVehTablet", false]) then {
		_selected isEqualTo "veh"
	} else {
		_selected isEqualTo "hand"
	}
};

CFUNC(getOtherTabletMonitor) = {
	params [["_monitor", objNull]];
	private _plr = PLAYER_;
	private _veh = objectParent _plr;
	if (_monitor isEqualTo _plr) exitWith {
		if (!isNull _veh && {!(_veh isEqualTo _plr)} && {_veh getVariable ["CFM_isVehTablet", false]}) then {_veh} else {objNull}
	};
	if (!isNull _veh && {_monitor isEqualTo _veh}) exitWith {
		if (_plr getVariable ["CFM_isHandMonitor", false]) then {_plr} else {objNull}
	};
	objNull
};

CFUNC(isPipVisible) = {
	params [["_monitor", objNull]];
	if !(IS_OBJ(_monitor)) exitWith {false};
	if !(_monitor getVariable ["CFM_isHandMonitor", false]) exitWith {false};
	if !(_monitor getVariable ["CFM_feedActive", false]) exitWith {false};
	if (_monitor getVariable ["CFM_turnedOffLocal", false]) exitWith {false};
	if ((_monitor getVariable ["CFM_isVehTablet", false]) && {!([_monitor] call FUNC(inVehicleTabletSeatCondition))}) exitWith {false};
	true
};

CFUNC(getPipSlotsSettings) = {
	private _pipSettings = missionNamespace getVariable ["CFM_PIPsettings", DEFAULT_PIP_SETTINGS_STR];
	if !(_pipSettings isEqualType "") then {
		_pipSettings = str _pipSettings;
		missionNamespace setVariable ["CFM_PIPsettings", _pipSettings];
	};
	private _compiled = parseSimpleArray _pipSettings;
	if ((isNil "_compiled") || {!(_compiled isEqualType [])} || {_compiled isEqualTo []}) exitWith {
		missionNamespace setVariable ["CFM_pipSlotsCount", count DEFAULT_PIP_SETTINGS];
		DEFAULT_PIP_SETTINGS
	};
	private _first = _compiled select 0;
	private _slots = if (
		(_first isEqualType []) &&
		{count _first >= 3} &&
		{(_first select 1) isEqualType 0} &&
		{(_first select 2) isEqualType 0}
	) then {
		_compiled
	} else {
		_compiled params [["_size", 0.3], ["_offsetX", 1], ["_offsetY", 0.8]];
		[[_size, _offsetX, _offsetY], [_size, [1, 0] select (_offsetX >= 0.5), _offsetY]]
	};
	missionNamespace setVariable ["CFM_pipSlotsCount", count _slots];
	_slots
};

CFUNC(getPipSlotSettings) = {
	params [["_monitor", objNull], ["_slotIdx", -1]];
	private _slots = call FUNC(getPipSlotsSettings);
	private _slotsCount = count _slots;
	if (_slotIdx < 0) then {
		_slotIdx = if (IS_OBJ(_monitor)) then {
			_monitor getVariable ["CFM_pipSlot", PIP_SLOT_RIGHT]
		} else {
			PIP_SLOT_RIGHT
		};
	};
	if (!(_slotIdx isEqualType 0) || {_slotIdx < 0} || {_slotIdx >= _slotsCount}) then {
		_slotIdx = 0;
	};
	_slots param [_slotIdx, DEFAULT_PIP_SETTINGS_RIGHT]
};

CFUNC(getFreePipSlot) = {
	params [["_monitor", objNull], ["_preferredSlot", -1]];
	private _slots = call FUNC(getPipSlotsSettings);
	private _slotsCount = count _slots;
	private _plr = PLAYER_;
	private _veh = objectParent _plr;
	private _usedSlots = [];
	{
		if (IS_OBJ(_x) && {!(_x isEqualTo _monitor)} && {[_x] call FUNC(isPipVisible)}) then {
			_usedSlots pushBackUnique (_x getVariable ["CFM_pipSlot", PIP_SLOT_RIGHT]);
		};
	} forEach [_plr, _veh];

	private _curSlot = if (_preferredSlot >= 0) then {
		_preferredSlot
	} else {
		if (IS_OBJ(_monitor)) then {_monitor getVariable ["CFM_pipSlot", PIP_SLOT_RIGHT]} else {PIP_SLOT_RIGHT}
	};
	if (!(_curSlot isEqualType 0) || {_curSlot < 0} || {_curSlot >= _slotsCount}) then {
		_curSlot = PIP_SLOT_RIGHT;
	};
	if !(_curSlot in _usedSlots) exitWith {_curSlot};

	private _freeSlot = _curSlot;
	for "_i" from 0 to (_slotsCount - 1) do {
		if !(_i in _usedSlots) exitWith {
			_freeSlot = _i;
		};
	};
	_freeSlot
};

CFUNC(calcPipControlsPositions) = {
	params [["_monitor", objNull], ["_settings", ""]];
	private _settingsCompiled = if ((_settings isEqualType "") && {!(_settings isEqualTo "")}) then {
		parseSimpleArray _settings
	} else {
		[_monitor] call FUNC(getPipSlotSettings)
	};
	if ((isNil "_settingsCompiled") || {!(_settingsCompiled isEqualType [])} || {count _settingsCompiled < 3}) then {
		_settingsCompiled = DEFAULT_PIP_SETTINGS_RIGHT;
	};
	_settingsCompiled params [["_size", 0.3], ["_offsetX", 1], ["_offsetY", 0.8]];

	private _w = _size;
	private _h = _size;
	if (_size isEqualType []) then {
		_w = _size#0;
		_h = _size#1;
	};

	private _totalW = _w * safeZoneW;
	private _totalH = _h * safeZoneH;

	private _bgX = safeZoneX + (safeZoneW - _totalW) * _offsetX;
	private _bgY = safeZoneY + (safeZoneH - _totalH) * _offsetY;

	private _borderSize = 0.004;
	private _headerHeight = 0.03;

	private _picX = _bgX + _borderSize;
	private _picY = _bgY + _headerHeight;
	private _picW = _totalW - (_borderSize * 2);
	private _picH = _totalH - _headerHeight - _borderSize;

	[
		[_bgX, _bgY, _totalW, _totalH],
		[_bgX, _bgY, _totalW, _headerHeight],
		[_picX, _picY, _picW, _picH]
	]
};

CFUNC(updatePipWindowPosition) = {
	params [["_monitor", objNull]];
	if !(IS_OBJ(_monitor)) exitWith {false};
	private _display = _monitor getVariable ["CFM_currentDisplay", displayNull];
	if (isNull _display) exitWith {false};
	private _ctrls = _monitor getVariable ["CFM_currentPipControls", []];
	if (count _ctrls < 3) exitWith {false};
	_ctrls params [["_background", controlNull], ["_title", controlNull], ["_pictureCtrl", controlNull]];
	if (isNull _background || {isNull _title} || {isNull _pictureCtrl}) exitWith {false};

	([_monitor] call FUNC(calcPipControlsPositions)) params ["_bgPos", "_titlePos", "_picPos"];
	_background ctrlSetPosition _bgPos;
	_background ctrlCommit 0;
	_title ctrlSetPosition _titlePos;
	_title ctrlCommit 0;
	_pictureCtrl ctrlSetPosition _picPos;
	_pictureCtrl ctrlCommit 0;
	true
};

CFUNC(bringPipToTop) = {
	params [["_monitor", objNull], ["_forceRecreate", false]];
	if !([_monitor] call FUNC(isPipVisible)) exitWith {false};
	private _otherMon = [_monitor] call FUNC(getOtherTabletMonitor);
	private _needRecreate = _forceRecreate;
	if (!_needRecreate && {[_otherMon] call FUNC(isPipVisible)}) then {
		private _mySlot = _monitor getVariable ["CFM_pipSlot", PIP_SLOT_RIGHT];
		private _otherSlot = _otherMon getVariable ["CFM_pipSlot", PIP_SLOT_RIGHT];
		private _myLayer = _monitor getVariable ["CFM_currentRscLayer", -1];
		private _otherLayer = _otherMon getVariable ["CFM_currentRscLayer", -1];
		if ((_mySlot isEqualTo _otherSlot) && {(_myLayer isEqualType 0) && (_otherLayer isEqualType 0) && {_myLayer <= _otherLayer}}) then {
			_needRecreate = true;
		};
	};
	if (_needRecreate) then {
		[_monitor, true] call FUNC(setHandDisplay);
	};
	true
};

CFUNC(switchTabletMenu) = {
	params [["_mode", ""]];
	private _plr = PLAYER_;
	private _veh = objectParent _plr;
	private _curMode = _plr getVariable ["CFM_selectedTablet", "veh"];
	if !(_mode in ["hand", "veh"]) then {
		_mode = ["hand", "veh"] select (_curMode isEqualTo "hand");
	};
	if (_mode isEqualTo "hand") then {
		if (IS_OBJ(_veh) && {_veh getVariable ["CFM_menuActive", false]}) then {
			[_veh] call FUNC(monitorCloseMenu);
		};
		_plr setVariable ["CFM_selectedTablet", "hand"];
		[_plr] call FUNC(bringPipToTop);
	} else {
		if (_plr getVariable ["CFM_menuActive", false]) then {
			[_plr] call FUNC(monitorCloseMenu);
		};
		_plr setVariable ["CFM_selectedTablet", "veh"];
		if (IS_OBJ(_veh)) then {
			[_veh] call FUNC(bringPipToTop);
		};
	};
	true
};

CFUNC(switchPipSlot) = {
	params [["_monitor", GET_MON], ["_targetSlot", -1]];
	if !(IS_OBJ(_monitor)) exitWith {false};
	if !(_monitor getVariable ["CFM_isHandMonitor", false]) exitWith {false};
	private _slots = call FUNC(getPipSlotsSettings);
	private _slotsCount = count _slots;
	private _curSlot = _monitor getVariable ["CFM_pipSlot", PIP_SLOT_RIGHT];
	if (_targetSlot < 0) then {
		_targetSlot = (_curSlot + 1) mod _slotsCount;
	};
	_monitor setVariable ["CFM_pipSlot", _targetSlot];
	if (_monitor getVariable ["CFM_isVehTablet", false]) then {
		["saveFromMonitor"] CALL_ACTIVE_SEAT_TABLET(_monitor);
	};
	if !([_monitor] call FUNC(isPipVisible)) exitWith {true};

	private _otherMon = [_monitor] call FUNC(getOtherTabletMonitor);
	private _needTopLayer = false;
	if ([_otherMon] call FUNC(isPipVisible)) then {
		private _otherSlot = _otherMon getVariable ["CFM_pipSlot", PIP_SLOT_RIGHT];
		private _myLayer = _monitor getVariable ["CFM_currentRscLayer", -1];
		private _otherLayer = _otherMon getVariable ["CFM_currentRscLayer", -1];
		if ((_targetSlot isEqualTo _otherSlot) && {(_myLayer isEqualType 0) && (_otherLayer isEqualType 0) && {_myLayer <= _otherLayer}}) then {
			_needTopLayer = true;
		};
	};
	if (_needTopLayer) exitWith {
		[_monitor, true] call FUNC(setHandDisplay);
		true
	};

	if !([_monitor] call FUNC(updatePipWindowPosition)) then {
		[_monitor, true] call FUNC(setHandDisplay);
	};
	true
};

CFUNC(switchTabletMenuActionCondition) = {
	params ["_target"];
	if !(call FUNC(hasDualTabletMenu)) exitWith {false};
	[_target] call FUNC(isSelectedTablet)
};

CFUNC(switchPipSlotActionCondition) = {
	params ["_target", ["_targetSlot", -1]];
	HAND_MON_CONDITION
	IS_MONITOR_ON
	if !(_target getVariable ["CFM_feedActive", false]) exitWith {false};
	if !(_target getVariable ["CFM_isHandMonitor", false]) exitWith {false};
	if (missionNamespace getVariable ["CFM_isInPIPFullScreen", false]) exitWith {false};
	if (
		(_target getVariable ["CFM_isHandMonitorDisplay", false]) ||
		{MGVAR ["CFM_allHandMonitorsAreDisplays", false]}
	) exitWith {false};

	private _slotsCount = missionNamespace getVariable ["CFM_pipSlotsCount", PIP_SLOTS_COUNT];
	if (_slotsCount < 2) exitWith {false};

	if (_targetSlot < 0) exitWith {
		_slotsCount > 2
	};
	if (_slotsCount > 2) exitWith {false};

	private _curSlot = _target getVariable ["CFM_pipSlot", PIP_SLOT_RIGHT];
	!(_curSlot isEqualTo _targetSlot)
};

CFUNC(inVehicleTabletActionCondition) = {
	params ["_target"];
	if !(_target getVariable ["CFM_isVehTablet", false]) exitWith {true};
	if !([_target] call FUNC(inVehicleTabletSeatCondition)) exitWith {false};
	[_target] call FUNC(isSelectedTablet)
};

CFUNC(hasMonitorPasswordAccess) = {
	params ["_monitor"];
	if !(_monitor getVariable ["CFM_canSetPassword", false]) exitWith {true};
	private _pass = _monitor getVariable ["CFM_password", ""];
	if (_pass isEqualTo "") exitWith {true};
	if ((MGVAR ["CFM_debug", false]) || {PLAYER_IS_ADMIN && {(MGVAR ["CFM_adminHaveAccessToAllMonitors", false])}}) exitWith {true};
	private _accessList = _monitor getVariable ["CFM_passwordAccess", []];
	PLAYER_PASS_ID in _accessList
};

// CAMERA OBJECT (proxy object that represents camera)
// destroyed = deleted, or damage allowed and damage reached 1
CFUNC(isCameraObjectDestroyed) = {
	params [["_camObj", objNull]];
	if !(IS_OBJ(_camObj)) exitWith {true};
	if !(isDamageAllowed _camObj) exitWith {false};
	((damage _camObj) >= 1) || {!(alive _camObj)}
};
// _turretIndex: turret index to check, or -2 to check if ALL operator turrets cameras are destroyed
CFUNC(isOperatorCameraDestroyed) = {
	params [["_op", objNull], ["_turretIndex", -2]];
	private _disabledTurrets = _op getVariable ["CFM_disabledTurrets", []];
	private _camObjs = _op getVariable ["CFM_cameraObjects", createHashMap];
	_turretIndex = TURRET_INDEX(_turretIndex);
	if (_turretIndex isNotEqualTo -2) exitWith {
		if (_turretIndex in _disabledTurrets) exitWith {true};
		if !(_turretIndex in _camObjs) exitWith {false};
		[_camObjs getOrDefault [_turretIndex, objNull]] call FUNC(isCameraObjectDestroyed)
	};
	private _allTurrets = _op getVariable ["CFM_allTurrets", _op getVariable ["CFM_turrets", [DRIVER_TURRET_IDX]]];
	if !(_allTurrets isEqualType []) then {_allTurrets = [_allTurrets]};
	if (_allTurrets isEqualTo []) then {_allTurrets = keys _camObjs};
	if (_allTurrets isEqualTo []) exitWith {false};
	(_allTurrets findIf {
		private _idx = TURRET_INDEX(_x);
		!(_idx in _disabledTurrets) && {
			!(_idx in _camObjs) || {!([_camObjs getOrDefault [_idx, objNull]] call FUNC(isCameraObjectDestroyed))}
		}
	}) == -1
};

CFUNC(initCameraObjectEHs) = {
	params [["_operator", objNull], ["_turretIndex", -1], ["_cameraObject", objNull]];

	if (!IS_OBJ(_operator) || {!IS_OBJ(_cameraObject)}) exitWith {false};

	_turretIndex = TURRET_INDEX(_turretIndex);

	// Register operator and turret on the camera object
	[_cameraObject, "CFM_registeredTurrets", [_operator, _turretIndex], true, false] call FUNC(pushBack);

	// If camera object is already destroyed, disable turret immediately
	if ([_cameraObject] call FUNC(isCameraObjectDestroyed)) exitWith {
		["CFM_" + "disableTurret", [_operator, _turretIndex], true] call FUNC(remoteEvent);
		true
	};

	// Ensure EHs are added only once per camera object
	private _ehsAdded = _cameraObject getVariable ["CFM_cameraObjectEHsAdded", false];
	if (!_ehsAdded) then {
		_cameraObject setVariable ["CFM_cameraObjectEHsAdded", true];

		_cameraObject addEventHandler ["Deleted", {
			params ["_entity"];
			if !(local _entity) exitWith {};
			private _turrets = _entity getVariable ["CFM_registeredTurrets", []];
			{
				_x params ["_op", "_tIdx"];
				if (IS_OBJ(_op)) then {
					["CFM_" + "disableTurret", [_op, _tIdx], true] call FUNC(remoteEvent);
				};
			} forEach _turrets;
		}];

		_cameraObject addEventHandler ["Killed", {
			params ["_unit"];
			if !(local _unit) exitWith {};
			private _turrets = _unit getVariable ["CFM_registeredTurrets", []];
			{
				_x params ["_op", "_tIdx"];
				if (IS_OBJ(_op)) then {
					["CFM_" + "disableTurret", [_op, _tIdx], true] call FUNC(remoteEvent);
				};
			} forEach _turrets;
		}];
	};

	true
};

// CONTINUOUS CAMERA MOVEMENT
CFUNC(stopContinuousCameraMove) = {
	private _lastOp = missionNamespace getVariable ["CFM_contMoveLastOp", objNull];
	private _lastTurr = missionNamespace getVariable ["CFM_contMoveLastTurr", [-1]];
	missionNamespace setVariable ["CFM_heldCameraMoveDirs", [false, false, false, false]];
	missionNamespace setVariable ["CFM_heldCameraMoveKeyInfo", [[], [], [], []]];
	missionNamespace setVariable ["CFM_isContinuousMoving", false];
	missionNamespace setVariable ["CFM_contMoveLastOp", objNull];
	if (IS_OBJ(_lastOp)) then {
		["syncContinuousMove", [_lastTurr], false] CALL_OBJCLASS("Operator", _lastOp);
	};
};

CFUNC(handleContinuousCameraMove) = {
	params [["_direction", ""], ["_isDown", false], ["_keyArgs", []]];

	private _dirIdx = CAMERA_MOVE_DIRECTIONS find _direction;
	if (_dirIdx == -1) exitWith {false};

	if ((missionNamespace getVariable ["CFM_contCamKeyUpEH", -1]) == -1) then {
		private _disp = findDisplay 46;
		if (!isNull _disp) then {
			private _eh = _disp displayAddEventHandler ["KeyUp", {
				params ["_displayOrControl", "_key"];
				if !(missionNamespace getVariable ["CFM_isContinuousMoving", false]) exitWith {false};
				private _held = missionNamespace getVariable ["CFM_heldCameraMoveDirs", [false, false, false, false]];
				private _info = missionNamespace getVariable ["CFM_heldCameraMoveKeyInfo", [[], [], [], []]];
				private _changed = false;
				{
					if (_x) then {
						private _kInfo = _info param [_forEachIndex, []];
						if (_kInfo isNotEqualTo []) then {
							_kInfo params [["_dik", -1], ["_reqShift", false], ["_reqCtrl", false], ["_reqAlt", false]];
							if (
								(_key == _dik) ||
								{_reqShift && {_key in [42, 54]}} ||
								{_reqCtrl && {_key in [29, 157]}} ||
								{_reqAlt && {_key in [56, 184]}}
							) then {
								_held set [_forEachIndex, false];
								_info set [_forEachIndex, []];
								_changed = true;
							};
						};
					};
				} forEach _held;
				if (_changed && {!(true in _held)}) then {
					call CFM_fnc_stopContinuousCameraMove;
				};
				false
			}];
			missionNamespace setVariable ["CFM_contCamKeyUpEH", _eh];
		};
	};

	private _held = missionNamespace getVariable ["CFM_heldCameraMoveDirs", [false, false, false, false]];
	private _info = missionNamespace getVariable ["CFM_heldCameraMoveKeyInfo", [[], [], [], []]];

	if (_isDown) then {
		private _monitor = GET_MON;
		if !(IS_OBJ(_monitor)) exitWith {false};
		if !(_monitor getVariable ["CFM_currentCameraCanMove", false]) exitWith {false};
		private _camera = _monitor getVariable ["CFM_currentFeedCam", objNull];
		if !(IS_OBJ(_camera)) exitWith {false};

		_held set [_dirIdx, true];
		if (_keyArgs isEqualType [] && {count _keyArgs >= 5}) then {
			_info set [_dirIdx, [_keyArgs select 1, _keyArgs select 2, _keyArgs select 3, _keyArgs select 4]];
		};
		missionNamespace setVariable ["CFM_heldCameraMoveDirs", _held];
		missionNamespace setVariable ["CFM_heldCameraMoveKeyInfo", _info];
		missionNamespace setVariable ["CFM_isContinuousMoving", true];
		true
	} else {
		_held set [_dirIdx, false];
		_info set [_dirIdx, []];
		missionNamespace setVariable ["CFM_heldCameraMoveDirs", _held];
		missionNamespace setVariable ["CFM_heldCameraMoveKeyInfo", _info];
		if !(true in _held) then {
			call CFM_fnc_stopContinuousCameraMove;
		};
		false
	};
};

CFUNC(updateContinuousCameraMove) = {
	if !(missionNamespace getVariable ["CFM_isContinuousMoving", false]) exitWith {};
	if !(MGVAR ["CFM_continuousCameraMove", false]) exitWith {
		call FUNC(stopContinuousCameraMove);
	};
	if (dialog || {!isNull findDisplay 49}) exitWith {
		call FUNC(stopContinuousCameraMove);
	};

	private _held = missionNamespace getVariable ["CFM_heldCameraMoveDirs", [false, false, false, false]];
	if !(true in _held) exitWith {
		call FUNC(stopContinuousCameraMove);
	};

	private _monitor = GET_MON;
	if !(IS_OBJ(_monitor)) exitWith {
		call FUNC(stopContinuousCameraMove);
	};

	private _canMove = _monitor getVariable ["CFM_currentCameraCanMove", false];
	if !(_canMove isEqualTo true) exitWith {
		call FUNC(stopContinuousCameraMove);
	};

	private _camera = _monitor getVariable ["CFM_currentFeedCam", objNull];
	private _operator = _monitor getVariable ["CFM_connectedOperator", objNull];
	if (!IS_OBJ(_camera) || {!IS_OBJ(_operator)}) exitWith {
		call FUNC(stopContinuousCameraMove);
	};

	private _turretIndex = _monitor getVariable ["CFM_currentTurret", [-1]];
	private _lastOp = missionNamespace getVariable ["CFM_contMoveLastOp", objNull];
	private _lastTurr = missionNamespace getVariable ["CFM_contMoveLastTurr", [-1]];
	if (IS_OBJ(_lastOp) && {(_lastOp isNotEqualTo _operator) || {_lastTurr isNotEqualTo _turretIndex}}) then {
		["syncContinuousMove", [_lastTurr], false] CALL_OBJCLASS("Operator", _lastOp);
	};
	missionNamespace setVariable ["CFM_contMoveLastOp", _operator];
	missionNamespace setVariable ["CFM_contMoveLastTurr", _turretIndex];

	private _currZoom = _monitor getVariable ["CFM_zoomFov", 1];
	if !(_currZoom isEqualType 1) then {
		_currZoom = _operator getVariable ["CFM_prevZoomLocalFov", getObjectFov _operator];
	};

	private _sensitivity = MGVAR ["CFM_cameraMoveSensitivity", 5];
	private _dt = diag_deltaTime min 0.1;
	// Continuous rotation speed in degrees/sec: sensitivity * 6 * zoomFov (at default sensitivity 5 -> 30 deg/s * zoomFov)
	private _baseStep = _sensitivity * 6 * _currZoom * _dt;
	if (_baseStep <= 0) exitWith {};

	private _movementRestrictions = _monitor getVariable ["CFM_currentCameraMoveRestrictions", [85, 85, 180, 180]];
	private _currentCameraMoves = _monitor getVariable ["CFM_currentCameraMoves", [0, 0, 0, 0]];

	private _vertical = 0;
	private _horizontal = 0;

	{
		if (_x) then {
			private _dirIdx = _forEachIndex;
			private _dirRestriction = _movementRestrictions param [_dirIdx, 0];
			if (_dirRestriction >= 1) then {
				private _curMove = _currentCameraMoves param [_dirIdx, 0];
				private _step = _baseStep;
				if (_dirRestriction < 180) then {
					if (_curMove >= _dirRestriction) then {
						_step = 0;
					} else {
						if ((_curMove + _step) > _dirRestriction) then {
							_step = _dirRestriction - _curMove;
						};
					};
				};
				if (_step > 0) then {
					switch (_dirIdx) do {
						case 0: { _vertical = _vertical + _step; };   // up
						case 1: { _vertical = _vertical - _step; };   // down
						case 2: { _horizontal = _horizontal + _step; }; // left
						case 3: { _horizontal = _horizontal - _step; }; // right
					};
				};
			};
		};
	} forEach _held;

	if ((_horizontal == 0) && {_vertical == 0}) exitWith {};

	["moveCamera", [_turretIndex, [_horizontal, _vertical], true], false] CALL_OBJCLASS("Operator", _operator);
};

// EFL WRAPPERS
if (!(isNil {FUNC(remoteExec)}) && {isFinal FUNC(remoteExec)}) exitWith {};

#define COMPILE_C
#ifdef FINAL
#define COMPILE_C compileFinal
#endif
#define EFL_WRAP(f) CFUNC(f) = COMPILE_C {(IF_NIL(_this, [])) call TRIPLE(EFL_PREF,_fnc_,f)};

EFL_WRAP(pushBackGlobal);
EFL_WRAP(hashSetGlobal);
EFL_WRAP(removeFromArrayGlobal);
EFL_WRAP(deleteAtGlobal);
EFL_WRAP(publicVariableServer);
EFL_WRAP(pushBackNet);
EFL_WRAP(pushBack);
EFL_WRAP(hashSetNet);
EFL_WRAP(hashSet);
EFL_WRAP(removeFromArrayNet);
EFL_WRAP(removeFromArray);
EFL_WRAP(deleteAtNet);
EFL_WRAP(deleteAt);
EFL_WRAP(remoteExec);
EFL_WRAP(remoteEvent);
EFL_WRAP(callVariableEH);
EFL_WRAP(publicVariable);
EFL_WRAP(setVariable);
