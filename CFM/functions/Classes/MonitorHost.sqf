PRIVATE GLOBAL SINGLETON_CLASS(MonitorHost)

	SET_SELF_VAR("_monitor");
	SET_VARS_PREFIX("");

	// -----------------------------------------------
	// Host-level object state (read directly via getVariable in hot paths)
	PRIVATE GLOBAL FIELD ["_isMonitorSet", false];
	PRIVATE GLOBAL FIELD ["_isVehSeatTablet", false];
	PRIVATE GLOBAL FIELD ["_isHandTablet", false];
	PRIVATE GLOBAL FIELD ["_hasNonSeatMonitors", false];
	PRIVATE GLOBAL FIELD ["_monitorInstancesMap", createHashMap];
	PRIVATE GLOBAL FIELD ["_monitorInstanceKeysMap", createHashMap];

	PRIVATE LOCAL FIELD ["_selectedMonitorInstance", -1];
	PRIVATE LOCAL FIELD ["_monitorSelectionPositions", createHashMap];
	PRIVATE LOCAL FIELD ["_switchMonitorActionId", -1];
	PRIVATE LOCAL FIELD ["_menuActionId", -1];
	PRIVATE LOCAL FIELD ["_operatorInfoActionId", -1];
	PRIVATE LOCAL FIELD ["_allMainActions", []];
	PRIVATE LOCAL FIELD ["_actionsRadius", ACTION_RADIUS];
	PRIVATE LOCAL FIELD ["_actionsPriority", ACTIONS_PRIORITY];
	PRIVATE LOCAL FIELD ["_targetInActionsConditions", "_target"];
	PRIVATE LOCAL FIELD ["_isHand", false];
	PRIVATE LOCAL FIELD ["_priorityUpdated", false];
	PRIVATE LOCAL FIELD ["_baseActionsAdded", false];
	PRIVATE LOCAL FIELD ["_switchMenuActionAdded", false];
	PRIVATE LOCAL FIELD ["_handMonitorActionsAdded", false];
	PRIVATE LOCAL FIELD ["_zoomActionsAdded", false];
	PRIVATE LOCAL FIELD ["_connectDroneActionAdded", false];
	PRIVATE LOCAL FIELD ["_fixActionAdded", false];
	PRIVATE LOCAL FIELD ["_switchTurretActionAdded", false];
	PRIVATE LOCAL FIELD ["_turnOffLocalActionsAdded", false];
	PRIVATE LOCAL FIELD ["_switchNvgActionAdded", false];
	PRIVATE LOCAL FIELD ["_switchTiActionAdded", false];
	PRIVATE LOCAL FIELD ["_fullScreenActionsAdded", false];
	// -----------------------------------------------

	//----------- Internal -----------
	PRIVATE LOCAL METHOD("Init") {
		params [["_isHandArg", false]];
		if !(IS_OBJ(_monitor)) exitWith {false};

		_isHand = _isHandArg;
		SET_SELFVAR(_isHand);

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
		if (isNil {_monitor getVariable "CFM_monitorBaseInstIds"}) then {
			_monitor setVariable ["CFM_monitorBaseInstIds", createHashMap];
		};
		if (isNil {_monitor getVariable "CFM_rewrittenMonitorSeats"}) then {
			_monitor setVariable ["CFM_rewrittenMonitorSeats", createHashMap];
		};
		if (isNil {_monitor getVariable "CFM_rewrittenMonitorTexSels"}) then {
			_monitor setVariable ["CFM_rewrittenMonitorTexSels", createHashMap];
		};
		if (isNil {_monitor getVariable "CFM_removedMonitorSeats"}) then {
			_monitor setVariable ["CFM_removedMonitorSeats", createHashMap];
		};
		if (isNil {_monitor getVariable "CFM_removedMonitorTexSels"}) then {
			_monitor setVariable ["CFM_removedMonitorTexSels", createHashMap];
		};

		_actionsRadius = _monitor getVariable ["CFM_actionsRadius", [ACTION_RADIUS, -1] select _isHand];
		_targetInActionsConditions = ["_target", "_target call CFM_fnc_getPlayer"] select _isHand;
		_actionsPriority = PLAYER_ getVariable ["CFM_currentActionsPriority", ACTIONS_PRIORITY];
		SET_SELFVAR(_actionsRadius);
		SET_SELFVAR(_targetInActionsConditions);
		SET_SELFVAR(_actionsPriority);

		if (hasInterface && {!_isHand} && {_switchMonitorActionId < 0}) then {
			private _priority = _actionsPriority + 0.6;
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

	PUBLIC LOCAL METHOD("syncSelectedActionLabels") {
		params [["_targetInstId", -1], ["_explicitInfoText", nil]];
		if !(hasInterface) exitWith {};
		if !(IS_OBJ(_monitor)) exitWith {};
		if (_targetInstId < 1) exitWith {};

		private _useDevSeatKey = missionNamespace getVariable ["CFM_devShowSeatKeys", false];
		if (_menuActionId >= 0) then {
			private _defMenuLbl = format["<t color='#00FF00'>%1</t>", CFM_STR_CAMERA_SYSTEM_MENU];
			private _lblVar = ["CFM_menuActionLabel", "CFM_menuActionLabelDev"] select _useDevSeatKey;
			private _menuLbl = MON_GVAR(_monitor, _targetInstId, _lblVar, _defMenuLbl);
			_monitor setUserActionText [_menuActionId, _menuLbl];
		};
		if (_operatorInfoActionId >= 0) then {
			private _infoText = if !(isNil "_explicitInfoText") then {
				_explicitInfoText
			} else {
				MON_GVAR(_monitor, _targetInstId, "CFM_operatorInfoText", OPERATOR_INFO_TEXT_DEF)
			};
			_monitor setUserActionText [_operatorInfoActionId, _infoText];
		};
		_monitor setVariable ["CFM_lastUiSyncedInst", _targetInstId];
		_monitor setVariable ["CFM_lastUiDevSeatKeys", _useDevSeatKey];
	};

	PUBLIC LOCAL METHOD("ensureHostActions") {
		params [
			["_hasAnyHand", false],
			["_hasAnyVehSeat", false],
			["_hasAnyHandMon", false],
			["_hasAnyNonHandMon", false],
			["_canZoom", true],
			["_canConnectDrone", true],
			["_canFix", true],
			["_canSwitchTurret", true],
			["_canTurnOffLocal", true],
			["_canSwitchNvg", true],
			["_canSwitchTi", true],
			["_canFullScreen", true]
		];
		if !(hasInterface) exitWith {};
		if !(IS_OBJ(_monitor)) exitWith {};

		private _actions = [];
		private _target = _targetInActionsConditions;
		private _priority = _actionsPriority;
		private _radius = _monitor getVariable ["CFM_actionsRadius", _actionsRadius];

		if !(_baseActionsAdded) then {
			_baseActionsAdded = true;
			SET_SELFVAR(_baseActionsAdded);

			private _actionCheckNewOps = _monitor addAction [format["<t color='#45d9b9'>%1</t>", CFM_STR_CHECK_FOR_NEW_OPERATORS], {
				params ["_target", "_caller", "_", "_p"];
				_p params ["_mon"];
				private _instId = [_mon] call CFM_fnc_getSelectedMonitorInstance;
				if (_instId < 1) exitWith {};
				STR_CHECK_FOR_NEW_OPS_ACT _HINT;
				[[_mon, _instId]] call CFM_fnc_checkForNewOperators;
			}, [_monitor], _priority - 1, true, false, "", format["[%1] call CFM_fnc_checkNewOpsActionCondition", _target], _radius];

			private _actionSetPassword = _monitor addAction [format["<t color='#e6c300'>%1</t>", CFM_STR_SET_PASSWORD], {
				params ["_target", "_caller", "_", "_p"];
				_p params ["_mon"];
				private _instId = [_mon] call CFM_fnc_getSelectedMonitorInstance;
				if (_instId < 1) exitWith {};
				[[_mon, _instId], "set", _caller, _target] call CFM_fnc_openPasswordDialog;
			}, [_monitor], _priority - 1, true, false, "", format["[%1] call CFM_fnc_setPasswordActionCondition", _target], _radius];

			private _actionChangePassword = _monitor addAction [format["<t color='#e6c300'>%1</t>", CFM_STR_CHANGE_PASSWORD], {
				params ["_target", "_caller", "_", "_p"];
				_p params ["_mon"];
				private _instId = [_mon] call CFM_fnc_getSelectedMonitorInstance;
				if (_instId < 1) exitWith {};
				[[_mon, _instId], "change", _caller, _target] call CFM_fnc_openPasswordDialog;
			}, [_monitor], _priority - 1, true, false, "", format["[%1] call CFM_fnc_changePasswordActionCondition", _target], _radius];

			_menuActionId = _monitor addAction [format["<t color='#00FF00'>%1</t>", CFM_STR_CAMERA_SYSTEM_MENU], {
				params ["_target", "_caller", "_", "_p"];
				_p params ["_mon"];
				private _instId = [_mon] call CFM_fnc_getSelectedMonitorInstance;
				if (_instId < 1) exitWith {};
				["loadMenu", [_caller, _target]] CALL_MON_INST(_mon, _instId);
			}, [_monitor], _priority, true, false, "", format["[%1] call CFM_fnc_menuActionCondition", _target], _radius];
			SET_SELFVAR(_menuActionId);

			private _actionDisc = _monitor addAction [format["<t color='#FF0000'>%1</t>", CFM_STR_DISCONNECT_CAMERA], {
				params ["_target", "_caller", "_", "_p"];
				_p params ["_mon"];
				private _instId = [_mon] call CFM_fnc_getSelectedMonitorInstance;
				if (_instId < 1) exitWith {};
				[[_mon, _instId], _caller] call CFM_fnc_disconnectMonitorFromOperator;
			}, [_monitor], _priority, true, false, "", format["[%1] call CFM_fnc_disconnectActionCondition", _target], _radius];

			_operatorInfoActionId = _monitor addAction [OPERATOR_INFO_TEXT_DEF, {
				(_this#3) params ["_mon"];
				private _instId = [_mon] call CFM_fnc_getSelectedMonitorInstance;
				if (_instId < 1) exitWith {};
				[[_mon, _instId]] call CFM_fnc_getOperatorInfo;
			}, [_monitor], _priority + 1, true, false, "", format["[%1] call CFM_fnc_operatorInfoActionCondition", _target], _radius];
			SET_SELFVAR(_operatorInfoActionId);

			_actions append [_actionCheckNewOps, _actionSetPassword, _actionChangePassword, _menuActionId, _actionDisc, _operatorInfoActionId];
		};

		if (!_switchMenuActionAdded && {_hasAnyHand || _hasAnyVehSeat}) then {
			_switchMenuActionAdded = true;
			SET_SELFVAR(_switchMenuActionAdded);
			private _isVehMode = _hasAnyVehSeat && {!_isHand};
			private _switchMenuText = [CFM_STR_SWITCH_MENU_SEAT_TABLET, CFM_STR_SWITCH_MENU_HAND_TABLET] select _isVehMode;
			private _switchTargetMode = ["veh", "hand"] select _isVehMode;
			private _actionSwitchMenu = _monitor addAction [format["<t color='#00e5ff'>%1</t>", _switchMenuText], {
				params ["_target", "_caller", "_", "_p"];
				_p params ["", "_mode"];
				[_mode] call CFM_fnc_switchTabletMenu;
			}, [_monitor, _switchTargetMode], _priority + 0.5, true, false, "", format["[%1] call CFM_fnc_switchTabletMenuActionCondition", _target], _radius];
			_actions pushBack _actionSwitchMenu;
		};

		if (!_handMonitorActionsAdded && {_hasAnyHandMon}) then {
			_handMonitorActionsAdded = true;
			SET_SELFVAR(_handMonitorActionsAdded);

			private _actionWatch = _monitor addAction [format["<t color='#0000FF'>%1</t>", CFM_STR_WATCH_TABLET], {
				params ["_target", "_caller", "_", "_p"];
				_p params ["_mon"];
				private _instId = [_mon] call CFM_fnc_getSelectedMonitorInstance;
				if (_instId < 1) exitWith {};
				[[_mon, _instId]] call CFM_fnc_turnOnMonitorLocal;
			}, [_monitor], _priority, true, false, "", format["[%1] call CFM_fnc_watchTabletActionCondition", _target], _radius];

			private _actionStopWatch = _monitor addAction [format["<t color='#FF3344'>%1</t>", CFM_STR_STOP_WATCHING_TABLET], {
				params ["_target", "_caller", "_", "_p"];
				_p params ["_mon"];
				private _instId = [_mon] call CFM_fnc_getSelectedMonitorInstance;
				if (_instId < 1) exitWith {};
				[[_mon, _instId]] call CFM_fnc_turnOffMonitorLocal;
			}, [_monitor], _priority, true, false, "", format["[%1] call CFM_fnc_stopWatchTabletActionCondition", _target], _radius];

			private _actionPipLeft = _monitor addAction [format["<t color='#20b2aa'>%1</t>", CFM_STR_PIP_TO_LEFT], {
				params ["_target", "_caller", "_", "_p"];
				_p params ["_mon"];
				private _instId = [_mon] call CFM_fnc_getSelectedMonitorInstance;
				if (_instId < 1) exitWith {};
				[[_mon, _instId], PIP_SLOT_LEFT] call CFM_fnc_switchPipSlot;
			}, [_monitor], _priority, true, false, "", format["[%1, -1, %2] call CFM_fnc_switchPipSlotActionCondition", _target, PIP_SLOT_LEFT], _radius];

			private _actionPipRight = _monitor addAction [format["<t color='#20b2aa'>%1</t>", CFM_STR_PIP_TO_RIGHT], {
				params ["_target", "_caller", "_", "_p"];
				_p params ["_mon"];
				private _instId = [_mon] call CFM_fnc_getSelectedMonitorInstance;
				if (_instId < 1) exitWith {};
				[[_mon, _instId], PIP_SLOT_RIGHT] call CFM_fnc_switchPipSlot;
			}, [_monitor], _priority, true, false, "", format["[%1, -1, %2] call CFM_fnc_switchPipSlotActionCondition", _target, PIP_SLOT_RIGHT], _radius];

			private _actionPipNextSlot = _monitor addAction [format["<t color='#20b2aa'>%1</t>", CFM_STR_PIP_NEXT_SLOT], {
				params ["_target", "_caller", "_", "_p"];
				_p params ["_mon"];
				private _instId = [_mon] call CFM_fnc_getSelectedMonitorInstance;
				if (_instId < 1) exitWith {};
				[[_mon, _instId], -1] call CFM_fnc_switchPipSlot;
			}, [_monitor], _priority, true, false, "", format["[%1, -1, -1] call CFM_fnc_switchPipSlotActionCondition", _target], _radius];

			private _actionSwitchDrones = _monitor addAction [format["<t color='#c31cff'>%1</t>", CFM_STR_SWITCH_UAV], {
				params ["_target", "_caller", "_", "_p"];
				_p params ["_mon"];
				private _instId = [_mon] call CFM_fnc_getSelectedMonitorInstance;
				if (_instId < 1) exitWith {};
				[[_mon, _instId]] call CFM_fnc_switchUAV;
			}, [_monitor], _priority, true, false, "", format["[%1] call CFM_fnc_switchUAVActionCondition", _target], _radius];

			_actions append [_actionWatch, _actionStopWatch, _actionPipLeft, _actionPipRight, _actionPipNextSlot, _actionSwitchDrones];
		};

		if (!_zoomActionsAdded && {_canZoom}) then {
			_zoomActionsAdded = true;
			SET_SELFVAR(_zoomActionsAdded);

			private _actionZoomIn = _monitor addAction [format["<t color='#c5dafa'>%1</t>", CFM_STR_ZOOM_IN], {
				(_this#3) params ["_mon"];
				private _instId = [_mon] call CFM_fnc_getSelectedMonitorInstance;
				if (_instId < 1) exitWith {};
				[[_mon, _instId], +1] call CFM_fnc_zoom;
			}, [_monitor], _priority, true, false, "", format["[%1] call CFM_fnc_zoomInActionCondition", _target], _radius];

			private _actionZoomOut = _monitor addAction [format["<t color='#c5dafa'>%1</t>", CFM_STR_ZOOM_OUT], {
				(_this#3) params ["_mon"];
				private _instId = [_mon] call CFM_fnc_getSelectedMonitorInstance;
				if (_instId < 1) exitWith {};
				[[_mon, _instId], -1] call CFM_fnc_zoom;
			}, [_monitor], _priority, true, false, "", format["[%1] call CFM_fnc_zoomActionsCondition", _target], _radius];

			private _actionZoomDefault = _monitor addAction [format["<t color='#45d9b9'>%1</t>", CFM_STR_RESET_ZOOM], {
				(_this#3) params ["_mon"];
				private _instId = [_mon] call CFM_fnc_getSelectedMonitorInstance;
				if (_instId < 1) exitWith {};
				[[_mon, _instId], "reset"] call CFM_fnc_zoom;
			}, [_monitor], _priority, true, false, "", format["[%1] call CFM_fnc_zoomActionsCondition", _target], _radius];

			private _actionZoomByDrone = _monitor addAction [format["<t color='#90c73e'>%1</t>", CFM_STR_USE_OPERATOR_ZOOM], {
				(_this#3) params ["_mon"];
				private _instId = [_mon] call CFM_fnc_getSelectedMonitorInstance;
				if (_instId < 1) exitWith {};
				[[_mon, _instId], "op"] call CFM_fnc_zoom;
			}, [_monitor], _priority, true, false, "", format["[%1] call CFM_fnc_operatorZoomActionsCondition", _target], _radius];

			_actions append [_actionZoomIn, _actionZoomOut, _actionZoomDefault, _actionZoomByDrone];
		};

		if (!_connectDroneActionAdded && {_canConnectDrone}) then {
			_connectDroneActionAdded = true;
			SET_SELFVAR(_connectDroneActionAdded);

			private _connectDroneAction = _monitor addAction [format["<t color='#1c399e'>%1</t>", CFM_STR_TAKE_UAV_CONTROL], {
				(_this#3) params ["_mon"];
				private _instId = [_mon] call CFM_fnc_getSelectedMonitorInstance;
				if (_instId < 1) exitWith {};
				[[_mon, _instId]] spawn CFM_fnc_takeUAVcontorls;
			}, [_monitor], _priority, true, false, "", format["[%1] call CFM_fnc_connectDroneActionCondition", _target], _radius];
			_actions pushBack _connectDroneAction;
		};

		if (!_fixActionAdded && {_canFix}) then {
			_fixActionAdded = true;
			SET_SELFVAR(_fixActionAdded);

			private _actionFix = _monitor addAction [format["<t color='#690707'>%1</t>", CFM_STR_RESET_FIX_FEED_LOCAL], {
				(_this#3) params ["_mon"];
				private _instId = [_mon] call CFM_fnc_getSelectedMonitorInstance;
				if (_instId < 1) exitWith {};
				[[_mon, _instId]] call CFM_fnc_fixFeed;
			}, [_monitor], _priority, true, false, "", format["[%1] call CFM_fnc_fixFeedActionCondition", _target], _radius];
			_actions pushBack _actionFix;
		};

		if (!_switchTurretActionAdded && {_canSwitchTurret}) then {
			_switchTurretActionAdded = true;
			SET_SELFVAR(_switchTurretActionAdded);

			private _actionSwitchCamera = _monitor addAction [format["<t color='#ffba4a'>%1</t>", CFM_STR_SWITCH_CAMERA], {
				(_this#3) params ["_mon"];
				private _instId = [_mon] call CFM_fnc_getSelectedMonitorInstance;
				if (_instId < 1) exitWith {};
				[[_mon, _instId]] call CFM_fnc_monitorNextTurretCamera;
			}, [_monitor], _priority, true, false, "", format["[%1] call CFM_fnc_switchCameraTurretActionCondition", _target], _radius];
			_actions pushBack _actionSwitchCamera;
		};

		if (!_turnOffLocalActionsAdded && {_canTurnOffLocal && _hasAnyNonHandMon}) then {
			_turnOffLocalActionsAdded = true;
			SET_SELFVAR(_turnOffLocalActionsAdded);

			private _actionTurnOffLocal = _monitor addAction [format["<t color='#8a3200'>%1</t>", CFM_STR_TURN_OFF_FEED_LOCAL], {
				(_this#3) params ["_mon"];
				private _instId = [_mon] call CFM_fnc_getSelectedMonitorInstance;
				if (_instId < 1) exitWith {};
				[[_mon, _instId]] call CFM_fnc_turnOffMonitorLocal;
			}, [_monitor], _priority, true, false, "", format["[%1] call CFM_fnc_turnOffActionCondition", _target], _radius];

			private _actionTurnOnLocal = _monitor addAction [format["<t color='#036900'>%1</t>", CFM_STR_TURN_ON_FEED_LOCAL], {
				(_this#3) params ["_mon"];
				private _instId = [_mon] call CFM_fnc_getSelectedMonitorInstance;
				if (_instId < 1) exitWith {};
				[[_mon, _instId]] call CFM_fnc_turnOnMonitorLocal;
			}, [_monitor], _priority, true, false, "", format["[%1] call CFM_fnc_turnOnActionCondition", _target], _radius];

			_actions append [_actionTurnOffLocal, _actionTurnOnLocal];
		};

		if (!_switchNvgActionAdded && {_canSwitchNvg}) then {
			_switchNvgActionAdded = true;
			SET_SELFVAR(_switchNvgActionAdded);

			private _actionSwitchNvg = _monitor addAction [format["<t color='#006e02'>%1</t>", CFM_STR_TOGGLE_NVG], {
				(_this#3) params ["_mon"];
				private _instId = [_mon] call CFM_fnc_getSelectedMonitorInstance;
				if (_instId < 1) exitWith {};
				[[_mon, _instId]] call CFM_fnc_monitorToggleNVG;
			}, [_monitor], _priority, true, false, "", format["[%1] call CFM_fnc_toggleNvgActionCondition", _target], _radius];
			_actions pushBack _actionSwitchNvg;
		};

		if (!_switchTiActionAdded && {_canSwitchTi}) then {
			_switchTiActionAdded = true;
			SET_SELFVAR(_switchTiActionAdded);

			private _actionSwitchTi = _monitor addAction [format["<t color='#525252'>%1</t>", CFM_STR_TOGGLE_TI], {
				(_this#3) params ["_mon"];
				private _instId = [_mon] call CFM_fnc_getSelectedMonitorInstance;
				if (_instId < 1) exitWith {};
				[[_mon, _instId]] call CFM_fnc_monitorSwitchTi;
			}, [_monitor], _priority, true, false, "", format["[%1] call CFM_fnc_toggleTiActionCondition", _target], _radius];
			_actions pushBack _actionSwitchTi;
		};

		if (!_fullScreenActionsAdded && {_canFullScreen}) then {
			_fullScreenActionsAdded = true;
			SET_SELFVAR(_fullScreenActionsAdded);

			private _actionEnterFullScreen = _monitor addAction [format["<t color='#67bce0'>%1</t>", CFM_STR_ENTER_FULLSCREEN], {
				(_this#3) params ["_mon"];
				private _instId = [_mon] call CFM_fnc_getSelectedMonitorInstance;
				if (_instId < 1) exitWith {};
				[[_mon, _instId]] call CFM_fnc_enterMonitorFullScreen;
			}, [_monitor], _priority, true, false, "", format["[%1] call CFM_fnc_enterFullScreenActionCondition", _target], _radius];

			private _actionExitFullScreen = _monitor addAction ["<t color='#67bce0'>Exit Fullscreen</t>", {
				(_this#3) params ["_mon"];
				private _instId = [_mon] call CFM_fnc_getSelectedMonitorInstance;
				if (_instId < 1) exitWith {};
				[[_mon, _instId]] call CFM_fnc_exitMonitorFullScreen;
			}, [_monitor], _priority, true, false, "", format["[%1] call CFM_fnc_exitFullScreenActionCondition", _target], _radius];

			_actions append [_actionEnterFullScreen, _actionExitFullScreen];
		};

		if !(_actions isEqualTo []) then {
			["registerMainActions", _actions] CALL_SELF;
		};
	};

	PRIVATE LOCAL METHOD("createMonitorInstance") {
		params [
			["_keyTuple", []],
			["_commonArgs", []],
			["_isLocal", false],
			["_isMultiMonitor", false]
		];
		if !(IS_OBJ(_monitor)) exitWith {-1};
		_keyTuple params [
			["_texSel", NO_TEXTURE_SELECTION],
			["_seatKey", ""],
			["_isVehSeat", false],
			["_isHand", false],
			["_seatKeys", []],
			["_controlSeatKeys", []]
		];
		if (_seatKeys isEqualTo [] && {!(_seatKey isEqualTo "")}) then {
			_seatKeys = [_seatKey];
		};
		private _cleanKeyTuple = [_texSel, _seatKey, _isVehSeat, _isHand, _seatKeys, _controlSeatKeys];

		private _instRes = [_monitor, [_cleanKeyTuple, _commonArgs, _isLocal, _isMultiMonitor]] NEW_OBJINSTANCE("Monitor");
		_instRes params [["_instId", -1], ["_ok", false]];
		if !((_ok isEqualTo true) && {_instId > 0}) exitWith {-1};

		// Always populate maps locally BEFORE CFM_isMonitorSet = true to prevent MP Init race
		[_monitor, "CFM_monitorInstanceKeysMap", _instId, _cleanKeyTuple, false] call CFM_fnc_hashSet;
		if (isServer && {!_isLocal}) then {
			[_monitor, "CFM_monitorInstanceKeysMap", _instId, _cleanKeyTuple, false, true, _monitor] call CFM_fnc_hashSetNet;
		};

		if (_isHand) then {
			[_monitor, "CFM_monitorInstancesMap", HAND_MONITOR_KEY, _instId, false] call CFM_fnc_hashSet;
			if (isServer && {!_isLocal}) then {
				[_monitor, "CFM_monitorInstancesMap", HAND_MONITOR_KEY, _instId, false, true, _monitor] call CFM_fnc_hashSetNet;
			};
		};

		if (_texSel >= 0) then {
			[_monitor, "CFM_monitorInstancesMap", _texSel, _instId, false] call CFM_fnc_hashSet;
			if (isServer && {!_isLocal}) then {
				[_monitor, "CFM_monitorInstancesMap", _texSel, _instId, false, true, _monitor] call CFM_fnc_hashSetNet;
			};
		};

		if (_isVehSeat) then {
			private _regSeats = if (_seatKeys isNotEqualTo []) then {_seatKeys} else {[_seatKey]};
			{
				private _sk = _x;
				private _seatArr = +((_monitor getVariable ["CFM_monitorInstancesMap", createHashMap]) getOrDefault [_sk, []]);
				_seatArr pushBackUnique _instId;
				[_monitor, "CFM_monitorInstancesMap", _sk, _seatArr, false] call CFM_fnc_hashSet;
				if (isServer && {!_isLocal}) then {
					[_monitor, "CFM_monitorInstancesMap", _sk, _seatArr, false, true, _monitor] call CFM_fnc_hashSetNet;
				};
			} forEach _regSeats;
		};

		_instId
	};

	PRIVATE LOCAL METHOD("removeInstance") {
		params [["_instId", -1]];
		if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};

		private _keysMap = _monitor getVariable ["CFM_monitorInstanceKeysMap", createHashMap];
		private _entry = _keysMap getOrDefault [_instId, []];
		if (_entry isEqualTo []) exitWith {false};

		_entry params [
			["_texSel", NO_TEXTURE_SELECTION],
			["_seatKey", ""],
			["_isVehSeat", false],
			["_isHand", false],
			["_seatKeys", []]
		];
		if (_seatKeys isEqualTo [] && {!(_seatKey isEqualTo "")}) then {
			_seatKeys = [_seatKey];
		};

		private _isLocalInst = MON_GVAR(_monitor, _instId, "CFM_isLocal", _isHand);
		["deinit"] CALL_MON_INST(_monitor, _instId);

		[_monitor, "CFM_monitorInstanceKeysMap", _instId, false] call CFM_fnc_deleteAt;
		if (isServer && {!_isLocalInst}) then {
			[_monitor, "CFM_monitorInstanceKeysMap", _instId, false, true, _monitor] call CFM_fnc_deleteAtNet;
		};

		private _instancesMap = _monitor getVariable ["CFM_monitorInstancesMap", createHashMap];
		if (_isHand && {(_instancesMap getOrDefault [HAND_MONITOR_KEY, -1]) isEqualTo _instId}) then {
			[_monitor, "CFM_monitorInstancesMap", HAND_MONITOR_KEY, false] call CFM_fnc_deleteAt;
			if (isServer && {!_isLocalInst}) then {
				[_monitor, "CFM_monitorInstancesMap", HAND_MONITOR_KEY, false, true, _monitor] call CFM_fnc_deleteAtNet;
			};
		};
		if (_texSel >= 0 && {(_instancesMap getOrDefault [_texSel, -1]) isEqualTo _instId}) then {
			[_monitor, "CFM_monitorInstancesMap", _texSel, false] call CFM_fnc_deleteAt;
			if (isServer && {!_isLocalInst}) then {
				[_monitor, "CFM_monitorInstancesMap", _texSel, false, true, _monitor] call CFM_fnc_deleteAtNet;
			};
		};
		if (_isVehSeat) then {
			{
				private _sk = _x;
				private _seatArr = +((_monitor getVariable ["CFM_monitorInstancesMap", createHashMap]) getOrDefault [_sk, []]);
				if (_instId in _seatArr) then {
					_seatArr = _seatArr - [_instId];
					if (_seatArr isEqualTo []) then {
						[_monitor, "CFM_monitorInstancesMap", _sk, false] call CFM_fnc_deleteAt;
						if (isServer && {!_isLocalInst}) then {
							[_monitor, "CFM_monitorInstancesMap", _sk, false, true, _monitor] call CFM_fnc_deleteAtNet;
						};
					} else {
						[_monitor, "CFM_monitorInstancesMap", _sk, _seatArr, false] call CFM_fnc_hashSet;
						if (isServer && {!_isLocalInst}) then {
							[_monitor, "CFM_monitorInstancesMap", _sk, _seatArr, false, true, _monitor] call CFM_fnc_hashSetNet;
						};
					};
				};
			} forEach _seatKeys;
		};

		private _baseInstIds = _monitor getVariable ["CFM_monitorBaseInstIds", createHashMap];
		_baseInstIds deleteAt _instId;
		_monitor setVariable ["CFM_monitorBaseInstIds", _baseInstIds];

		true
	};

	PRIVATE LOCAL METHOD("detachSeatsFromInstance") {
		params [["_instId", -1], ["_detachSeats", []]];
		if (!(IS_OBJ(_monitor)) || {_instId < 1} || {_detachSeats isEqualTo []}) exitWith {false};

		private _keysMap = _monitor getVariable ["CFM_monitorInstanceKeysMap", createHashMap];
		private _entry = _keysMap getOrDefault [_instId, []];
		if (_entry isEqualTo []) exitWith {false};

		_entry params [
			["_eTexSel", NO_TEXTURE_SELECTION],
			["_eSeatKey", ""],
			["_eIsVehSeat", false],
			["_eIsHand", false],
			["_eSeatKeys", []],
			["_eControlSeatKeys", []]
		];
		if (_eSeatKeys isEqualTo [] && {!(_eSeatKey isEqualTo "")}) then {
			_eSeatKeys = [_eSeatKey];
		};

		private _keptSeats = _eSeatKeys select {!(_x in _detachSeats)};
		if ((count _keptSeats) == (count _eSeatKeys)) exitWith {false};
		if (_keptSeats isEqualTo []) exitWith {
			["removeInstance", [_instId]] CALL_SELF
		};

		private _isLocalInst = MON_GVAR(_monitor, _instId, "CFM_isLocal", _eIsHand);
		{
			private _sk = _x;
			private _seatArr = +((_monitor getVariable ["CFM_monitorInstancesMap", createHashMap]) getOrDefault [_sk, []]);
			if (_instId in _seatArr) then {
				_seatArr = _seatArr - [_instId];
				if (_seatArr isEqualTo []) then {
					[_monitor, "CFM_monitorInstancesMap", _sk, false] call CFM_fnc_deleteAt;
					if (isServer && {!_isLocalInst}) then {
						[_monitor, "CFM_monitorInstancesMap", _sk, false, true, _monitor] call CFM_fnc_deleteAtNet;
					};
				} else {
					[_monitor, "CFM_monitorInstancesMap", _sk, _seatArr, false] call CFM_fnc_hashSet;
					if (isServer && {!_isLocalInst}) then {
						[_monitor, "CFM_monitorInstancesMap", _sk, _seatArr, false, true, _monitor] call CFM_fnc_hashSetNet;
					};
				};
			};
		} forEach (_eSeatKeys - _keptSeats);

		private _newSeatKey = _keptSeats joinString ", ";
		private _newCtrlKeys = if (_eControlSeatKeys isEqualTo [] || {_eControlSeatKeys isEqualTo ["__NO_CONTROLLER__"]}) then {
			_eControlSeatKeys
		} else {
			private _c = _eControlSeatKeys select {_x in _keptSeats};
			if (_c isEqualTo []) then {["__NO_CONTROLLER__"]} else {_c}
		};
		private _newEntry = [_eTexSel, _newSeatKey, _eIsVehSeat, _eIsHand, _keptSeats, _newCtrlKeys];
		[_monitor, "CFM_monitorInstanceKeysMap", _instId, _newEntry, false] call CFM_fnc_hashSet;
		if (isServer && {!_isLocalInst}) then {
			[_monitor, "CFM_monitorInstanceKeysMap", _instId, _newEntry, false, true, _monitor] call CFM_fnc_hashSetNet;
		};

		["updateSharedSeats", [_keptSeats, _newCtrlKeys]] CALL_MON_INST(_monitor, _instId);

		private _baseInstIds = _monitor getVariable ["CFM_monitorBaseInstIds", createHashMap];
		_baseInstIds deleteAt _instId;
		_monitor setVariable ["CFM_monitorBaseInstIds", _baseInstIds];

		true
	};

	PRIVATE LOCAL METHOD("reconfigureInstance") {
		params [
			["_instId", -1],
			["_newKeyTuple", []],
			["_commonArgs", []],
			["_isLocal", false],
			["_isMultiMonitor", false]
		];
		if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};

		private _keysMap = _monitor getVariable ["CFM_monitorInstanceKeysMap", createHashMap];
		private _oldEntry = _keysMap getOrDefault [_instId, []];
		_oldEntry params [
			["_oldTexSel", NO_TEXTURE_SELECTION],
			["_oldSeatKey", ""],
			["_oldIsVehSeat", false],
			["_oldIsHand", false],
			["_oldSeatKeys", []]
		];
		if (_oldSeatKeys isEqualTo [] && {!(_oldSeatKey isEqualTo "")}) then {
			_oldSeatKeys = [_oldSeatKey];
		};

		_newKeyTuple params [
			["_texSel", NO_TEXTURE_SELECTION],
			["_seatKey", ""],
			["_isVehSeat", false],
			["_isHand", false],
			["_seatKeys", []],
			["_controlSeatKeys", []]
		];
		if (_seatKeys isEqualTo [] && {!(_seatKey isEqualTo "")}) then {
			_seatKeys = [_seatKey];
		};
		private _cleanKeyTuple = [_texSel, _seatKey, _isVehSeat, _isHand, _seatKeys, _controlSeatKeys];

		private _ok = ["Init", [_cleanKeyTuple, _commonArgs, _isLocal, _isMultiMonitor]] CALL_MON_INST(_monitor, _instId);
		if !(_ok isEqualTo true) exitWith {false};

		private _instancesMap = _monitor getVariable ["CFM_monitorInstancesMap", createHashMap];
		if (_oldIsHand && {!_isHand} && {(_instancesMap getOrDefault [HAND_MONITOR_KEY, -1]) isEqualTo _instId}) then {
			[_monitor, "CFM_monitorInstancesMap", HAND_MONITOR_KEY, false] call CFM_fnc_deleteAt;
			if (isServer && {!_isLocal}) then {
				[_monitor, "CFM_monitorInstancesMap", HAND_MONITOR_KEY, false, true, _monitor] call CFM_fnc_deleteAtNet;
			};
		};
		if (_oldTexSel >= 0 && {_oldTexSel != _texSel} && {(_instancesMap getOrDefault [_oldTexSel, -1]) isEqualTo _instId}) then {
			[_monitor, "CFM_monitorInstancesMap", _oldTexSel, false] call CFM_fnc_deleteAt;
			if (isServer && {!_isLocal}) then {
				[_monitor, "CFM_monitorInstancesMap", _oldTexSel, false, true, _monitor] call CFM_fnc_deleteAtNet;
			};
		};
		if (_oldIsVehSeat) then {
			{
				private _sk = _x;
				if (!_isVehSeat || {!(_sk in _seatKeys)}) then {
					private _seatArr = +((_monitor getVariable ["CFM_monitorInstancesMap", createHashMap]) getOrDefault [_sk, []]);
					if (_instId in _seatArr) then {
						_seatArr = _seatArr - [_instId];
						if (_seatArr isEqualTo []) then {
							[_monitor, "CFM_monitorInstancesMap", _sk, false] call CFM_fnc_deleteAt;
							if (isServer && {!_isLocal}) then {
								[_monitor, "CFM_monitorInstancesMap", _sk, false, true, _monitor] call CFM_fnc_deleteAtNet;
							};
						} else {
							[_monitor, "CFM_monitorInstancesMap", _sk, _seatArr, false] call CFM_fnc_hashSet;
							if (isServer && {!_isLocal}) then {
								[_monitor, "CFM_monitorInstancesMap", _sk, _seatArr, false, true, _monitor] call CFM_fnc_hashSetNet;
							};
						};
					};
				};
			} forEach _oldSeatKeys;
		};

		[_monitor, "CFM_monitorInstanceKeysMap", _instId, _cleanKeyTuple, false] call CFM_fnc_hashSet;
		if (isServer && {!_isLocal}) then {
			[_monitor, "CFM_monitorInstanceKeysMap", _instId, _cleanKeyTuple, false, true, _monitor] call CFM_fnc_hashSetNet;
		};

		if (_isHand) then {
			[_monitor, "CFM_monitorInstancesMap", HAND_MONITOR_KEY, _instId, false] call CFM_fnc_hashSet;
			if (isServer && {!_isLocal}) then {
				[_monitor, "CFM_monitorInstancesMap", HAND_MONITOR_KEY, _instId, false, true, _monitor] call CFM_fnc_hashSetNet;
			};
		};

		if (_texSel >= 0) then {
			[_monitor, "CFM_monitorInstancesMap", _texSel, _instId, false] call CFM_fnc_hashSet;
			if (isServer && {!_isLocal}) then {
				[_monitor, "CFM_monitorInstancesMap", _texSel, _instId, false, true, _monitor] call CFM_fnc_hashSetNet;
			};
		};

		if (_isVehSeat) then {
			private _regSeats = if (_seatKeys isNotEqualTo []) then {_seatKeys} else {[_seatKey]};
			{
				private _sk = _x;
				private _seatArr = +((_monitor getVariable ["CFM_monitorInstancesMap", createHashMap]) getOrDefault [_sk, []]);
				if !(_instId in _seatArr) then {
					_seatArr pushBackUnique _instId;
					[_monitor, "CFM_monitorInstancesMap", _sk, _seatArr, false] call CFM_fnc_hashSet;
					if (isServer && {!_isLocal}) then {
						[_monitor, "CFM_monitorInstancesMap", _sk, _seatArr, false, true, _monitor] call CFM_fnc_hashSetNet;
					};
				};
			} forEach _regSeats;
		};

		true
	};

	PRIVATE LOCAL METHOD("refreshHostAfterInstancesChange") {
		params [["_commonArgs", []], ["_isLocal", false]];
		if !(IS_OBJ(_monitor)) exitWith {false};

		private _keysMap = _monitor getVariable ["CFM_monitorInstanceKeysMap", createHashMap];
		private _totalCount = count _keysMap;

		private _hasAnyHand = false;
		private _hasAnyVehSeat = false;
		private _hasAnyNonSeat = false;
		private _anyHandMonitor = false;
		private _anyNonHandMonitor = false;
		{
			_y params [["_eTex", NO_TEXTURE_SELECTION], ["_eSeat", ""], ["_eIsVeh", false], ["_eIsHand", false]];
			if (_eIsHand) then {_hasAnyHand = true;};
			if (_eIsVeh) then {
				_hasAnyVehSeat = true;
			} else {
				if !(_eIsHand) then {_hasAnyNonSeat = true;};
			};
			if (_eIsHand || {_eIsVeh && {_eTex < 0}}) then {
				_anyHandMonitor = true;
			} else {
				_anyNonHandMonitor = true;
			};
		} forEach _keysMap;

		_isHandTablet = _hasAnyHand;
		_isVehSeatTablet = _hasAnyVehSeat;
		_hasNonSeatMonitors = _hasAnyNonSeat;
		_isMonitorSet = _totalCount > 0;

		_monitor setVariable ["CFM_isHandTablet", _isHandTablet];
		_monitor setVariable ["CFM_isVehSeatTablet", _isVehSeatTablet];
		_monitor setVariable ["CFM_hasNonSeatMonitors", _hasNonSeatMonitors];
		_monitor setVariable ["CFM_isMonitorSet", _isMonitorSet];
		if (isServer && {!_isLocal}) then {
			_monitor setVariable ["CFM_isHandTablet", _isHandTablet, true];
			_monitor setVariable ["CFM_isVehSeatTablet", _isVehSeatTablet, true];
			_monitor setVariable ["CFM_hasNonSeatMonitors", _hasNonSeatMonitors, true];
			_monitor setVariable ["CFM_isMonitorSet", _isMonitorSet, true];
		};

		_monitor setVariable ["CFM_availInstCache", nil];
		_monitor setVariable ["CFM_selInstCache", nil];
		_monitor setVariable ["CFM_lastUiSyncedInst", nil];

		if (hasInterface) then {
			if (_totalCount > 0) then {
				private _isMultiAll = _totalCount > 1;
				private _anyZoom = false;
				private _anyConnDrone = false;
				private _anyFix = false;
				private _anySwitchTurret = false;
				private _anyTurnOffLocal = false;
				private _anySwitchNvg = false;
				private _anySwitchTi = false;
				private _anyFullScreen = false;
				{
					private _id = _x;
					["buildMenuActionLabels", [_isMultiAll]] CALL_MON_INST(_monitor, _id);
					if (MON_GVAR(_monitor, _id, "CFM_canZoomAction", true)) then {_anyZoom = true};
					if (MON_GVAR(_monitor, _id, "CFM_canConnectDroneAction", true)) then {_anyConnDrone = true};
					if (MON_GVAR(_monitor, _id, "CFM_canFixAction", true)) then {_anyFix = true};
					if (MON_GVAR(_monitor, _id, "CFM_canSwitchTurretAction", true)) then {_anySwitchTurret = true};
					if (MON_GVAR(_monitor, _id, "CFM_canTurnOffLocalAction", true)) then {_anyTurnOffLocal = true};
					if (MON_GVAR(_monitor, _id, "CFM_canSwitchNvgAction", true)) then {_anySwitchNvg = true};
					if (MON_GVAR(_monitor, _id, "CFM_canSwitchTiAction", true)) then {_anySwitchTi = true};
					if (MON_GVAR(_monitor, _id, "CFM_canFullScreen", true)) then {_anyFullScreen = true};
				} forEach (keys _keysMap);

				["ensureHostActions", [_hasAnyHand, _hasAnyVehSeat, _anyHandMonitor, _anyNonHandMonitor, _anyZoom, _anyConnDrone, _anyFix, _anySwitchTurret, _anyTurnOffLocal, _anySwitchNvg, _anySwitchTi, _anyFullScreen]] CALL_SELF;
			};

			private _avail = [_monitor] call CFM_fnc_getAvailableMonitorInstances;
			if (_avail isEqualTo []) then {
				_selectedMonitorInstance = -1;
				SET_SELFVAR(_selectedMonitorInstance);
				_monitor setVariable ["CFM_selectedMonitorInstance", -1];
			} else {
				if (_selectedMonitorInstance < 1 || {!(_selectedMonitorInstance in _avail)}) then {
					_selectedMonitorInstance = _avail select 0;
					SET_SELFVAR(_selectedMonitorInstance);
					_monitor setVariable ["CFM_selectedMonitorInstance", _selectedMonitorInstance];
				};
			};

			if (_switchMonitorActionId >= 0) then {
				if ((count _avail) > 1) then {
					private _curPos = ((_avail find _selectedMonitorInstance) max 0) + 1;
					_monitor setUserActionText [
						_switchMonitorActionId,
						format ["<t color='#ffaa00'>%1 (%2/%3)</t>", CFM_STR_SWITCH_MONITOR, _curPos, count _avail]
					];
				} else {
					_monitor setUserActionText [
						_switchMonitorActionId,
						format ["<t color='#ffaa00'>%1</t>", CFM_STR_SWITCH_MONITOR]
					];
				};
			};
			if (_selectedMonitorInstance > 0) then {
				["syncSelectedActionLabels", [_selectedMonitorInstance]] CALL_SELF;
			};
		};

		if (_totalCount > 0) then {
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

			if !(_priorityUpdated) then {
				_priorityUpdated = true;
				SET_SELFVAR(_priorityUpdated);
				["updateActionPriority"] CALL_CLASS("DbHandler");
			};
		};

		true
	};

	PRIVATE LOCAL METHOD("addInstances") {
		params [
			["_instanceSpecs", []],
			["_commonArgs", []],
			["_isLocal", false]
		];
		if (!(IS_OBJ(_monitor)) || {_instanceSpecs isEqualTo []}) exitWith {[]};

		private _existingKeysMap = _monitor getVariable ["CFM_monitorInstanceKeysMap", createHashMap];
		private _existingCount = count _existingKeysMap;
		private _existingKeys = keys _existingKeysMap;

		// Rule 1: empty-keys overwrite existing instances regardless of init order
		private _allBaseEmpty = (_instanceSpecs findIf {(_x param [6, "ADD"]) isNotEqualTo "BASE_EMPTY"}) == -1;
		if (_existingCount > 0 && {_allBaseEmpty}) exitWith {
			private _sortedExisting = +_existingKeys;
			_sortedExisting sort true;
			private _isMulti = _existingCount > 1;
			private _updatedIds = [];
			{
				private _instId = _x;
				private _curTuple = (_monitor getVariable ["CFM_monitorInstanceKeysMap", createHashMap]) getOrDefault [_instId, []];
				if (_curTuple isNotEqualTo []) then {
					if (["reconfigureInstance", [_instId, _curTuple, _commonArgs, _isLocal, _isMulti]] CALL_SELF) then {
						_updatedIds pushBack _instId;
					};
				};
			} forEach _sortedExisting;

			if (_updatedIds isNotEqualTo []) then {
				["refreshHostAfterInstancesChange", [_commonArgs, _isLocal]] CALL_SELF;
			};
			_updatedIds
		};

		private _createdIds = [];
		private _stateChanged = false;
		private _isMultiMonitor = (_existingCount + (count _instanceSpecs)) > 1;
		private _now = diag_tickTime;

		{
			_x params [
				["_texSel", NO_TEXTURE_SELECTION],
				["_seatKey", ""],
				["_isVehSeat", false],
				["_isHand", false],
				["_seatKeys", []],
				["_controlSeatKeys", []],
				["_opMode", "ADD"],
				["_hasExplicitTexSel", false]
			];
			if (_seatKeys isEqualTo [] && {!(_seatKey isEqualTo "")}) then {
				_seatKeys = [_seatKey];
			};

			private _instancesMap = _monitor getVariable ["CFM_monitorInstancesMap", createHashMap];
			private _keysMap = _monitor getVariable ["CFM_monitorInstanceKeysMap", createHashMap];
			private _baseInstIds = _monitor getVariable ["CFM_monitorBaseInstIds", createHashMap];
			private _rwSeats = _monitor getVariable ["CFM_rewrittenMonitorSeats", createHashMap];
			private _rwTexSels = _monitor getVariable ["CFM_rewrittenMonitorTexSels", createHashMap];
			private _remSeats = _monitor getVariable ["CFM_removedMonitorSeats", createHashMap];
			private _remTexSels = _monitor getVariable ["CFM_removedMonitorTexSels", createHashMap];

			if (_opMode isEqualTo "REMOVE") then {
				if (_isVehSeat && {_seatKeys isNotEqualTo []}) then {
					{
						if (_hasExplicitTexSel) then {
							_remSeats set [format ["%1|%2", _x, _texSel], _now];
						} else {
							_remSeats set [_x, _now];
						};
					} forEach _seatKeys;
				} else {
					if (_texSel >= 0) then {
						_remTexSels set [_texSel, _now];
					};
				};
				_monitor setVariable ["CFM_removedMonitorSeats", _remSeats];
				_monitor setVariable ["CFM_removedMonitorTexSels", _remTexSels];

				if (_isHand) then {
					private _instId = _instancesMap getOrDefault [HAND_MONITOR_KEY, -1];
					if (_instId > 0 && {["removeInstance", [_instId]] CALL_SELF}) then {
						_stateChanged = true;
					};
					continue;
				};

				if (!_isVehSeat && {_texSel >= 0}) then {
					private _instId = _instancesMap getOrDefault [_texSel, -1];
					if (_instId > 0 && {["removeInstance", [_instId]] CALL_SELF}) then {
						_stateChanged = true;
					};
					continue;
				};

				if (_isVehSeat && {_seatKeys isNotEqualTo []}) then {
					private _candidateInsts = [];
					{
						{
							_candidateInsts pushBackUnique _x;
						} forEach (_instancesMap getOrDefault [_x, []]);
					} forEach _seatKeys;

					{
						private _instId = _x;
						private _entry = (_monitor getVariable ["CFM_monitorInstanceKeysMap", createHashMap]) getOrDefault [_instId, []];
						if (_entry isNotEqualTo []) then {
							_entry params [["_eTexSel", NO_TEXTURE_SELECTION], ["_eSeatKey", ""], "", "", ["_eSeatKeys", []]];
							if (_eSeatKeys isEqualTo [] && {!(_eSeatKey isEqualTo "")}) then {
								_eSeatKeys = [_eSeatKey];
							};
							if (!_hasExplicitTexSel || {_eTexSel == _texSel}) then {
								private _keptSeats = _eSeatKeys select {!(_x in _seatKeys)};
								if (_keptSeats isEqualTo []) then {
									if (["removeInstance", [_instId]] CALL_SELF) then {_stateChanged = true};
								} else {
									if ((count _keptSeats) < (count _eSeatKeys)) then {
										if (["detachSeatsFromInstance", [_instId, _seatKeys]] CALL_SELF) then {_stateChanged = true};
									};
								};
							};
						};
					} forEach _candidateInsts;
				};
				continue;
			};

			if (_opMode isEqualTo "REWRITE") then {
				private _blocked = false;
				if (!_isVehSeat && {_texSel >= 0}) then {
					if ((_now - (_remTexSels getOrDefault [_texSel, -999])) < 1) then {_blocked = true};
				};
				if (_isVehSeat && {_seatKeys isNotEqualTo []}) then {
					private _keptSeats = _seatKeys select {
						private _sk = _x;
						!((_now - (_remSeats getOrDefault [_sk, -999])) < 1) &&
						{!(_hasExplicitTexSel && {(_now - (_remSeats getOrDefault [format ["%1|%2", _sk, _texSel], -999])) < 1})}
					};
					if (_keptSeats isEqualTo []) then {
						_blocked = true;
					} else {
						if ((count _keptSeats) < (count _seatKeys)) then {
							_seatKeys = _keptSeats;
							_seatKey = _seatKeys joinString ", ";
							if (_controlSeatKeys isNotEqualTo [] && {!(_controlSeatKeys isEqualTo ["__NO_CONTROLLER__"])}) then {
								private _c = _controlSeatKeys select {_x in _seatKeys};
								_controlSeatKeys = if (_c isEqualTo []) then {["__NO_CONTROLLER__"]} else {_c};
							};
						};
					};
					if (!_blocked && {_texSel >= 0} && {(_now - (_remTexSels getOrDefault [_texSel, -999])) < 1}) then {
						_blocked = true;
					};
				};
				if (_blocked) then {continue};

				if (_isVehSeat && {_seatKeys isNotEqualTo []}) then {
					{
						_rwSeats set [_x, true];
						if (_hasExplicitTexSel && {_texSel >= 0}) then {
							_rwSeats set [format ["%1|%2", _x, _texSel], true];
						};
					} forEach _seatKeys;
				};
				if (_texSel >= 0) then {
					_rwTexSels set [_texSel, true];
				};
				_monitor setVariable ["CFM_rewrittenMonitorSeats", _rwSeats];
				_monitor setVariable ["CFM_rewrittenMonitorTexSels", _rwTexSels];

				if (_isHand) then {
					private _targetInstId = _instancesMap getOrDefault [HAND_MONITOR_KEY, -1];
					private _keyTuple = [_texSel, _seatKey, _isVehSeat, _isHand, _seatKeys, _controlSeatKeys];
					if (_targetInstId > 0) then {
						if (["reconfigureInstance", [_targetInstId, _keyTuple, _commonArgs, _isLocal, _isMultiMonitor]] CALL_SELF) then {
							_baseInstIds deleteAt _targetInstId;
							_monitor setVariable ["CFM_monitorBaseInstIds", _baseInstIds];
							_stateChanged = true;
						};
					} else {
						private _newId = ["createMonitorInstance", [_keyTuple, _commonArgs, _isLocal, _isMultiMonitor]] CALL_SELF;
						if (_newId > 0) then {
							_createdIds pushBack _newId;
							_stateChanged = true;
						};
					};
					continue;
				};

				if (!_isVehSeat && {_texSel >= 0}) then {
					private _targetInstId = _instancesMap getOrDefault [_texSel, -1];
					private _keyTuple = [_texSel, "", false, false, [], []];
					if (_targetInstId > 0) then {
						if (["reconfigureInstance", [_targetInstId, _keyTuple, _commonArgs, _isLocal, _isMultiMonitor]] CALL_SELF) then {
							_baseInstIds deleteAt _targetInstId;
							_monitor setVariable ["CFM_monitorBaseInstIds", _baseInstIds];
							_stateChanged = true;
						};
					} else {
						private _newId = ["createMonitorInstance", [_keyTuple, _commonArgs, _isLocal, _isMultiMonitor]] CALL_SELF;
						if (_newId > 0) then {
							_createdIds pushBack _newId;
							_stateChanged = true;
						};
					};
					continue;
				};

				if (_isVehSeat && {_seatKeys isNotEqualTo []}) then {
					private _isSharedGroup = ((count _seatKeys) > 1) || {_controlSeatKeys isNotEqualTo []};
					if (_isSharedGroup) then {
						private _pipInsts = [];
						{
							{
								private _eEntry = _keysMap getOrDefault [_x, []];
								if ((_eEntry param [0, NO_TEXTURE_SELECTION]) < 0) then {
									_pipInsts pushBackUnique _x;
								};
							} forEach (_instancesMap getOrDefault [_x, []]);
						} forEach _seatKeys;

						private _exactMatchId = -1;
						if ((count _pipInsts) == 1) then {
							private _candId = _pipInsts select 0;
							private _candEntry = _keysMap getOrDefault [_candId, []];
							private _candSeats = +(_candEntry param [4, []]);
							if (_candSeats isEqualTo [] && {!((_candEntry param [1, ""]) isEqualTo "")}) then {
								_candSeats = [_candEntry param [1, ""]];
							};
							private _sortedCand = +_candSeats;
							private _sortedNew = +_seatKeys;
							_sortedCand sort true;
							_sortedNew sort true;
							if (_sortedCand isEqualTo _sortedNew) then {
								_exactMatchId = _candId;
							};
						};

						private _keyTuple = [NO_TEXTURE_SELECTION, _seatKey, true, false, _seatKeys, _controlSeatKeys];
						if (_exactMatchId > 0) then {
							if (["reconfigureInstance", [_exactMatchId, _keyTuple, _commonArgs, _isLocal, _isMultiMonitor]] CALL_SELF) then {
								_baseInstIds deleteAt _exactMatchId;
								_monitor setVariable ["CFM_monitorBaseInstIds", _baseInstIds];
								_stateChanged = true;
							};
						} else {
							{
								if (["detachSeatsFromInstance", [_x, _seatKeys]] CALL_SELF) then {_stateChanged = true};
							} forEach _pipInsts;
							private _newId = ["createMonitorInstance", [_keyTuple, _commonArgs, _isLocal, _isMultiMonitor]] CALL_SELF;
							if (_newId > 0) then {
								_createdIds pushBack _newId;
								_stateChanged = true;
							};
						};
						continue;
					};

					// Single-seat REWRITE
					private _sk = _seatKeys select 0;
					private _seatInstIds = +(_instancesMap getOrDefault [_sk, []]);
					private _singleInstIds = [];
					private _sharedPipIds = [];
					private _singlePipId = -1;
					private _singleTexIds = [];

					{
						private _eId = _x;
						private _eEntry = _keysMap getOrDefault [_eId, []];
						if (_eEntry isNotEqualTo []) then {
							_eEntry params [["_eTex", NO_TEXTURE_SELECTION], ["_eSeat", ""], "", "", ["_eSeats", []]];
							if (_eSeats isEqualTo [] && {!(_eSeat isEqualTo "")}) then {_eSeats = [_eSeat]};
							if ((count _eSeats) <= 1) then {
								_singleInstIds pushBack _eId;
								if (_eTex < 0) then {
									if (_singlePipId < 0) then {_singlePipId = _eId};
								} else {
									_singleTexIds pushBack _eId;
								};
							} else {
								if (_eTex < 0) then {_sharedPipIds pushBack _eId};
							};
						};
					} forEach _seatInstIds;

					if (!_hasExplicitTexSel) then {
						if (_singleInstIds isNotEqualTo []) then {
							{
								private _eId = _x;
								private _eTex = (_keysMap getOrDefault [_eId, []]) param [0, NO_TEXTURE_SELECTION];
								private _keyTuple = [_eTex, _sk, true, false, [_sk], []];
								if (["reconfigureInstance", [_eId, _keyTuple, _commonArgs, _isLocal, _isMultiMonitor]] CALL_SELF) then {
									_baseInstIds deleteAt _eId;
									_monitor setVariable ["CFM_monitorBaseInstIds", _baseInstIds];
									_stateChanged = true;
								};
							} forEach _singleInstIds;
						} else {
							{
								if (["detachSeatsFromInstance", [_x, [_sk]]] CALL_SELF) then {_stateChanged = true};
							} forEach _sharedPipIds;
							private _keyTuple = [NO_TEXTURE_SELECTION, _sk, true, false, [_sk], []];
							private _newId = ["createMonitorInstance", [_keyTuple, _commonArgs, _isLocal, _isMultiMonitor]] CALL_SELF;
							if (_newId > 0) then {
								_createdIds pushBack _newId;
								_stateChanged = true;
							};
						};
					} else {
						if (_texSel >= 0) then {
							private _keyTuple = [_texSel, _sk, true, false, [_sk], []];
							private _texOwnerId = (_monitor getVariable ["CFM_monitorInstancesMap", createHashMap]) getOrDefault [_texSel, -1];
							private _handled = false;
							if (_texOwnerId > 0) then {
								private _ownerEntry = (_monitor getVariable ["CFM_monitorInstanceKeysMap", createHashMap]) getOrDefault [_texOwnerId, []];
								private _ownerIsVeh = _ownerEntry param [2, false];
								private _ownerSeats = +(_ownerEntry param [4, []]);
								if (_ownerSeats isEqualTo [] && {!((_ownerEntry param [1, ""]) isEqualTo "")}) then {
									_ownerSeats = [_ownerEntry param [1, ""]];
								};
								if (_ownerIsVeh && {_ownerSeats isEqualTo [_sk]}) then {
									if (["reconfigureInstance", [_texOwnerId, _keyTuple, _commonArgs, _isLocal, _isMultiMonitor]] CALL_SELF) then {
										_baseInstIds deleteAt _texOwnerId;
										_monitor setVariable ["CFM_monitorBaseInstIds", _baseInstIds];
										_stateChanged = true;
									};
									_handled = true;
								} else {
									if (["removeInstance", [_texOwnerId]] CALL_SELF) then {_stateChanged = true};
								};
							};
							if !(_handled) then {
								if (_singlePipId > 0 && {(_monitor getVariable ["CFM_monitorInstanceKeysMap", createHashMap]) getOrDefault [_singlePipId, []] isNotEqualTo []}) then {
									if (["reconfigureInstance", [_singlePipId, _keyTuple, _commonArgs, _isLocal, _isMultiMonitor]] CALL_SELF) then {
										_baseInstIds deleteAt _singlePipId;
										_monitor setVariable ["CFM_monitorBaseInstIds", _baseInstIds];
										_stateChanged = true;
									};
								} else {
									{
										if (["detachSeatsFromInstance", [_x, [_sk]]] CALL_SELF) then {_stateChanged = true};
									} forEach _sharedPipIds;
									private _newId = ["createMonitorInstance", [_keyTuple, _commonArgs, _isLocal, _isMultiMonitor]] CALL_SELF;
									if (_newId > 0) then {
										_createdIds pushBack _newId;
										_stateChanged = true;
									};
								};
							};
						} else {
							private _keyTuple = [NO_TEXTURE_SELECTION, _sk, true, false, [_sk], []];
							if (_singlePipId > 0) then {
								if (["reconfigureInstance", [_singlePipId, _keyTuple, _commonArgs, _isLocal, _isMultiMonitor]] CALL_SELF) then {
									_baseInstIds deleteAt _singlePipId;
									_monitor setVariable ["CFM_monitorBaseInstIds", _baseInstIds];
									_stateChanged = true;
								};
							} else {
								if (_singleTexIds isNotEqualTo []) then {
									private _targetId = _singleTexIds select 0;
									if (["reconfigureInstance", [_targetId, _keyTuple, _commonArgs, _isLocal, _isMultiMonitor]] CALL_SELF) then {
										_baseInstIds deleteAt _targetId;
										_monitor setVariable ["CFM_monitorBaseInstIds", _baseInstIds];
										_stateChanged = true;
									};
								} else {
									{
										if (["detachSeatsFromInstance", [_x, [_sk]]] CALL_SELF) then {_stateChanged = true};
									} forEach _sharedPipIds;
									private _newId = ["createMonitorInstance", [_keyTuple, _commonArgs, _isLocal, _isMultiMonitor]] CALL_SELF;
									if (_newId > 0) then {
										_createdIds pushBack _newId;
										_stateChanged = true;
									};
								};
							};
						};
					};
				};
				continue;
			};

			// "BASE_EMPTY", "BASE", "ADD"
			private _isBase = _opMode in ["BASE", "BASE_EMPTY"];

			if (!_isVehSeat && {!_isHand} && {_texSel >= 0}) then {
				private _remBlocked = if (_isBase) then {
					_texSel in _remTexSels
				} else {
					(_now - (_remTexSels getOrDefault [_texSel, -999])) < 1
				};
				if (_remBlocked || {_texSel in _rwTexSels} || {_texSel in _instancesMap}) then {continue};

				private _keyTuple = [_texSel, "", false, false, [], []];
				private _newId = ["createMonitorInstance", [_keyTuple, _commonArgs, _isLocal, _isMultiMonitor]] CALL_SELF;
				if (_newId > 0) then {
					if (_isBase) then {
						_baseInstIds set [_newId, true];
						_monitor setVariable ["CFM_monitorBaseInstIds", _baseInstIds];
					};
					_createdIds pushBack _newId;
					_stateChanged = true;
				};
				continue;
			};

			if (_isHand) then {
				if (HAND_MONITOR_KEY in _instancesMap) then {continue};
				private _keyTuple = [_texSel, _seatKey, _isVehSeat, _isHand, _seatKeys, _controlSeatKeys];
				private _newId = ["createMonitorInstance", [_keyTuple, _commonArgs, _isLocal, _isMultiMonitor]] CALL_SELF;
				if (_newId > 0) then {
					if (_isBase) then {
						_baseInstIds set [_newId, true];
						_monitor setVariable ["CFM_monitorBaseInstIds", _baseInstIds];
					};
					_createdIds pushBack _newId;
					_stateChanged = true;
				};
				continue;
			};

			if (_isVehSeat) then {
				if (_seatKeys isNotEqualTo []) then {
					private _filteredSeats = _seatKeys select {
						private _sk = _x;
						private _remBlocked = if (_isBase) then {
							(_sk in _remSeats) || {(format ["%1|%2", _sk, _texSel]) in _remSeats}
						} else {
							((_now - (_remSeats getOrDefault [_sk, -999])) < 1) ||
							{(_now - (_remSeats getOrDefault [format ["%1|%2", _sk, _texSel], -999])) < 1} ||
							{!_hasExplicitTexSel && {(_now - (_remSeats getOrDefault [format ["%1|-1", _sk], -999])) < 1}}
						};
						private _rwBlocked = if (_isBase || {!_hasExplicitTexSel} || {_texSel < 0}) then {
							_sk in _rwSeats
						} else {
							(format ["%1|%2", _sk, _texSel]) in _rwSeats
						};
						!_remBlocked && {!_rwBlocked}
					};
					if (_filteredSeats isEqualTo []) then {continue};

					if (_texSel >= 0) then {
						private _texBlocked = if (_isBase) then {_texSel in _remTexSels} else {(_now - (_remTexSels getOrDefault [_texSel, -999])) < 1};
						if (_texBlocked || {_texSel in _rwTexSels}) then {continue};
					};

					if (_isBase || {!_hasExplicitTexSel}) then {
						_filteredSeats = _filteredSeats select {(_instancesMap getOrDefault [_x, []]) isEqualTo []};
						if (_filteredSeats isEqualTo []) then {continue};
					};

					if ((count _filteredSeats) < (count _seatKeys)) then {
						_seatKeys = _filteredSeats;
						_seatKey = _seatKeys joinString ", ";
						if (_controlSeatKeys isNotEqualTo [] && {!(_controlSeatKeys isEqualTo ["__NO_CONTROLLER__"])}) then {
							private _c = _controlSeatKeys select {_x in _seatKeys};
							_controlSeatKeys = if (_c isEqualTo []) then {["__NO_CONTROLLER__"]} else {_c};
						};
					};
				};

				if (_texSel >= 0 && {_texSel in _instancesMap}) then {continue};

				// Upgrade automatic BASE PiP instance in-place when ADD explicitly binds a texture selection to that seat
				if (_opMode isEqualTo "ADD" && {_hasExplicitTexSel} && {_texSel >= 0} && {(count _seatKeys) == 1}) then {
					private _sk = _seatKeys select 0;
					private _basePipId = -1;
					{
						private _eId = _x;
						if (_eId in _baseInstIds) then {
							private _eEntry = _keysMap getOrDefault [_eId, []];
							private _eSeats = _eEntry param [4, []];
							if ((_eEntry param [0, NO_TEXTURE_SELECTION]) < 0 && {(count _eSeats) <= 1}) exitWith {_basePipId = _eId};
						};
					} forEach (_instancesMap getOrDefault [_sk, []]);

					if (_basePipId > 0) then {
						private _keyTuple = [_texSel, _sk, true, false, [_sk], []];
						if (["reconfigureInstance", [_basePipId, _keyTuple, _commonArgs, _isLocal, _isMultiMonitor]] CALL_SELF) then {
							_baseInstIds deleteAt _basePipId;
							_monitor setVariable ["CFM_monitorBaseInstIds", _baseInstIds];
							_stateChanged = true;
						};
						continue;
					};
				};

				// Remove automatic BASE single-seat PiP instances when ADD creates a shared group over those seats
				if (_opMode isEqualTo "ADD" && {_hasExplicitTexSel} && {_texSel < 0} && {((count _seatKeys) > 1) || {_controlSeatKeys isNotEqualTo []}}) then {
					{
						private _sk = _x;
						private _toRemove = [];
						{
							private _eId = _x;
							if (_eId in _baseInstIds) then {
								private _eEntry = _keysMap getOrDefault [_eId, []];
								private _eTex = _eEntry param [0, NO_TEXTURE_SELECTION];
								private _eSeats = _eEntry param [4, []];
								if (_eTex < 0 && {(count _eSeats) <= 1}) then {
									_toRemove pushBack _eId;
								};
							};
						} forEach (+(_instancesMap getOrDefault [_sk, []]));
						{
							if (["removeInstance", [_x]] CALL_SELF) then {_stateChanged = true};
						} forEach _toRemove;
					} forEach _seatKeys;
					_instancesMap = _monitor getVariable ["CFM_monitorInstancesMap", createHashMap];
					_keysMap = _monitor getVariable ["CFM_monitorInstanceKeysMap", createHashMap];
				};

				private _duplicate = false;
				if (_texSel < 0) then {
					private _checkSeats = if (_seatKeys isNotEqualTo []) then {_seatKeys} else {[_seatKey]};
					{
						private _seatExisting = _instancesMap getOrDefault [_x, []];
						{
							private _entry = _keysMap getOrDefault [_x, []];
							if ((_entry param [0, NO_TEXTURE_SELECTION]) < 0) exitWith {_duplicate = true};
						} forEach _seatExisting;
						if (_duplicate) exitWith {};
					} forEach _checkSeats;
				};

				if !(_duplicate) then {
					private _keyTuple = [_texSel, _seatKey, _isVehSeat, _isHand, _seatKeys, _controlSeatKeys];
					private _newId = ["createMonitorInstance", [_keyTuple, _commonArgs, _isLocal, _isMultiMonitor]] CALL_SELF;
					if (_newId > 0) then {
						if (_isBase) then {
							_baseInstIds set [_newId, true];
							_monitor setVariable ["CFM_monitorBaseInstIds", _baseInstIds];
						};
						_createdIds pushBack _newId;
						_stateChanged = true;
					};
				};
			};
		} forEach _instanceSpecs;

		if (_stateChanged) then {
			["refreshHostAfterInstancesChange", [_commonArgs, _isLocal]] CALL_SELF;
		};

		_createdIds
	};

	PUBLIC LOCAL METHOD("switchMonitor") {
		params [["_targetInstId", -1]];
		if !(hasInterface) exitWith {-1};
		if !(IS_OBJ(_monitor)) exitWith {-1};

		_monitor setVariable ["CFM_availInstCache", nil];
		_monitor setVariable ["CFM_selInstCache", nil];

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
		_monitor setVariable ["CFM_selInstCache", nil];

		private _pos = (_available find _nextInstId) + 1;
		private _total = count _available;
		private _keysMap = _monitor getVariable ["CFM_monitorInstanceKeysMap", createHashMap];
		private _entry = _keysMap getOrDefault [_nextInstId, []];
		_entry params [["_texSel", NO_TEXTURE_SELECTION], ["_seatKey", ""], ["_isVehSeat", false]];

		private _label = if (_isVehSeat && {!(_seatKey isEqualTo "")}) then {
			private _useDevSeatKey = missionNamespace getVariable ["CFM_devShowSeatKeys", false];
			private _dispSeat = if (_useDevSeatKey) then {
				_seatKey
			} else {
				private _cachedName = MON_GVAR(_monitor, _nextInstId, "CFM_seatDisplayName", "");
				if (_cachedName isEqualTo "") then {_seatKey} else {_cachedName}
			};
			if (_texSel >= 0) then {
				format ["%1 #%2", _dispSeat, _texSel]
			} else {
				_dispSeat
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

		["syncSelectedActionLabels", [_nextInstId]] CALL_SELF;

		(format [CFM_STR_SWITCH_MONITOR_HINT, _label, _pos, _total]) _HINT;
		_nextInstId
	};

	PUBLIC LOCAL METHOD("onSeatChanged") {
		params [["_lastSeatKey", ""], ["_curSeatKey", ""]];
		if !(hasInterface) exitWith {false};
		if !(IS_OBJ(_monitor)) exitWith {false};

		[_monitor, true] call CFM_fnc_monitorCloseMenu;
		private _map = _monitor getVariable ["CFM_monitorInstancesMap", createHashMap];
		private _oldInsts = if !(_lastSeatKey isEqualTo "") then {_map getOrDefault [_lastSeatKey, []]} else {[]};
		private _newInsts = if !(_curSeatKey isEqualTo "") then {_map getOrDefault [_curSeatKey, []]} else {[]};

		if (!(_lastSeatKey isEqualTo "") && {!(_lastSeatKey isEqualTo _curSeatKey)}) then {
			{
				if !(_x in _newInsts) then {
					["deactivateSeat"] CALL_MON_INST(_monitor, _x);
				};
			} forEach _oldInsts;
		};

		if !(_curSeatKey isEqualTo "") then {
			{
				if !(_x in _oldInsts) then {
					["activateSeat"] CALL_MON_INST(_monitor, _x);
				};
			} forEach _newInsts;
		};

		_monitor setVariable ["CFM_availInstCache", nil];
		_monitor setVariable ["CFM_selInstCache", nil];

		private _avail = [_monitor] call CFM_fnc_getAvailableMonitorInstances;
		if !(_selectedMonitorInstance in _avail) then {
			_selectedMonitorInstance = _avail param [0, -1];
			SET_SELFVAR(_selectedMonitorInstance);
			_monitor setVariable ["CFM_selInstCache", nil];
		};
		if (_switchMonitorActionId >= 0 && {(count _avail) > 1}) then {
			private _curPos = ((_avail find _selectedMonitorInstance) max 0) + 1;
			_monitor setUserActionText [
				_switchMonitorActionId,
				format ["<t color='#ffaa00'>%1 (%2/%3)</t>", CFM_STR_SWITCH_MONITOR, _curPos, count _avail]
			];
		};
		if (_selectedMonitorInstance > 0) then {
			["syncSelectedActionLabels", [_selectedMonitorInstance]] CALL_SELF;
		};

		true
	};
CLASS_END
