#define OPERATOR_INFO_TEXT_DEF "<t color='#0d6aff'>Operator Info</t>"

OBJCLASS(Monitor)

	SET_SELF_VAR(_monitor);

	OBJ_VARIABLE(_radius, ACTION_RADIUS);
	OBJ_VARIABLE(_monitorSides, [side PLAYER_]);
	OBJ_VARIABLE(_turnedOffLocal, false);
	OBJ_VARIABLE(_originalTexture, "");
	OBJ_VARIABLE(_menuActive, false);
	OBJ_VARIABLE(_isHandMonitor, false);
	OBJ_VARIABLE(_isHandMonitorDisplay, false);
	OBJ_VARIABLE(_isLocal, false);
	OBJ_VARIABLE(_actionCaller, objNull);
	OBJ_VARIABLE(_mainActions, objNull);
	OBJ_VARIABLE(_operatorInfoActionId, -1);
	OBJ_VARIABLE(_currentMenuObj, _self);
	OBJ_VARIABLE(_targetInActionsConditions, "_target");

	OBJ_VARIABLE(_currentTurret, DRIVER_TURRET_PATH);
	OBJ_VARIABLE(_connectedOperator, objNull);
	OBJ_VARIABLE(_connectedTurretObject, _connectedOperator);
	OBJ_VARIABLE(_feedActive, false);
	OBJ_VARIABLE(_currentCameraType, "");
	OBJ_VARIABLE(_currentFeedCam, objNull);
	OBJ_VARIABLE(_currentR2T, "");
	OBJ_VARIABLE(_currentOpHasTurrets, false);
	OBJ_VARIABLE(_currentCameraSmoothZoom, true);
	OBJ_VARIABLE(_currentCameraIsStatic, false);
	OBJ_VARIABLE(_currentCameraCanMove, false);
	OBJ_VARIABLE(_currentCameraMoves, [0 I 0 I 0 I 0]);
	OBJ_VARIABLE(_currentCameraMoveRestrictions, []);
	OBJ_VARIABLE(_monitorCanSwitchNvg, false);
	OBJ_VARIABLE(_monitorCanSwitchTi, false);
	OBJ_VARIABLE(_currentPiPEffect, 0);
	OBJ_VARIABLE(_isInNvg, false);
	OBJ_VARIABLE(_currentTiTable, createHashMap);
	OBJ_VARIABLE(_currentNvgTable, createHashMap);
	TYPE_OBJ_VARIABLE(_zoom, 1, ["" I 1]);
	TYPE_OBJ_VARIABLE(_zoomFov, 1, ["" I 1]);
	OBJ_VARIABLE(_zoomMax, 1);
	OBJ_VARIABLE(_zoomTable, createHashMap);
	OBJ_VARIABLE(_turretLocal, false);
	OBJ_VARIABLE(_maxZoomed, false);
	OBJ_VARIABLE(_currentOperatorIsDrone, false);
	OBJ_VARIABLE(_canFullScreen, false);
	OBJ_VARIABLE(_cameraPosFunc, {});
	OBJ_VARIABLE(_currentCamPointParams, []);
	OBJ_VARIABLE(_camDoInterpolation, false);

	METHODS

	METHOD("Init") { 
		// should be executed globaly
		params [
			["_sides", [side PLAYER_]],
			["_isHandMonitorDisplay", false],
			["_canSwitchNvg", true],
			["_canSwitchTi", true],
			["_canSwitchTurret", true],
			["_canZoom", true],
			["_canFullScreen", true],
			["_canConnectDrone", true],
			["_canFix", true],
			["_canTurnOffLocal", true]
		]; 

		if !(IS_OBJ(_monitor)) exitWith {false};
			

		private _reset = if (isNil "_reset") then {false} else {_reset};
		if (!_reset && {((_monitor getVariable ["CFM_isMonitorSet", false]) isEqualTo true)}) exitWith {false};

		private _isPlayer = (_monitor isEqualTo PLAYER_) || {(_monitor isKindOf "Man")};
		private _local = local _monitor;

		// Hand monitors are local
		if (_isPlayer && !_local) exitWith {false};

		_isHandMonitor = _isPlayer;

		if (_isHandMonitor) then {
			// if hand monitor then wait for terminal
			waitUntil {
				sleep 2;
				_self call CFM_fnc_hasUAVterminal;
			};
			// upd actions to remote controlled uav units
			_self spawn {
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

		private _hasTextureSelection = count (getObjectTextures _monitor) > 0;
		if (!_isHandMonitor && !(_hasTextureSelection)) exitWith {
			format["CLASS Monitor init: Object '%1' has no texture selections!", _monitor] WARN;
			false
		};
		
		if ((_monitor getVariable ["CFM_isMonitorSet", false]) && {_feedActive}) then {
			[_monitor] call CFM_fnc_stopOperatorFeed;
		};
		
		if (_local) then {
			_isLocal = _isHandMonitor;
			private _originalTexture = (getObjectTextures _monitor) select 0;
			_originalTexture = if (isNil "_originalTexture") then {""} else {_originalTexture};
			_monitor setVariable ["CFM_originalTexture", _originalTexture, !_isLocal]; 

			["addMonitor", [_monitor]] CALL_CLASS("DbHandler");
			_monitor setVariable ["CFM_isHandMonitor", _isHandMonitor, true];
			_monitor setVariable ["CFM_isLocal", _isLocal, true];

			if !(_sides isEqualType []) then {
				_sides = [_sides];
			};
			_sides = _sides select {_x isEqualType west};
			if (count _sides == 0) then {_sides = [side PLAYER_]};

			_monitor setVariable ["CFM_monitorSides", _sides, !_isLocal];
			_monitor setVariable ["CFM_canFullScreen", _canFullScreen, !_isLocal];
			_monitor setVariable ["CFM_isHandMonitorDisplay", _isHandMonitor && _isHandMonitorDisplay];
		};

		private _radius = ACTION_RADIUS;
		private _menuText = "Camera System Menu";
		if (_isPlayer) then {
			_radius = -1;
			_targetInActionsConditions = "_target call CFM_fnc_getPlayer";
			_monitor setVariable ["CFM_targetInActionsConditions", _targetInActionsConditions];
		};
		_monitor setVariable ["CFM_actionsRadius", _radius];

		["addMenuActions", [_radius]] CALL_OBJCLASS("Monitor", _self);
		["addOptionalActions", [_radius]] CALL_OBJCLASS("Monitor", _self);
		["updateActionPriority"] CALL_CLASS("DbHandler");

		_monitor setVariable ["CFM_isMonitorSet", true];

		true
	};
	METHOD("setRenderPicture") {
		params[["_render", true], ["_r2t", ""], ["_turnOff", false]];

		if (_render && {_r2t isEqualTo ""}) then {
			_r2t = _currentR2T;
		};
		_render = _render && !(_r2t isEqualTo "");
		if !(_turnOff) then {
			_monitor setVariable ["CFM_currentR2T", _r2t];
		};
		if ((_monitor getVariable ["CFM_isHandMonitor", false]) isEqualTo true) exitWith {
			[_monitor, _render] call CFM_fnc_setHandDisplay;
		};

		if (_render) then {
			_monitor setObjectTexture [0, "#(argb,512,512,1)r2t(" + _r2t + ",1.0)"];  
		} else {
			_monitor setObjectTexture [0, _originalTexture];
		};
	};
	METHOD("startFeed") {  
		params [["_operator", objNull], ["_turret", []], ["_reset", false]];

		private _monitor = _self;

		if !(IS_OBJ(_monitor)) exitWith {[false, "CFM_fnc_startOperatorFeed: Monitor is not an object"]};
		if !(IS_OBJ(_operator)) exitWith {[false, "CFM_fnc_startOperatorFeed: Operator is not an object"]};

		if (!(_turret isEqualTo []) && {(_turret isEqualType []) && {(count _turret) == 1}}) then {
			_monitor setVariable ["CFM_currentTurret", _turret];
			_currentTurret = _turret;
		} else {
			_turret = _currentTurret;
		};
		
		_self setVariable ['CFM_actionCaller', nil];

		private _renderTargetAndCamera = ["spawnCamera", [_monitor], nil, ["NONE", objNull]] CALL_CLASS("CameraManager");
		private _renderTarget = _renderTargetAndCamera#0;
		private _camera = _renderTargetAndCamera#1;

		if !(IS_VALID_R2T(_renderTarget)) exitWith {
			_monitor setVariable ["CFM_feedActive", false];
			_self setVariable ["CFM_menuActive", false];
			"ERROR: CAN'T CONNECT TO OPERATOR: NO RENDER TARGET" WARN;
			false
		};

		_monitor setVariable ["CFM_currentFeedCam", _camera];
		_monitor setVariable ["CFM_feedActive", true];
		_monitor setVariable ["CFM_connectedOperator", _operator];

		["setRenderPicture", [true, _renderTarget]] CALL_OBJCLASS("Monitor", _monitor);
		["addActiveViewer", [PLAYER_]] CALL_CLASS("DbHandler");
		["monitorConnected", [_monitor, _turret, _actionCaller], _operator, "NULL"] CALL_OBJCLASS("Operator", _operator);

		["addActiveMonitor", [_monitor]] CALL_CLASS("DbHandler");

		if (_reset) then {
			[_monitor, _currentPiPEffect] call CFM_fnc_setMonitorPiPEffect;
		};
		{ _currentMenuObj removeAction _x } forEach (_currentMenuObj getVariable ["CFM_tempActions", []]); 

		true
	}; 
	METHOD("stopFeed") {
		params[["_reset", false]];
		if !(_reset) then {
			if ((missionNamespace getVariable ["CFM_currentFullScreenMonitor", objNull]) isEqualTo _self) then {
				closeDialog 1;
				call CFM_fnc_onDisplayUnload;
			};
			["monitorDisconnected", [_monitor, _currentTurret, _actionCaller]] CALL_OBJCLASS("Operator", _connectedOperator);
			_self setVariable ['CFM_actionCaller', nil];
			["clearVariables"] CALL_OBJCLASS("Monitor", _monitor);
			["destroyCamera", [_currentFeedCam]] CALL_CLASS("CameraManager");
			["removeActiveMonitor", [_monitor]] CALL_CLASS("DbHandler");
			["setOperatorInfo", [false]] CALL_OBJCLASS("Monitor", _monitor);
		} else {
			_monitor setVariable ["CFM_turnedOffLocal", nil]; 
		};
		["setRenderPicture", [false]] CALL_OBJCLASS("Monitor", _monitor);
	};
	METHOD("clearVariables") {
		_monitor setVariable ["CFM_monitorCanSwitchNvg", nil];
		_monitor setVariable ["CFM_monitorCanSwitchTi", nil];
		_monitor setVariable ["CFM_currentOpHasTurrets", nil];
		_monitor setVariable ["CFM_cameraType", nil];
		_monitor setVariable ["CFM_currentTiTable", nil];
		_monitor setVariable ["CFM_currentNvgTable", nil];
		_monitor setVariable ["CFM_currentTurret", nil];
		_monitor setVariable ["CFM_currentPiPEffect", nil];
		_monitor setVariable ["CFM_currentR2T", nil];
		_monitor setVariable ["CFM_currentFeedCam", nil];
		_monitor setVariable ["CFM_connectedOperator", nil];
		_monitor setVariable ["CFM_feedActive", nil];
		_monitor setVariable ["CFM_zoom", nil];
		_monitor setVariable ["CFM_zoomMax", nil];
		_monitor setVariable ["CFM_zoomFov", nil];
		_monitor setVariable ["CFM_maxZoomed", nil];
		_monitor setVariable ["CFM_turretLocal", nil];
		_monitor setVariable ["CFM_currentCameraType", nil];
		_monitor setVariable ["CFM_currentOperatorIsDrone", nil];
		_monitor setVariable ["CFM_cameraPosFunc", nil];
		_monitor setVariable ['CFM_menuActive', false];
		_monitor setVariable ['CFM_actionCaller', nil];
		_monitor setVariable ['CFM_isInNvg', nil];
		_monitor setVariable ["CFM_turnedOffLocal", nil]; 
		_monitor setVariable ["CFM_currentCamPointParams", nil];
		_monitor setVariable ["CFM_camDoInterpolation", nil];
		_monitor setVariable ["CFM_currentCameraMoveRestrictions", nil];
		_monitor setVariable ["CFM_currentCameraMoves", nil];
		_monitor setVariable ["CFM_currentCameraCanMove", nil];
		_monitor setVariable ["CFM_currentCameraIsStatic", nil];
		_monitor setVariable ["CFM_currentCameraSmoothZoom", nil];
		_monitor setVariable ["CFM_camInterp_lastDir", nil];
		_monitor setVariable ["CFM_camInterp_lastUp", nil];
	};
	METHOD("connect") {
		params["_op", ["_caller", objNull]];
		_self setVariable ['CFM_actionCaller', _caller];
		[[netId _self, netId _op, true], "CFM_fnc_syncState", !_isLocal, _self] call CFM_fnc_remoteExec; 
		_self setVariable ['CFM_menuActive', false, true];
		true
	};
	METHOD("disconnect") {
		params[["_caller", objNull]];
		_self setVariable ['CFM_actionCaller', _caller];
		[[netId _self, "", false], "CFM_fnc_syncState", !_isLocal, _self] call CFM_fnc_remoteExec; 
		_self setVariable ['CFM_menuActive', false, true];
	};
	METHOD("loadMenu") {
		params[["_caller", objNull], ["_target", _self]];
		if (missionNamespace getVariable ["CFM_useScrollMenuForConnection", true]) then {
			["loadMenuScrollMenu", [_caller, _target]] CALL_OBJCLASS("Monitor", _self);
		} else {
			"ERROR loadMenu: UI menu WIP!" WARN;
			["loadMenuScrollMenu", [_caller, _target]] CALL_OBJCLASS("Monitor", _self);
		};
	};
	METHOD("loadMenuScrollMenu") { 
		params [["_caller", objNull], ["_target", _self], ["_targetStr", _targetInActionsConditions]]; 
		format["Monitor.loadMenuScrollMenu. Self: %1, Target: %2", _self, _target] DLOG
		private _targetStr = _targetInActionsConditions;
		private _ops = [_self] call CFM_fnc_getActiveOperators; 
		// private _opsGlobal = [_self] call CFM_fnc_getActiveOperatorsCheckGlobal; 
		// {
		// 	_ops pushBackUnique _x;
		// } forEach _opsGlobal;

		private _radius = MONITOR_ACTION_RADIUS(_self);

		if (count _ops == 0) exitWith { "No active cameras!" _HINT }; 
			
		private _tempIDs = []; 

		private _closeID = _target addAction ["<t color='#ff6600'>   [Close Menu]</t>", { 
			params ["_target", "_caller", "_", "_p"];
			_p params ["_monitor"]; 
			
			{ _target removeAction _x } forEach (_target getVariable ["CFM_tempActions", []]); 
			_monitor setVariable ['CFM_menuActive', false];
		}, [_self], 11, true,false,"",format["[%1] call CFM_fnc_menuCloseActionCondition", _targetStr], _radius]; 
		_tempIDs pushBack _closeID; 

		private _showDist = missionNamespace getVariable ["CFM_menuShowOperatorDistance", false];
		private _showGrid = missionNamespace getVariable ["CFM_menuShowOperatorGrid", false];
		private _distanceStrFormat = format[
			"%1 %2",
			if (_showDist) then {"[%1 m]"} else {""}, 
			if (_showGrid) then {"[Grid: %2]"} else {""}
		];
		if (_showGrid || _showDist) then {
			_distanceStrFormat = format["<t color='#36f56f'>%1</t>", _distanceStrFormat];
		}; 
		{  
			private _grid = mapGridPosition _x;
			private _distanceStr = format[_distanceStrFormat, round (_self distance _x), _grid];
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
			private _id = _target addAction [format["        <t color='#3e99fa'>[Connect]</t>: %1 %2", _name, _distanceStr], { 
				params ["_t", "_c", "_i", "_p"]; 
				_p params ["_m", "_o"];
				[_m, _o, _c] call CFM_fnc_connectMonitorToOperator;
			}, [_self, _x], 10, true,false,"",format["[%1] call CFM_fnc_connectActionCondition", _targetStr], _radius]; 
			_tempIDs pushBack _id; 
		} forEach _ops; 
		
		_target setVariable ["CFM_tempActions", _tempIDs]; 
		_self setVariable ['CFM_menuActive', true];
		_self setVariable ['CFM_currentMenuObj', _target];

		private _prevMenuHndl = _target getVariable ['CFM_menuHndl', scriptNull];
		if ((_prevMenuHndl isEqualType scriptNull) && {!(scriptDone _prevMenuHndl)}) then {
			terminate _prevMenuHndl;
		};
			
		private _menuHndl = [_target, _self, _tempIDs] spawn { 
			params["_target", "_self", "_tempIDs"];
			waitUntil {sleep 1; !(_self getVariable ['CFM_menuActive', false]) || {(_self distance PLAYER_) > 5}};
			{ _target removeAction _x } forEach _tempIDs; 
			_self setVariable ['CFM_menuActive', false];
		}; 
		_target setVariable ['CFM_menuHndl', _menuHndl];
		_menuHndl
	};
	METHOD("zoom") {
		params [["_zoomAdd", 0], ["_zoomSet", -1]]; 

		if ((_zoomAdd isEqualTo 1) && {_maxZoomed}) exitWith {_zoom};

		private _maxZoomed = false;
		private _newzoom = if (_zoomAdd isEqualType 1) then {
			private _newzoom = if (_zoomSet isEqualTo -1) then {
				private _zoom = _monitor getVariable ['CFM_zoom', 1];
				if !(_zoom isEqualType 1) then {
					_zoom = 1;
				};
				(_zoom + _zoomAdd) max 1;
			} else {
				_zoomSet
			};

			private _zoomMax = _monitor getVariable ["CFM_zoomMax", 1];

			_maxZoomed = _newzoom >= _zoomMax;

			_newzoom
		} else {
			_maxZoomed = false;
			_zoomAdd
		};

		private _fov = if (_newzoom isEqualType 1) then {
			_zoomTable getOrDefault [_newzoom, 1/_newzoom];
		} else {_newzoom};

		if (_zoomAdd isEqualTo "reset") then {
			_fov = 0.9;
			_newzoom = 1;
			_maxZoomed = false;
		};

		_monitor setVariable ['CFM_maxZoomed', _maxZoomed, true];
		_monitor setVariable ["CFM_zoom", _newzoom, true];
		_monitor setVariable ["CFM_zoomFov", _fov, true];
		_monitor setVariable ["CFM_doUpdateCamera", true, true];

		_newzoom
	};
	METHOD("nextTurret") {
		_monitor setVariable ["CFM_currentPiPEffect", 0, true];
		_monitor setVariable ["CFM_doUpdatePip", true, true];
		["NextTurret", [_monitor, _monitor getVariable ["CFM_currentTurret", -1]]] CALL_OBJCLASS("Operator", _connectedOperator);
	};
	METHOD("switchTurret") {
		params[["_turret", DRIVER_TURRET_PATH]];
		// _self setVariable ["CFM_currentTurret", _turret, true];
		_monitor setVariable ["CFM_currentPiPEffect", 0, true];
		_monitor setVariable ["CFM_doUpdatePip", true, true];
		["TurretChanged", [_monitor, _turret, true, true]] CALL_OBJCLASS("Operator", _connectedOperator);
	};
	METHOD("switchNvg") { 
		private _newEffect = 0;
		if (_currentPiPEffect != 1) then {
			_newEffect = 1;
		};
		if (_currentPiPEffect == 1) then {
			_newEffect = 0;
		};
		_monitor setVariable ["CFM_currentPiPEffect", _newEffect, true];
		_monitor setVariable ["CFM_doUpdatePip", true, true];
		_monitor setVariable ["CFM_isInNvg", _newEffect isEqualTo 1, true];
	};
	METHOD("switchTi") { 
		private _currentTurret = _self getVariable ["CFM_currentTurret", [-1]];
		private _tiModes = _currentTiTable getOrDefault [TURRET_INDEX(_currentTurret), [0]];
		private _newEffect = if !(_currentPiPEffect in _tiModes) then {
			_tiModes#0;
		} else {
			private _i = _tiModes find _currentPiPEffect;
			private _newI = _i + 1;
			if (_newI >= (count _tiModes)) exitWith {
				0;
			};
			_tiModes select _newI;
		};
		if (isNil "_newEffect") exitWith {};
		if !(_newEffect isEqualType 1) exitWith {};
		_monitor setVariable ["CFM_currentPiPEffect", _newEffect, true];
		_monitor setVariable ["CFM_doUpdatePip", true, true];
		_monitor setVariable ["CFM_isInNvg", false, true];
	};
	METHOD("addActionsToActionsList") {
		private _savedActions = _self getVariable ["CFM_mainActions", []];
		_savedActions append _this;
		_self setVariable ["CFM_mainActions", _savedActions];
		_savedActions
	};
	METHOD("addMenuActions") {
		params[["_radius", ACTION_RADIUS], ["_target", _targetInActionsConditions]];
		
		private _actions = [];
		private _target = _targetInActionsConditions;
		private _menuText = "Camera System Menu";
		private _additionalCondition = if (_isHandMonitor) then {
			_radius = -1;
			_menuText = "Hand Tablet Camera System Menu";
			"([_target] call CFM_fnc_hasUAVterminal)"
		} else {"true"};
		private _priority = PLAYER_ getVariable ["CFM_currentActionsPriority", ACTIONS_PRIORITY];
		private _radius = _self getVariable ["CFM_actionsRadius", _radius];
		private _name = if !(_isHandMonitor) then {
			// _menuText = _menuText + ": %1";
			// getText (configFile >> "CfgVehicles" >> typeOf _self >> "displayName")
		} else {
			""
		};
		private _actionMenu = _self addAction [format["<t color='#00FF00'>%1</t>", format[_menuText, _name]], { 
			params ["_target", "_caller", "_", "_p"];
			_p params ["_monitor"]; 

			["loadMenu", [_caller, _target]] CALL_OBJCLASS("Monitor", _monitor);
		}, [_self], _priority, true, false, "", format["[%1] call CFM_fnc_menuActionCondition", _target], _radius]; 

		private _actionDisc = _self addAction ["<t color='#FF0000'>Disconnect Camera</t>", { 
			params ["_target", "_caller", "_", "_p"];
			_p params ["_monitor"]; 

			[_monitor, _caller] call CFM_fnc_disconnectMonitorFromOperator;
		}, [_self], _priority, true, false, "", format["[%1] call CFM_fnc_disconnectActionCondition", _target], _radius]; 

		_actions append [_actionMenu, _actionDisc];

		if (_isHandMonitor) then {
			private _actionWatch = _self addAction ["<t color='#0000FF'>Watch tablet</t>", { 
				params ["_target", "_caller", "_", "_p"];
				_p params ["_monitor"]; 
				
				[_monitor] call CFM_fnc_turnOnMonitorLocal;
			}, [_self], _priority, true, false, "", format["[%1] call CFM_fnc_watchTabletActionCondition", _target], _radius]; 

			private _actionStopWatch = _self addAction ["<t color='#FF3344'>Stop Watching tablet</t>", { 
				params ["_target", "_caller", "_", "_p"];
				_p params ["_monitor"]; 

				[_monitor] call CFM_fnc_turnOffMonitorLocal;
			}, [_self], _priority, true, false, "", format["[%1] call CFM_fnc_stopWatchTabletActionCondition", _target], _radius]; 

			private _actionSwitchDrones = _self addAction ["<t color='#c31cff'>Switch UAV</t>", { 
				params ["_target", "_caller", "_", "_p"];
				_p params ["_monitor"]; 

				[_monitor] call CFM_fnc_switchUAV;
			}, [_self], _priority, true, false, "", format["[%1] call CFM_fnc_switchUAVActionCondition", _target], _radius]; 

			_actions append [_actionWatch, _actionStopWatch, _actionSwitchDrones];
		};

		["addActionsToActionsList", _actions] CALL_OBJCLASS("Monitor", _self);
	};
	METHOD("addOptionalActions") {
		params [
			["_radius", ACTION_RADIUS],
			["_canZoom", true],
			["_canConnectDrone", true],
			["_canFix", true],
			["_canSwitchTurret", true],
			["_canTurnOffLocal", true],
			["_canSwitchNvg", true],
			["_canSwitchTi", true]
		]; 
		private _target = _targetInActionsConditions;
		private _priority = PLAYER_ getVariable ["CFM_currentActionsPriority", ACTIONS_PRIORITY];
		private _actions = [];
		private _radius = _self getVariable ["CFM_actionsRadius", _radius];
		call {
			if (true) then {
				_operatorInfoActionId = _self addAction [OPERATOR_INFO_TEXT_DEF, { 
					(_this#3) params ["_target"];
					
					[_target] call CFM_fnc_getOperatorInfo;
				}, [_self], _priority + 1, true, false, "", format["[%1] call CFM_fnc_operatorInfoActionCondition", _target], _radius]; 
				_self setVariable ["CFM_operatorInfoActionId", _operatorInfoActionId];
				_actions append [_operatorInfoActionId];
			};

			if (_canZoom) then {
				private _actionZoomIn = _self addAction ["<t color='#c5dafa'>Zoom In</t>", { 
					(_this#3) params ["_target"];
					
					[_target, +1] call CFM_fnc_zoom;
				}, [_self], _priority, true, false, "", format["[%1] call CFM_fnc_zoomInActionCondition", _target], _radius]; 

				private _actionZoomOut = _self addAction ["<t color='#c5dafa'>Zoom Out</t>", { 
					(_this#3) params ["_target"];
					
					[_target, -1] call CFM_fnc_zoom;
				}, [_self], _priority, true, false, "", format["[%1] call CFM_fnc_zoomActionsCondition", _target], _radius]; 
			
				private _actionZoomDefault = _self addAction ["<t color='#45d9b9'>Reset Zoom</t>", { 
					(_this#3) params ["_target"]; 

					[_target, "reset"] call CFM_fnc_zoom;
				}, [_self], _priority, true, false, "", format["[%1] call CFM_fnc_zoomActionsCondition", _target], _radius]; 

				private _actionZoomByDrone = _self addAction ["<t color='#90c73e'>Use Operator Zoom</t>", { 
					(_this#3) params ["_target"]; 

					[_target, "op"] call CFM_fnc_zoom;
				}, [_self], _priority, true, false, "", format["[%1] call CFM_fnc_operatorZoomActionsCondition", _target], _radius]; 

				_actions append [_actionZoomIn, _actionZoomOut, _actionZoomDefault, _actionZoomByDrone];
			};

			if (_canConnectDrone) then {
				private _connectDroneAction = _self addAction ["<t color='#1c399e'>Take UAV controls</t>", { 
					(_this#3) params ["_target"]; 

					[_target] spawn CFM_fnc_takeUAVcontorls;
				}, [_self], _priority, true, false, "", format["[%1] call CFM_fnc_connectDroneActionCondition", _target], _radius]; 
				_actions append [_connectDroneAction];
			};

			if (_canFix) then {
				private _actionFix = _self addAction ["<t color='#690707'>Reset/Fix feed (local)</t>", { 
					(_this#3) params ["_target"]; 
					
					[_target] call CFM_fnc_fixFeed;
				}, [_self], _priority, true, false, "", format["[%1] call CFM_fnc_fixFeedActionCondition", _target], _radius]; 
				_actions append [_actionFix];
			};

			if (_canSwitchTurret) then {
				// private _actionSwitchTurret = _self addAction ["<t color='#ffba4a'>Switch to Turret Camera</t>", { 
				// 	(_this#3) params ["_target"]; 
					
				// 	["switchTurret", [GUNNER_TURRET_PATH]] CALL_OBJCLASS("Monitor", _target);
				// }, [_self], _priority, true, false, "", format["[%1] call CFM_fnc_switchCameraToGunnerActionCondition", _target], _radius]; 
				// private _actionSwitchDriver = _self addAction ["<t color='#ffba4a'>Switch to Pilot Camera</t>", { 
				// 	(_this#3) params ["_target"]; 

				// 	["switchTurret", [DRIVER_TURRET_PATH]] CALL_OBJCLASS("Monitor", _target);
				// }, [_self], _priority, true, false, "", format["[%1] call CFM_fnc_switchCameraToPilotActionCondition", _target], _radius]; 
				// _actions append [_actionSwitchTurret, _actionSwitchDriver];
				private _actionSwitchCamera = _self addAction ["<t color='#ffba4a'>Switch Camera</t>", { 
					(_this#3) params ["_target"]; 

					[_target] call CFM_fnc_monitorNextTurretCamera;
				}, [_self], _priority, true, false, "", format["[%1] call CFM_fnc_switchCameraTurretActionCondition", _target], _radius]; 
				_actions append [_actionSwitchCamera];
			};

			if (_canTurnOffLocal && !_isHandMonitor) then {
				private _actionTurnOffLocal = _self addAction ["<t color='#8a3200'>Turn off feed (local)</t>", { 
					(_this#3) params ["_target"]; 
					
					[_target] call CFM_fnc_turnOffMonitorLocal;
				}, [_self], _priority, true, false, "", format["[%1] call CFM_fnc_turnOffActionCondition", _target], _radius]; 
				private _actionTurnOnLocal = _self addAction ["<t color='#036900'>Turn on feed (local)</t>", { 
					(_this#3) params ["_target"]; 
					
					[_target] call CFM_fnc_turnOnMonitorLocal;
				}, [_self], _priority, true, false, "", format["[%1] call CFM_fnc_turnOnActionCondition", _target], _radius]; 
				_actions append [_actionTurnOffLocal, _actionTurnOnLocal];
			};

			if (_canSwitchNvg) then {
				private _actionSwitchNvg = _self addAction ["<t color='#006e02'>Toggle NVG</t>", { 
					(_this#3) params ["_target"]; 
					[_target] call CFM_fnc_monitorToggleNVG;
				}, [_self], _priority, true, false, "", format["[%1] call CFM_fnc_toggleNvgActionCondition", _target], _radius]; 
				_actions append [_actionSwitchNvg];
			};

			if (_canSwitchTi) then {
				private _actionSwitchTi = _self addAction ["<t color='#525252'>Toggle TI</t>", { 
					(_this#3) params ["_target"]; 
					[_target] call CFM_fnc_monitorSwitchTi;
				}, [_self], _priority, true, false, "", format["[%1] call CFM_fnc_toggleTiActionCondition", _target], _radius]; 
				_actions append [_actionSwitchTi];
			};

			if (_canFullScreen) then {
				private _actionEnterFullScreen = _self addAction ["<t color='#67bce0'>Enter Fullscreen</t>", { 
					(_this#3) params ["_target"]; 
					[_target] call CFM_fnc_enterMonitorFullScreen;
				}, [_self], _priority, true, false, "", format["[%1] call CFM_fnc_enterFullScreenActionCondition", _target], _radius]; 
				// private _actionExitFullScreen = _self addAction ["<t color='#67bce0'>Exit Fullscreen</t>", { 
				// 	(_this#3) params ["_target"]; 
				// 	[_target] call CFM_fnc_exitMonitorFullScreen;
				// }, [_self], _priority, true, false, "", format["[%1] call CFM_fnc_exitFullScreenActionCondition", _target], _radius]; 
				_actions append [_actionEnterFullScreen];
			};
		};
		["addActionsToActionsList", _actions] CALL_OBJCLASS("Monitor", _self);
	};
	METHOD("monitorEnterFullScreen") {
		missionNamespace setVariable ["CFM_currentFullScreenMonitor", _self];
		if (missionNamespace getVariable ["CFM_fullscreenIsPip", false]) exitWith {
			[_self, true, true] call CFM_fnc_setHandDisplay;
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
		if (_onTempCam) then {
			createDialog "RscDisplayCFM";
			missionNamespace setVariable ["CFM_currentFullScreenCam", _unitCam];
			missionNamespace setVariable ["CFM_r2tOfFullScreenCam", _currentR2T];
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
			_self spawn {
				private _initPos = getPosASL PLAYER_;
				private _initDir = getDir PLAYER_;
				waitUntil {
					uiSleep 1;
					!(_initPos isEqualTo (getPosASL PLAYER_)) 
					// ||
					// !(_initDir isEqualTo (getDir PLAYER_))
				};
				[_this] call CFM_fnc_exitMonitorFullScreen;
				sleep 1;
				[_this] call CFM_fnc_exitMonitorFullScreen;
			};
		};
		if (_isHandMonitor) then {
			[_self] call CFM_fnc_turnOffMonitorLocal;
		};
		missionNamespace setVariable ["CFM_isInFullScreen", true];
		_hintText _HINT;
		// cutText [format["<t size='2' color='#ff0000'>%1</t>", _hintText], "PLAIN DOWN", 5, true, true];
		true
	};
	METHOD("monitorExitFullScreen") {
		private _onTempCam = missionNamespace getVariable ["CFM_fullScreenOnTempCam", true];
		private _isMavic = _connectedOperator getVariable ["CFM_isMavic", false];
		private _isFPV = _connectedOperator getVariable ["CFM_isFPV", false];
		if (_onTempCam) then {
			if (IS_VALID_R2T(_currentR2T)) then {
				_currentFeedCam cameraEffect ["internal", "back", _currentR2T];
			} else {
				_currentFeedCam cameraEffect ["Terminate", "back"];
				PLAYER_ switchCamera "INTERNAL";
			};
			[_self, _currentPiPEffect] call CFM_fnc_setMonitorPiPEffect;
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
			[_self] call CFM_fnc_turnOnMonitorLocal;
		};
		false setCamUseTI 0;
		camUseNVG false;
		CLEAR_HINT
		cutText ["", "PLAIN"];
		missionNamespace setVariable ["CFM_isInFullScreen", false];
		missionNamespace setVariable ["CFM_currentFullScreenMonitor", nil];
		missionNamespace setVariable ["CFM_currentFullScreenCam", nil];
		missionNamespace setVariable ["CFM_r2tOfFullScreenCam", nil];
		true
	};
	METHOD("getOperatorInfo") {
		private _opName = _connectedOperator getVariable ["CFM_operatorName", ""];
		private _dist = _self distance _connectedOperator;
		private _grid = mapGridPosition _connectedOperator;
		private _currentTurret = _self getVariable ["CFM_currentTurret", _currentTurret];
		private _turrIndex = TURRET_INDEX(_currentTurret);

		private _infoStr = format["Operator info %1 Name: %2%1 Map pos: %3%1 Distance: %4%1 Turret: %5", endl, _opName, _grid, _dist, _turrIndex];

		_infoStr _HINT;
	};
	METHOD("setOperatorInfo") {
		params[["_set", false]];
		private _infoStr = if (_set && {IS_OBJ(_connectedOperator)}) then {
			private _currentTurret = _self getVariable ["CFM_currentTurret", _currentTurret];
			private _turrIndex = TURRET_INDEX(_currentTurret);
			private _opName = [_connectedOperator, _turrIndex] call CFM_fnc_getOperatorName;
			private _turrName = if (_currentCameraIsStatic) then {_turrIndex} else {
				switch (_turrIndex) do {
					case -1: {
						if (_currentOperatorIsDrone) then {"Pilot"} else {"Driver"};
					};
					case 0: {
						"Gunner"
					};
					default {_turrIndex};
				};
			};
			if (_currentOpHasTurrets) then {
				format["<t color='#0d6aff'>Camera:</t> %1 <t color='#0d6aff'>Turret</t>: %2", _opName, _turrIndex];
			} else {
				format["<t color='#0d6aff'>Camera:</t> %1", _opName];
			};
		} else {
			OPERATOR_INFO_TEXT_DEF
		};

		_self setUserActionText [_operatorInfoActionId, _infoStr];

		_infoStr
	};
	METHOD("switchUAV") {
		if !(_currentOperatorIsDrone) exitWith {
			"Current feed is not UAV!" _HINT
			false
		};

		private _currentUav = vehicle (remoteControlled PLAYER_);

		if !(IS_OBJ(_currentUav)) exitWith {
			"You're not controlling any UAV!" _HINT
			false
		};

		private _newUav = _connectedOperator;
		private _controled = [_newUav, "DRIVER"] call CFM_fnc_isUAVControlled;

		if (_controled) exitWith {
			"Can't connect! UAV is controlled" _HINT
			false
		};

		private _currentUavIsOp = _currentUav getVariable ["CFM_operatorSet", false];

		if !(_currentUavIsOp) exitWith {
			"Current UAV can't feed!" _HINT
			false
		};

		// take uav control
		[_self] spawn CFM_fnc_takeUAVcontorls;

		// wait for taking uav controll
		private _waitStart = time;
		waitUntil {
			(
				(MGVAR ["CFM_currentControlledUAV", objNull]) isEqualTo _newUav
			) || {
				(time - _waitStart) > 2
			}
		};

		// check if we have taken control of new uav
		if !((MGVAR ["CFM_currentControlledUAV", objNull]) isEqualTo _newUav) exitWith {
			"Can't connect to UAV!" _HINT
			false
		};

		// connect previuos uav to hand monitor
		[_self, _currentUav, PLAYER_] call CFM_fnc_connectMonitorToOperator;

		true
	};
CLASS_END