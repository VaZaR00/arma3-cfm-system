PRIVATE GLOBAL SINGLETON_CLASS(MonitorHost)

	SET_SELF_VAR("_monitor");
	SET_VARS_PREFIX("");

	// -----------------------------------------------
	// Host-level object state (read directly via getVariable in hot paths)
	PRIVATE GLOBAL FIELD ["_isMonitorSet", false];
	PRIVATE GLOBAL FIELD ["_isVehSeatTablet", false];
	PRIVATE GLOBAL FIELD ["_isHandTablet", false];
	PRIVATE GLOBAL FIELD ["_monitorInstancesMap", createHashMap];
	PRIVATE GLOBAL FIELD ["_monitorInstanceKeysMap", createHashMap];

	PRIVATE LOCAL FIELD ["_selectedMonitorInstance", -1];
	PRIVATE LOCAL FIELD ["_monitorSelectionPositions", createHashMap];
	PRIVATE LOCAL FIELD ["_switchMonitorActionId", -1];
	PRIVATE LOCAL FIELD ["_allMainActions", []];
	PRIVATE LOCAL FIELD ["_actionsRadius", ACTION_RADIUS];
	PRIVATE LOCAL FIELD ["_targetInActionsConditions", "_target"];
	// -----------------------------------------------

	//----------- Internal -----------
	PRIVATE LOCAL METHOD("Init") {
		params [["_isHand", false]];
		if !(IS_OBJ(_monitor)) exitWith {false};

		if (isNil {_monitor getVariable "CFM_monitorInstancesMap"}) then {
			_monitorInstancesMap = createHashMap;
			_monitor setVariable ["CFM_monitorInstancesMap", _monitorInstancesMap];
		};
		if (isNil {_monitor getVariable "CFM_monitorInstanceKeysMap"}) then {
			_monitorInstanceKeysMap = createHashMap;
			_monitor setVariable ["CFM_monitorInstanceKeysMap", _monitorInstanceKeysMap];
		};
		if (isNil {_monitor getVariable "CFM_monitorSelectionPositions"}) then {
			_monitorSelectionPositions = createHashMap;
			_monitor setVariable ["CFM_monitorSelectionPositions", _monitorSelectionPositions];
		};

		_actionsRadius = [ACTION_RADIUS, -1] select _isHand;
		_targetInActionsConditions = ["_target", "_target call CFM_fnc_getPlayer"] select _isHand;
		SET_SELFVAR(_actionsRadius);
		SET_SELFVAR(_targetInActionsConditions);

		if (hasInterface && {!_isHand} && {_switchMonitorActionId < 0}) then {
			private _priority = (PLAYER_ getVariable ["CFM_currentActionsPriority", ACTIONS_PRIORITY]) + 0.6;
			_switchMonitorActionId = _monitor addAction [
				format ["<t color='#ffaa00'>%1</t>", CFM_STR_SWITCH_MONITOR],
				{
					params ["_target"];
					[_target] call CFM_fnc_switchMonitor;
				},
				[],
				_priority,
				true,
				false,
				"",
				format ["[%1] call CFM_fnc_switchMonitorActionCondition", _targetInActionsConditions],
				_actionsRadius
			];
			SET_SELFVAR(_switchMonitorActionId);
			["registerMainActions", [_switchMonitorActionId]] CALL_SELF;
		};

		_monitor setVariable ["CFM_isMonitorHostCreated", true];
		true
	};

	PUBLIC LE GA METHOD("registerMainActions") {
		private _saved = _monitor getVariable ["CFM_allMainActions", []];
		_saved append _this;
		_allMainActions = _saved;
		_monitor setVariable ["CFM_allMainActions", _saved];
		_saved
	};

	PRIVATE LOCAL METHOD("addInstances") {
		params [
			["_instanceSpecs", []],
			["_commonArgs", []],
			["_isLocal", false]
		];
		if (!(IS_OBJ(_monitor)) || {_instanceSpecs isEqualTo []}) exitWith {[]};

		private _createdIds = [];
		private _hasAnyHand = _monitor getVariable ["CFM_isHandTablet", false];
		private _hasAnyVehSeat = _monitor getVariable ["CFM_isVehSeatTablet", false];

		{
			_x params [
				["_texSel", NO_TEXTURE_SELECTION],
				["_seatKey", ""],
				["_isVehSeat", false],
				["_isHand", false]
			];

			private _instancesMap = _monitor getVariable ["CFM_monitorInstancesMap", createHashMap];
			private _keysMap = _monitor getVariable ["CFM_monitorInstanceKeysMap", createHashMap];

			private _duplicate = false;
			if (_isHand && {HAND_MONITOR_KEY in _instancesMap}) then {_duplicate = true};
			if (!_duplicate && {_texSel >= 0} && {_texSel in _instancesMap}) then {_duplicate = true};
			if (!_duplicate && {_isVehSeat} && {_texSel < 0}) then {
				private _seatExisting = _instancesMap getOrDefault [_seatKey, []];
				{
					private _entry = _keysMap getOrDefault [_x, []];
					if ((_entry param [0, NO_TEXTURE_SELECTION]) < 0) exitWith {_duplicate = true};
				} forEach _seatExisting;
			};

			if !(_duplicate) then {
				private _instRes = [_monitor, [[_texSel, _seatKey, _isVehSeat, _isHand], _commonArgs, _isLocal]] NEW_OBJINSTANCE("Monitor");
				_instRes params [["_instId", -1], ["_ok", false]];

				if ((_ok isEqualTo true) && {_instId > 0}) then {
					private _keyTuple = [_texSel, _seatKey, _isVehSeat, _isHand];

					// Always populate maps locally BEFORE CFM_isMonitorSet = true to prevent MP Init race
					[_monitor, "CFM_monitorInstanceKeysMap", _instId, _keyTuple, true] call CFM_fnc_hashSet;
					if (isServer && {!_isLocal}) then {
						[_monitor, "CFM_monitorInstanceKeysMap", _instId, _keyTuple, true, true, _monitor] call CFM_fnc_hashSetNet;
					};

					if (_isHand) then {
						[_monitor, "CFM_monitorInstancesMap", HAND_MONITOR_KEY, _instId, true] call CFM_fnc_hashSet;
						if (isServer && {!_isLocal}) then {
							[_monitor, "CFM_monitorInstancesMap", HAND_MONITOR_KEY, _instId, true, true, _monitor] call CFM_fnc_hashSetNet;
						};
						_hasAnyHand = true;
					};

					if (_texSel >= 0) then {
						[_monitor, "CFM_monitorInstancesMap", _texSel, _instId, true] call CFM_fnc_hashSet;
						if (isServer && {!_isLocal}) then {
							[_monitor, "CFM_monitorInstancesMap", _texSel, _instId, true, true, _monitor] call CFM_fnc_hashSetNet;
						};
					};

					if (_isVehSeat) then {
						private _seatArr = +((_monitor getVariable ["CFM_monitorInstancesMap", createHashMap]) getOrDefault [_seatKey, []]);
						_seatArr pushBackUnique _instId;
						[_monitor, "CFM_monitorInstancesMap", _seatKey, _seatArr, true] call CFM_fnc_hashSet;
						if (isServer && {!_isLocal}) then {
							[_monitor, "CFM_monitorInstancesMap", _seatKey, _seatArr, true, true, _monitor] call CFM_fnc_hashSetNet;
						};
						_hasAnyVehSeat = true;
					};

					_createdIds pushBack _instId;
				};
			};
		} forEach _instanceSpecs;

		if !(_createdIds isEqualTo []) then {
			_isHandTablet = _hasAnyHand;
			_isVehSeatTablet = _hasAnyVehSeat;
			_monitor setVariable ["CFM_isHandTablet", _isHandTablet];
			_monitor setVariable ["CFM_isVehSeatTablet", _isVehSeatTablet];
			if (isServer && {!_isLocal}) then {
				_monitor setVariable ["CFM_isHandTablet", _isHandTablet, true];
				_monitor setVariable ["CFM_isVehSeatTablet", _isVehSeatTablet, true];
			};

			_isMonitorSet = true;
			_monitor setVariable ["CFM_isMonitorSet", true];
			if (isServer && {!_isLocal}) then {
				_monitor setVariable ["CFM_isMonitorSet", true, true];
			};

			if (hasInterface) then {
				private _avail = [_monitor] call CFM_fnc_getAvailableMonitorInstances;
				if (_selectedMonitorInstance < 1 || {!(_selectedMonitorInstance in _avail)}) then {
					_selectedMonitorInstance = _avail param [0, _createdIds param [0, -1]];
					SET_SELFVAR(_selectedMonitorInstance);
				};
				if (_switchMonitorActionId >= 0 && {(count _avail) > 1}) then {
					private _curPos = ((_avail find _selectedMonitorInstance) max 0) + 1;
					_monitor setUserActionText [
						_switchMonitorActionId,
						format ["<t color='#ffaa00'>%1 (%2/%3)</t>", CFM_STR_SWITCH_MONITOR, _curPos, count _avail]
					];
				};
			};

			if (_isHandTablet && {hasInterface} && {!(_monitor getVariable ["CFM_uavCopyActionsLoop", false])}) then {
				_monitor setVariable ["CFM_uavCopyActionsLoop", true];
				_monitor spawn {
					private _plr = _this;
					while {alive _plr} do {
						sleep 1;
						if !(isPipEnabled) then {continue};
						private _unit = focusOn;
						if !(_unit isEqualTo _plr) then {
							private _unitIsSet = _unit getVariable ["CFM_actionsSet", false];
							if (_unitIsSet) exitWith {};
							if ((_unit getVariable ["CFM_isMonitorSet", false]) isEqualTo true) exitWith {
								_unit setVariable ["CFM_actionsSet", true];
							};
							if !((vehicle _unit) call CFM_fnc_isUAV) exitWith {
								_unit setVariable ["CFM_actionsSet", true];
							};
							[_plr, _unit] call CFM_fnc_copyMenuActionsToObj;
						};
					};
				};
			};

			["updateActionPriority"] CALL_CLASS("DbHandler");
		};

		_createdIds
	};

	PUBLIC LOCAL METHOD("switchMonitor") {
		params [["_targetInstId", -1]];
		if !(hasInterface) exitWith {-1};
		if !(IS_OBJ(_monitor)) exitWith {-1};

		private _available = [_monitor] call CFM_fnc_getAvailableMonitorInstances;
		if ((count _available) <= 1) exitWith {_available param [0, -1]};

		[_monitor, true] call CFM_fnc_monitorCloseMenu;

		private _nextInstId = if (_targetInstId in _available) then {
			_targetInstId
		} else {
			private _curIdx = _available find _selectedMonitorInstance;
			private _nextIdx = if (_curIdx < 0) then {0} else {(_curIdx + 1) mod (count _available)};
			_available select _nextIdx
		};

		_selectedMonitorInstance = _nextInstId;
		SET_SELFVAR(_selectedMonitorInstance);

		private _pos = (_available find _nextInstId) + 1;
		private _total = count _available;
		private _keysMap = _monitor getVariable ["CFM_monitorInstanceKeysMap", createHashMap];
		private _entry = _keysMap getOrDefault [_nextInstId, []];
		_entry params [["_texSel", NO_TEXTURE_SELECTION], ["_seatKey", ""], ["_isVehSeat", false]];

		private _label = if (_isVehSeat && {!(_seatKey isEqualTo "")}) then {
			if (_texSel >= 0) then {
				format ["%1 #%2", _seatKey, _texSel]
			} else {
				_seatKey
			}
		} else {
			format ["#%1", _nextInstId]
		};

		if (_switchMonitorActionId >= 0) then {
			_monitor setUserActionText [
				_switchMonitorActionId,
				format ["<t color='#ffaa00'>%1 (%2/%3)</t>", CFM_STR_SWITCH_MONITOR, _pos, _total]
			];
		};

		(format [CFM_STR_SWITCH_MONITOR_HINT, _label, _pos, _total]) _HINT;
		_nextInstId
	};

	PUBLIC LOCAL METHOD("onSeatChanged") {
		params [["_lastSeatKey", ""], ["_curSeatKey", ""]];
		if !(hasInterface) exitWith {false};
		if !(IS_OBJ(_monitor)) exitWith {false};

		[_monitor, true] call CFM_fnc_monitorCloseMenu;
		private _map = _monitor getVariable ["CFM_monitorInstancesMap", createHashMap];

		if (!(_lastSeatKey isEqualTo "") && {!(_lastSeatKey isEqualTo _curSeatKey)}) then {
			private _oldInsts = _map getOrDefault [_lastSeatKey, []];
			{
				["deactivateSeat"] CALL_MON_INST(_monitor, _x);
			} forEach _oldInsts;
		};

		if !(_curSeatKey isEqualTo "") then {
			private _newInsts = _map getOrDefault [_curSeatKey, []];
			{
				["activateSeat"] CALL_MON_INST(_monitor, _x);
			} forEach _newInsts;
		};

		private _avail = [_monitor] call CFM_fnc_getAvailableMonitorInstances;
		if !(_selectedMonitorInstance in _avail) then {
			_selectedMonitorInstance = _avail param [0, -1];
			SET_SELFVAR(_selectedMonitorInstance);
		};
		if (_switchMonitorActionId >= 0 && {(count _avail) > 1}) then {
			private _curPos = ((_avail find _selectedMonitorInstance) max 0) + 1;
			_monitor setUserActionText [
				_switchMonitorActionId,
				format ["<t color='#ffaa00'>%1 (%2/%3)</t>", CFM_STR_SWITCH_MONITOR, _curPos, count _avail]
			];
		};

		true
	};
CLASS_END
