CLASS(Monitor)

	SET_SELF_VAR(_monitor);

	VARIABLE(_radius, ACTION_RADIUS);
	VARIABLE(_menuActive, false);
	VARIABLE(_isHandMonitor, false);
	VARIABLE(_isLocal, false);
	VARIABLE(_currentTurret, DRIVER_TURRET_PATH);
	VARIABLE(_connectedOperator, objNull);
	VARIABLE(_isOff, false);
	VARIABLE(_feedActive, false);
	VARIABLE(_renderTarget, "");
	VARIABLE(_cameraType, "");
	VARIABLE(_currentFeedCam, objNull);
	VARIABLE(_currentR2T, "");
	VARIABLE(_opHasTurrets, false);
	VARIABLE(_turnedOffLocal, false);
	VARIABLE(_originalTexture, "");
	VARIABLE(_canSwitchNvg, false);
	VARIABLE(_canSwitchTi, false);
	VARIABLE(_currentPiPEffect, 0);
	VARIABLE(_tiTable, createHashMap);

	METHODS

	METHOD("init") { 
		// should be executed globaly
		params [
			["_monitor", objNull], 
			["_canZoom", true],
			["_canConnectDrone", true],
			["_canFix", true],
			["_canSwitchTurret", true],
			["_canTurnOffLocal", true],
			["_canSwitchNvg", true],
			["_canSwitchTi", true]
		]; 

		if (_monitor isEqualTo objNull) exitWith {};
			
		if ((_monitor getVariable ["CFM_isMonitorSet", false]) isEqualTo true) exitWith {};

		private _isPlayer = (_monitor isEqualTo player) || {(_monitor isKindOf "Man")};
		private _setlocal = !_isPlayer;
		private _local = local _monitor;

		if (!_setlocal && !_local) exitWith {};

		_isHandMonitor = _isPlayer;
		_isLocal = _isHandMonitor;
		private _originalTexture = (getObjectTextures _monitor) select 0;
		_monitor setVariable ["CFM_originalTexture", _originalTexture]; 

		if (_local) then {
			private _mons = missionNamespace getVariable ["CFM_currentMonitors", []];
			_mons pushBackUnique _monitor;
			missionNamespace setVariable ["CFM_currentMonitors", _mons, true];
			_monitor setVariable ["CFM_isHandMonitor", _isHandMonitor, true];
			_monitor setVariable ["CFM_isLocal", _isLocal, true];
		};
		private _radius = ACTION_RADIUS;
		private _menuText = "Camera System Menu";
		private _additionalCondition = if (_isHandMonitor) then {
			_monitor setVariable ["CFM_isHandMonitor", true, true];
			_radius = -1;
			_menuText = "Camera System Tablet";
			"&& {[_target] call CFM_fnc_hasUAVterminal}"
		} else {""};
		
		_monitor setVariable ["CFM_actionsRadius", _radius];

		["addMenuActions", [_radius, _menuText, _additionalCondition]] CALL_OBJCLASS(_self);
		["addOptionalActions", [_radius]] CALL_OBJCLASS(_self);

		_monitor setVariable ["CFM_isMonitorSet", true];
	};
	METHOD("setRenderPicture") {
		params[["_render", true], ["_r2t", ""]];

		if (_render && {_r2t isEqualTo ""}) then {
			_r2t = _currentR2T;
		};
		_render = _render && !(_r2t isEqualTo "");
		_monitor setVariable ["CFM_currentR2T", _r2t];

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
		params [["_operator", objNull], ["_turret", []]];

		private _monitor = _self;

		if !(IS_OBJ(_monitor)) exitWith {"CFM_fnc_startOperatorFeed: Monitor is not an object"};
		if !(IS_OBJ(_operator)) exitWith {"CFM_fnc_startOperatorFeed: Operator is not an object"};

		if (_turret isEqualTo []) then {
			_turret = _currentTurret;
		};

		private _renderTarget = ["getRenderTarget", [_monitor, _turret], _operator, ""] CALL_OBJCLASS(_operator);
		["setRenderPicture", [true, _renderTarget]] CALL_OBJCLASS(_monitor);
	}; 
	METHOD("stopFeed") {
		["setRenderPicture", [false]] CALL_OBJCLASS(_monitor);
	};
	METHOD("connect") {
		params["_op"];
		[[netId _self, netId _op, true], "CFM_fnc_syncState", !_isLocal, _self] call CFM_fnc_remoteExec; 
		_self setVariable ['CFM_menuActive', false];
		{ _self removeAction _x } forEach (_self getVariable ["CFM_tempActions", []]); 
	};
	METHOD("disconnect") {
		[[netId _self, "", false], "CFM_fnc_syncState", !_isLocal, _self] call CFM_fnc_remoteExec; 
		_self setVariable ['CFM_menuActive', false];
	};
	METHOD("loadMenu") { 
		params [["_caller", objNull]]; 
		private _ops = call CFM_fnc_getActiveCameras; 
		private _opsGlobal = call CFM_fnc_getActiveCamerasCheckGlobal; 
		{
			_ops pushBackUnique _x;
		} forEach _opsGlobal;

		private _radius = MONITOR_ACTION_RADIUS(_target);

		if (count _ops == 0) exitWith { hint "No active cameras!" }; 
			
		private _tempIDs = []; 

		private _closeID = _target addAction ["<t color='#ff6600'>   [Close Menu]</t>", { 
			params ["_t"]; 
			{ _t removeAction _x } forEach (_t getVariable ["CFM_tempActions", []]); 
			_t setVariable ['CFM_menuActive', false];
		}, nil, 11, true,false,"","(_target getVariable ['CFM_menuActive', false])",_radius]; 
		_tempIDs pushBack _closeID; 

		{  
			private _type = _x getVariable ["CFM_cameraType", GOPRO];
			private _name = switch (_type) do {
				case GOPRO: {
					format["%1: %2", groupId group _x, name _x]
				};
				default {format["%1: %2", groupId group _x, (getText (configFile >> "CfgVehicles" >> (typeOf _x) >> "displayName"))]};
			};
			private _id = _target addAction [format["        <t color='#3e99fa'>[Connect]</t>: %1", _name], { 
				params ["_t", "_c", "_i", "_p"]; 
				["connect", [_p select 0]] CALL_OBJCLASS(_t);
			}, [_x], 10, true,false,"","(_target getVariable ['CFM_menuActive', false])", _radius]; 
			_tempIDs pushBack _id; 
		} forEach _ops; 
			
		_target setVariable ["CFM_tempActions", _tempIDs]; 
		_target setVariable ['CFM_menuActive', true];
			
		[_target, _tempIDs] spawn { 
			params["_target", "_tempIDs"];
			waitUntil {sleep 1; (_target distance player) > 5;};
			{ _target removeAction _x } forEach _tempIDs; 
			_target setVariable ['CFM_menuActive', false];
		}; 
	};
	METHOD("zoom") {
		params [["_zoomAdd", 0], ["_zoomSet", -1]]; 

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

			private _type = _monitor getVariable ["CFM_cameraType", GOPRO];
			private _maxZoom = switch (_type) do {
				case GOPRO: {missionNamespace getVariable ["CFM_max_zoom_gopro", 2]};
				case DRONETYPE: {missionNamespace getVariable ["CFM_max_zoom_drone", 5]};
				default {1};
			};

			private _zoomedMax = _newzoom >= _maxZoom;
			_monitor setVariable ['CFM_maxZoomed', _zoomedMax, true];

			_newzoom
		} else {_zoomAdd};

		["setZoom", [_self, _currentTurret, _newzoom]] CALL_OBJCLASS(_connectedOperator);

		_newzoom
	};
	METHOD("switchTurret") {
		params[["_turret", DRIVER_TURRET_PATH]];
		_self setVariable ["CFM_currentTurret", _turret, true]; 
		[[_self], "CFM_fnc_resetFeed", !_isLocal, _self] call CFM_fnc_remoteExec;
	};
	METHOD("switchNvg") { 
		private _newEffect = 0;
		if (_currentPiPEffect != 1) then {
			_newEffect = 1;
		};
		if (_currentPiPEffect == 1) then {
			_newEffect = 0;
		};
		[[_self, _newEffect], "CFM_fnc_setMonitorPiPEffect", !_isLocal, _self] call CFM_fnc_remoteExec;
	};
	METHOD("switchTi") { 
		private _tiModes = _tiTable getOrDefault [_currentTurret#0, [0]];
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
		[[_self, _newEffect], "CFM_fnc_setMonitorPiPEffect", !_isLocal, _self] call CFM_fnc_remoteExec;
	};
	METHOD("addActionsToActionsList") {
		params["_actions"];
		private _savedActions = _self getVariable ["CFM_mainActions", []];
		_savedActions append _actions;
		_self setVariable ["CFM_mainActions", _savedActions];
		_savedActions
	};
	METHOD("addMenuActions") {
		params[["_radius", ACTION_RADIUS], ["_menuText", "Camera System Menu"], ["_additionalCondition", ""]];
		private _radius = _self getVariable ["CFM_actionsRadius", _radius];
		private _actionMenu = _self addAction [format["<t color='#00FF00'>%1</t>", _menuText], { 
			params ["_target", "_caller"]; 

			["loadMenu", [_caller]] CALL_OBJCLASS(_target);
		}, nil, 1.5, true, false, "", "!((_target getVariable ['CFM_feedActive', false]) || (_target getVariable ['CFM_menuActive', false]))" + _additionalCondition, _radius]; 

		private _actionDisc = _self addAction ["<t color='#FF0000'>Disconnect Camera</t>", { 
			params ["_target"]; 
			[[netId _target, "", false], "CFM_fnc_syncState", true, _target] call CFM_fnc_remoteExec; 
			_target setVariable ['CFM_menuActive', false];
		}, nil, 1.5, true, false, "", "_target getVariable ['CFM_feedActive', false]", _radius]; 
		["addActionsToActionsList", [_actionMenu, _actionDisc]] call CALL_CLASS(_self);
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
		private _actions = [];
		private _radius = _self getVariable ["CFM_actionsRadius", _radius];
		call {
			if (_canZoom) then {
				private _actionZoomIn = _self addAction ["<t color='#c5dafa'>Zoom In</t>", { 
					params ["_target"];
					
					[_target, +1] call CFM_fnc_zoom;
				}, nil, 1.5, true, false, "", "(_target getVariable ['CFM_feedActive', false]) && !(_target getVariable ['CFM_maxZoomed', false])", _radius]; 

				private _actionZoomOut = _self addAction ["<t color='#c5dafa'>Zoom Out</t>", { 
					params ["_target"];
					
					[_target, -1] call CFM_fnc_zoom;
				}, nil, 1.5, true, false, "", "_target getVariable ['CFM_feedActive', false]", _radius]; 
			
				private _actionZoomDefault = _self addAction ["<t color='#45d9b9'>Reset Zoom</t>", { 
					params ["_target"]; 

					[_target, "reset"] call CFM_fnc_zoom;
				}, nil, 1.5, true, false, "", "_target getVariable ['CFM_feedActive', false]", _radius]; 

				private _actionZoomByDrone = _self addAction ["<t color='#90c73e'>Use Operator Zoom</t>", { 
					params ["_target"]; 

					[_target, "op"] call CFM_fnc_zoom;
				}, nil, 1.5, true, false, "", "_target getVariable ['CFM_feedActive', false]", _radius]; 

				_actions append [_actionZoomIn, _actionZoomOut, _actionZoomDefault, _actionZoomByDrone];
			};

			if (_canConnectDrone) then {
				private _connectDroneAction = _self addAction ["<t color='#1c399e'>Take drone controls</t>", { 
					params ["_target"]; 

					private _drone = _target getVariable ["CFM_connectedOperator", objNull]; 
					private _errtext = "Can't connect to drone";

					if ((_drone isEqualTo objNull) || !(_drone isEqualType objNull)) exitWith {
						hint _errtext;
					};

					private _controler = remoteControlled _drone;

					if (!(_controler isEqualTo objNull) || !(_controler isEqualType objNull)) exitWith {
						hint _errtext;
					};

					private _connect = player connectTerminalToUAV _drone;

					if !(_connect) exitWith {
						hint _errtext;
					};

					private _bot = driver _drone;
					private _currTurret = _target getVariable ["CFM_currentTurret", DRIVER_TURRET_PATH]; 
					if (_currTurret isEqualTo GUNNER_TURRET_PATH) then {
						_bot = gunner _drone;
						if (isNull _bot) then {
							_bot = driver _drone;
						};
					};

					player remoteControl (_bot);
					_drone switchCamera "internal";
				}, nil, 1.5, true, false, "", "
					(_target getVariable ['CFM_feedActive', false]) && {
						(_target getVariable ['CFM_isDroneFeed', false]) &&
						{[player] call CFM_fnc_hasUAVterminal}
					}
				", _radius]; 
				_actions append [_connectDroneAction];
			};

			if (_canFix) then {
				private _actionFix = _self addAction ["<t color='#690707'>Fix feed (local)</t>", { 
					params ["_target"]; 
					
					[] call CFM_fnc_fixFeed;
				}, nil, 1.5, true, false, "", "(_target getVariable ['CFM_feedActive', false])", _radius]; 
				_actions append [_actionFix];
			};

			if (_canSwitchTurret) then {
				private _actionSwitchTurret = _self addAction ["<t color='#ffba4a'>Switch to Turret Camera</t>", { 
					params ["_target"]; 
					
					["switchTurret", [GUNNER_TURRET_PATH]] CALL_OBJCLASS(_target);
				}, nil, 1.5, true, false, "", "
					(_target getVariable ['CFM_feedActive', false]) && {
						(_target getVariable ['CFM_opHasTurrets', false]) && {
							((_target getVariable ['CFM_currentTurret', [-1]]) isEqualTo [-1])
						}
					}
				", _radius]; 
				private _actionSwitchDriver = _self addAction ["<t color='#ffba4a'>Switch to Pilot Camera</t>", { 
					params ["_target"]; 

					["switchTurret", [DRIVER_TURRET_PATH]] CALL_OBJCLASS(_target);
				}, nil, 1.5, true, false, "", "
					(_target getVariable ['CFM_feedActive', false]) && {
						(_target getVariable ['CFM_opHasTurrets', false]) && {
							((_target getVariable ['CFM_currentTurret', [-1]]) isEqualTo [0])
						}
					}
				", _radius]; 
				_actions append [_actionSwitchTurret, _actionSwitchDriver];
			};

			if (_canTurnOffLocal) then {
				private _actionTurnOffLocal = _self addAction ["<t color='#8a3200'>Turn off feed (local)</t>", { 
					params ["_target"]; 
					
					[_target, false] call CFM_fnc_setMonitorTexture;
					_target setVariable ["CFM_turnedOffLocal", true]; 
				}, nil, 1.5, true, false, "", "(_target getVariable ['CFM_feedActive', false]) && {!(_target getVariable ['CFM_turnedOffLocal', false])}", _radius]; 
				private _actionTurnOnLocal = _self addAction ["<t color='#036900'>Turn on feed (local)</t>", { 
					params ["_target"]; 
					
					[_target] call CFM_fnc_setMonitorTexture;
					_target setVariable ["CFM_turnedOffLocal", false];  
				}, nil, 1.5, true, false, "", "(_target getVariable ['CFM_feedActive', false]) && {(_target getVariable ['CFM_turnedOffLocal', false])}", _radius]; 
				_actions append [_actionTurnOffLocal, _actionTurnOnLocal];
			};

			if (_canSwitchNvg) then {
				private _actionSwitchNvg = _self addAction ["<t color='#006e02'>Toggle NVG</t>", { 
					params ["_target"]; 
					["switchNvg"] CALL_OBJCLASS(_target);
				}, nil, 1.5, true, false, "", "
					(_target getVariable ['CFM_feedActive', false]) && {
						(_target getVariable ['CFM_canSwitchNvg', false]) && {
							!((equipmentDisabled (_target getVariable ['CFM_connectedOperator', objNull]))#0) && {
								(
									(_target getVariable ['CFM_nvgTable', createHashMap]) getOrDefault 
									[((_target getVariable ['CFM_currentTurret', [-1]])#0), false]
								)
							}
						}
					}
				", _radius]; 
				_actions append [_actionSwitchNvg];
			};

			if (_canSwitchTi) then {
				private _actionSwitchTi = _self addAction ["<t color='#525252'>Toggle TI</t>", { 
					params ["_target"]; 
					["switchTi"] CALL_OBJCLASS(_target);
				}, nil, 1.5, true, false, "", "
					(_target getVariable ['CFM_feedActive', false]) && {
						(_target getVariable ['CFM_canSwitchTi', false]) && {
							!((equipmentDisabled (_target getVariable ['CFM_connectedOperator', objNull]))#1) && {
								(
									!(
										(
											(_target getVariable ['CFM_tiTable', createHashMap]) getOrDefault 
											[((_target getVariable ['CFM_currentTurret', [-1]])#0), []]
										) isEqualTo []
									)
								)
							}
						}
					}
				", _radius]; 
				_actions append [_actionSwitchTi];
			};
		};
		["addActionsToActionsList", _actions] call CALL_CLASS(_self);
	};
CLASS_END