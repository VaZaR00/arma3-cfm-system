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
CFUNC(setupDefScreenResolutions) = {
	private _resSetDef = parsingNamespace getVariable ["CFM_classesScreenResolutionSet", createHashMap];
	private _patternsDef = parsingNamespace getVariable ["CFM_screenResolutionPatterns", []];
	if (_resSetDef isEqualTo createHashMap) then {
		[] call FUNC(initDefaultScreenResolutions);
		_resSetDef = parsingNamespace getVariable ["CFM_classesScreenResolutionSet", createHashMap];
		_patternsDef = parsingNamespace getVariable ["CFM_screenResolutionPatterns", []];
		missionNamespace setVariable ["CFM_classesScreenResolutionSet", _resSetDef];
		missionNamespace setVariable ["CFM_screenResolutionPatterns", _patternsDef];
	} else {
		missionNamespace setVariable ["CFM_classesScreenResolutionSet", _resSetDef];
		missionNamespace setVariable ["CFM_screenResolutionPatterns", _patternsDef];
	};
	CFM_initDefScreenResolutionsSet = true;
	_resSetDef
};

CFUNC(resolveMonitor) = {
	params [["_monArg", objNull]];
	if (_monArg isEqualType []) exitWith {
		_monArg params [["_obj", objNull], ["_instId", -1]];
		if !(IS_OBJ(_obj)) exitWith {[objNull, -1]};
		if (_instId < 1) then {
			_instId = [_obj] call FUNC(getSelectedMonitorInstance);
			if (_instId < 1) then {
				private _keys = keys (_obj getVariable ["CFM_monitorInstanceKeysMap", createHashMap]);
				_keys sort true;
				_instId = _keys param [0, -1];
			};
		};
		[_obj, _instId]
	};
	if !(IS_OBJ(_monArg)) exitWith {[objNull, -1]};
	private _instId = [_monArg] call FUNC(getSelectedMonitorInstance);
	if (_instId < 1) then {
		private _keys = keys (_monArg getVariable ["CFM_monitorInstanceKeysMap", createHashMap]);
		_keys sort true;
		_instId = _keys param [0, -1];
	};
	[_monArg, _instId]
};

CFUNC(resolveTurret) = {
	params [["_operator", objNull], ["_turret", -1]];
	if (_operator isEqualType []) then {
		_operator params [["_opObj", objNull], ["_tArg", -1]];
		_operator = _opObj;
		if (_turret isEqualTo -1) then {_turret = _tArg};
	};
	if !(IS_OBJ(_operator)) exitWith {[objNull, -1]};
	private _turretsInstances = _operator getVariable ["CFM_turretsInstances", createHashMap];
	private _turretIndex = TURRET_INDEX(_turret);
	if (_turretIndex in _turretsInstances) exitWith {
		private _instData = _turretsInstances getOrDefault [_turretIndex, [-1, objNull]];
		_instData params [["_instId", -1], ["_turrObj", objNull]];
		[_turrObj, _instId]
	};
	[objNull, -1]
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
	if !(IS_OBJ(_veh)) exitWith {false};
	private _seatKey = if (_crewEntry isEqualType "") then {
		_crewEntry
	} else {
		[_crewEntry] call FUNC(getCrewSeatKey)
	};
	if (_seatKey isEqualTo "") exitWith {false};
	private _map = _veh getVariable ["CFM_monitorInstancesMap", createHashMap];
	private _instIds = _map getOrDefault [_seatKey, []];
	!(_instIds isEqualTo [])
};

CFUNC(isMonitorUsingOperator) = {
	params ["_monitor", "_operator", ["_turretIdx", nil], ["_excludeInstId", -1]];
	if !(IS_OBJ(_monitor)) exitWith {false};
	private _keysMap = _monitor getVariable ["CFM_monitorInstanceKeysMap", createHashMap];
	private _used = false;
	{
		private _instId = _x;
		if !(_instId isEqualTo _excludeInstId) then {
			private _op = MON_GVAR(_monitor, _instId, "CFM_connectedOperator", objNull);
			if (_op isEqualTo _operator) then {
				if (isNil "_turretIdx") exitWith { _used = true; };
				private _turr = MON_GVAR(_monitor, _instId, "CFM_currentTurret", DRIVER_TURRET_PATH);
				if (TURRET_INDEX(_turr) isEqualTo TURRET_INDEX(_turretIdx)) exitWith { _used = true; };
			};
		};
		if (_used) exitWith {};
	} forEach _keysMap;
	_used
};

CFUNC(inVehicleTabletSeatCondition) = {
	params ["_target", ["_instId", -1]];
	if (_target isEqualType []) then {
		_target params [["_obj", objNull], ["_id", -1]];
		_target = _obj;
		if (_instId < 0) then {_instId = _id};
	};
	if !(IS_OBJ(_target)) exitWith {false};
	private _plr = PLAYER_;
	if (_instId > 0) exitWith {
		if !(MON_GVAR(_target, _instId, "CFM_isVehSeatTablet", false)) exitWith {true};
		if !(_plr in _target) exitWith {false};
		private _reqSeats = MON_GVAR(_target, _instId, "CFM_seatKeys", []);
		if (_reqSeats isNotEqualTo []) exitWith {
			private _curSeat = [_target, _plr] call FUNC(getUnitVehicleSeatKey);
			!(_curSeat isEqualTo "") && {_curSeat in _reqSeats}
		};
		private _reqSeat = MON_GVAR(_target, _instId, "CFM_seatKey", "");
		if (_reqSeat isEqualTo "") exitWith {true};
		private _curSeat = [_target, _plr] call FUNC(getUnitVehicleSeatKey);
		!(_curSeat isEqualTo "") && {_curSeat isEqualTo _reqSeat}
	};
	if !(_target getVariable ["CFM_isVehSeatTablet", false]) exitWith {true};
	if !(_plr in _target) exitWith {false};
	private _curSeat = [_target, _plr] call FUNC(getUnitVehicleSeatKey);
	if (_curSeat isEqualTo "") exitWith {false};
	private _map = _target getVariable ["CFM_monitorInstancesMap", createHashMap];
	!((_map getOrDefault [_curSeat, []]) isEqualTo [])
};

CFUNC(canControlMonitorSeat) = {
	params ["_target", ["_instId", -1]];
	if (_target isEqualType []) then {
		_target params [["_obj", objNull], ["_id", -1]];
		_target = _obj;
		if (_instId < 0) then {_instId = _id};
	};
	if !(IS_OBJ(_target)) exitWith {false};
	if (_instId < 1) then {
		_instId = [_target] call FUNC(getSelectedMonitorInstance);
	};
	if (_instId < 1) exitWith {false};
	if !(MON_GVAR(_target, _instId, "CFM_isVehSeatTablet", false)) exitWith {true};
	private _controlSeats = MON_GVAR(_target, _instId, "CFM_controlSeatKeys", []);
	if (_controlSeats isEqualTo []) exitWith {true};
	private _plr = PLAYER_;
	if !(_plr in _target) exitWith {false};
	private _curSeat = [_target, _plr] call FUNC(getUnitVehicleSeatKey);
	!(_curSeat isEqualTo "") && {_curSeat in _controlSeats}
};

CFUNC(hasHandTablet) = {
	params [["_plr", PLAYER_]];
	if !(IS_OBJ(_plr)) exitWith {false};
	private _handInst = (_plr getVariable ["CFM_monitorInstancesMap", createHashMap]) getOrDefault [HAND_MONITOR_KEY, -1];
	(_plr getVariable ["CFM_isMonitorSet", false]) &&
	{_plr getVariable ["CFM_isHandTablet", false]} &&
	{_handInst > 0} &&
	{MON_GVAR(_plr, _handInst, "CFM_isHandMonitor", false)} &&
	{[_plr] call FUNC(hasUAVterminal)}
};

CFUNC(hasDualTabletMenu) = {
	private _plr = PLAYER_;
	if !([_plr] call FUNC(hasHandTablet)) exitWith {false};
	private _veh = objectParent _plr;
	if (isNull _veh || {_veh isEqualTo _plr}) exitWith {false};
	if !(_veh getVariable ["CFM_isMonitorSet", false]) exitWith {false};
	if !(_veh getVariable ["CFM_isVehSeatTablet", false]) exitWith {false};
	[_veh] call FUNC(inVehicleTabletSeatCondition)
};

CFUNC(isSelectedTablet) = {
	params [["_monArg", objNull], ["_instId", -1]];
	if (_monArg isEqualType []) then {
		_monArg params [["_obj", objNull], ["_id", -1]];
		_monArg = _obj;
		if (_instId < 0) then {_instId = _id};
	};
	if !(IS_OBJ(_monArg)) exitWith {false};
	if !(call FUNC(hasDualTabletMenu)) exitWith {true};
	private _selected = PLAYER_ getVariable ["CFM_selectedTablet", "veh"];
	if ((_monArg isEqualTo PLAYER_) || {(_instId > 0) && {MON_GVAR(_monArg, _instId, "CFM_isHandTablet", false)}}) exitWith {
		_selected isEqualTo "hand"
	};
	if ((_monArg isEqualTo (objectParent PLAYER_)) || {(_instId > 0) && {MON_GVAR(_monArg, _instId, "CFM_isVehSeatTablet", false)}}) exitWith {
		_selected isEqualTo "veh"
	};
	true
};

CFUNC(getSeatPipOrdinal) = {
	params [["_monitor", objNull], ["_instId", -1]];
	if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {[0, 0]};
	private _keysMap = _monitor getVariable ["CFM_monitorInstanceKeysMap", createHashMap];
	private _entry = _keysMap getOrDefault [_instId, []];
	if (_entry isEqualTo []) exitWith {[0, 0]};
	_entry params [["_texSel", NO_TEXTURE_SELECTION], ["_seatKey", ""], ["_isVehSeat", false], "", ["_seatKeys", []]];
	if (!_isVehSeat || {_texSel >= 0}) exitWith {[0, 0]};
	if (_seatKeys isEqualTo [] && {!(_seatKey isEqualTo "")}) then {_seatKeys = [_seatKey]};
	if (_seatKeys isEqualTo []) exitWith {[0, 0]};

	private _sortedTarget = +_seatKeys;
	_sortedTarget sort true;

	private _samePipIds = [];
	{
		private _eId = _x;
		_y params [["_eTex", NO_TEXTURE_SELECTION], ["_eSeat", ""], ["_eIsVeh", false], "", ["_eSeats", []]];
		if (_eIsVeh && {_eTex < 0}) then {
			if (_eSeats isEqualTo [] && {!(_eSeat isEqualTo "")}) then {_eSeats = [_eSeat]};
			private _sortedE = +_eSeats;
			_sortedE sort true;
			if (_sortedE isEqualTo _sortedTarget) then {
				_samePipIds pushBack _eId;
			};
		};
	} forEach _keysMap;

	private _total = count _samePipIds;
	if (_total <= 1) exitWith {[0, _total]};
	_samePipIds sort true;
	[(_samePipIds find _instId) + 1, _total]
};

CFUNC(getOtherPipMonitors) = {
	params [["_monArg", objNull], ["_instId", -1]];
	if (_monArg isEqualType []) then {
		_monArg params [["_obj", objNull], ["_id", -1]];
		_monArg = _obj;
		if (_instId < 0) then {_instId = _id};
	};
	private _plr = PLAYER_;
	private _veh = objectParent _plr;
	private _others = [];

	private _handInst = (_plr getVariable ["CFM_monitorInstancesMap", createHashMap]) getOrDefault [HAND_MONITOR_KEY, -1];
	if (_handInst > 0 && {MON_GVAR(_plr, _handInst, "CFM_isHandMonitor", false)} && {!((_monArg isEqualTo _plr) && {_instId == _handInst})}) then {
		_others pushBack [_plr, _handInst];
	};

	if (!isNull _veh && {!(_veh isEqualTo _plr)} && {_veh getVariable ["CFM_isVehSeatTablet", false]}) then {
		private _curSeat = [_veh, _plr] call FUNC(getUnitVehicleSeatKey);
		private _seatInsts = (_veh getVariable ["CFM_monitorInstancesMap", createHashMap]) getOrDefault [_curSeat, []];
		{
			if (MON_GVAR(_veh, _x, "CFM_isHandMonitor", false) && {!((_monArg isEqualTo _veh) && {_instId == _x})}) then {
				_others pushBack [_veh, _x];
			};
		} forEach _seatInsts;
	};

	_others
};

CFUNC(getOtherTabletMonitor) = {
	params [["_monArg", objNull], ["_instId", -1]];
	if (_monArg isEqualType []) then {
		_monArg params [["_obj", objNull], ["_id", -1]];
		_monArg = _obj;
		if (_instId < 0) then {_instId = _id};
	};
	if !(IS_OBJ(_monArg)) exitWith {[objNull, -1]};
	private _plr = PLAYER_;
	private _veh = objectParent _plr;
	if (_monArg isEqualTo _plr) exitWith {
		if (!isNull _veh && {!(_veh isEqualTo _plr)} && {_veh getVariable ["CFM_isVehSeatTablet", false]}) then {
			private _selInst = [_veh] call FUNC(getSelectedMonitorInstance);
			if (_selInst > 0 && {MON_GVAR(_veh, _selInst, "CFM_isHandMonitor", false)}) exitWith {[_veh, _selInst]};
			private _curSeat = [_veh, _plr] call FUNC(getUnitVehicleSeatKey);
			private _seatInsts = (_veh getVariable ["CFM_monitorInstancesMap", createHashMap]) getOrDefault [_curSeat, []];
			if (_seatInsts isEqualTo []) exitWith {[objNull, -1]};
			private _pipInst = -1;
			{
				if (MON_GVAR(_veh, _x, "CFM_isHandMonitor", false)) exitWith {_pipInst = _x};
			} forEach _seatInsts;
			if (_pipInst < 0) then {_pipInst = _seatInsts select 0};
			[_veh, _pipInst]
		} else {[objNull, -1]}
	};
	if (!isNull _veh && {_monArg isEqualTo _veh}) exitWith {
		private _handInst = (_plr getVariable ["CFM_monitorInstancesMap", createHashMap]) getOrDefault [HAND_MONITOR_KEY, -1];
		if (_handInst > 0 && {MON_GVAR(_plr, _handInst, "CFM_isHandMonitor", false)}) then {[_plr, _handInst]} else {[objNull, -1]}
	};
	[objNull, -1]
};

CFUNC(isPipVisible) = {
	params [["_monArg", objNull], ["_instId", -1]];
	(RESOLVE_MON(if (_instId > 0 && {!(_monArg isEqualType [])}) then {[_monArg I _instId]} else {_monArg})) params ["_monitor", "_resolvedId"];
	if (!(IS_OBJ(_monitor)) || {_resolvedId < 1}) exitWith {false};
	if !(MON_GVAR(_monitor, _resolvedId, "CFM_isHandMonitor", false)) exitWith {false};
	if !(MON_GVAR(_monitor, _resolvedId, "CFM_feedActive", false)) exitWith {false};
	if (MON_GVAR(_monitor, _resolvedId, "CFM_turnedOffLocal", false)) exitWith {false};
	if (MON_GVAR(_monitor, _resolvedId, "CFM_isVehSeatTablet", false) && {!([_monitor, _resolvedId] call FUNC(inVehicleTabletSeatCondition))}) exitWith {false};
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
	params [["_monArg", objNull], ["_slotIdx", -1]];
	(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
	private _slots = call FUNC(getPipSlotsSettings);
	private _slotsCount = count _slots;
	if (_slotIdx < 0) then {
		_slotIdx = if (IS_OBJ(_monitor) && {_instId > 0}) then {
			MON_GVAR(_monitor, _instId, "CFM_pipSlot", PIP_SLOT_RIGHT)
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
	params [["_monArg", objNull], ["_preferredSlot", -1]];
	(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
	private _slots = call FUNC(getPipSlotsSettings);
	private _slotsCount = count _slots;
	private _usedSlots = [];
	private _otherMons = if (IS_OBJ(_monitor)) then {[[_monitor, _instId]] call FUNC(getOtherPipMonitors)} else {[]};
	{
		_x params ["_otherObj", "_otherId"];
		private _otherActive = ([_x] call FUNC(isPipVisible)) || {
			!(MON_GVAR(_otherObj, _otherId, "CFM_turnedOffLocal", false)) &&
			{(MON_GVAR(_otherObj, _otherId, "CFM_waitingForStart", false)) || {(diag_tickTime - (MON_GVAR(_otherObj, _otherId, "CFM_pipSlotReservedAt", -999))) < 2}} &&
			{!isNil {_otherObj getVariable (MON_VAR_NAME("CFM_pipSlot", _otherId))}}
		};
		if (_otherActive) then {
			_usedSlots pushBackUnique (MON_GVAR(_otherObj, _otherId, "CFM_pipSlot", PIP_SLOT_RIGHT));
		};
	} forEach _otherMons;

	private _curSlot = if (_preferredSlot >= 0) then {
		_preferredSlot
	} else {
		if (IS_OBJ(_monitor) && {_instId > 0}) then {MON_GVAR(_monitor, _instId, "CFM_pipSlot", PIP_SLOT_RIGHT)} else {PIP_SLOT_RIGHT}
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
	params [["_monArg", objNull], ["_settings", ""]];
	private _settingsCompiled = if ((_settings isEqualType "") && {!(_settings isEqualTo "")}) then {
		parseSimpleArray _settings
	} else {
		[_monArg] call FUNC(getPipSlotSettings)
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
	params [["_monArg", objNull]];
	(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
	if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
	private _display = MON_GVAR(_monitor, _instId, "CFM_currentDisplay", displayNull);
	if (isNull _display) exitWith {false};
	private _ctrls = MON_GVAR(_monitor, _instId, "CFM_currentPipControls", []);
	if (count _ctrls < 3) exitWith {false};
	_ctrls params [["_background", controlNull], ["_title", controlNull], ["_pictureCtrl", controlNull]];
	if (isNull _background || {isNull _title} || {isNull _pictureCtrl}) exitWith {false};

	([[_monitor, _instId]] call FUNC(calcPipControlsPositions)) params ["_bgPos", "_titlePos", "_picPos"];
	_background ctrlSetPosition _bgPos;
	_background ctrlCommit 0;
	_title ctrlSetPosition _titlePos;
	_title ctrlCommit 0;
	_pictureCtrl ctrlSetPosition _picPos;
	_pictureCtrl ctrlCommit 0;
	true
};

CFUNC(bringPipToTop) = {
	params [["_monArg", objNull], ["_forceRecreate", false]];
	(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
	if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
	if !([[_monitor, _instId]] call FUNC(isPipVisible)) exitWith {false};
	private _needRecreate = _forceRecreate;
	if (!_needRecreate) then {
		private _mySlot = MON_GVAR(_monitor, _instId, "CFM_pipSlot", PIP_SLOT_RIGHT);
		private _myLayer = MON_GVAR(_monitor, _instId, "CFM_currentRscLayer", -1);
		{
			if ([_x] call FUNC(isPipVisible)) then {
				_x params ["_otherMon", "_otherInstId"];
				private _otherSlot = MON_GVAR(_otherMon, _otherInstId, "CFM_pipSlot", PIP_SLOT_RIGHT);
				private _otherLayer = MON_GVAR(_otherMon, _otherInstId, "CFM_currentRscLayer", -1);
				if ((_mySlot isEqualTo _otherSlot) && {(_myLayer isEqualType 0) && (_otherLayer isEqualType 0) && {_myLayer <= _otherLayer}}) exitWith {
					_needRecreate = true;
				};
			};
		} forEach ([[_monitor, _instId]] call FUNC(getOtherPipMonitors));
	};
	if (_needRecreate) then {
		[[_monitor, _instId], true] call FUNC(setHandDisplay);
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
		if (IS_OBJ(_veh)) then {
			[_veh, true] call FUNC(monitorCloseMenu);
		};
		_plr setVariable ["CFM_selectedTablet", "hand"];
		[_plr] call FUNC(bringPipToTop);
	} else {
		[_plr, true] call FUNC(monitorCloseMenu);
		_plr setVariable ["CFM_selectedTablet", "veh"];
		if (IS_OBJ(_veh)) then {
			private _otherPair = [_plr] call FUNC(getOtherTabletMonitor);
			if (IS_VALID_MON(_otherPair)) then {
				[_otherPair] call FUNC(bringPipToTop);
			};
		};
	};
	true
};

CFUNC(switchPipSlot) = {
	params [["_monArg", GET_MON], ["_targetSlot", -1]];
	(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
	if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
	if !(MON_GVAR(_monitor, _instId, "CFM_isHandMonitor", false)) exitWith {false};
	private _slots = call FUNC(getPipSlotsSettings);
	private _slotsCount = count _slots;
	private _curSlot = MON_GVAR(_monitor, _instId, "CFM_pipSlot", PIP_SLOT_RIGHT);
	if (_targetSlot < 0) then {
		_targetSlot = (_curSlot + 1) mod _slotsCount;
	};
	MON_SVAR(_monitor, _instId, "CFM_pipSlot", _targetSlot);
	if !([[_monitor, _instId]] call FUNC(isPipVisible)) exitWith {true};

	private _needTopLayer = false;
	private _myLayer = MON_GVAR(_monitor, _instId, "CFM_currentRscLayer", -1);
	{
		if ([_x] call FUNC(isPipVisible)) then {
			_x params ["_otherMon", "_otherInstId"];
			private _otherSlot = MON_GVAR(_otherMon, _otherInstId, "CFM_pipSlot", PIP_SLOT_RIGHT);
			private _otherLayer = MON_GVAR(_otherMon, _otherInstId, "CFM_currentRscLayer", -1);
			if ((_targetSlot isEqualTo _otherSlot) && {(_myLayer isEqualType 0) && (_otherLayer isEqualType 0) && {_myLayer <= _otherLayer}}) exitWith {
				_needTopLayer = true;
			};
		};
	} forEach ([[_monitor, _instId]] call FUNC(getOtherPipMonitors));
	if (_needTopLayer) exitWith {
		[[_monitor, _instId], true] call FUNC(setHandDisplay);
		true
	};

	if !([[_monitor, _instId]] call FUNC(updatePipWindowPosition)) then {
		[[_monitor, _instId], true] call FUNC(setHandDisplay);
	};
	true
};

CFUNC(switchTabletMenuActionCondition) = {
	params ["_target", ["_instId", -1]];
	if !(call FUNC(hasDualTabletMenu)) exitWith {false};
	if (_instId >= 0 && {_instId != ([_target] call CFM_fnc_getSelectedMonitorInstance)}) exitWith {false};
	[_target, _instId] call FUNC(isSelectedTablet)
};

CFUNC(switchPipSlotActionCondition) = {
	params ["_target", ["_instId", -1], ["_targetSlot", -1]];
	RESOLVE_ACTION_INST
	HAND_MON_CONDITION
	IS_MONITOR_ON
	if !(MON_GVAR(_target, _instId, "CFM_feedActive", false)) exitWith {false};
	if !(MON_GVAR(_target, _instId, "CFM_isHandMonitor", false)) exitWith {false};
	if (missionNamespace getVariable ["CFM_isInPIPFullScreen", false]) exitWith {false};
	if (
		(MON_GVAR(_target, _instId, "CFM_isHandMonitorDisplay", false)) ||
		{MGVAR ["CFM_allHandMonitorsAreDisplays", false]}
	) exitWith {false};

	private _slotsCount = missionNamespace getVariable ["CFM_pipSlotsCount", PIP_SLOTS_COUNT];
	if (_slotsCount < 2) exitWith {false};

	if (_targetSlot < 0) exitWith {
		_slotsCount > 2
	};
	if (_slotsCount > 2) exitWith {false};

	private _curSlot = MON_GVAR(_target, _instId, "CFM_pipSlot", PIP_SLOT_RIGHT);
	!(_curSlot isEqualTo _targetSlot)
};

CFUNC(inVehicleTabletActionCondition) = {
	params ["_target", ["_instId", -1]];
	if !(IS_OBJ(_target)) exitWith {false};
	if (_instId > 0) then {
		if !(MON_GVAR(_target, _instId, "CFM_isVehSeatTablet", false)) exitWith {true};
		if !([_target, _instId] call FUNC(inVehicleTabletSeatCondition)) exitWith {false};
		[_target, _instId] call FUNC(isSelectedTablet)
	} else {
		if !(_target getVariable ["CFM_isVehSeatTablet", false]) exitWith {true};
		if !([_target] call FUNC(inVehicleTabletSeatCondition)) exitWith {false};
		[_target] call FUNC(isSelectedTablet)
	}
};

CFUNC(hasMonitorPasswordAccess) = {
	params ["_monitor", ["_instId", -1]];
	if (_monitor isEqualType []) then {
		_monitor params [["_obj", objNull], ["_id", -1]];
		_monitor = _obj;
		if (_instId < 0) then {_instId = _id};
	};
	if !(IS_OBJ(_monitor)) exitWith {false};
	if (_instId < 1) then {_instId = [_monitor] call FUNC(getSelectedMonitorInstance)};
	if (_instId < 1) exitWith {true};
	if !(MON_GVAR(_monitor, _instId, "CFM_canSetPassword", false)) exitWith {true};
	private _pass = MON_GVAR(_monitor, _instId, "CFM_password", "");
	if (_pass isEqualTo "") exitWith {true};
	if ((MGVAR ["CFM_debug", false]) || {PLAYER_IS_ADMIN && {(MGVAR ["CFM_adminHaveAccessToAllMonitors", false])}}) exitWith {true};
	private _accessList = MON_GVAR(_monitor, _instId, "CFM_passwordAccess", []);
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

// CONTINUOUS CAMERA MOVEMENT & ZOOM
CFUNC(ensureContinuousKeyUpEH) = {
	if ((missionNamespace getVariable ["CFM_contCamKeyUpEH", -1]) != -1) exitWith {};
	private _disp = findDisplay 46;
	if (isNull _disp) exitWith {};
	private _eh = _disp displayAddEventHandler ["KeyUp", {
		params ["_displayOrControl", "_key"];
		if (missionNamespace getVariable ["CFM_isContinuousMoving", false]) then {
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
		};
		if (missionNamespace getVariable ["CFM_isContinuousZooming", false]) then {
			private _heldZ = missionNamespace getVariable ["CFM_heldZoomDirs", [false, false]];
			private _infoZ = missionNamespace getVariable ["CFM_heldZoomKeyInfo", [[], []]];
			private _changedZ = false;
			{
				if (_x) then {
					private _kInfo = _infoZ param [_forEachIndex, []];
					if (_kInfo isNotEqualTo []) then {
						_kInfo params [["_dik", -1], ["_reqShift", false], ["_reqCtrl", false], ["_reqAlt", false]];
						if (
							(_key == _dik) ||
							{_reqShift && {_key in [42, 54]}} ||
							{_reqCtrl && {_key in [29, 157]}} ||
							{_reqAlt && {_key in [56, 184]}}
						) then {
							_heldZ set [_forEachIndex, false];
							_infoZ set [_forEachIndex, []];
							_changedZ = true;
						};
					};
				};
			} forEach _heldZ;
			if (_changedZ && {!(true in _heldZ)}) then {
				call CFM_fnc_stopContinuousZoom;
			};
		};
		false
	}];
	missionNamespace setVariable ["CFM_contCamKeyUpEH", _eh];
};

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

	call FUNC(ensureContinuousKeyUpEH);

	private _held = missionNamespace getVariable ["CFM_heldCameraMoveDirs", [false, false, false, false]];
	private _info = missionNamespace getVariable ["CFM_heldCameraMoveKeyInfo", [[], [], [], []]];

	if (_isDown) then {
		GET_MON params [["_monitor", objNull], ["_instId", -1]];
		if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
		if !([_monitor, _instId] call FUNC(canControlMonitorSeat)) exitWith {false};
		if !(MON_GVAR(_monitor, _instId, "CFM_currentCameraCanMove", false)) exitWith {false};
		private _camera = MON_GVAR(_monitor, _instId, "CFM_currentFeedCam", objNull);
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

	GET_MON params [["_monitor", objNull], ["_instId", -1]];
	if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {
		call FUNC(stopContinuousCameraMove);
	};
	if !([_monitor, _instId] call FUNC(canControlMonitorSeat)) exitWith {
		call FUNC(stopContinuousCameraMove);
	};

	private _canMove = MON_GVAR(_monitor, _instId, "CFM_currentCameraCanMove", false);
	if !(_canMove isEqualTo true) exitWith {
		call FUNC(stopContinuousCameraMove);
	};

	private _camera = MON_GVAR(_monitor, _instId, "CFM_currentFeedCam", objNull);
	private _operator = MON_GVAR(_monitor, _instId, "CFM_connectedOperator", objNull);
	if (!IS_OBJ(_camera) || {!IS_OBJ(_operator)}) exitWith {
		call FUNC(stopContinuousCameraMove);
	};

	private _turretIndex = MON_GVAR(_monitor, _instId, "CFM_currentTurret", [-1]);
	private _lastOp = missionNamespace getVariable ["CFM_contMoveLastOp", objNull];
	private _lastTurr = missionNamespace getVariable ["CFM_contMoveLastTurr", [-1]];
	if (IS_OBJ(_lastOp) && {(_lastOp isNotEqualTo _operator) || {_lastTurr isNotEqualTo _turretIndex}}) then {
		["syncContinuousMove", [_lastTurr], false] CALL_OBJCLASS("Operator", _lastOp);
	};
	missionNamespace setVariable ["CFM_contMoveLastOp", _operator];
	missionNamespace setVariable ["CFM_contMoveLastTurr", _turretIndex];

	private _currZoom = MON_GVAR(_monitor, _instId, "CFM_zoomFov", 1);
	if !(_currZoom isEqualType 1) then {
		_currZoom = _operator getVariable ["CFM_prevZoomLocalFov", getObjectFov _operator];
	};

	private _sensitivity = MGVAR ["CFM_cameraMoveSensitivity", 5];
	private _dt = diag_deltaTime min 0.1;
	// Continuous rotation speed in degrees/sec: sensitivity * 6 * zoomFov (at default sensitivity 5 -> 30 deg/s * zoomFov)
	private _baseStep = _sensitivity * 6 * _currZoom * _dt;
	if (_baseStep <= 0) exitWith {};

	private _movementRestrictions = MON_GVAR(_monitor, _instId, "CFM_currentCameraMoveRestrictions", [85 I 85 I 180 I 180]);
	private _currentCameraMoves = MON_GVAR(_monitor, _instId, "CFM_currentCameraMoves", [0 I 0 I 0 I 0]);

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

CFUNC(stopContinuousZoom) = {
	private _lastMonPair = missionNamespace getVariable ["CFM_contZoomLastMon", [objNull, -1]];
	_lastMonPair params [["_lastMon", objNull], ["_lastInstId", -1]];
	missionNamespace setVariable ["CFM_heldZoomDirs", [false, false]];
	missionNamespace setVariable ["CFM_heldZoomKeyInfo", [[], []]];
	missionNamespace setVariable ["CFM_isContinuousZooming", false];
	missionNamespace setVariable ["CFM_contZoomLastMon", [objNull, -1]];
	if (IS_OBJ(_lastMon) && {_lastInstId > 0}) then {
		["syncContinuousZoom", []] CALL_MON_INST(_lastMon, _lastInstId);
	};
};

CFUNC(handleContinuousZoom) = {
	params [["_dir", 0], ["_isDown", false], ["_keyArgs", []]];

	private _dirIdx = if (_dir > 0) then {0} else {if (_dir < 0) then {1} else {-1}};
	if (_dirIdx == -1) exitWith {false};

	call FUNC(ensureContinuousKeyUpEH);

	private _held = missionNamespace getVariable ["CFM_heldZoomDirs", [false, false]];
	private _info = missionNamespace getVariable ["CFM_heldZoomKeyInfo", [[], []]];

	if (_isDown) then {
		GET_MON params [["_monitor", objNull], ["_instId", -1]];
		if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
		if !([_monitor, _instId] call FUNC(canControlMonitorSeat)) exitWith {false};
		if !(MON_GVAR(_monitor, _instId, "CFM_feedActive", false)) exitWith {false};
		if (
			(MON_GVAR(_monitor, _instId, "CFM_currentOperatorIsDrone", false)) &&
			{!(MGVAR ["CFM_canChangeZoomOnDrones", true])}
		) exitWith {false};

		_held set [_dirIdx, true];
		if (_keyArgs isEqualType [] && {count _keyArgs >= 5}) then {
			_info set [_dirIdx, [_keyArgs select 1, _keyArgs select 2, _keyArgs select 3, _keyArgs select 4]];
		};
		missionNamespace setVariable ["CFM_heldZoomDirs", _held];
		missionNamespace setVariable ["CFM_heldZoomKeyInfo", _info];
		missionNamespace setVariable ["CFM_isContinuousZooming", true];
		true
	} else {
		_held set [_dirIdx, false];
		_info set [_dirIdx, []];
		missionNamespace setVariable ["CFM_heldZoomDirs", _held];
		missionNamespace setVariable ["CFM_heldZoomKeyInfo", _info];
		if !(true in _held) then {
			call CFM_fnc_stopContinuousZoom;
		};
		false
	};
};

CFUNC(updateContinuousZoom) = {
	if !(missionNamespace getVariable ["CFM_isContinuousZooming", false]) exitWith {};
	if !(MGVAR ["CFM_continuousCameraZoom", false]) exitWith {
		call FUNC(stopContinuousZoom);
	};
	if (dialog || {!isNull findDisplay 49}) exitWith {
		call FUNC(stopContinuousZoom);
	};

	private _held = missionNamespace getVariable ["CFM_heldZoomDirs", [false, false]];
	if !(true in _held) exitWith {
		call FUNC(stopContinuousZoom);
	};

	GET_MON params [["_monitor", objNull], ["_instId", -1]];
	if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {
		call FUNC(stopContinuousZoom);
	};
	if !([_monitor, _instId] call FUNC(canControlMonitorSeat)) exitWith {
		call FUNC(stopContinuousZoom);
	};
	if !(MON_GVAR(_monitor, _instId, "CFM_feedActive", false)) exitWith {
		call FUNC(stopContinuousZoom);
	};
	if (
		(MON_GVAR(_monitor, _instId, "CFM_currentOperatorIsDrone", false)) &&
		{!(MGVAR ["CFM_canChangeZoomOnDrones", true])}
	) exitWith {
		call FUNC(stopContinuousZoom);
	};

	private _lastMonPair = missionNamespace getVariable ["CFM_contZoomLastMon", [objNull, -1]];
	_lastMonPair params [["_lastMon", objNull], ["_lastInstId", -1]];
	if (IS_OBJ(_lastMon) && {_lastInstId > 0} && {(_lastMon isNotEqualTo _monitor) || {_lastInstId != _instId}}) then {
		["syncContinuousZoom", []] CALL_MON_INST(_lastMon, _lastInstId);
	};
	missionNamespace setVariable ["CFM_contZoomLastMon", [_monitor, _instId]];

	private _dir = 0;
	if (_held select 0) then { _dir = _dir + 1; };
	if (_held select 1) then { _dir = _dir - 1; };
	if (_dir == 0) exitWith {};

	private _curZoom = MON_GVAR(_monitor, _instId, "CFM_zoom", 1);
	if !(_curZoom isEqualType 1) then { _curZoom = 1; };
	private _zoomMax = MON_GVAR(_monitor, _instId, "CFM_zoomMax", 1);
	if ((_dir > 0) && {_curZoom >= _zoomMax}) exitWith {};
	if ((_dir < 0) && {_curZoom <= 1}) exitWith {};

	private _dt = diag_deltaTime min 0.1;
	private _zoomStep = _dir * 2.0 * _dt;

	[[_monitor, _instId], _zoomStep, -1, true] call FUNC(zoom);
};

{
	_x params ["_shortName", "_fullName"];
	private _fn = missionNamespace getVariable [_fullName, {}];
	missionNamespace setVariable [_shortName, _fn];
	uiNamespace setVariable [_shortName, _fn];
} forEach [
	["fnc_width", "CFM_fnc_width"],
	["fnc_height", "CFM_fnc_height"],
	["fnc_pixelW", "CFM_fnc_pixelW"],
	["fnc_pixelH", "CFM_fnc_pixelH"],
	["fnc_posX", "CFM_fnc_posX"],
	["fnc_posY", "CFM_fnc_posY"]
];

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
