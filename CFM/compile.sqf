#include "defines.hpp"

CFM_fnc_init = {
	CFM_updatePosSystem = false;

	if (CFM_updatePosSystem) then {
		[] call CFM_fnc_setupDraw3dEH;
	};

	CFM_max_zoom_gopro = 2;
	CFM_max_zoom_drone = 5;

	CFM_goPro_zoomTable = createHashMapFromArray [[2, 0.25]];
	CFM_drone_zoomTable = createHashMapFromArray [[2, 0.5], [3, 0.2], [4, 0.09], [5, 0.07]];

	CFM_tiModesTable = createHashMapFromArray [[0, 2], [1, 7], [6, 12]];

	CFM_classesSetup = createHashMap;

	CFM_inited = true;
};

CFM_fnc_updateOperatorZoom = {
	private _isRemoteControlling = isRemoteControlling player;
	if !(_isRemoteControlling) exitWith {};

	private _controlledObj = remoteControlled player;
	if (_controlledObj isEqualTo objNull) exitWith {};
	if (_controlledObj isEqualTo player) exitWith {};
	if (_controlledObj isEqualTo (vehicle player)) exitWith {};

	private _currentFOV = getObjectFOV _controlledObj;
	private _currentZoom = round (1 / _currentFOV);
	private _prevZoom = _controlledObj getVariable ["CFM_prevZoom", _currentZoom];

	if (_currentZoom isEqualTo _prevZoom) exitWith {};

	_controlledObj setVariable ["CFM_prevZoom", _currentZoom, true];
};

CFM_fnc_draw3dEH = {
	if !(missionNamespace getVariable ["CFM_updatePosSystem", false]) exitWith {};

	private _monitors = missionNamespace getVariable ["CFM_currentMonitors", []];
	{
		private _monitorCamIsUpdating = _x getVariable ["CFM_monitorCamUpdating", true];
		if !(_monitorCamIsUpdating) then {continue};
		private _monitorLive = [_x] call CFM_fnc_monitorLiveCondition;
		if (!_monitorLive) then {
			if ((_x getVariable ["CFM_isOff", true]) isEqualTo false) then {
				[_x] call CFM_fnc_stopOperatorFeed;
			};
			continue
		};
		private _checkLocality = _monitor getVariable ["CFM_doCheckTurretLocality", false];
		[_x, true, false, _checkLocality] call CFM_fnc_updateCamera;
	} forEach _monitors;

	// UPDATE OBJECT ZOOM
	// [] call CFM_fnc_updateOperatorZoom;
};

CFM_fnc_setupDraw3dEH = {
	if !(isNil "CFM_EH_id") exitWith {};
	private _id = addMissionEventHandler ["Draw3D", {call CFM_fnc_draw3dEH}];
	CFM_EH_id = _id;
};

CFM_fnc_zoom = {
	params ["_op", ["_zoomAdd", 0], ["_zoomSet", -1]]; 

	if !(_zoomAdd isEqualType 1) exitWith {
		_op setVariable ['CFM_zoom', _zoomAdd, true];
	};
	private _newZoom = if (_zoomSet isEqualTo -1) then {
		private _zoom = _op getVariable ['CFM_zoom', 1];
		if !(_zoom isEqualType 1) then {
			_zoom = 1;
		};
		(_zoom + _zoomAdd) max 1;
	} else {
		_zoomSet
	};

	_op setVariable ['CFM_zoom', _newzoom, true];

	private _type = _op getVariable ["CFM_cameraType", GOPRO];
	private _maxZoom = switch (_type) do {
		case GOPRO: {missionNamespace getVariable ["CFM_max_zoom_gopro", 2]};
		case DRONETYPE: {missionNamespace getVariable ["CFM_max_zoom_drone", 5]};
		default {1};
	};

	private _zoomedMax = _newzoom >= _maxZoom;
	_op setVariable ['CFM_maxZoomed', _zoomedMax, true];
};

CFM_fnc_setMonitor = { 
	// should be executed globaly
	params [
		"_monitor", 
		["_canZoom", true],
		["_canConnectDrone", true],
		["_canFix", true],
		["_canSwitchTurret", true],
		["_canTurnOffLocal", true],
		["_canSwitchNvg", true],
		["_canSwitchTi", true]
	]; 
		
	if ((_monitor getVariable ["CFM_isSet", false]) isEqualTo true) exitWith {};

	if (isNil "CFM_Cam_Idx") then { CFM_Cam_Idx = 0 }; 
	private _rTarget = format["cfmrtarget%1", CFM_Cam_Idx]; 
	CFM_Cam_Idx = CFM_Cam_Idx + 1; 
	_monitor setVariable ["CFM_operatorRenderTarget", _rTarget, true]; 

	private _mons = missionNamespace getVariable ["CFM_currentMonitors", []];
	_mons pushBackUnique _monitor;
	missionNamespace setVariable ["CFM_currentMonitors", _mons];

	private _actions = [];

	private _actionMenu = _monitor addAction ["<t color='#00FF00'>Camera System Menu</t>", { 
		params ["_target", "_caller"]; 
		private _ops = call CFM_fnc_getActiveCameras; 
		private _opsGlobal = call CFM_fnc_getActiveCamerasCheckGlobal; 
		{
			_ops pushBackUnique _x;
		} forEach _opsGlobal;

		if (count _ops == 0) exitWith { hint "No active cameras!" }; 
			
		private _tempIDs = []; 

		private _closeID = _target addAction ["<t color='#ff6600'>   [Close Menu]</t>", { 
			params ["_t"]; 
			{ _t removeAction _x } forEach (_t getVariable ["CFM_tempActions", []]); 
			_t setVariable ['CFM_menuActive', false];
		}, nil, 11, true,false,"","(_target getVariable ['CFM_menuActive', false])",ACTION_RADIUS]; 
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
				[[netId _t, netId (_p select 0), true], "CFM_fnc_syncState", true, _t] call CFM_fnc_remoteExec; 
				{ _t removeAction _x } forEach (_t getVariable ["CFM_tempActions", []]); 
			}, [_x], 10, true,false,"","(_target getVariable ['CFM_menuActive', false])", ACTION_RADIUS]; 
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
	}, nil, 1.5, true, false, "", "!((_target getVariable ['CFM_operatorFeedActive', false]) || (_target getVariable ['CFM_menuActive', false]))", ACTION_RADIUS]; 

	private _actionDisc = _monitor addAction ["<t color='#FF0000'>Disconnect Camera</t>", { 
		params ["_target"]; 
		[[netId _target, "", false], "CFM_fnc_syncState", true, _target] call CFM_fnc_remoteExec; 
		_target setVariable ['CFM_menuActive', false];
	}, nil, 1.5, true, false, "", "_target getVariable ['CFM_operatorFeedActive', false]", ACTION_RADIUS]; 

	_actions append [_actionMenu, _actionDisc];

	// ACTIONS
	call {
		if (_canZoom) then {
			private _actionZoomIn = _monitor addAction ["<t color='#c5dafa'>Zoom In</t>", { 
				params ["_target"];
				
				[_target, +1] call CFM_fnc_zoom;
			}, nil, 1.5, true, false, "", "(_target getVariable ['CFM_operatorFeedActive', false]) && !(_target getVariable ['CFM_maxZoomed', false])", ACTION_RADIUS]; 

			private _actionZoomOut = _monitor addAction ["<t color='#c5dafa'>Zoom Out</t>", { 
				params ["_target"];
				
				[_target, -1] call CFM_fnc_zoom;
			}, nil, 1.5, true, false, "", "_target getVariable ['CFM_operatorFeedActive', false]", ACTION_RADIUS]; 
		
			private _actionZoomDefault = _monitor addAction ["<t color='#45d9b9'>Reset Zoom</t>", { 
				params ["_target"]; 

				[_target, "reset"] call CFM_fnc_zoom;
			}, nil, 1.5, true, false, "", "_target getVariable ['CFM_operatorFeedActive', false]", ACTION_RADIUS]; 

			private _actionZoomByDrone = _monitor addAction ["<t color='#90c73e'>Use Operator Zoom</t>", { 
				params ["_target"]; 

				[_target, "op"] call CFM_fnc_zoom;
			}, nil, 1.5, true, false, "", "_target getVariable ['CFM_operatorFeedActive', false]", ACTION_RADIUS]; 

			_actions append [_actionZoomIn, _actionZoomOut, _actionZoomDefault, _actionZoomByDrone];
		};

		if (_canConnectDrone) then {
			private _connectDroneAction = _monitor addAction ["<t color='#1c399e'>Take drone controls</t>", { 
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
				(_target getVariable ['CFM_operatorFeedActive', false]) && {
					(_target getVariable ['CFM_isDroneFeed', false]) &&
					{'terminal' in (toLower (player getSlotItemName 612))}
				}
			", ACTION_RADIUS]; 
			_actions append [_connectDroneAction];
		};

		if (_canFix) then {
			private _actionFix = _monitor addAction ["<t color='#690707'>Fix feed (local)</t>", { 
				params ["_target"]; 
				
				[] call CFM_fnc_fixFeed;
			}, nil, 1.5, true, false, "", "(_target getVariable ['CFM_operatorFeedActive', false])", ACTION_RADIUS]; 
			_actions append [_actionFix];
		};

		if (_canSwitchTurret) then {
			private _actionSwitchTurret = _monitor addAction ["<t color='#ffba4a'>Switch to Turret Camera</t>", { 
				params ["_target"]; 
				
				_target setVariable ["CFM_currentTurret", GUNNER_TURRET_PATH, true];  
				[[_target], "CFM_fnc_resetFeed", true, _target] call CFM_fnc_remoteExec;
			}, nil, 1.5, true, false, "", "
				(_target getVariable ['CFM_operatorFeedActive', false]) && {
					(_target getVariable ['CFM_opHasTurrets', false]) && {
						((_target getVariable ['CFM_currentTurret', [-1]]) isEqualTo [-1])
					}
				}
			", ACTION_RADIUS]; 
			private _actionSwitchDriver = _monitor addAction ["<t color='#ffba4a'>Switch to Pilot Camera</t>", { 
				params ["_target"]; 

				_target setVariable ["CFM_currentTurret", DRIVER_TURRET_PATH, true];  
				[[_target], "CFM_fnc_resetFeed", true, _target] call CFM_fnc_remoteExec;
			}, nil, 1.5, true, false, "", "
				(_target getVariable ['CFM_operatorFeedActive', false]) && {
					(_target getVariable ['CFM_opHasTurrets', false]) && {
						((_target getVariable ['CFM_currentTurret', [-1]]) isEqualTo [0])
					}
				}
			", ACTION_RADIUS]; 
			_actions append [_actionSwitchTurret, _actionSwitchDriver];
		};

		if (_canTurnOffLocal) then {
			private _actionTurnOffLocal = _monitor addAction ["<t color='#8a3200'>Turn off feed (local)</t>", { 
				params ["_target"]; 
				
				_target setObjectTexture [0, ""];  
				_target setVariable ["CFM_turnedOffLocal", true]; 
			}, nil, 1.5, true, false, "", "(_target getVariable ['CFM_operatorFeedActive', false]) && {!(_target getVariable ['CFM_turnedOffLocal', false])}", ACTION_RADIUS]; 
			private _actionTurnOnLocal = _monitor addAction ["<t color='#036900'>Turn on feed (local)</t>", { 
				params ["_target"]; 
				
				[_target] call CFM_fnc_setMonitorTexture;
				_target setVariable ["CFM_turnedOffLocal", false];  
			}, nil, 1.5, true, false, "", "(_target getVariable ['CFM_operatorFeedActive', false]) && {(_target getVariable ['CFM_turnedOffLocal', false])}", ACTION_RADIUS]; 
			_actions append [_actionTurnOffLocal, _actionTurnOnLocal];
		};

		if (_canSwitchNvg) then {
			private _actionSwitchNvg = _monitor addAction ["<t color='#006e02'>Toggle NVG</t>", { 
				params ["_target"]; 
				
				private _currentPiPEffect = _target getVariable ["CFM_currentPiPEffect", 0]; 
				private _newEffect = 0;
				if (_currentPiPEffect != 1) then {
					_newEffect = 1;
				};
				if (_currentPiPEffect == 1) then {
					_newEffect = 0;
				};
				[[_target, _newEffect], "CFM_fnc_setMonitorPiPEffect", true, _target] call CFM_fnc_remoteExec;
			}, nil, 1.5, true, false, "", "
				(_target getVariable ['CFM_operatorFeedActive', false]) && {
					(_target getVariable ['CFM_canSwitchNvg', false]) && {
						!((equipmentDisabled (_target getVariable ['CFM_connectedOperator', objNull]))#0) && {
							(
								(_target getVariable ['CFM_nvgTable', createHashMap]) getOrDefault 
								[((_target getVariable ['CFM_currentTurret', [-1]])#0), false]
							)
						}
					}
				}
			", ACTION_RADIUS]; 
			_actions append [_actionSwitchNvg];
		};

		if (_canSwitchTi) then {
			private _actionSwitchTi = _monitor addAction ["<t color='#525252'>Toggle TI</t>", { 
				params ["_target"]; 
				
				private _currentPiPEffect = _target getVariable ["CFM_currentPiPEffect", 0]; 
				private _tiTable = _target getVariable ["CFM_tiTable", 0]; 
				private _turret = (_target getVariable ["CFM_currentTurret", DRIVER_TURRET_PATH])#0; 
				private _tiModes = _tiTable getOrDefault [_turret, [0]];
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
				[[_target, _newEffect], "CFM_fnc_setMonitorPiPEffect", true, _target] call CFM_fnc_remoteExec;
			}, nil, 1.5, true, false, "", "
				(_target getVariable ['CFM_operatorFeedActive', false]) && {
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
			", ACTION_RADIUS]; 
			_actions append [_actionSwitchTi];
		};
	};

	_monitor setVariable ["CFM_mainActions", _actions];
	_monitor setVariable ["CFM_isSet", true];
};

CFM_fnc_setCamera = {
	// should be executed globaly
	params["_op", ["_type", ""], ["_hasTInNvg", [0, 0]], ["_params", []]];

	if (_op isEqualType []) exitWith {
		_op apply {
			[_x, _type, _hasTInNvg, _params] call CFM_fnc_setCamera;
		};
	};

	if !(IS_OBJ(_op) || IS_STR(_op)) exitWith {"CFM_fnc_setCamera: Argument is not object or string"};
	if !(IS_STR(_type)) then {
		_type = "";
	};

	private _opIsObj = IS_OBJ(_op);
	private _classType = "";
	if !(_opIsObj) then {
		_classType = [_op] call CFM_fnc_validClassType;
	};
	if (!_opIsObj && !(_classType in VALID_CLASS_TYPES)) exitWith {"CFM_fnc_setCamera: Invalid class type passed"};

	_hasTInNvg params ["_ti", "_nvg"];
	if !(_ti isEqualType true) then {
		_ti = true;
	};
	if !(_nvg isEqualType true) then {
		_nvg = true;
	};

	private _clssSetup = missionNamespace getVariable ["CFM_classesSetup", createHashMap];

	if (_opIsObj) then {
		_op setVariable ["CFM_canSwitchTi", _ti];
		_op setVariable ["CFM_canSwitchNvg", _nvg];
	};

	_type = if (_type isEqualTo "") then {
		if ((_op isKindOf "Man") || {_classType isEqualTo TYPE_UNIT}) exitWith {
			GOPRO
		};
		if (_classType isEqualTo TYPE_HELM) exitWith {
			GOPRO
		};
		if (_classType isEqualTo TYPE_UAV) exitWith {
			DRONETYPE
		};
		DRONETYPE
	} else {
		_type
	};

	if (_opIsObj) then {
		_op setVariable ["CFM_cameraType", _type];

		private _activeCameras = missionNamespace getVariable ["CFM_activeCameras", []];
		_activeCameras pushBackUnique _op;
		missionNamespace setVariable ["CFM_activeCameras", _activeCameras];

		switch (_type) do {
			case GOPRO: {
				_op setVariable ["CFM_hasGoPro", true];
			};
			case DRONETYPE: {
				_op setVariable ["CFM_canFeed", true];
			};
			default {};
		};
	} else {
		private _clsParams = _clssSetup getOrDefault [_op, createHashMap];
		_clsParams set ["CFM_canSwitchTi", _ti];
		_clsParams set ["CFM_canSwitchNvg", _nvg];
		_clsParams set ["CFM_cameraType", _type];
		_clssSetup set [_op, _clsParams];
		if (_classType isEqualTo TYPE_HELM) then {
			private _goproHelms = missionNamespace getVariable ["CFM_goProHelmets", createHashMap];
			_goproHelms set [_op, true];
			missionNamespace setVariable ["CFM_goProHelmets", _goproHelms];
			CFM_checkGoPros = true;
		};
		if (_classType isEqualTo TYPE_UAV) then {
			CFM_checkUavsCams = true;
		};
		if (_classType isEqualTo TYPE_VEH) then {
			CFM_checkVehCams = true;
		};
	};

	[_op, _type, _classType]
};

CFM_fnc_cameraType = {
	params["_obj"];

	if !(IS_OBJ(_obj)) exitWith {""};

	private _type = _obj getVariable ["CFM_cameraType", ""];

	if !(IS_STR(_type)) then {
		_type = "";
	};

	if !(_type isEqualTo "") exitWith {_type};

	private _cls = typeOf _obj;
	private _classType = [_cls] call CFM_fnc_validClassType;

	if ((_obj isKindOf "Man") || {_classType isEqualTo TYPE_UNIT}) exitWith {
		GOPRO
	};
	if (_classType isEqualTo TYPE_HELM) exitWith {
		GOPRO
	};
	if (_classType isEqualTo TYPE_UAV) exitWith {
		DRONETYPE
	};
	DRONETYPE
};

CFM_fnc_validClassType = {
	params["_cls"];

	private _isVeh = isClass (configFile >> "CfgVehicles" >> _cls);
	if (_isVeh && {(getNumber (configFile >> "CfgVehicles" >> _cls >> "isUav")) isEqualTo 1}) exitWith {TYPE_UAV};
	if (_isVeh && {_cls isKindOf "Man"}) exitWith {TYPE_UNIT};
	if (_isVeh) exitWith {TYPE_VEH};
	private _isWeap = isClass (configFile >> "CfgWeapons" >> _cls);
	if (_isWeap && {
		private _parents = [configFile >> "CfgWeapons" >> _cls >> "ItemInfo", true] call BIS_fnc_returnParents;
		"headgearItem" in _parents
	}) exitWith {TYPE_HELM};
	if (_isWeap) exitWith {TYPE_WEAP};

	""
};

CFM_fnc_isUAV = {
	params["_obj"];

	(_obj isKindOf "Air") && {(getNumber (configFile >> "CfgVehicles" >> (typeOf _obj) >> "isUav")) isEqualTo 1}
};

CFM_fnc_cameraCondition = {
	private _type = [_this] call CFM_fnc_cameraType;
	private _cls = typeOf _this;
	private _clssSetup = missionNamespace getVariable ["CFM_classesSetup", createHashMap];

	switch (_type) do {
		case GOPRO: {
			private _hasGoPro = _this getVariable ["CFM_hasGoPro", false];
			private _goprohelms = missionNamespace getVariable ["CFM_goProHelmets", createHashMap];
			if (_goprohelms isEqualTo createHashMap) exitWith {_hasGoPro};
			private _playerHelm = headgear _this;
			_playerHelm in _goprohelms;
		};
		case DRONETYPE: {
			if !(alive _this) exitWith {false};
			private _canFeed = _this getVariable ["CFM_canFeed", false];
			if (_canFeed) exitWith {true};
			if (_cls in _clssSetup) exitWith {
				private _clsParams = _clssSetup getOrDefault [_cls, createHashMap];
				private _setType = _clsParams getOrDefault ["CFM_cameraType", ""];
				private _ti = _clsParams getOrDefault ["CFM_canSwitchTi", 0];
				private _nvg = _clsParams getOrDefault ["CFM_canSwitchNvg", 0];
				_this setVariable ["CFM_cameraType", _setType];
				_this setVariable ["CFM_canSwitchTi", _ti];
				_this setVariable ["CFM_canSwitchNvg", _nvg];
				_this setVariable ["CFM_canFeed", true];
				true
			};
			_canFeed
		};
		default {false};
	};
};

CFM_fnc_getActiveCamerasCheckGlobal = {
	private _obj = [];
	if (missionNamespace getVariable ["CFM_checkGoPros", false]) then {
		_obj append allUnits;
	}; 
	if (missionNamespace getVariable ["CFM_checkUavsCams", false]) then {
		_obj append allUnitsUAV;
	}; 
	if (missionNamespace getVariable ["CFM_checkVehCams", false]) then {
		_obj append vehicles;
	}; 
	private _playerSide = side player;
	_obj select {  
		private _side = side _x;
		private _sidesUseCiv = missionNamespace getVariable ["CFM_sidesCanUseCiv", []];
		((_side isEqualTo _playerSide) || ((_playerSide in _sidesUseCiv) && {_side == civilian})) && 
		(_x call CFM_fnc_cameraCondition)  
	}  
}; 

CFM_fnc_getActiveCameras = {
	(missionNamespace getVariable ["CFM_activeCameras", []]) select {_x call CFM_fnc_cameraCondition};
};

CFM_fnc_timeInterpolate = {
    params ["_cam", "_targetPos", "_targetDir", "_targetUp", ["_doInterpolate", true], ["_tightness", 5], ["_dt", diag_deltaTime]];
    
	if (!DO_CAM_INTERPOLATION && !_doInterpolate) exitWith {
		[_targetPos, [_targetDir, _targetUp]];
	};

    // Формула затухания, независимая от FPS: 
    // Эффект = 1 - e^(-tightness * dt)
    private _interpFactor = 1 - (exp (-_tightness * _dt));

    // 1. Позиция
    private _lastPos = _cam getVariable ["CFM_cam_lastPos", _targetPos];
    private _newPos = +_lastPos;

    // Интерполируем каждую ось (или через vectorAdd/vectorDiff)
    for "_i" from 0 to 2 do {
        private _diff = (_targetPos select _i) - (_lastPos select _i);
        _newPos set [_i, (_lastPos select _i) + (_diff * _interpFactor)];
    };

    // 2. Векторы (Dir и Up)
    private _lastDir = _cam getVariable ["CFM_cam_lastDir", _targetDir];
    private _lastUp = _cam getVariable ["CFM_cam_lastUp", _targetUp];

    // Плавный поворот векторов
    private _newDir = _lastDir vectorAdd ((_targetDir vectorDiff _lastDir) vectorMultiply _interpFactor);
    private _newUp = _lastUp vectorAdd ((_targetUp vectorDiff _lastUp) vectorMultiply _interpFactor);

    // 3. Сохраняем состояние
    _cam setVariable ["CFM_cam_lastPos", _newPos];
    _cam setVariable ["CFM_cam_lastDir", _newDir];
    _cam setVariable ["CFM_cam_lastUp", _newUp];

    [_newPos, [_newDir, _newUp]];
};

CFM_fnc_updateCamera = {  
	params ["_monitor", ["_setup", false, [false]], ["_justZoom", false, [false]], ["_turretLocal", false, [false]]]; 

	private _op = _monitor getVariable ["CFM_connectedOperator", objNull];  
	private _type = _op getVariable ["CFM_cameraType", GOPRO];
	private _doInterpolation = false;

	private _cam = _monitor getVariable ["CFM_operatorCam", objNull];  
	private _turret = _monitor getVariable ["CFM_currentTurret", DRIVER_TURRET_PATH];  

	private _zoom = _monitor getVariable ["CFM_zoom", 1];
	([_op, _cam, _zoom, _turret, _justZoom] call CFM_fnc_getCamPos) params [["_pos", [0,0,0]], ["_dir", [0,0,0]], ["_up", [0,0,0]], ["_fov", 1]];
		
	if (_turretLocal) then {
		if (local _op) then {
			private _prevDir = _op getVariable ["CFM_currentTurretDir", []];
			private _prevUp = _op getVariable ["CFM_currentTurretUp", []];
			private _currDir = vectorDir _cam;
			private _currUp = vectorUp _cam;
			if !(_currDir isEqualTo _prevDir) then {
				_op setVariable ["CFM_currentTurretDir", vectorDir _cam, true];
			};
			if !(_currUp isEqualTo _prevUp) then {
				_op setVariable ["CFM_currentTurretUp", vectorUp _cam, true];
			};
		} else {
			_doInterpolation = true;
			_setup = true;
			_pos = [];
			_dir = _op getVariable ["CFM_currentTurretDir", []];
			_up = _op getVariable ["CFM_currentTurretUp", []];
		};
	};

	if (_setup) then {
		private _posAndVUP = [_cam, _pos, _dir, _up, _doInterpolation] call CFM_fnc_timeInterpolate;
		_posAndVUP params ["_newpos", ["_vDirUp", []]];
		_vDirUp params [["_newdir", []], ["_newup", []]];
		if ((count _newpos) == 3) then {
			_cam setPosASL _newpos; 
		};
		if (((count _newdir) == 3) && {((count _newup) == 3)}) then {
			_cam setVectorDirAndUp [_newdir, _newup];  
		};
	};
	_cam camSetFov _fov;  
	_cam camCommit 0;  
};

CFM_fnc_getUAVCameraPoints = {  
    params ["_vehicle", ["_turretPath", DRIVER_TURRET_PATH]]; 

    private _droneType = toLower (typeOf _vehicle);

	if ("mavik" in _droneType) exitWith {
		[["pos_pilotcamera", [], [-1,0,-1]], "pos_pilotcamera_dir"]
	};
	if ("uav_01" in _droneType) exitWith {
		if (_turretPath isEqualTo DRIVER_TURRET_PATH) exitWith {
			[["pip_pilot_pos", [], [-1,0,-1]], "pip_pilot_dir"]
		};
		[["pip0_pos", [], [-1,0,-1]], "pip0_dir"]
	};

    private _camPos = "uavCameraGunnerPos";  
    private _camDir = "uavCameraGunnerDir";

    if (_turretPath isEqualTo [-1]) then {  
        if ("mavik" in _droneType) exitWith {};
        _camPos = "uavCameraDriverPos";  
        _camDir = "uavCameraDriverDir";  
    };

    private _config = configFile >> "CfgVehicles" >> typeOf _vehicle;  
    private _posPoint = getText (_config >> _camPos);  
    private _dirPoint = getText (_config >> _camDir);  
    if (_posPoint == "") then {  
        {  
            private _testPos = _vehicle selectionPosition _x;  
            if (!(_testPos isEqualTo [0,0,0])) exitWith {_posPoint = _x;};  
        } forEach ["PiP0_pos", "PiP1_pos", "pip0_pos", "pip1_pos", "pip_pilot_pos"];  
    };  
    if (_dirPoint == "") then {  
        {  
            private _testDir = _vehicle selectionPosition _x;  
            if (!(_testDir isEqualTo [0,0,0])) exitWith {_dirPoint = _x;};  
        } forEach ["PiP0_dir", "PiP1_dir", "pip0_dir", "pip1_dir", "flir", "pip_pilot_dir"];  
    };  
    [_posPoint, _dirPoint]  
};  

CFM_fnc_memoryPointAlignment = {
	params["_obj", ["_pointParams", "", [[], ""]]];

	private _lod = OBJ_LOD(_obj);

	if (_pointParams isEqualType "") exitWith {
		_s = selectionPosition [_obj, _pointParams, _lod, false];
		hintSilent str [_obj, "", _s, _lod, _pointParams];
		_s
	};
	if !(_pointParams isEqualType []) exitWith {
		[0,0,0]
	};

	_pointParams params [["_point", "", [""]], ["_addArr", [0,0,0], [[]]], ["_setArr", [-1,-1,-1], [[]]]];

	if ((count _addArr) != 3) then {
		_addArr = [0,0,0];
	};
	if ((count _setArr) != 3) then {
		_setArr = [-1,-1,-1];
	};

	private _selPos = selectionPosition [_obj, _point, _lod, true];
	_selPos = _selPos vectorAdd _addArr;

	for "_i" from 0 to 2 do {
		private _set = _setArr#_i;
		if (_set isEqualTo -1) then {continue};
		_selPos set [_i, _set];
	};
	_selPos
};

CFM_fnc_getOffsetInModelSpace = {
    params ["_unit", ["_selectionName", "head"], ["_offset", [0,0,0]]];

    // 1. Получаем позицию селекшна в Model Space
    private _selectionPosMS = _unit selectionPosition _selectionName;

    // 2. Получаем ориентацию селекшна (векторы направления и верха)
    private _dirUp = _unit selectionVectorDirAndUp _selectionName;
    private _dir = _dirUp#0;
    private _up = _dirUp#1;

    // 3. Строим правую сторону (вектор Right) для полной системы координат
    private _right = _dir vectorCrossProduct _up;

    // 4. Трансформируем офсет
    // Мы умножаем компоненты офсета на соответствующие векторы ориентации
    private _rotatedOffset = [0,0,0];
    _rotatedOffset = _rotatedOffset vectorAdd (_right vectorMultiply (_offset select 0)); // X - влево/вправо
    _rotatedOffset = _rotatedOffset vectorAdd (_dir   vectorMultiply (_offset select 1)); // Y - вперед/назад
    _rotatedOffset = _rotatedOffset vectorAdd (_up    vectorMultiply (_offset select 2)); // Z - вверх/вниз

    // 5. Итоговая позиция в Model Space
    _selectionPosMS vectorAdd _rotatedOffset
};

CFM_fnc_getCamPos = {
	params["_obj", "_cam", ["_zoom", 1], ["_turretPath", DRIVER_TURRET_PATH, [[]], 1], ["_justZoom", false]];

	private _prevTurret = 0;
	private _curTurret = 0;
	if !(_justZoom) then {
		_prevTurret = (+(_obj getVariable ["CFM_prevTurret", +_turretPath]))#0;
		_curTurret = _turretPath#0;
		_obj setVariable ["CFM_prevTurret", +_turretPath];
	};

	private _type = _obj getVariable ["CFM_cameraType", GOPRO];

	if (_zoom isEqualTo "op") then {
		_zoom = _op getVariable ['CFM_prevZoom', _zoom];
	};

	private _zoomDefault = !(_zoom isEqualType 1);

	switch (_type) do {
		case GOPRO: {
			private _pos = [];
			private _dir = [];
			private _up = [];
			if !(_justZoom) then {
				private _headPos = selectionPosition [_obj, "head", 9, true];
				private _dirUp = _obj selectionVectorDirAndUp ["head", "memory"]; 
				_dir = _obj vectorModelToWorldVisual _dirUp#0;
				_up = _obj vectorModelToWorldVisual _dirUp#1;
				_headPos = [_obj, ["head", "memory"], [-0.19, 0.1, 0.25]] call CFM_fnc_getOffsetInModelSpace;
				_pos = _obj modelToWorldVisualWorld _headPos; 

				_obj setVariable ["CFM_camPosPoint", GOPRO_MEMPOINT];
			};

			private _fov = if !(_zoomDefault) then {
				_zoom = _zoom min (missionNamespace getVariable ["CFM_max_zoom_gopro", 2]);
				private _zoomfov = [_zoom, _type] call CFM_fnc_getZoomFov;
				if (_zoomfov > DEF_FOV_GOPRO) then {DEF_FOV_GOPRO} else {_zoomfov};
			} else {DEF_FOV_GOPRO};
			[_pos, _dir, _up, _fov]
		};
		case DRONETYPE: {
			private _pos = [];
			private _dir = [];
			private _up = [];
			if !(_justZoom) then {
				private _dirPointParams = _obj getVariable ["CFM_camDirPointParams", []];  
				private _dirPoint = _obj getVariable ["CFM_camDirPoint", ""];  

				if (((_dirPoint isEqualTo "") || {(_dirPointParams isEqualTo []) || {(_dirPointParams isEqualTo "")}}) || !(_prevTurret isEqualTo _curTurret)) then {
					private _pointsParams = [_obj, _turretPath] call CFM_fnc_getUAVCameraPoints;
					_dirPointParams = _pointsParams#1; 
					_dirPoint = _dirPointParams;
					if (_dirPoint isEqualType []) then {_dirPoint = _dirPoint#0};
					_obj setVariable ["CFM_camDirPointParams", _dirPointParams];
					_obj setVariable ["CFM_camDirPoint", _dirPoint];
				};

				private _lod = OBJ_LOD(_obj);
				private _dirPointPos = selectionPosition [_obj, _dirPoint, _lod, true];
				private _dirPointVUP = _obj selectionVectorDirAndUp [_dirPoint, "Memory"];

				_pos = _obj modelToWorldVisualWorld _dirPointPos;
				_dir = _obj vectorModelToWorldVisual (_dirPointVUP#0);
				_up = _obj vectorModelToWorldVisual (_dirPointVUP#1);
			};

			private _fov = if !(_zoomDefault) then {
				_zoom = _zoom min (missionNamespace getVariable ["CFM_max_zoom_drone", 5]);
				private _zoomfov = [_zoom, _type] call CFM_fnc_getZoomFov;
				if (_zoomfov > 1) then {getObjectFOV _obj} else {_zoomfov};
			} else {getObjectFOV _obj};

			[_pos, _dir, _up, _fov]
		};
		default {[]};
	};
};

CFM_fnc_getZoomFov = {
	params["_zoom", ["_type", GOPRO]];

	private _table = missionNamespace getVariable [(switch (_type) do {
		case GOPRO: {
			"CFM_goPro_zoomTable"
		};
		case DRONETYPE: {
			"CFM_drone_zoomTable"
		};
		default {"CFM_nullvar"};
	}), createHashMap];

	if !(_table isEqualType createHashMap) exitWith {1};

	_table getOrDefault [_zoom, 1/_zoom];
};

CFM_fnc_monitorLiveCondition = {
	params["_monitor"];

	private _op = _monitor getVariable ["CFM_connectedOperator", objNull];
	private _cam = _monitor getVariable ["CFM_operatorCam", objNull]; 

	CHECK_EX(!IS_OBJ(_op));
	CHECK_EX(!IS_OBJ(_cam));

	private _opType = _op getVariable ["CFM_cameraType", GOPRO];

	CHECK_EX(!(_opType isEqualTo GOPRO) && !(alive _op));
	CHECK_EX(!(alive _cam));
	
	private _active = _monitor getVariable ["CFM_operatorFeedActive", false]; 

	CHECK_EX(!_active);

	true
};

CFM_fnc_monitorFeedActive = {
	params["_monitor"];

	private _active = _monitor getVariable ["CFM_operatorFeedActive", false]; 

	_active
};

CFM_fnc_doCheckTurretLocality = {
	params["_op"];

	if !(IS_OBJ(_op)) exitWith {false};

	[_op] call CFM_fnc_isUAV;
};

CFM_fnc_startOperatorFeed = {  
	params ["_monitor", ["_operator", objNull], ["_turret", DRIVER_TURRET_PATH]];  

	if !(IS_OBJ(_monitor)) exitWith {"CFM_fnc_startOperatorFeed: Monitor is not an object"};
	if !(IS_OBJ(_operator)) exitWith {"CFM_fnc_startOperatorFeed: Operator is not an object"};

	private _renderTarget = _monitor getVariable ["CFM_operatorRenderTarget", "rendertarget0"];  
	private _cam = "camera" camCreate [0,0,0];  
	_cam cameraEffect ["internal", "back", _renderTarget];  
	[_monitor] call CFM_fnc_setMonitorTexture;
	_monitor setVariable ["CFM_operatorCam", _cam];  
	_monitor setVariable ["CFM_connectedOperator", _operator];  
	_monitor setVariable ["CFM_operatorFeedActive", true]; 
	_monitor setVariable ["CFM_isOff", false]; 
	_monitor setVariable ["CFM_opIsUAV", [_operator] call CFM_fnc_isUAV]; 
	_monitor setVariable ["CFM_doCheckTurretLocality", [_operator] call CFM_fnc_doCheckTurretLocality]; 

	if ((isNil {_monitor getVariable ["CFM_currentTurret", nil]}) && {("uav_0" in (toLower (typeOf _operator)))}) then {
		// will be triggered only on monitor init
		// sets default turret as gunner if has
		_turret = GUNNER_TURRET_PATH;
	};
	if ((count (crew _operator) > 1) && {!((gunner _operator) isEqualTo objNull)}) then {
		_monitor setVariable ["CFM_opHasTurrets", true];  
	};
	_monitor setVariable ["CFM_currentTurret", _turret];  

	private _type = _operator getVariable ["CFM_cameraType", GOPRO];
	_monitor setVariable ["CFM_cameraType", _type];  

	// TI and NVG
	([_operator] call CFM_fnc_setupNvgAndTI) params [["_tiTable", createHashMap], ["_nvgTable", createHashMap], ["_canSwitchTi", false], ["_canSwitchNvg", false]];
	_monitor setVariable ["CFM_tiTable", _tiTable];
	_monitor setVariable ["CFM_nvgTable", _nvgTable];
	_monitor setVariable ["CFM_canSwitchTi", _canSwitchTi];
	_monitor setVariable ["CFM_canSwitchNvg", _canSwitchNvg];

	switch (_type) do {
		case DRONETYPE: {
			_monitor setVariable ["CFM_isDroneFeed", true];
		};
		default { };
	};

	private _updPosSystem = missionNamespace getVariable ["CFM_updatePosSystem", false];

	_monitor setVariable ["CFM_monitorCamUpdating", _updPosSystem];

	private _mainHndl = if !(_updPosSystem) then {
		[_monitor, _operator, _cam, _turret] call CFM_fnc_attachCam;

		[_monitor] spawn {  
			params ["_monitor"];  
			private _cam = _monitor getVariable ["CFM_operatorCam", objNull];   
			private _renderTarget = _monitor getVariable ["CFM_operatorRenderTarget", "rendertarget0"];  
			private _op = _monitor getVariable ["CFM_connectedOperator", objNull];  

			private _checkLocality = _monitor getVariable ["CFM_doCheckTurretLocality", false];
			private _opType = typeOf _op;

			waitUntil {
				[_monitor, false, true, _checkLocality] call CFM_fnc_updateCamera;
				!([_monitor] call CFM_fnc_monitorLiveCondition)
			};
	
			if ((_monitor getVariable ["CFM_isOff", true]) isEqualTo false) then {
				[_monitor] call CFM_fnc_stopOperatorFeed;
			};
		};
	} else {
		[] call CFM_fnc_setupDraw3dEH;
		scriptNull
	};
	_monitor setVariable ["CFM_monitorMainHndl", _mainHndl];  
}; 

CFM_fnc_destroyCamera = {
	params["_monitor"];

	private _cam = _monitor getVariable ["CFM_operatorCam", objNull];

	if !(IS_OBJ(_cam)) exitWith {};

	private _renderTarget = _monitor getVariable ["CFM_operatorRenderTarget", "rendertarget0"];

	_cam cameraEffect ["terminate", "back", _renderTarget]; 
	camDestroy _cam;  
};

CFM_fnc_setupNvgAndTI = {
	params["_operator"];

	private _d = 0;
	private _typeOp = typeOf _operator;
	private _canSwitchTi = _operator getVariable ["CFM_canSwitchTi", 0];
	private _canSwitchNvg = _operator getVariable ["CFM_canSwitchNvg", 0];
	private _tiTable = _operator getVariable ["CFM_tiTable", []];
	private _nvgTable = _operator getVariable ["CFM_nvgTable", []];
	if (!(_canSwitchTi isEqualTo false) && ((_tiTable isEqualTo []) && {!(_tiTable isEqualTo createHashMap)})) then {
		private _tiPilot = getArray (configFile >> "CfgVehicles" >> _typeOp >> "PilotCamera" >> "OpticsIn" >> "Wide" >> "thermalMode");
		private _tiTurret = getArray (configFile >> "CfgVehicles" >> _typeOp >> "Turrets" >> "MainTurret" >> "OpticsIn" >> "Wide" >> "thermalMode");
		
		private _tiModesTable = missionNamespace getVariable ["CFM_tiModesTable", createHashMap];

		_tiPilot = _tiPilot apply {
			_tiModesTable getOrDefault [_x, 2]
		};
		_tiTurret = _tiTurret apply {
			_tiModesTable getOrDefault [_x, 2]
		};

		_d = 1;

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
		private _nvgPilot = "NVG" in (getArray (configFile >> "CfgVehicles" >> _typeOp >> "PilotCamera" >> "OpticsIn" >> "Wide" >> "visionMode"));
		private _nvgTurret = "NVG" in (getArray (configFile >> "CfgVehicles" >> _typeOp >> "Turrets" >> "MainTurret" >> "OpticsIn" >> "Wide" >> "visionMode"));
		
		_d = _d + 2;

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

	[_tiTable, _nvgTable, _canSwitchTi, _canSwitchNvg, _d,
	(getArray (configFile >> "CfgVehicles" >> _typeOp >> "PilotCamera" >> "OpticsIn" >> "Wide" >> "visionMode")),
	(getArray (configFile >> "CfgVehicles" >> _typeOp >> "Turrets" >> "MainTurret" >> "OpticsIn" >> "Wide" >> "visionMode")),
	getArray (configFile >> "CfgVehicles" >> _typeOp >> "PilotCamera" >> "OpticsIn" >> "Wide" >> "thermalMode"),
	getArray (configFile >> "CfgVehicles" >> _typeOp >> "Turrets" >> "MainTurret" >> "OpticsIn" >> "Wide" >> "thermalMode")
	];
};

CFM_fnc_attachCam = {
	params["_monitor", "_obj", "_cam", ["_turretPath", DRIVER_TURRET_PATH, [[]], 1]];

	[_monitor, true] call CFM_fnc_updateCamera;

	private _turPathNum = str (_turretPath#0);
	private _relPos = _obj getVariable [("CFM_relPos_" + (_turPathNum)), 0];
	private _memPoint = _obj getVariable [("CFM_memPoint_" + (_turPathNum)), 0];
	private _orient = _obj getVariable [("CFM_orient_" + (_turPathNum)), 0];
	if ((_relPos isEqualTo 0) || {(_memPoint isEqualTo 0) || {(_orient isEqualTo 0)}}) then {
		_relPos = _obj worldToModel (getPos _cam);
		_memPoint = _obj getVariable ["CFM_camPosPoint", ""];
		_orient = [_cam, _obj] call (missionNamespace getVariable ["BIS_fnc_vectorDirAndUpRelative", {[[0,0,0], [0,0,0]]}]);

		if (_memPoint isEqualTo GOPRO_MEMPOINT) then {
			private _headRelPos = _obj selectionPosition [GOPRO_MEMPOINT, "Memory"];
			_relPos = _relPos vectorDiff _headRelPos;
			_relPos = _relPos vectorAdd [0,0,0.2];
		};

		_obj setVariable [("CFM_relPos_" + (_turPathNum)), _relPos];
		_obj setVariable [("CFM_memPoint_" + (_turPathNum)), _memPoint];
		_obj setVariable [("CFM_orient_" + (_turPathNum)), _orient];
	};

	_cam attachTo [_obj, _relPos, _memPoint, true];
	_cam setVectorDirAndUp _orient;
};

CFM_fnc_setMonitorTexture = {
	params["_monitor"];
	private _renderTarget = _monitor getVariable ["CFM_operatorRenderTarget", "rendertarget0"];  
	_monitor setObjectTexture [0, "#(argb,512,512,1)r2t(" + _renderTarget + ",1.0)"];  
};

CFM_fnc_setMonitorPiPEffect = {
	params["_monitor", ["_pipEffect", 0]];
	private _renderTarget = _monitor getVariable ["CFM_operatorRenderTarget", "rendertarget0"];  
	_renderTarget setPiPEffect [_pipEffect];
	_monitor setVariable ["CFM_currentPiPEffect", _pipEffect]; 
};

CFM_fnc_resetFeed = {
	params["_monitor"];
	private _op = _monitor getVariable ["CFM_connectedOperator", objNull];  
	private _turret = _monitor getVariable ["CFM_currentTurret", DRIVER_TURRET_PATH];  
	[_monitor, true] call CFM_fnc_stopOperatorFeed;
	if ((_op isEqualTo objNull) || !(_op isEqualType objNull)) exitWith {};
	private _hndl = _monitor getVariable ["CFM_monitorMainHndl", scriptNull];
	if !(_hndl isEqualType scriptNull) then {
		_hndl = scriptNull;
	};
	waitUntil {scriptDone (_hndl)};
	[_monitor, _op, _turret] call CFM_fnc_startOperatorFeed;
};

CFM_fnc_stopOperatorFeed = {  
	params ["_monitor", ["_reset", false]];  
	[_monitor] call CFM_fnc_destroyCamera;
	_monitor setVariable ["CFM_operatorCam", nil];  
	_monitor setVariable ["CFM_operatorFeedActive", false];  
	_monitor setVariable ["CFM_connectedOperator", nil]; 
	_monitor setVariable ["CFM_isDroneFeed", nil];  
	_monitor setVariable ["CFM_tiTable", nil];
	_monitor setVariable ["CFM_nvgTable", nil];
	_monitor setVariable ["CFM_canSwitchTi", nil];
	_monitor setVariable ["CFM_canSwitchNvg", nil];
	_monitor setVariable ['CFM_menuActive', false];
	_monitor setVariable ["CFM_opIsUAV", nil];
	_monitor setVariable ["CFM_doCheckTurretLocality", nil];
	_monitor setVariable ['CFM_isOff', true];
	_monitor setVariable ["CFM_monitorCamUpdating", false];
	_monitor setObjectTexture [0, ""];  
	if (_reset) exitWith {};
	_monitor setVariable ["CFM_opHasTurrets", nil];  
	_monitor setVariable ["CFM_currentTurret", nil]; 
	_monitor setVariable ["CFM_zoom", nil]; 
}; 

CFM_fnc_remoteExec = {
	params[["_args", []], ["_func", "call"], ["_targets", 0], ["_jip", 0]];

	if (_targets isEqualType true) then {
		if (_targets isEqualTo true) then {
			_targets = 0;
		} else {
			_targets = 2;
		};
	};
	if (_jip isEqualType objNull) then {
		private _netid = netId _jip;
		private _idArr = (_netid splitString ":");
		private _id = "0";
		if (count _idArr > 1) then {
			_id = _idArr#1;
			if !(_id isEqualType "") then {
				_id = str _id;
			};
		};
		_jip = "CFM_jip_remote_exec_id_" + _id;
	};

	_args remoteExec [_func, _targets, _jip];
};

CFM_fnc_syncState = { 
	params ["_mNetId", "_oNetId", "_start", ["_turret", DRIVER_TURRET_PATH]]; 

	if !(hasInterface) exitWith {};

	private _m = objectFromNetId _mNetId; 
	private _o = objectFromNetId _oNetId; 
	private _isWaiting = _m getVariable ["CFM_waitingForStart", false]; 

	if (_isWaiting && _start) exitWith {};

	_m setVariable ["CFM_waitingForStart", _start];

	if (_start) then {
		waitUntil {
			private _dist = _m distance player;
			private _isClose = _dist <= START_MONITOR_FEED_DIST;
			_start = _m getVariable ["CFM_waitingForStart", true];
			if (_isClose) exitWith {true};
			if !(_start) exitWith {true};
			sleep 1;
			_isClose
		};
	};
	if (_start) then { 
		if (_m getVariable ["CFM_operatorFeedActive", false]) exitWith {};
		[_m, _o, _turret] call CFM_fnc_startOperatorFeed 
	} else {
		[_m] call CFM_fnc_stopOperatorFeed;
	}; 
}; 

CFM_fnc_fixFeed = {
	private _monitors = missionNamespace getVariable ["CFM_currentMonitors", []];
	{
		[_x] spawn CFM_fnc_resetFeed;
	} forEach _monitors;
};