PUBLIC GLOBAL CLASS(Monitor)

	SET_SELF_VAR("_monitor");
	SET_VARS_PREFIX("");

	// -----------------------------------------------
	// instance identity & mode config
	PUBLIC GLOBAL FIELD ["_textureSelection", NO_TEXTURE_SELECTION];
	PUBLIC GLOBAL FIELD ["_seatKey", ""];
	PUBLIC GLOBAL FIELD ["_seatKeys", []];
	PUBLIC GLOBAL FIELD ["_controlSeatKeys", []];
	PUBLIC GLOBAL FIELD ["_isVehSeatTablet", false];
	PUBLIC GLOBAL FIELD ["_isHandTablet", false];
	PUBLIC LOCAL FIELD ["_seatDisplayName", ""];
	PRIVATE LOCAL FIELD ["_displayHandlerId", -1];
	PRIVATE LOCAL FIELD ["_isMonitorInstanceSet", false];

	// monitor config
	PUBLIC GLOBAL FIELD ["_monitorSides", []];
	PUBLIC GLOBAL FIELD ["_originalTexture", ""];
	PUBLIC GLOBAL FIELD ["_allowedOperators", [], [objNull, []]];
	PUBLIC GLOBAL FIELD ["_allowedOperatorsTypes", [], ["", 1, []]];
	PUBLIC GLOBAL FIELD ["_canFullScreen", false];
	PUBLIC GLOBAL FIELD ["_canSetPassword", true];
	PRIVATE LOCAL FIELD ["_isLocal", false];
	PRIVATE LOCAL FIELD ["_radius", ACTION_RADIUS];
	PRIVATE GLOBAL FIELD ["_isHandMonitor", false];
	PRIVATE GLOBAL FIELD ["_isHandMonitorDisplay", false];
	PRIVATE GLOBAL FIELD ["_targetInActionsConditions", "_target"];
	PRIVATE LOCAL FIELD ["_monitorUid", ""];
	PRIVATE LOCAL FIELD ["_monitorR2Tid", ""];
	PRIVATE GLOBAL FIELD ["_password", ""];
	PRIVATE GLOBAL FIELD ["_screenResolution", DEFAULT_SCREEN_RESOLUTION];
	// -----------------------------------------------

	// -----------------------------------------------
	// state vars
	PRIVATE GLOBAL FIELD ["_passwordAccess", []];
	PRIVATE GLOBAL FIELD ["_connectedOperator", objNull];
	PRIVATE GLOBAL FIELD ["_currentTurret", DRIVER_TURRET_PATH];
	PRIVATE GLOBAL FIELD ["_feedActive", false];
	PRIVATE GLOBAL FIELD ["_currentCamPointParams", []];
	PRIVATE SERVER FIELD ["_activeMonitorViewers", [2]];
	PRIVATE LOCAL FIELD ["_currentFeedCam", objNull];
	PRIVATE LOCAL FIELD ["_menuActive", false];
	PRIVATE LOCAL FIELD ["_currentMenuObj", objNull];
	PRIVATE LOCAL FIELD ["_turnedOffLocal", false];
	PRIVATE LOCAL FIELD ["_actionCaller", objNull];
	PRIVATE LOCAL FIELD ["_pipSlot", PIP_SLOT_RIGHT];
	// -----------------------------------------------

	// -----------------------------------------------
	// Parameters below are temporary for current feed
	// NVG
	PUBLIC GLOBAL FIELD ["_monitorCanSwitchNvg", false];
	PRIVATE GLOBAL FIELD ["_isInNvg", false];
	PRIVATE GLOBAL FIELD ["_currentNvgParam", false];

	// TI
	PUBLIC GLOBAL FIELD ["_monitorCanSwitchTi", false];
	PRIVATE GLOBAL FIELD ["_currentTiTable", []];

	// Zoom
	PUBLIC GLOBAL FIELD ["_currentCameraSmoothZoom", true];
	PRIVATE GLOBAL FIELD ["_zoom", 1, ["", 1]];
	PRIVATE GLOBAL FIELD ["_zoomMax", 1];
	PRIVATE GLOBAL FIELD ["_zoomTable", createHashMap];
	PRIVATE GLOBAL FIELD ["_zoomFov", 1, ["", 1]];
	PRIVATE GLOBAL FIELD ["_maxZoomed", false];

	// Movement
	PUBLIC GLOBAL FIELD ["_currentCameraCanMove", false];
	PUBLIC GLOBAL FIELD ["_currentCameraMoveRestrictions", []];
	PRIVATE GLOBAL FIELD ["_currentCameraIsStatic", false];
	PRIVATE GLOBAL FIELD ["_currentCameraMoves", [0, 0, 0, 0]];
	PRIVATE GLOBAL FIELD ["_camDoInterpolation", false];

	// other turret params
	PRIVATE GLOBAL FIELD ["_currentPiPEffect", 0];
	PRIVATE LOCAL FIELD ["_turretLocal", false];
	PRIVATE GLOBAL FIELD ["_cameraPosFunc", {}];
	PRIVATE GLOBAL FIELD ["_connectedTurretObject", objNull];

	// operator data
	PRIVATE GLOBAL FIELD ["_currentOperatorIsDrone", false];
	PRIVATE GLOBAL FIELD ["_currentOpHasTurrets", false];
	PRIVATE GLOBAL FIELD ["_currentCameraType", ""];
	// -----------------------------------------------

	//----------- Internal -----------
	PRIVATE GLOBAL METHOD("Init") {
		params [
			["_instanceSpec", []],
			["_commonArgs", []],
			["_isLocalArg", false],
			["_isMultiMonitor", false]
		];

		if !(IS_OBJ(_monitor)) exitWith {false};

		_instanceSpec params [
			["_texSelArg", 0],
			["_seatKeyArg", ""],
			["_isVehSeatArg", false],
			["_isHandArg", false],
			["_seatKeysArg", []],
			["_controlSeatKeysArg", []]
		];

		_commonArgs params [
			["_sides", []],
			["_allowedOperatorsSet", []],
			["_allowedOperatorsTypesSet", []],
			["_isHandMonitorDisplaySet", false],
			["_canSwitchNvg", true],
			["_canSwitchTi", true],
			["_canSwitchTurret", true],
			["_canZoom", true],
			["_canFullScreenSet", true],
			["_canConnectDrone", true],
			["_canFix", true],
			["_canTurnOffLocal", true],
			["_canSetPasswordSet", true],
			["_screenResolutionSet", ""]
		];

		if (_isHandArg && {!(_monitor isEqualTo PLAYER_)}) exitWith {false};

		private _wasAlreadySet = MON_GVAR(_monitor, _instanceIndex, "CFM_isMonitorInstanceSet", false);
		private _prevTexSel = MON_GVAR(_monitor, _instanceIndex, "CFM_textureSelection", NO_TEXTURE_SELECTION);
		private _prevOrigTex = MON_GVAR(_monitor, _instanceIndex, "CFM_originalTexture", "");

		private _monitorTextures = [];
		if (_texSelArg >= 0) then {
			_monitorTextures = getObjectTextures _monitor;
		};
		if (_texSelArg >= 0 && {_texSelArg >= (count _monitorTextures)}) exitWith {
			format["CLASS Monitor init: Object '%1' has no texture selection %2!", _monitor, _texSelArg] WARN;
			false
		};

		if (_wasAlreadySet) then {
			if (hasInterface && {MON_GVAR(_monitor, _instanceIndex, "CFM_menuActive", false)}) then {
				[[_monitor, _instanceIndex]] call CFM_fnc_monitorCloseMenu;
			};
			if (hasInterface && {(missionNamespace getVariable ["CFM_currentFullScreenMonitor", [objNull, -1]]) isEqualTo [_monitor, _instanceIndex]}) then {
				["monitorExitFullScreen"] CALL_SELF;
			};
			if (_feedActive || {MON_GVAR(_monitor, _instanceIndex, "CFM_feedActive", false)}) then {
				[[_monitor, _instanceIndex], false, false, false] call CFM_fnc_stopOperatorFeed;
			};
			if (hasInterface && {_prevTexSel >= 0} && {_prevTexSel != _texSelArg}) then {
				_monitor setObjectTexture [_prevTexSel, _prevOrigTex];
			};
		};

		_textureSelection = _texSelArg;
		_seatKey = _seatKeyArg;
		_seatKeys = if (_seatKeysArg isEqualType [] && {_seatKeysArg isNotEqualTo []}) then {
			+_seatKeysArg
		} else {
			if !(_seatKeyArg isEqualTo "") then {[_seatKeyArg]} else {[]}
		};
		_controlSeatKeys = if (_controlSeatKeysArg isEqualType []) then {+_controlSeatKeysArg} else {[]};
		_isVehSeatTablet = _isVehSeatArg;
		_isHandTablet = _isHandArg;
		_isLocal = _isLocalArg || _isHandTablet;
		_isHandMonitor = _isHandTablet || (_isVehSeatTablet && {_textureSelection < 0});

		private _parsedScreenRes = [_screenResolutionSet, _monitor] call CFM_fnc_parseScreenResolution;
		if (_parsedScreenRes isEqualTo []) then {
			private _existingRes = if (_wasAlreadySet) then {
				_monitor getVariable ["ScreenResolution", ""]
			} else {
				MON_GVAR(_monitor, _instanceIndex, "CFM_screenResolution", _monitor getVariable ["ScreenResolution" I ""])
			};
			_parsedScreenRes = [_existingRes, _monitor] call CFM_fnc_parseScreenResolution;
		};
		if (_parsedScreenRes isEqualTo []) then {
			_parsedScreenRes = [_monitor] call CFM_fnc_getDefaultScreenResolution;
		};
		_screenResolution = _parsedScreenRes;

		_originalTexture = if (_textureSelection >= 0) then {
			private _tex = _monitorTextures param [_textureSelection, ""];
			if (isNil "_tex") then {_tex = ""};
			if (_wasAlreadySet && {_prevTexSel == _textureSelection} && {!(_prevOrigTex isEqualTo "")} && {(_tex select [0, 2]) isEqualTo "#("}) then {
				_prevOrigTex
			} else {
				if ((_tex select [0, 2]) isEqualTo "#(") then {""} else {_tex}
			};
		} else {""};

		if !(_sides isEqualType []) then {_sides = [_sides]};
		_sides = _sides select {_x isEqualType west};

		if !(_allowedOperatorsSet isEqualType []) then {_allowedOperatorsSet = [_allowedOperatorsSet]};
		_allowedOperatorsSet = _allowedOperatorsSet select {_x isEqualType objNull};

		if !(_allowedOperatorsTypesSet isEqualType []) then {_allowedOperatorsTypesSet = [_allowedOperatorsTypesSet]};
		_allowedOperatorsTypesSet = _allowedOperatorsTypesSet select {(_x isEqualType "") || {(_x isEqualType 1)}};

		_canFullScreen = _canFullScreenSet;
		_canSetPassword = _canSetPasswordSet && {!_isHandMonitor || _isVehSeatTablet};
		_isHandMonitorDisplay = _isHandMonitor && _isHandMonitorDisplaySet;

		// Deterministic local writes first so fast clients have full config before server packets arrive
		MON_SVAR(_monitor, _instanceIndex, "CFM_textureSelection", _textureSelection);
		MON_SVAR(_monitor, _instanceIndex, "CFM_seatKey", _seatKey);
		MON_SVAR(_monitor, _instanceIndex, "CFM_seatKeys", _seatKeys);
		MON_SVAR(_monitor, _instanceIndex, "CFM_controlSeatKeys", _controlSeatKeys);
		MON_SVAR(_monitor, _instanceIndex, "CFM_isVehSeatTablet", _isVehSeatTablet);
		MON_SVAR(_monitor, _instanceIndex, "CFM_isHandTablet", _isHandTablet);
		MON_SVAR(_monitor, _instanceIndex, "CFM_originalTexture", _originalTexture);
		MON_SVAR(_monitor, _instanceIndex, "CFM_isHandMonitor", _isHandMonitor);
		MON_SVAR(_monitor, _instanceIndex, "CFM_isHandMonitorDisplay", _isHandMonitorDisplay);
		MON_SVAR(_monitor, _instanceIndex, "CFM_isLocal", _isLocal);
		MON_SVAR(_monitor, _instanceIndex, "CFM_monitorSides", _sides);
		MON_SVAR(_monitor, _instanceIndex, "CFM_allowedOperators", _allowedOperatorsSet);
		MON_SVAR(_monitor, _instanceIndex, "CFM_allowedOperatorsTypes", _allowedOperatorsTypesSet);
		MON_SVAR(_monitor, _instanceIndex, "CFM_canFullScreen", _canFullScreen);
		MON_SVAR(_monitor, _instanceIndex, "CFM_canSetPassword", _canSetPassword);
		MON_SVAR(_monitor, _instanceIndex, "CFM_screenResolution", _screenResolution);

		if (isNil {MON_GVAR(_monitor, _instanceIndex, "CFM_password", nil)}) then {
			MON_SVAR(_monitor, _instanceIndex, "CFM_password", "");
		};
		if (isNil {MON_GVAR(_monitor, _instanceIndex, "CFM_passwordAccess", nil)}) then {
			MON_SVAR(_monitor, _instanceIndex, "CFM_passwordAccess", []);
		};

		// Authoritative server sync for JIP / global objects (regardless of vehicle local ownership)
		if (isServer && {!_isLocal}) then {
			MON_SVARG(_monitor, _instanceIndex, "CFM_textureSelection", _textureSelection, true);
			MON_SVARG(_monitor, _instanceIndex, "CFM_seatKey", _seatKey, true);
			MON_SVARG(_monitor, _instanceIndex, "CFM_seatKeys", _seatKeys, true);
			MON_SVARG(_monitor, _instanceIndex, "CFM_controlSeatKeys", _controlSeatKeys, true);
			MON_SVARG(_monitor, _instanceIndex, "CFM_isVehSeatTablet", _isVehSeatTablet, true);
			MON_SVARG(_monitor, _instanceIndex, "CFM_isHandTablet", _isHandTablet, true);
			MON_SVARG(_monitor, _instanceIndex, "CFM_originalTexture", _originalTexture, true);
			MON_SVARG(_monitor, _instanceIndex, "CFM_isHandMonitor", _isHandMonitor, true);
			MON_SVARG(_monitor, _instanceIndex, "CFM_isLocal", _isLocal, true);
			MON_SVARG(_monitor, _instanceIndex, "CFM_monitorSides", _sides, true);
			MON_SVARG(_monitor, _instanceIndex, "CFM_allowedOperators", _allowedOperatorsSet, true);
			MON_SVARG(_monitor, _instanceIndex, "CFM_allowedOperatorsTypes", _allowedOperatorsTypesSet, true);
			MON_SVARG(_monitor, _instanceIndex, "CFM_canFullScreen", _canFullScreen, true);
			MON_SVARG(_monitor, _instanceIndex, "CFM_canSetPassword", _canSetPassword, true);
			MON_SVARG(_monitor, _instanceIndex, "CFM_screenResolution", _screenResolution, true);
		};

		["addMonitor", [[_monitor, _instanceIndex], false]] CALL_CLASS("DbHandler");

		if (_textureSelection >= 0) then {
			[_monitor, _textureSelection, _instanceIndex] call CFM_fnc_cacheMonitorSelectionPos;
		} else {
			private _posMap = _monitor getVariable ["CFM_monitorSelectionPositions", createHashMap];
			if (_instanceIndex in _posMap) then {
				_posMap deleteAt _instanceIndex;
				_monitor setVariable ["CFM_monitorSelectionPositions", _posMap];
			};
		};

		_radius = if (_isHandTablet) then {-1} else {ACTION_RADIUS};
		_targetInActionsConditions = if (_isHandTablet) then {"_target call CFM_fnc_getPlayer"} else {"_target"};
		MON_SVAR(_monitor, _instanceIndex, "CFM_radius", _radius);
		MON_SVAR(_monitor, _instanceIndex, "CFM_targetInActionsConditions", _targetInActionsConditions);

		if (hasInterface) then {
			_seatDisplayName = if (_isVehSeatTablet) then {
				if ((count _seatKeys) > 1) then {
					private _names = _seatKeys apply {[_monitor, _x] call CFM_fnc_getSeatDisplayName};
					if ((count _names) <= 2) then {
						_names joinString " + "
					} else {
						format ["%1, %2 (+%3)", _names select 0, _names select 1, (count _names) - 2]
					}
				} else {
					private _singleKey = if (_seatKeys isNotEqualTo []) then {_seatKeys select 0} else {_seatKey};
					if !(_singleKey isEqualTo "") then {
						[_monitor, _singleKey] call CFM_fnc_getSeatDisplayName
					} else {""}
				}
			} else {""};
			SET_SELFVAR(_seatDisplayName);
			MON_SVAR(_monitor, _instanceIndex, "CFM_seatDisplayName", _seatDisplayName);

			["buildMenuActionLabels", [_isMultiMonitor]] CALL_SELF;
			MON_SVAR(_monitor, _instanceIndex, "CFM_operatorInfoText", OPERATOR_INFO_TEXT_DEF);
			MON_SVAR(_monitor, _instanceIndex, "CFM_canZoomAction", _canZoom);
			MON_SVAR(_monitor, _instanceIndex, "CFM_canConnectDroneAction", _canConnectDrone);
			MON_SVAR(_monitor, _instanceIndex, "CFM_canFixAction", _canFix);
			MON_SVAR(_monitor, _instanceIndex, "CFM_canSwitchTurretAction", _canSwitchTurret);
			MON_SVAR(_monitor, _instanceIndex, "CFM_canTurnOffLocalAction", _canTurnOffLocal);
			MON_SVAR(_monitor, _instanceIndex, "CFM_canSwitchNvgAction", _canSwitchNvg);
			MON_SVAR(_monitor, _instanceIndex, "CFM_canSwitchTiAction", _canSwitchTi);
		};

		_displayHandlerId = MON_GVAR(_monitor, _instanceIndex, "CFM_displayHandlerId", -1);
		if (_displayHandlerId <= 0) then {
			_displayHandlerId = ["setupMonitorDisplay", [_monitor, _instanceIndex]] CALL_CLASS("DbHandler");
		} else {
			[_monitor, "DisplayHandler", "_textureSelection", _textureSelection, false, _displayHandlerId] call OOP_FUNC(setVar);
			[_monitor, "DisplayHandler", "_originalTexture", _originalTexture, false, _displayHandlerId] call OOP_FUNC(setVar);
			[_monitor, "DisplayHandler", "_isHandMonitor", _isHandMonitor, false, _displayHandlerId] call OOP_FUNC(setVar);
		};
		SET_SELFVAR(_displayHandlerId);

		_isMonitorInstanceSet = true;
		MON_SVAR(_monitor, _instanceIndex, "CFM_isMonitorInstanceSet", true);
		_monitor setVariable ["CFM_availInstCache", nil];
		_monitor setVariable ["CFM_selInstCache", nil];

		if (_wasAlreadySet) then {
			["validateConnectedOperator"] CALL_SELF;
		};

		true
	};

	PUBLIC LOCAL METHOD("deinit") {
		if !(IS_OBJ(_monitor)) exitWith {false};
		private _monPair = [_monitor, _instanceIndex];
		private _curTexSel = MON_GVAR(_monitor, _instanceIndex, "CFM_textureSelection", _textureSelection);
		private _curOrigTex = MON_GVAR(_monitor, _instanceIndex, "CFM_originalTexture", _originalTexture);
		private _curIsLocal = MON_GVAR(_monitor, _instanceIndex, "CFM_isLocal", _isLocal);
		private _curOp = MON_GVAR(_monitor, _instanceIndex, "CFM_connectedOperator", _connectedOperator);
		private _curTurret = MON_GVAR(_monitor, _instanceIndex, "CFM_currentTurret", _currentTurret);

		if (hasInterface && {MON_GVAR(_monitor, _instanceIndex, "CFM_menuActive", false)}) then {
			[_monPair] call CFM_fnc_monitorCloseMenu;
		};
		if (hasInterface && {(missionNamespace getVariable ["CFM_currentFullScreenMonitor", [objNull, -1]]) isEqualTo _monPair}) then {
			["monitorExitFullScreen"] CALL_SELF;
		};
		if (MON_GVAR(_monitor, _instanceIndex, "CFM_feedActive", false)) then {
			[_monPair, false, false, false] call CFM_fnc_stopOperatorFeed;
		};
		if (IS_OBJ(_curOp)) then {
			["monitorDisconnected", [_monPair, _curTurret, objNull]] CALL_OBJCLASS("Operator", _curOp);
		};
		if (hasInterface && {_curTexSel >= 0}) then {
			_monitor setObjectTexture [_curTexSel, _curOrigTex];
		};

		private _posMap = _monitor getVariable ["CFM_monitorSelectionPositions", createHashMap];
		if (_instanceIndex in _posMap) then {
			_posMap deleteAt _instanceIndex;
			_monitor setVariable ["CFM_monitorSelectionPositions", _posMap];
		};

		["clearVariables"] CALL_SELF;

		_isMonitorInstanceSet = false;
		MON_SVAR(_monitor, _instanceIndex, "CFM_isMonitorInstanceSet", false);
		if (isServer && {!_curIsLocal}) then {
			MON_SVARG(_monitor, _instanceIndex, "CFM_isMonitorInstanceSet", false, true);
		};

		["removeFromList", [[_monPair], "CFM_Monitors"]] CALL_CLASS("DbHandler");
		_monitor setVariable ["CFM_availInstCache", nil];
		_monitor setVariable ["CFM_selInstCache", nil];
		true
	};

	PUBLIC LOCAL METHOD("updateSharedSeats") {
		params [["_newSeatKeys", []], ["_newControlSeatKeys", []]];
		if !(IS_OBJ(_monitor)) exitWith {false};
		private _curIsLocal = MON_GVAR(_monitor, _instanceIndex, "CFM_isLocal", _isLocal);
		_seatKeys = +_newSeatKeys;
		_seatKey = _seatKeys joinString ", ";
		_controlSeatKeys = +_newControlSeatKeys;
		MON_SVAR(_monitor, _instanceIndex, "CFM_seatKey", _seatKey);
		MON_SVAR(_monitor, _instanceIndex, "CFM_seatKeys", _seatKeys);
		MON_SVAR(_monitor, _instanceIndex, "CFM_controlSeatKeys", _controlSeatKeys);
		if (isServer && {!_curIsLocal}) then {
			MON_SVARG(_monitor, _instanceIndex, "CFM_seatKey", _seatKey, true);
			MON_SVARG(_monitor, _instanceIndex, "CFM_seatKeys", _seatKeys, true);
			MON_SVARG(_monitor, _instanceIndex, "CFM_controlSeatKeys", _controlSeatKeys, true);
		};
		_monitor setVariable ["CFM_availInstCache", nil];
		_monitor setVariable ["CFM_selInstCache", nil];
		["refreshSeatLabels", [true]] CALL_SELF;
		if (hasInterface && {MON_GVAR(_monitor, _instanceIndex, "CFM_menuActive", false)} && {!([_selfObj, _instanceIndex] call CFM_fnc_canControlMonitorSeat)}) then {
			[[_selfObj, _instanceIndex], _currentMenuObj] call CFM_fnc_monitorCloseMenu;
		};
		true
	};

	PRIVATE LOCAL METHOD("buildMenuActionLabels") {
		params [["_isMultiMonitor", false]];
		if !(hasInterface) exitWith {};
		private _curIsHand = MON_GVAR(_monitor, _instanceIndex, "CFM_isHandTablet", _isHandTablet);
		private _curIsVehSeat = MON_GVAR(_monitor, _instanceIndex, "CFM_isVehSeatTablet", _isVehSeatTablet);
		private _curTexSel = MON_GVAR(_monitor, _instanceIndex, "CFM_textureSelection", _textureSelection);
		private _curSeatKey = MON_GVAR(_monitor, _instanceIndex, "CFM_seatKey", _seatKey);
		private _curSeatKeys = MON_GVAR(_monitor, _instanceIndex, "CFM_seatKeys", _seatKeys);
		private _curSeatDispName = MON_GVAR(_monitor, _instanceIndex, "CFM_seatDisplayName", _seatDisplayName);
		private _menuText = if (_curIsHand) then {
			CFM_STR_HAND_TABLET_CAMERA_SYSTEM_MENU
		} else {
			if (_curIsVehSeat && {_curTexSel < 0}) then {
				CFM_STR_VEHICLE_TABLET_CAMERA_SYSTEM_MENU
			} else {
				CFM_STR_CAMERA_SYSTEM_MENU
			}
		};
		private _instTag = "";
		private _instTagDev = "";
		if !(_curIsHand) then {
			if (_curIsVehSeat && {!(_curSeatKey isEqualTo "")}) then {
				private _dispSeat = if (_curSeatDispName isEqualTo "") then {_curSeatKey} else {_curSeatDispName};
				private _devSeat = if ((count _curSeatKeys) > 3) then {
					format ["%1, %2 (+%3)", _curSeatKeys select 0, _curSeatKeys select 1, (count _curSeatKeys) - 2]
				} else {
					_curSeatKey
				};
				if (_curTexSel >= 0) then {
					_instTag = format [" [%1 #%2]", _dispSeat, _curTexSel];
					_instTagDev = format [" [%1 #%2]", _devSeat, _curTexSel];
				} else {
					_instTag = format [" [%1]", _dispSeat];
					_instTagDev = format [" [%1]", _devSeat];
				};
			} else {
				if (_isMultiMonitor || {_instanceIndex > 1}) then {
					_instTag = format [" [#%1]", _instanceIndex];
					_instTagDev = _instTag;
				};
			};
		};
		private _menuLabel = format ["<t color='#00FF00'>%1%2</t>", _menuText, _instTag];
		private _menuLabelDev = format ["<t color='#00FF00'>%1%2</t>", _menuText, _instTagDev];
		MON_SVAR(_monitor, _instanceIndex, "CFM_menuActionLabel", _menuLabel);
		MON_SVAR(_monitor, _instanceIndex, "CFM_menuActionLabelDev", _menuLabelDev);
	};

	PRIVATE GE GA METHOD("activateSeat") {
		if !(hasInterface) exitWith {false};
		if !(IS_OBJ(_monitor)) exitWith {false};
		private _monPair = [_monitor, _instanceIndex];
		if (IS_OBJ(_connectedOperator)) then {
			if !([_connectedOperator, _monPair] call CFM_fnc_operatorCondition) exitWith {
				["disconnect"] CALL_SELF;
				false
			};
			if (_feedActive && {IS_OBJ(_currentFeedCam)}) exitWith {true};
			if (_isHandMonitor) then {
				_pipSlot = [_monPair, _pipSlot] call CFM_fnc_getFreePipSlot;
				MON_SVAR(_monitor, _instanceIndex, "CFM_pipSlot", _pipSlot);
			};
			private _startTurret = if (_isVehSeatTablet && {_textureSelection < 0} && {(count _seatKeys) > 1}) then {
				MON_GVAR(_monitor, _instanceIndex, "CFM_waitingForStartTurret", _currentTurret)
			} else {
				_currentTurret
			};
			[_monPair, _connectedOperator, true, _startTurret, true] spawn CFM_fnc_syncState;
			true
		} else {
			MON_SVAR(_monitor, _instanceIndex, "CFM_waitingForStart", false);
			if (_feedActive) then {
				[_monPair, false, true, false] call CFM_fnc_stopOperatorFeed;
			};
			false
		};
	};

	PRIVATE GE GA METHOD("deactivateSeat") {
		if !(hasInterface) exitWith {false};
		if !(IS_OBJ(_monitor)) exitWith {false};
		private _monPair = [_monitor, _instanceIndex];
		[_monPair] call CFM_fnc_monitorCloseMenu;

		// For seat-bound 3D screens ([seatKey, texSel]), keep local feed running when client setting allows
		if (!_isHandMonitor && {missionNamespace getVariable ["CFM_renderSeatTextureOutOfSeat", true]}) exitWith {true};

		MON_SVAR(_monitor, _instanceIndex, "CFM_waitingForStart", false);
		if (MON_GVAR(_monitor, _instanceIndex, "CFM_feedActive", false)) then {
			[_monPair, false, true, false] call CFM_fnc_stopOperatorFeed;
		};
		true
	};

	PUBLIC GE GA METHOD("syncContinuousZoom") {
		private _isSingleSeatPip = _isVehSeatTablet && {_textureSelection < 0} && {(count _seatKeys) <= 1};
		private _syncGlobal = !_isLocal && {!_isSingleSeatPip};
		private _valMaxZoomed = MON_GVAR(_monitor, _instanceIndex, "CFM_maxZoomed", false);
		private _valZoom = MON_GVAR(_monitor, _instanceIndex, "CFM_zoom", 1);
		private _valZoomFov = MON_GVAR(_monitor, _instanceIndex, "CFM_zoomFov", 1);
		if (_syncGlobal || _isVehSeatTablet) then {
			private _pub = !_isLocal;
			MON_SVARG(_monitor, _instanceIndex, "CFM_maxZoomed", _valMaxZoomed, _pub);
			MON_SVARG(_monitor, _instanceIndex, "CFM_zoom", _valZoom, _pub);
			MON_SVARG(_monitor, _instanceIndex, "CFM_zoomFov", _valZoomFov, _pub);
			MON_SVARG(_monitor, _instanceIndex, "CFM_doUpdateCamera", true, _pub);
		};
		true
	};

	PRIVATE LOCAL METHOD("clearVariables") {
		{
			MON_SVAR(_monitor, _instanceIndex, _x, nil);
		} forEach [
			"CFM_monitorCanSwitchNvg",
			"CFM_monitorCanSwitchTi",
			"CFM_currentOpHasTurrets",
			"CFM_cameraType",
			"CFM_currentTiTable",
			"CFM_currentNvgParam",
			"CFM_currentTurret",
			"CFM_currentPiPEffect",
			"CFM_currentFeedCam",
			"CFM_connectedOperator",
			"CFM_zoom",
			"CFM_zoomMax",
			"CFM_zoomTable",
			"CFM_zoomFov",
			"CFM_maxZoomed",
			"CFM_turretLocal",
			"CFM_currentCameraType",
			"CFM_currentOperatorIsDrone",
			"CFM_cameraPosFunc",
			"CFM_actionCaller",
			"CFM_isInNvg",
			"CFM_turnedOffLocal",
			"CFM_currentCamPointParams",
			"CFM_camDoInterpolation",
			"CFM_currentCameraMoveRestrictions",
			"CFM_currentCameraMoves",
			"CFM_currentCameraCanMove",
			"CFM_currentCameraIsStatic",
			"CFM_currentCameraSmoothZoom",
			"CFM_camInterp_lastDir",
			"CFM_camInterp_lastUp",
			"CFM_camInterp_lastFov",
			"CFM_doUpdateCamera",
			"CFM_cam_prevSetPos",
			"CFM_waitingForStartOperator",
			"CFM_waitingForStartTurret"
		];
		MON_SVAR(_monitor, _instanceIndex, "CFM_feedActive", nil);
		MON_SVAR(_monitor, _instanceIndex, "CFM_menuActive", false);
	};

	PRIVATE LOCAL METHOD("refreshSeatLabels") {
		params [["_recomputeSeatName", true]];
		if !(hasInterface) exitWith {};
		if (_recomputeSeatName) then {
			private _curIsVehSeat = MON_GVAR(_monitor, _instanceIndex, "CFM_isVehSeatTablet", _isVehSeatTablet);
			private _curSeatKeys = MON_GVAR(_monitor, _instanceIndex, "CFM_seatKeys", _seatKeys);
			private _curSeatKey = MON_GVAR(_monitor, _instanceIndex, "CFM_seatKey", _seatKey);
			_seatDisplayName = if (_curIsVehSeat) then {
				if ((count _curSeatKeys) > 1) then {
					private _names = _curSeatKeys apply {[_monitor, _x] call CFM_fnc_getSeatDisplayName};
					if ((count _names) <= 2) then {
						_names joinString " + "
					} else {
						format ["%1, %2 (+%3)", _names select 0, _names select 1, (count _names) - 2]
					}
				} else {
					private _singleKey = if (_curSeatKeys isNotEqualTo []) then {_curSeatKeys select 0} else {_curSeatKey};
					if !(_singleKey isEqualTo "") then {
						[_monitor, _singleKey] call CFM_fnc_getSeatDisplayName
					} else {""}
				}
			} else {""};
			SET_SELFVAR(_seatDisplayName);
			MON_SVAR(_monitor, _instanceIndex, "CFM_seatDisplayName", _seatDisplayName);
		};
		private _isMultiMonitor = (count (_monitor getVariable ["CFM_monitorInstanceKeysMap", createHashMap])) > 1;
		["buildMenuActionLabels", [_isMultiMonitor]] CALL_SELF;
		if (_selfObj getVariable ["CFM_isMonitorHostCreated", false] && {([_selfObj] call CFM_fnc_getSelectedMonitorInstance) isEqualTo _instanceIndex}) then {
			["syncSelectedActionLabels", [_instanceIndex]] CALL_OBJCLASS("MonitorHost", _selfObj);
		};
	};

	PRIVATE LOCAL METHOD("validateConnectedOperator") {
		private _curIsLocal = MON_GVAR(_selfObj, _instanceIndex, "CFM_isLocal", _isLocal);
		private _curOp = MON_GVAR(_selfObj, _instanceIndex, "CFM_connectedOperator", _connectedOperator);
		if ((isServer || _curIsLocal) && {IS_OBJ(_curOp)} && {!([_curOp, [_selfObj, _instanceIndex]] call CFM_fnc_operatorCondition)}) then {
			["disconnect"] CALL_SELF;
		};
	};

	//----------- Config set -----------
	PUBLIC LE GA METHOD("setScreenResolution") {
		params [["_screenResolutionSet", ""]];
		private _parsedScreenRes = [_screenResolutionSet, _monitor] call CFM_fnc_parseScreenResolution;
		if (_parsedScreenRes isEqualTo []) then {
			_parsedScreenRes = [_monitor] call CFM_fnc_getDefaultScreenResolution;
		};
		_screenResolution = _parsedScreenRes;
		MON_SVAR(_monitor, _instanceIndex, "CFM_screenResolution", _screenResolution);
		if (hasInterface && {_feedActive}) then {
			[[_selfObj, _instanceIndex]] spawn CFM_fnc_resetFeed;
		};
		_screenResolution
	};

	PUBLIC GE GA METHOD("grantAccess") {
		params["_plrId"];
		if !(_plrId isEqualType "") exitWith {};
		if (_plrId isEqualTo "") exitWith {};
		[_monitor, MON_VAR_NAME("CFM_passwordAccess", _instanceIndex), _plrId, true, false, !_isLocal, !_isLocal] call CFM_fnc_pushBackNet;
	};

	PUBLIC LE GA METHOD("setTextureSelection") {
		params [["_texSelArg", NO_TEXTURE_SELECTION]];
		if !(_texSelArg isEqualType 0) exitWith {false};
		private _monitorTextures = if (_texSelArg >= 0) then {getObjectTextures _monitor} else {[]};
		if (_texSelArg >= 0 && {_texSelArg >= (count _monitorTextures)}) exitWith {
			format["Monitor::setTextureSelection: Object '%1' has no texture selection %2!", _monitor, _texSelArg] WARN;
			false
		};
		if (hasInterface && {_textureSelection >= 0} && {_textureSelection != _texSelArg}) then {
			_monitor setObjectTexture [_textureSelection, _originalTexture];
		};
		_textureSelection = _texSelArg;
		_isHandMonitor = _isHandTablet || (_isVehSeatTablet && {_textureSelection < 0});
		_originalTexture = if (_textureSelection >= 0) then {
			private _tex = _monitorTextures param [_textureSelection, ""];
			if (isNil "_tex") then {""} else {_tex}
		} else {""};
		MON_SVAR(_monitor, _instanceIndex, "CFM_textureSelection", _textureSelection);
		MON_SVAR(_monitor, _instanceIndex, "CFM_originalTexture", _originalTexture);
		MON_SVAR(_monitor, _instanceIndex, "CFM_isHandMonitor", _isHandMonitor);
		if (_displayHandlerId > 0) then {
			[_monitor, "DisplayHandler", "_textureSelection", _textureSelection, false, _displayHandlerId] call OOP_FUNC(setVar);
			[_monitor, "DisplayHandler", "_originalTexture", _originalTexture, false, _displayHandlerId] call OOP_FUNC(setVar);
			[_monitor, "DisplayHandler", "_isHandMonitor", _isHandMonitor, false, _displayHandlerId] call OOP_FUNC(setVar);
		};
		if (_textureSelection >= 0) then {
			[_monitor, _textureSelection, _instanceIndex] call CFM_fnc_cacheMonitorSelectionPos;
		};
		_monitor setVariable ["CFM_availInstCache", nil];
		_monitor setVariable ["CFM_selInstCache", nil];
		["refreshSeatLabels", [false]] CALL_SELF;
		if (hasInterface && {_feedActive}) then {
			[[_selfObj, _instanceIndex]] spawn CFM_fnc_resetFeed;
		};
		true
	};

	PUBLIC LE GA METHOD("setSeatKey") {
		params [["_seatKeyArg", ""]];
		if !(_seatKeyArg isEqualType "") exitWith {false};
		_seatKey = _seatKeyArg;
		if (_seatKeys isEqualTo [] && {!(_seatKey isEqualTo "")}) then {
			_seatKeys = [_seatKey];
			MON_SVAR(_monitor, _instanceIndex, "CFM_seatKeys", _seatKeys);
		};
		MON_SVAR(_monitor, _instanceIndex, "CFM_seatKey", _seatKey);
		_monitor setVariable ["CFM_availInstCache", nil];
		_monitor setVariable ["CFM_selInstCache", nil];
		["refreshSeatLabels", [true]] CALL_SELF;
		true
	};

	PUBLIC LE GA METHOD("setSeatKeys") {
		params [["_seatKeysArg", []]];
		if !(_seatKeysArg isEqualType []) exitWith {false};
		_seatKeys = _seatKeysArg select {_x isEqualType ""};
		if (_seatKey isEqualTo "" && {_seatKeys isNotEqualTo []}) then {
			_seatKey = _seatKeys select 0;
			MON_SVAR(_monitor, _instanceIndex, "CFM_seatKey", _seatKey);
		};
		MON_SVAR(_monitor, _instanceIndex, "CFM_seatKeys", _seatKeys);
		_monitor setVariable ["CFM_availInstCache", nil];
		_monitor setVariable ["CFM_selInstCache", nil];
		["refreshSeatLabels", [true]] CALL_SELF;
		true
	};

	PUBLIC LE GA METHOD("setControlSeatKeys") {
		params [["_controlSeatKeysArg", []]];
		if !(_controlSeatKeysArg isEqualType []) exitWith {false};
		_controlSeatKeys = _controlSeatKeysArg select {_x isEqualType ""};
		MON_SVAR(_monitor, _instanceIndex, "CFM_controlSeatKeys", _controlSeatKeys);
		if (hasInterface && {_menuActive} && {!([_selfObj, _instanceIndex] call CFM_fnc_canControlMonitorSeat)}) then {
			[[_selfObj, _instanceIndex], _currentMenuObj] call CFM_fnc_monitorCloseMenu;
		};
		true
	};

	PUBLIC LE GA METHOD("setIsVehSeatTablet") {
		params [["_isVehSeatArg", false]];
		if !(_isVehSeatArg isEqualType false) exitWith {false};
		_isVehSeatTablet = _isVehSeatArg;
		_isHandMonitor = _isHandTablet || (_isVehSeatTablet && {_textureSelection < 0});
		MON_SVAR(_monitor, _instanceIndex, "CFM_isVehSeatTablet", _isVehSeatTablet);
		MON_SVAR(_monitor, _instanceIndex, "CFM_isHandMonitor", _isHandMonitor);
		if (_displayHandlerId > 0) then {
			[_monitor, "DisplayHandler", "_isHandMonitor", _isHandMonitor, false, _displayHandlerId] call OOP_FUNC(setVar);
		};
		_monitor setVariable ["CFM_availInstCache", nil];
		_monitor setVariable ["CFM_selInstCache", nil];
		["refreshSeatLabels", [true]] CALL_SELF;
		true
	};

	PUBLIC LE GA METHOD("setIsHandTablet") {
		params [["_isHandArg", false]];
		if !(_isHandArg isEqualType false) exitWith {false};
		_isHandTablet = _isHandArg;
		_isHandMonitor = _isHandTablet || (_isVehSeatTablet && {_textureSelection < 0});
		MON_SVAR(_monitor, _instanceIndex, "CFM_isHandTablet", _isHandTablet);
		MON_SVAR(_monitor, _instanceIndex, "CFM_isHandMonitor", _isHandMonitor);
		if (_displayHandlerId > 0) then {
			[_monitor, "DisplayHandler", "_isHandMonitor", _isHandMonitor, false, _displayHandlerId] call OOP_FUNC(setVar);
		};
		_monitor setVariable ["CFM_availInstCache", nil];
		_monitor setVariable ["CFM_selInstCache", nil];
		["refreshSeatLabels", [false]] CALL_SELF;
		true
	};

	PUBLIC LE GA METHOD("setSeatDisplayName") {
		params [["_seatDisplayNameArg", ""]];
		if !(_seatDisplayNameArg isEqualType "") exitWith {false};
		_seatDisplayName = _seatDisplayNameArg;
		SET_SELFVAR(_seatDisplayName);
		MON_SVAR(_monitor, _instanceIndex, "CFM_seatDisplayName", _seatDisplayName);
		["refreshSeatLabels", [false]] CALL_SELF;
		true
	};

	PUBLIC LE GA METHOD("setMonitorSides") {
		params [["_sidesArg", []]];
		if !(_sidesArg isEqualType []) then {_sidesArg = [_sidesArg]};
		_sidesArg = _sidesArg select {_x isEqualType west};
		_monitorSides = _sidesArg;
		MON_SVAR(_monitor, _instanceIndex, "CFM_monitorSides", _monitorSides);
		["validateConnectedOperator"] CALL_SELF;
		true
	};

	PUBLIC LE GA METHOD("setOriginalTexture") {
		params [["_origTexArg", ""]];
		if !(_origTexArg isEqualType "") exitWith {false};
		_originalTexture = _origTexArg;
		MON_SVAR(_monitor, _instanceIndex, "CFM_originalTexture", _originalTexture);
		if (_displayHandlerId > 0) then {
			[_monitor, "DisplayHandler", "_originalTexture", _originalTexture, false, _displayHandlerId] call OOP_FUNC(setVar);
		};
		if (hasInterface && {!_feedActive} && {_textureSelection >= 0}) then {
			_monitor setObjectTexture [_textureSelection, _originalTexture];
		};
		true
	};

	PUBLIC LE GA METHOD("setAllowedOperators") {
		params [["_allowedOpsArg", []]];
		if !(_allowedOpsArg isEqualTypeAny [objNull, []]) exitWith {false};
		if !(_allowedOpsArg isEqualType []) then {_allowedOpsArg = [_allowedOpsArg]};
		_allowedOperators = _allowedOpsArg select {_x isEqualType objNull};
		MON_SVAR(_monitor, _instanceIndex, "CFM_allowedOperators", _allowedOperators);
		["validateConnectedOperator"] CALL_SELF;
		true
	};

	PUBLIC LE GA METHOD("setAllowedOperatorsTypes") {
		params [["_allowedTypesArg", []]];
		if !(_allowedTypesArg isEqualTypeAny ["", 1, []]) exitWith {false};
		if !(_allowedTypesArg isEqualType []) then {_allowedTypesArg = [_allowedTypesArg]};
		_allowedOperatorsTypes = _allowedTypesArg select {(_x isEqualType "") || {(_x isEqualType 1)}};
		MON_SVAR(_monitor, _instanceIndex, "CFM_allowedOperatorsTypes", _allowedOperatorsTypes);
		["validateConnectedOperator"] CALL_SELF;
		true
	};

	PUBLIC LE GA METHOD("setCanFullScreen") {
		params [["_canFullScreenArg", false]];
		if !(_canFullScreenArg isEqualType false) exitWith {false};
		_canFullScreen = _canFullScreenArg;
		MON_SVAR(_monitor, _instanceIndex, "CFM_canFullScreen", _canFullScreen);
		if (hasInterface) then {
			if (_canFullScreen) then {
				if (_monitor getVariable ["CFM_isMonitorHostCreated", false]) then {
					["ensureHostActions", [false, false, false, false, false, false, false, false, false, false, false, true]] CALL_OBJCLASS("MonitorHost", _monitor);
				};
			} else {
				private _curFullMon = missionNamespace getVariable ["CFM_currentFullScreenMonitor", [objNull, -1]];
				if (_curFullMon isEqualTo [_selfObj, _instanceIndex]) then {
					["monitorExitFullScreen"] CALL_SELF;
				};
			};
		};
		true
	};

	PUBLIC LE GA METHOD("setCanSetPassword") {
		params [["_canSetPasswordArg", true]];
		if !(_canSetPasswordArg isEqualType false) exitWith {false};
		_canSetPassword = _canSetPasswordArg && {!_isHandMonitor || _isVehSeatTablet};
		MON_SVAR(_monitor, _instanceIndex, "CFM_canSetPassword", _canSetPassword);
		true
	};

	//----------- State set -----------
	PUBLIC LE GA GLOBAL METHOD("startFeed") {
		params [["_operator", objNull], ["_turret", []], ["_reset", false]];

		private _monitor = _selfObj;
		private _monPair = [_monitor, _instanceIndex];

		if !(IS_OBJ(_monitor)) exitWith {[false, "CFM_fnc_startOperatorFeed: Monitor is not an object"]};
		if !(IS_OBJ(_operator)) exitWith {[false, "CFM_fnc_startOperatorFeed: Operator is not an object"]};

		if (_turret isEqualTo []) then {
			_turret = _currentTurret;
		};
		private _turretIndex = TURRET_INDEX(_turret);
		_currentTurret = [_turretIndex];
		MON_SVAR(_monitor, _instanceIndex, "CFM_currentTurret", +_currentTurret);
		MON_SVAR(_monitor, _instanceIndex, "CFM_actionCaller", nil);

		private _monR2Tid = MON_GVAR(_monitor, _instanceIndex, "CFM_monitorR2Tid", _monitorR2Tid);
		private _camera = ["spawnCamera", [_monitor, _monR2Tid], nil, ["NONE", objNull]] CALL_CLASS("CameraManager");

		if (hasInterface && {!(IS_OBJ(_camera))}) exitWith {
			MON_SVAR(_monitor, _instanceIndex, "CFM_feedActive", false);
			MON_SVAR(_monitor, _instanceIndex, "CFM_menuActive", false);
			format["ERROR: CAN'T CONNECT TO OPERATOR: CAN'T CREATE CAMERA. Monitor: %1 . RenderTarget: %2", _monPair, _monR2Tid] WARN;
			false
		};

		MON_SVAR(_monitor, _instanceIndex, "CFM_currentFeedCam", _camera);
		MON_SVAR(_monitor, _instanceIndex, "CFM_feedActive", true);
		MON_SVAR(_monitor, _instanceIndex, "CFM_connectedOperator", _operator);

		private _initFov = MON_GVAR(_monitor, _instanceIndex, "CFM_zoomFov", 1);
		if (_initFov isEqualType 1) then {
			_camera camSetFov _initFov;
			_camera camCommit 0;
		};

		["monitorConnected", [_monPair, _turretIndex, _actionCaller, _reset], "NULL"] CALL_OBJCLASS("Operator", _operator);
		["addActiveMonitor", [_monPair]] CALL_CLASS("DbHandler");

		["addActiveViewer", [PLAYER_]] CALL_CLASS("DbHandler");
		["monitorAddActiveViewer", [_monPair, PLAYER_]] CALL_CLASS("DbHandler");

		[_monPair, _currentMenuObj] call CFM_fnc_monitorCloseMenu;

		if (_isHandMonitor && {hasInterface}) then {
			if !(_reset) then {
				private _slot = [_monPair, MON_GVAR(_monitor, _instanceIndex, "CFM_pipSlot", PIP_SLOT_RIGHT)] call CFM_fnc_getFreePipSlot;
				MON_SVAR(_monitor, _instanceIndex, "CFM_pipSlot", _slot);
			};
			private _prevHndl = MON_GVAR(_monitor, _instanceIndex, "CFM_opCheckHndl", scriptNull);
			private _opCheckHndl = [_monitor, _instanceIndex, _operator, _prevHndl] spawn {
				params["_monitor", "_instId", "_operator", "_prevHndl"];
				terminate _prevHndl;
				waitUntil {scriptDone _prevHndl};
				private _monPair = [_monitor, _instId];
				private _currentOperator = _operator;
				private _signalLost = false;
				while {MON_GVAR(_monitor, _instId, "CFM_feedActive", false)} do {
					_currentOperator = MON_GVAR(_monitor, _instId, "CFM_connectedOperator", objNull);
					if !(_currentOperator isEqualTo _operator) exitWith {break};
					if !([_operator, _monPair] call CFM_fnc_operatorCondition) exitWith {
						_signalLost = true;
						break
					};
					sleep 1;
				};
				if !(_signalLost) exitWith {};
				if !(IS_OBJ(MON_GVAR(_monitor, _instId, "CFM_connectedOperator", objNull))) exitWith {};
				[_monPair, player] call CFM_fnc_disconnectMonitorFromOperator;
			};
			MON_SVAR(_monitor, _instanceIndex, "CFM_opCheckHndl", _opCheckHndl);
		};

		true
	};

	PUBLIC LE GA GLOBAL METHOD("stopFeed") {
		params[["_reset", false], ["_isOptimize", false]];
		private _monPair = [_selfObj, _instanceIndex];

		private _curFullMon = missionNamespace getVariable ["CFM_currentFullScreenMonitor", [objNull, -1]];
		if (_curFullMon isEqualTo _monPair) then {
			closeDialog 1;
			call CFM_fnc_onTempDisplayUnload;
		};
		if (!_isOptimize && {IS_OBJ(_connectedOperator)}) then {
			["monitorDisconnected", [_monPair, _currentTurret, _actionCaller]] CALL_OBJCLASS("Operator", _connectedOperator);
		};
		MON_SVAR(_selfObj, _instanceIndex, "CFM_actionCaller", nil);
		["removeActiveMonitor", [_monPair]] CALL_CLASS("DbHandler");
		["setOperatorInfo", [false]] CALL_SELF;

		private _monR2Tid = MON_GVAR(_monitor, _instanceIndex, "CFM_monitorR2Tid", _monitorR2Tid);
		["destroyCamera", [_currentFeedCam, _monR2Tid]] CALL_CLASS("CameraManager");

		if (_displayHandlerId > 0) then {
			["stopRendering", [_reset]] CALL_DH_INST(_monitor, _displayHandlerId);
		};

		if (_isOptimize) then {
			["monitorRemoveActiveViewer", [_monPair, PLAYER_]] CALL_CLASS("DbHandler");
			MON_SVAR(_monitor, _instanceIndex, "CFM_currentFeedCam", nil);
			MON_SVAR(_monitor, _instanceIndex, "CFM_feedActive", false);
			MON_SVAR(_monitor, _instanceIndex, "CFM_menuActive", false);
			MON_SVAR(_monitor, _instanceIndex, "CFM_actionCaller", nil);
			MON_SVAR(_monitor, _instanceIndex, "CFM_camInterp_lastDir", nil);
			MON_SVAR(_monitor, _instanceIndex, "CFM_camInterp_lastUp", nil);
			MON_SVAR(_monitor, _instanceIndex, "CFM_camInterp_lastFov", nil);
			MON_SVAR(_monitor, _instanceIndex, "CFM_doUpdateCamera", nil);
			MON_SVAR(_monitor, _instanceIndex, "CFM_cam_prevSetPos", nil);
		} else {
			if !(_reset) then {
				["monitorRemoveActiveViewer", [_monPair, PLAYER_]] CALL_CLASS("DbHandler");
				["clearVariables"] CALL_SELF;
			};
		};
	};

	PUBLIC GE GA LOCAL METHOD("connect") {
		params["_op", ["_caller", objNull]];
		if !(IS_OBJ(_op)) exitWith {false};

		private _monPair = [_selfObj, _instanceIndex];
		private _prevOp = _connectedOperator;
		private _prevTurr = _currentTurret;

		MON_SVAR(_selfObj, _instanceIndex, "CFM_actionCaller", _caller);

		private _initTurret = (_op getVariable ["CFM_turrets", DRIVER_TURRET_PATH]) param [0, DRIVER_TURRET_PATH];
		private _initTurrIdx = TURRET_INDEX(_initTurret);
		private _disabledTurrs = _op getVariable ["CFM_disabledTurrets", []];
		if (_initTurrIdx in _disabledTurrs) then {
			private _activeTurrs = _op getVariable ["CFM_turrets", [DRIVER_TURRET_PATH]];
			_initTurrIdx = TURRET_INDEX(_activeTurrs param [0 I DRIVER_TURRET_PATH]);
		};

		if (_isHandMonitor && {!(MON_GVAR(_selfObj, _instanceIndex, "CFM_feedActive", false))}) then {
			private _slot = [_monPair, MON_GVAR(_selfObj, _instanceIndex, "CFM_pipSlot", PIP_SLOT_RIGHT)] call CFM_fnc_getFreePipSlot;
			MON_SVAR(_selfObj, _instanceIndex, "CFM_pipSlot", _slot);
		};

		private _pub = !_isLocal;
		private _isSingleSeatPip = _isVehSeatTablet && {_textureSelection < 0} && {(count _seatKeys) <= 1};

		MON_SVARG(_selfObj, _instanceIndex, "CFM_connectedOperator", _op, _pub);
		MON_SVARG(_selfObj, _instanceIndex, "CFM_waitingForStartTurret", _initTurrIdx, _pub && {!_isSingleSeatPip});
		MON_SVARG(_selfObj, _instanceIndex, "CFM_currentTurret", [_initTurrIdx], _pub);
		MON_SVARG(_selfObj, _instanceIndex, "CFM_currentPiPEffect", 0, _pub);
		MON_SVARG(_selfObj, _instanceIndex, "CFM_isInNvg", false, _pub);
		MON_SVARG(_selfObj, _instanceIndex, "CFM_zoom", 1, _pub);
		MON_SVARG(_selfObj, _instanceIndex, "CFM_zoomFov", 1, _pub);
		MON_SVARG(_selfObj, _instanceIndex, "CFM_maxZoomed", false, _pub);
		MON_SVAR(_selfObj, _instanceIndex, "CFM_turnedOffLocal", false);

		if (_isSingleSeatPip) then {
			// Single-seat PiP tablets sync operator notifications to operator owner and run feed only locally for seated client
			if (IS_OBJ(_prevOp) && {!(_prevOp isEqualTo _op) || {!(TURRET_INDEX(_prevTurr) isEqualTo _initTurrIdx)}}) then {
				["CFM_operatorMonitorDisconnected", [_prevOp, _monPair, _prevTurr], _prevOp] call CBA_fnc_targetEvent;
			};
			["CFM_operatorMonitorConnected", [_op, _monPair, [_initTurrIdx]], _op] call CBA_fnc_targetEvent;
			[_monPair, _op, true, [_initTurrIdx], true] spawn CFM_fnc_syncState;
		} else {
			private _jipKey = if (_isLocal) then {false} else {format ["cfm_mon_%1_%2", netId _selfObj, _instanceIndex]};
			["CFM_syncMonitorState", [[netId _selfObj, _instanceIndex], netId _op, true, _initTurrIdx, false], _pub, _jipKey] call CFM_fnc_remoteEvent;
		};

		[_monPair] call CFM_fnc_monitorCloseMenu;
		true
	};

	PUBLIC GE GA LOCAL METHOD("disconnect") {
		params[["_caller", objNull]];
		private _monPair = [_selfObj, _instanceIndex];
		private _prevOp = _connectedOperator;
		private _prevTurr = _currentTurret;

		MON_SVAR(_selfObj, _instanceIndex, "CFM_actionCaller", _caller);

		private _isSingleSeatPip = _isVehSeatTablet && {_textureSelection < 0} && {(count _seatKeys) <= 1};
		if (_isSingleSeatPip) then {
			MON_SVARG(_selfObj, _instanceIndex, "CFM_connectedOperator", objNull, true);
			MON_SVARG(_selfObj, _instanceIndex, "CFM_currentTurret", DRIVER_TURRET_PATH, true);
			MON_SVARG(_selfObj, _instanceIndex, "CFM_currentPiPEffect", 0, true);
			MON_SVARG(_selfObj, _instanceIndex, "CFM_isInNvg", false, true);
			MON_SVARG(_selfObj, _instanceIndex, "CFM_zoom", 1, true);
			MON_SVARG(_selfObj, _instanceIndex, "CFM_zoomFov", 1, true);
			MON_SVARG(_selfObj, _instanceIndex, "CFM_maxZoomed", false, true);
			MON_SVAR(_selfObj, _instanceIndex, "CFM_turnedOffLocal", false);

			if (IS_OBJ(_prevOp)) then {
				["CFM_operatorMonitorDisconnected", [_prevOp, _monPair, _prevTurr], _prevOp] call CBA_fnc_targetEvent;
			};

			MON_SVAR(_selfObj, _instanceIndex, "CFM_waitingForStart", false);
			if (hasInterface && {MON_GVAR(_selfObj, _instanceIndex, "CFM_feedActive", false)}) then {
				[_monPair, false, false, false] call CFM_fnc_stopOperatorFeed;
			} else {
				["clearVariables"] CALL_SELF;
			};
		} else {
			private _pub = !_isLocal;
			private _jipKey = if (_isLocal) then {false} else {format ["cfm_mon_%1_%2", netId _selfObj, _instanceIndex]};
			["CFM_syncMonitorState", [[netId _selfObj, _instanceIndex], "", false, -1, false], _pub, _jipKey] call CFM_fnc_remoteEvent;
		};

		[_monPair] call CFM_fnc_monitorCloseMenu;
	};

	PUBLIC GE GA METHOD("zoom") {
		params [["_zoomAdd", 0], ["_zoomSet", -1], ["_isContinuous", false, [false]]];

		if ((_zoomAdd isEqualType 1) && {(_zoomAdd > 0) && _maxZoomed}) exitWith {_zoom};

		private _newMaxZoomed = false;
		private _newzoom = if (_zoomAdd isEqualType 1) then {
			private _valZoomMax = MON_GVAR(_monitor, _instanceIndex, "CFM_zoomMax", 1);
			private _valZoom = if (_zoomSet isEqualTo -1) then {
				private _z = MON_GVAR(_monitor, _instanceIndex, "CFM_zoom", 1);
				if !(_z isEqualType 1) then {_z = 1};
				if (!_isContinuous && {(_z % 1) != 0}) then {
					if (_zoomAdd > 0) then {(floor _z) + _zoomAdd} else {(ceil _z) + _zoomAdd};
				} else {
					_z + _zoomAdd
				};
			} else {
				_zoomSet
			};
			_valZoom = (_valZoom max 1) min _valZoomMax;
			_newMaxZoomed = _valZoom >= _valZoomMax;
			_valZoom
		} else {
			_newMaxZoomed = false;
			_zoomAdd
		};

		private _fov = if (_newzoom isEqualType 1) then {
			private _zLow = floor _newzoom;
			private _zHigh = ceil _newzoom;
			private _fovLow = _zoomTable getOrDefault [_zLow, 1 / (_zLow max 1)];
			if (_zLow == _zHigh) then {
				_fovLow
			} else {
				private _fovHigh = _zoomTable getOrDefault [_zHigh, 1 / (_zHigh max 1)];
				_fovLow + (_fovHigh - _fovLow) * (_newzoom - _zLow)
			};
		} else {_newzoom};

		if (_zoomAdd isEqualTo "reset") then {
			_fov = 0.9;
			_newzoom = 1;
			_newMaxZoomed = false;
		};

		private _pub = !_isLocal && {!(_isVehSeatTablet && {_textureSelection < 0} && {(count _seatKeys) <= 1})};

		if (_isContinuous) then {
			MON_SVAR(_monitor, _instanceIndex, "CFM_maxZoomed", _newMaxZoomed);
			MON_SVAR(_monitor, _instanceIndex, "CFM_zoom", _newzoom);
			MON_SVAR(_monitor, _instanceIndex, "CFM_zoomFov", _fov);
			MON_SVAR(_monitor, _instanceIndex, "CFM_doUpdateCamera", true);

			if ((diag_tickTime - (MON_GVAR(_monitor, _instanceIndex, "CFM_contZoomLastNetSync", 0))) >= 0.1) then {
				MON_SVAR(_monitor, _instanceIndex, "CFM_contZoomLastNetSync", diag_tickTime);
				if (_pub) then {
					MON_SVARG(_monitor, _instanceIndex, "CFM_maxZoomed", _newMaxZoomed, true);
					MON_SVARG(_monitor, _instanceIndex, "CFM_zoom", _newzoom, true);
					MON_SVARG(_monitor, _instanceIndex, "CFM_zoomFov", _fov, true);
					MON_SVARG(_monitor, _instanceIndex, "CFM_doUpdateCamera", true, true);
				};
			};
		} else {
			MON_SVARG(_monitor, _instanceIndex, "CFM_maxZoomed", _newMaxZoomed, _pub);
			MON_SVARG(_monitor, _instanceIndex, "CFM_zoom", _newzoom, _pub);
			MON_SVARG(_monitor, _instanceIndex, "CFM_zoomFov", _fov, _pub);
			MON_SVARG(_monitor, _instanceIndex, "CFM_doUpdateCamera", true, _pub);
		};

		_newzoom
	};

	PUBLIC GE GA METHOD("nextTurret") {
		private _syncGlobal = !_isLocal && {!(_isVehSeatTablet && {_textureSelection < 0} && {(count _seatKeys) <= 1})};
		MON_SVARG(_monitor, _instanceIndex, "CFM_currentPiPEffect", 0, _syncGlobal);
		MON_SVARG(_monitor, _instanceIndex, "CFM_doUpdatePip", true, _syncGlobal);
		MON_SVARG(_monitor, _instanceIndex, "CFM_isInNvg", false, _syncGlobal);
		["NextTurret", [[_monitor, _instanceIndex], MON_GVAR(_monitor, _instanceIndex, "CFM_currentTurret", -1)]] CALL_OBJCLASS("Operator", _connectedOperator);
	};

	PUBLIC GE GA METHOD("setTurret") {
		params[["_turretIndex", -1]];
		private _syncGlobal = !_isLocal && {!(_isVehSeatTablet && {_textureSelection < 0} && {(count _seatKeys) <= 1})};
		MON_SVARG(_monitor, _instanceIndex, "CFM_currentPiPEffect", 0, _syncGlobal);
		MON_SVARG(_monitor, _instanceIndex, "CFM_doUpdatePip", true, _syncGlobal);
		MON_SVARG(_monitor, _instanceIndex, "CFM_isInNvg", false, _syncGlobal);
		["feedTurretToMonitor", [[_monitor, _instanceIndex], _turretIndex]] CALL_OBJCLASS("Operator", _connectedOperator);
	};

	PUBLIC GE GA METHOD("switchNvg") {
		private _newEffect = if (_currentPiPEffect != 1) then {1} else {0};
		private _syncGlobal = !_isLocal && {!(_isVehSeatTablet && {_textureSelection < 0} && {(count _seatKeys) <= 1})};
		MON_SVARG(_monitor, _instanceIndex, "CFM_currentPiPEffect", _newEffect, _syncGlobal);
		MON_SVARG(_monitor, _instanceIndex, "CFM_doUpdatePip", true, _syncGlobal);
		MON_SVARG(_monitor, _instanceIndex, "CFM_isInNvg", _newEffect isEqualTo 1, _syncGlobal);
	};

	PUBLIC GE GA METHOD("switchTi") {
		private _newEffect = if !(_currentPiPEffect in _currentTiTable) then {
			_currentTiTable#0;
		} else {
			private _i = _currentTiTable find _currentPiPEffect;
			private _newI = _i + 1;
			if (_newI >= (count _currentTiTable)) exitWith {0};
			_currentTiTable select _newI;
		};
		if (isNil "_newEffect") exitWith {};
		if !(_newEffect isEqualType 1) exitWith {};
		private _syncGlobal = !_isLocal && {!(_isVehSeatTablet && {_textureSelection < 0} && {(count _seatKeys) <= 1})};
		MON_SVARG(_monitor, _instanceIndex, "CFM_currentPiPEffect", _newEffect, _syncGlobal);
		MON_SVARG(_monitor, _instanceIndex, "CFM_doUpdatePip", true, _syncGlobal);
		MON_SVARG(_monitor, _instanceIndex, "CFM_isInNvg", false, _syncGlobal);
	};

	PUBLIC LOCAL METHOD("switchUAV") {
		if !(_currentOperatorIsDrone) exitWith {
			CFM_STR_CURRENT_FEED_NOT_UAV _HINT
			false
		};

		private _currentUav = vehicle (remoteControlled PLAYER_);

		if !(IS_OBJ(_currentUav)) exitWith {
			CFM_STR_NOT_CONTROLLING_UAV _HINT
			false
		};

		private _newUav = _connectedOperator;
		private _controled = [_newUav, "DRIVER"] call CFM_fnc_isUAVControlled;

		if (_controled) exitWith {
			CFM_STR_CANT_CONNECT_UAV_CONTROLLED _HINT
			false
		};

		private _currentUavIsOp = _currentUav getVariable ["CFM_operatorSet", false];

		if !(_currentUavIsOp) exitWith {
			CFM_STR_CURRENT_UAV_CANT_FEED _HINT
			false
		};

		private _monPair = [_selfObj, _instanceIndex];
		[_monPair] spawn CFM_fnc_takeUAVcontorls;

		private _waitStart = time;
		waitUntil {
			((MGVAR ["CFM_currentControlledUAV", objNull]) isEqualTo _newUav) ||
			{(time - _waitStart) > 2}
		};

		if !((MGVAR ["CFM_currentControlledUAV", objNull]) isEqualTo _newUav) exitWith {
			CFM_STR_CANT_CONNECT_TO_UAV _HINT
			false
		};

		[_monPair, _currentUav, PLAYER_] call CFM_fnc_connectMonitorToOperator;
		true
	};

	PUBLIC LOCAL METHOD("monitorEnterFullScreen") {
		private _monPair = [_selfObj, _instanceIndex];
		if !([_selfObj, _instanceIndex] call CFM_fnc_enterFullScreenActionCondition) exitWith {false};
		missionNamespace setVariable ["CFM_currentFullScreenMonitor", _monPair];
		if (missionNamespace getVariable ["CFM_fullscreenIsPip", false]) exitWith {
			[_monPair, true, true] call CFM_fnc_setHandDisplay;
		};
		private _unitCam = _currentFeedCam;
		private _mode = "INTERNAL";
		private _onTempCam = missionNamespace getVariable ["CFM_fullScreenOnTempCam", true];
		if !(_onTempCam) then {
			_mode = switch (TURRET_INDEX(_currentTurret)) do {
				case (DRIVER_TURRET_PATH#0): {
					_unitCam = driver (vehicle _connectedOperator);
					"INTERNAL"
				};
				case (GUNNER_TURRET_PATH#0): {
					_unitCam = gunner (vehicle _connectedOperator);
					"GUNNER"
				};
				default {""};
			};
		};
		if (_mode isEqualTo "") exitWith {
			format["ERROR monitorFullScreen: NO CAMERA MODE FOR THIS TURRET PATH: %1", _currentTurret] WARN;
			false
		};
		if !(IS_OBJ(_unitCam)) exitWith {
			format["ERROR monitorFullScreen: NO UNIT IN VEHICLE FOR THIS TURRET PATH: %1", _currentTurret] WARN;
			false
		};
		private _hintText = FULLSCREEN_HINT;
		private _isMavic = _connectedOperator getVariable ["CFM_isMavic", false];
		private _isFPV = _connectedOperator getVariable ["CFM_isFPV", false];
		private _monR2Tid = MON_GVAR(_selfObj, _instanceIndex, "CFM_monitorR2Tid", _monitorR2Tid);
		if (_onTempCam) then {
			if (missionNamespace getVariable ["CFM_blockMovementInFullscreen", false]) then {
				createDialog "RscDisplayCFMEmpty";
			} else {
				(findDisplay 46) createDisplay "RscDisplayCFMEmpty";
			};
			missionNamespace setVariable ["CFM_currentFullScreenCam", _unitCam];
			missionNamespace setVariable ["CFM_r2tOfFullScreenCam", _monR2Tid];
			_hintText = FULLSCREEN_TEMPCAM_HINT;
			_unitCam cameraEffect ["internal", "BACK"];
			showCinemaBorder false;
			if (_isInNvg) then {
				camUseNVG true;
			} else {
				private _tiMode = (missionNamespace getVariable ["CFM_tiModesTableReverse", createHashMap]) getOrDefault [_currentPiPEffect, -1];
				if ((_tiMode isEqualType 1) && {!(_tiMode isEqualTo -1)}) then {
					true setCamUseTI _tiMode;
				};
			};
			if (_isMavic) exitWith {
				if (MGVAR ["Mavic_showInterface", true]) then {
					("DB_Mavic_Layer" call BIS_fnc_rscLayer) cutRsc ["Mavic_Interface", "PLAIN"];
					mavic_3dehId = addMissionEventHandler ["Draw3D", { call mavic_fnc_drawHud }];
				};
			};
			if (_isFPV) exitWith {
				call DB_fnc_fpv_createDialog;
			};
		} else {
			_unitCam switchCamera _mode;
			_monPair spawn {
				private _initPos = getPosASL PLAYER_;
				waitUntil {
					uiSleep 1;
					!(_initPos isEqualTo (getPosASL PLAYER_))
				};
				[_this] call CFM_fnc_exitMonitorFullScreen;
				sleep 1;
				[_this] call CFM_fnc_exitMonitorFullScreen;
			};
		};
		if (_isHandMonitor) then {
			[_monPair] call CFM_fnc_turnOffMonitorLocal;
		};
		missionNamespace setVariable ["CFM_isInFullScreen", true];
		[_monPair] call CFM_fnc_playHandTabletAnim;
		_hintText _HINT;
		true
	};

	PUBLIC LOCAL METHOD("monitorExitFullScreen") {
		private _monPair = [_selfObj, _instanceIndex];
		if (missionNamespace getVariable ["CFM_isInPIPFullScreen", false]) exitWith {
			private _disp = uiNamespace getVariable ["CFM_tabletDisplay", displayNull];
			if (!isNull _disp) then {
				_disp closeDisplay 1;
			} else {
				call CFM_fnc_onTempDisplayUnload;
			};
			true
		};
		private _onTempCam = missionNamespace getVariable ["CFM_fullScreenOnTempCam", true];
		private _isMavic = _connectedOperator getVariable ["CFM_isMavic", false];
		private _isFPV = _connectedOperator getVariable ["CFM_isFPV", false];
		private _monR2Tid = MON_GVAR(_selfObj, _instanceIndex, "CFM_monitorR2Tid", _monitorR2Tid);
		if (_onTempCam) then {
			if (IS_VALID_R2T(_monR2Tid)) then {
				_currentFeedCam cameraEffect ["internal", "back", _monR2Tid];
			} else {
				_currentFeedCam cameraEffect ["Terminate", "back"];
				PLAYER_ switchCamera "INTERNAL";
			};
			[_monPair, _currentPiPEffect, false] call CFM_fnc_setMonitorPiPEffect;
			if (_isMavic) exitWith {
				false call MAVIC_fnc_handleConnect;
			};
			if (_isFPV) exitWith {
				call DB_fnc_fpv_destroyUI;
			};
		} else {
			PLAYER_ switchCamera "INTERNAL";
		};
		if (_isHandMonitor) then {
			[_monPair] call CFM_fnc_turnOnMonitorLocal;
		};
		false setCamUseTI 0;
		camUseNVG false;
		CLEAR_HINT
		cutText ["", "PLAIN"];
		missionNamespace setVariable ["CFM_isInFullScreen", false];
		missionNamespace setVariable ["CFM_currentFullScreenMonitor", nil];
		missionNamespace setVariable ["CFM_currentFullScreenCam", nil];
		missionNamespace setVariable ["CFM_r2tOfFullScreenCam", nil];
		private _fullDisp = findDisplay 167;
		if (!isNull _fullDisp) then {
			_fullDisp closeDisplay 1;
		};
		true
	};

	PUBLIC LE GA METHOD("setOperatorInfo") {
		params[["_set", false], ["_operator", _connectedOperator]];
		private _infoStr = if (_set && {IS_OBJ(_operator)}) then {
			private _curTurret = MON_GVAR(_selfObj, _instanceIndex, "CFM_currentTurret", _currentTurret);
			private _turrIndex = TURRET_INDEX(_curTurret);
			private _opName = [_operator, _turrIndex] call CFM_fnc_getOperatorName;
			private _turrName = if (_currentCameraIsStatic) then {_turrIndex} else {
				switch (_turrIndex) do {
					case -1: {
						if (_currentOperatorIsDrone) then {CFM_STR_PILOT} else {CFM_STR_DRIVER};
					};
					case 0: {
						CFM_STR_GUNNER
					};
					default {_turrIndex};
				};
			};
			if (_currentOpHasTurrets) then {
				format["<t color='#0d6aff'>%1:</t> %2 <t color='#0d6aff'>%3</t>: %4", CFM_STR_CAMERA, _opName, CFM_STR_TURRET, _turrName];
			} else {
				format["<t color='#0d6aff'>%1:</t> %2", CFM_STR_CAMERA, _opName];
			};
		} else {
			OPERATOR_INFO_TEXT_DEF
		};

		MON_SVAR(_selfObj, _instanceIndex, "CFM_operatorInfoText", _infoStr);
		if (hasInterface && {_selfObj getVariable ["CFM_isMonitorHostCreated", false]} && {([_selfObj] call CFM_fnc_getSelectedMonitorInstance) isEqualTo _instanceIndex}) then {
			["syncSelectedActionLabels", [_instanceIndex, _infoStr]] CALL_OBJCLASS("MonitorHost", _selfObj);
		};

		_infoStr
	};

	PUBLIC LE GA METHOD("setPiPEffect") {
		params [["_pipEffect", 0]];
		if !(_pipEffect isEqualType 0) exitWith {false};
		private _renderTarget = MON_GVAR(_monitor, _instanceIndex, "CFM_monitorR2Tid", _monitorR2Tid);
		if (hasInterface && {!(_renderTarget isEqualTo "")}) then {
			_renderTarget setPiPEffect [_pipEffect];
		};
		_currentPiPEffect = _pipEffect;
		_isInNvg = _pipEffect isEqualTo 1;
		MON_SVAR(_monitor, _instanceIndex, "CFM_currentPiPEffect", _pipEffect);
		MON_SVAR(_monitor, _instanceIndex, "CFM_isInNvg", _isInNvg);
		true
	};

	PUBLIC LE GA METHOD("setMonitorCanSwitchNvg") {
		params [["_canSwitchNvg", false]];
		if !(_canSwitchNvg isEqualType false) exitWith {false};
		_monitorCanSwitchNvg = _canSwitchNvg;
		MON_SVAR(_monitor, _instanceIndex, "CFM_monitorCanSwitchNvg", _monitorCanSwitchNvg);
		if (_monitorCanSwitchNvg) then {
			MON_SVAR(_monitor, _instanceIndex, "CFM_canSwitchNvgAction", true);
			if (hasInterface && {_monitor getVariable ["CFM_isMonitorHostCreated", false]}) then {
				["ensureHostActions", [false, false, false, false, false, false, false, false, false, true, false, false]] CALL_OBJCLASS("MonitorHost", _monitor);
			};
		} else {
			if (_isInNvg) then {
				["setPiPEffect", [0]] CALL_SELF;
			};
		};
		true
	};

	PUBLIC LE GA METHOD("setMonitorCanSwitchTi") {
		params [["_canSwitchTi", false]];
		if !(_canSwitchTi isEqualType false) exitWith {false};
		_monitorCanSwitchTi = _canSwitchTi;
		MON_SVAR(_monitor, _instanceIndex, "CFM_monitorCanSwitchTi", _monitorCanSwitchTi);
		if (_monitorCanSwitchTi) then {
			MON_SVAR(_monitor, _instanceIndex, "CFM_canSwitchTiAction", true);
			if (hasInterface && {_monitor getVariable ["CFM_isMonitorHostCreated", false]}) then {
				["ensureHostActions", [false, false, false, false, false, false, false, false, false, false, true, false]] CALL_OBJCLASS("MonitorHost", _monitor);
			};
		} else {
			if (_currentPiPEffect > 1) then {
				["setPiPEffect", [0]] CALL_SELF;
			};
		};
		true
	};

	PUBLIC LE GA METHOD("setCurrentCameraSmoothZoom") {
		params [["_smoothZoom", true]];
		if !(_smoothZoom isEqualType false) exitWith {false};
		_currentCameraSmoothZoom = _smoothZoom;
		MON_SVAR(_monitor, _instanceIndex, "CFM_currentCameraSmoothZoom", _currentCameraSmoothZoom);
		true
	};

	PUBLIC LE GA METHOD("setCurrentCameraCanMove") {
		params [["_canMove", false]];
		if !(_canMove isEqualType false) exitWith {false};
		_currentCameraCanMove = _canMove;
		MON_SVAR(_monitor, _instanceIndex, "CFM_currentCameraCanMove", _currentCameraCanMove);
		if (!_currentCameraCanMove && {hasInterface} && {missionNamespace getVariable ["CFM_isContinuousMoving", false]} && {(GET_MON) isEqualTo [_selfObj, _instanceIndex]}) then {
			call CFM_fnc_stopContinuousCameraMove;
		};
		true
	};

	PUBLIC LE GA METHOD("setCurrentCameraMoveRestrictions") {
		params [["_restrictions", []]];
		if !(_restrictions isEqualType []) exitWith {false};
		private _res = +_restrictions;
		if (_res isNotEqualTo []) then {
			_res resize [4, 0];
		};
		_currentCameraMoveRestrictions = _res;
		MON_SVAR(_monitor, _instanceIndex, "CFM_currentCameraMoveRestrictions", _currentCameraMoveRestrictions);
		true
	};

	//----------- State get -----------
	PUBLIC LOCAL METHOD("getOperatorInfo") {
		private _opName = _connectedOperator getVariable ["CFM_operatorName", ""];
		private _dist = _selfObj distance _connectedOperator;
		private _grid = mapGridPosition _connectedOperator;
		private _curTurret = MON_GVAR(_selfObj, _instanceIndex, "CFM_currentTurret", _currentTurret);
		private _turrIndex = TURRET_INDEX(_curTurret);
		private _showDist = missionNamespace getVariable ["CFM_menuShowOperatorDistance", false];
		private _showGrid = missionNamespace getVariable ["CFM_menuShowOperatorGrid", false];

		private _lines = [
			CFM_STR_OPERATOR_INFO_TITLE,
			format [" %1: %2", CFM_STR_NAME, _opName]
		];
		if (_showGrid) then {
			_lines pushBack format [" %1: %2", CFM_STR_MAP_POS, _grid];
		};
		if (_showDist) then {
			_lines pushBack format [" %1: %2", CFM_STR_DISTANCE, _dist];
		};
		_lines pushBack format [" %1: %2", CFM_STR_TURRET, _turrIndex];
		private _infoStr = _lines joinString endl;

		_infoStr _HINT;
	};

	//----------- Menu -----------
	PRIVATE LOCAL METHOD("loadMenu") {
		params[["_caller", objNull], ["_target", _selfObj]];
		private _monPair = [_selfObj, _instanceIndex];
		if !([_selfObj, _instanceIndex] call CFM_fnc_canControlMonitorSeat) exitWith {};
		if !([_selfObj, _instanceIndex] call CFM_fnc_hasMonitorPasswordAccess) exitWith {
			[_monPair, "enter", _caller, _target] call CFM_fnc_openPasswordDialog;
		};
		if (missionNamespace getVariable ["CFM_useScrollMenuForConnection", true]) then {
			["loadMenuScrollMenu", [_caller, _target]] CALL_SELF;
		} else {
			"ERROR loadMenu: UI menu WIP!" WARN;
			["loadMenuScrollMenu", [_caller, _target]] CALL_SELF;
		};
	};

	PRIVATE LOCAL METHOD("loadMenuScrollMenu") {
		params [["_caller", objNull], ["_target", _selfObj], ["_targetStr", _targetInActionsConditions]];
		_targetStr = _targetInActionsConditions;
		private _monPair = [_selfObj, _instanceIndex];
		private _ops = [_monPair] call CFM_fnc_getActiveOperators;

		private _radius = MONITOR_ACTION_RADIUS(_selfObj);

		if (count _ops == 0) then {
			CFM_STR_NO_ACTIVE_CAMERAS _HINT;
		};
		if ((count _ops == 0) && {!(_canSetPassword)}) exitWith {};

		private _tempIDs = [];

		private _closeID = _target addAction [format["<t color='#ff6600'>   [%1]</t>", CFM_STR_CLOSE_MENU], {
			params ["_target", "_caller", "_", "_p"];
			_p params ["_monitor", "_instId"];
			[[_monitor, _instId], _target] call CFM_fnc_monitorCloseMenu;
		}, [_selfObj, _instanceIndex], 11, true, false, "", format["[%1, %2] call CFM_fnc_menuCloseActionCondition", _targetStr, _instanceIndex], _radius];
		_tempIDs pushBack _closeID;

		private _showDist = missionNamespace getVariable ["CFM_menuShowOperatorDistance", false];
		private _showGrid = missionNamespace getVariable ["CFM_menuShowOperatorGrid", false];
		{
			private _parts = [];
			if (_showDist) then { _parts pushBack format ["[%1 m]", round (_selfObj distance _x)]; };
			if (_showGrid) then { _parts pushBack format ["[Grid: %1]", mapGridPosition _x]; };
			private _distanceStr = if (_parts isNotEqualTo []) then {
				format ["<t color='#36f56f'>%1</t>", _parts joinString " "]
			} else {""};
			private _type = _x getVariable ["CFM_currentCameraType", [_x] call CFM_fnc_cameraType];
			private _opName = _x getVariable ["CFM_operatorName", ""];
			private _name = if ((_opName isEqualType "") && {!(_opName isEqualTo "")}) then {
				_opName
			} else {
				switch (_type) do {
					case GOPRO: {
						format["%1: %2", groupId group _x, name _x]
					};
					case TYPE_STATIC: {
						_x getVariable ["CFM_staticCameraID", "Camera"];
					};
					default {
						private _group = groupId group _x;
						private _dispName = getText (configFile >> "CfgVehicles" >> (typeOf _x) >> "displayName");
						if (_group isEqualTo "") then {
							_dispName
						} else {
							format["%1: %2", _group, _dispName]
						};
					};
				};
			};
			private _id = _target addAction [format["        <t color='#3e99fa'>[%1]</t>: %2 %3", CFM_STR_CONNECT, _name, _distanceStr], {
				params ["_t", "_c", "_i", "_p"];
				_p params ["_m", "_instId", "_o"];
				[[_m, _instId], _o, _c] call CFM_fnc_connectMonitorToOperator;
			}, [_selfObj, _instanceIndex, _x], 10, true, false, "", format["[%1, %2] call CFM_fnc_connectActionCondition", _targetStr, _instanceIndex], _radius];
			_tempIDs pushBack _id;
		} forEach _ops;

		_target setVariable ["CFM_tempActions", _tempIDs];
		_selfObj setVariable ["CFM_activeMenuInstance", _instanceIndex];
		_selfObj setVariable ["CFM_menuActive", true];
		MON_SVAR(_selfObj, _instanceIndex, "CFM_menuActive", true);
		MON_SVAR(_selfObj, _instanceIndex, "CFM_currentMenuObj", _target);

		private _prevMenuHndl = _target getVariable ['CFM_menuHndl', scriptNull];
		if ((_prevMenuHndl isEqualType scriptNull) && {!(scriptDone _prevMenuHndl)}) then {
			terminate _prevMenuHndl;
		};

		private _menuHndl = [_target, _selfObj, _instanceIndex, _tempIDs] spawn {
			params["_target", "_selfObj", "_instId", "_tempIDs"];
			waitUntil {
				sleep 1;
				!(MON_GVAR(_selfObj, _instId, "CFM_menuActive", false)) ||
				{!(([_selfObj] call CFM_fnc_getSelectedMonitorInstance) isEqualTo _instId)} ||
				{!(_selfObj isEqualTo PLAYER_) && {(_selfObj distance PLAYER_) > (MONITOR_ACTION_RADIUS(_selfObj))}} ||
				{(MON_GVAR(_selfObj, _instId, "CFM_isVehSeatTablet", false)) && {!([_selfObj, _instId] call CFM_fnc_inVehicleTabletSeatCondition) || {!([_selfObj, _instId] call CFM_fnc_canControlMonitorSeat)}}} ||
				{(MON_GVAR(_selfObj, _instId, "CFM_isHandMonitor", false)) && {!([_selfObj, _instId] call CFM_fnc_isSelectedTablet)}} ||
				{!([_selfObj, _instId] call CFM_fnc_hasMonitorPasswordAccess)}
			};
			[[_selfObj, _instId], _target] call CFM_fnc_monitorCloseMenu;
		};
		_target setVariable ['CFM_menuHndl', _menuHndl];
		_menuHndl
	};

CLASS_END
