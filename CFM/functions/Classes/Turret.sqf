OBJCLASS(Turret)

    SET_SELF_VAR("_turret");
    SET_VARS_PREFIX("_turret");

    FIELD ["_operator", objNull];
    FIELD ["_objClass", ""];
	FIELD ["_isDroneFeed", false];	
	FIELD ["_isMavic", false];	
	FIELD ["_isFPV", false];
	FIELD ["_hasGoPro", false];
	FIELD ["_isStaticCam", false];
	FIELD ["_classType", ""];
    FIELD ["_turretObject", objNull];
    FIELD ["_turretIndex", -1];
    FIELD ["_zoomTable", createHashMap];
    FIELD ["_smoothZoom", true];
    FIELD ["_tiParams", []];
    FIELD ["_nvgParam", false];
    FIELD ["_isLocal", false];
    FIELD ["_camPosFunc", CAM_POS_FUNC_DEF];
    FIELD ["_doInterpolation", false];
    FIELD ["_ppType", PP_NONE];
    FIELD ["_pointParams", []];
    FIELD ["_canMoveCamera", false];
    FIELD ["_currentCameraMoves", [0,0,0,0]];
    FIELD ["_cameraMoveRestrictions", DEF_CAM_MOVE_RESTR];
    FIELD ["_initialDirUp", [DEF_DIR, DEF_UP]];
    FIELD ["_turretName", ""];
    FIELD ["_signalFunc", {1}];
    FIELD ["_effectFunc", {}];
    FIELD ["_interfaceFunc", {}];
    FIELD ["_interfaceClass", ""];
    FIELD ["_initInterfaceFunc", {}];
    FIELD ["_currentCamMove", [0,0,0,0]];
    FIELD ["_monitorsSet", []];
    FIELD ["_hasActiveTurretsObjects", -1];
    FIELD ["_monitorsOnTurret", []];

	// PP - point params types
	#define PP_NONE -1
	#define PP_STATIC 0
	#define PP_VEH_STATIC 1
	#define PP_VEH_TURRET 2
	#define TimeToMoveSmoothCoef 0.2
    
    METHOD("Init") {
		[
			["_operator", objNull], 
			["_turretIndex", -1], 
			["_canMoveCamera", -1], 
			["_setZoomTable", []], 
			["_setNvgAndTi", []], 
			["_pointParams", -1],  
			["_doInterpolationSet", true], 
			["_turretName", ""],
			["_smoothZoomSetTurr", -1],
			["_interfaceClass", -1],
			["_interfaceFunc", -1],
			["_initInterfaceFunc", -1],
			["_signalFunc", -1],
			["_effectFunc", -1]
		] NP_PARAMS;

		SAVE_VARS
		GLOBAL_SETTER

		SIVAR_S(_operator,"Operator",_isFPV,false);
		SIVAR_S(_operator,"Operator",_isMavic,false);
		SIVAR_S(_operator,"Operator",_hasGoPro,false);
		SIVAR_S(_operator,"Operator",_isDroneFeed,false);
		SIVAR_S(_operator,"Operator",_isStaticCam,false);
		SIVAR_S(_operator,"Operator",_objClass,"");
		SIVAR_S(_operator,"Operator",_classType,"");
		PR_SIVAR_S(_operator,"Operator",_cameraZoomSmoothDefault,true);
		PR_SIVAR_S(_operator,"Operator",_canMoveCameraByDefault,false);
		PR_SIVAR_S(_operator,"Operator",_cameraMoveRestrictionsByDefault,[]);

		_turretIndex = TURRET_INDEX(_turretIndex);

		_turretObject = if (_self getVariable ["OOP_isDummy", false]) then {
			_operator
		} else {_self};

		// ZOOM
		_zoomTable = createHashMap;
		if ((_setZoomTable isEqualType 1) && {_setZoomTable > 0}) then {
			for "_i" from 1 to _setZoomTable do {
				private _fov = [_i] call CFM_fnc_getFovForZoom;
				_zoomTable set [_i, _fov];
			};
		} else {
			if ((_setZoomTable isEqualType []) && !(_setZoomTable isEqualTo [])) then {
				private _c = (count _setZoomTable) - 1;
				for "_i" from 0 to _c do {
					private _val = _setZoomTable#_i;
					if (_val isEqualType []) then {_val = [_val]};
					_val params [["_zoom", 1], ["_fov", -1]];
					if (_zoom < 1) then {
						_fov = _zoom;
						_zoom = _i + 1;
					};
					if (_fov == -1) then {
						_fov = [_zoom] call CFM_fnc_getFovForZoom;
					};
					if ((_zoom >= 1) && {(_fov <= 1) && (_fov > 0)}) then {
						_zoomTable set [_zoom, _fov];
					};
				};
			} else {
				_zoomTable = +(switch (_classType) do {
					case TYPE_UNIT: {CFM_goPro_zoomTable};
					case TYPE_UAV: {CFM_drone_zoomTable};
					case TYPE_VEH: {CFM_drone_zoomTable};
					case TYPE_STATIC: {CFM_drone_zoomTable};
					default {_zoomTable};
				});
			};
		};
		private _zooms = (keys _zoomTable) select {_x isEqualType 1};
		_zooms sort false;
		private _max = if (count _zooms != 0) then {_zooms#0} else {1};
		if (isNil "_max") then {_max = 1};
		if (_isFPV) then {
			_zoomTable set [1, 0.85];
		};
		_zoomTable set ["max", _max];
		_smoothZoom = if (_smoothZoomSetTurr isEqualTo -1) then {
			_cameraZoomSmoothDefault && !_hasGoPro
		} else {
			if (_smoothZoomSetTurr isEqualType true) exitWith {_smoothZoomSetTurr};
			_smoothZoomSetTurr isEqualTo 1
		};

		// NVG AND TI
		if ((_setNvgAndTi isEqualTo []) || (_setNvgAndTi isEqualTo true)) then {
			if (_setNvgAndTi isEqualTo false) then {
				_tiParams = [];
				_nvgParam = false;
			} else {
				_setNvgAndTi params [["_setNvgParam", false], ["_setTiParam", []]];
				// NVG
				if (_setNvgParam isEqualType false) then {
					_nvgParam = _setNvgParam;
				};
				// TI
				if (_setTiParam isEqualType []) exitWith {
					private _validTIs = values CFM_tiModesTable; 
					_setTiParam = _setTiParam select {
						_x in _validTIs;
					};
					if (_setTiParam isEqualTo []) exitWith {};
					_tiParams = +_setTiParam;
				};
				if (_setTiParam isEqualTo false) then {
					_tiParams = [];
				};
				if (_setTiParam isEqualTo true) then {
					_tiParams = +[2];
				};
			};
		};

		// IS LOCAL TURRET
		_isLocal = [_operator] call CFM_fnc_doCheckTurretLocality;

		// CAM POS FUNC
		private _fullCrew = fullCrew [_operator, "", true];
		private _isVehWithTurrets = (_fullCrew findIf {(_x#1) isEqualTo "gunner"}) != -1;
		private _isDriverTurr = _turretIndex in DRIVER_TURRET_PATH;
		_camPosFunc = if (!_hasGoPro && {_isFPV && {_isDriverTurr}}) then {
			_ppType = PP_VEH_STATIC;
			CFM_fnc_camPosVehStatic
		} else {
			switch (_classType) do {
				case TYPE_UAV: {
					if (_isDriverTurr) then {
						if (_isMavic || {
							("uav_01" in _objClass) || 
							{("uav_06" in _objClass)}
						}) then {
							CFM_fnc_camPosPilotTurret
						} else {
							_ppType = PP_VEH_TURRET;
							CFM_fnc_camPosVehTurret
						};
					} else {
						_ppType = PP_VEH_TURRET;
						CFM_fnc_camPosVehTurret
					};
				};
				case TYPE_UNIT: {
					CFM_fnc_camPosGoPro
				};
				case TYPE_STATIC: {
					_ppType = PP_STATIC;	
					CFM_fnc_camPosStatic
				};
				case TYPE_VEH: {
					if (call {
						if !(_pointParams isEqualType []) then {
							// will get default point params
							false
						} else {
							private _memPoint = _pointParams param [0,""];
							if (_memPoint isEqualType []) then {_memPoint = _memPoint param [0,""]};
							if (!(_memPoint isEqualType '') || {_memPoint isEqualTo ""}) then {
								true
							} else {
								false
							};
						}
					}) then {
						_ppType = PP_VEH_STATIC;
						CFM_fnc_camPosVehStatic
					} else {
						_ppType = PP_VEH_TURRET;
						CFM_fnc_camPosVehTurret
					};
				};
				default {
					_ppType = PP_VEH_STATIC;
					CFM_fnc_camPosVehStatic
				};
			};
		};
		_doInterpolation = !_hasGoPro && {!(_ppType > 0) && {_doInterpolationSet && (isMultiplayer || _isStaticCam)}};

		// POINT ALIGNMENT
		if (_ppType != PP_NONE) then {
			_pointParams = ["setPointParams", [_pointParams]] CALL_OBJINSTANCE("Turret", _instanceIndex, _self);
		};

		// CAN MOVE CAMERA
		private _moveParams = if (_canMoveCamera isEqualTo -1) then {
			[_canMoveCameraByDefault, +_cameraMoveRestrictionsByDefault]
		} else {
			[_canMoveCamera, _self] call CFM_fnc_defineCameraMovementOptions
		};
		_canMoveCamera = _moveParams param [0, _canMoveCameraByDefault];
		_cameraMoveRestrictions = _moveParams param [1, +_cameraMoveRestrictionsByDefault];
		if (count _cameraMoveRestrictions != 4) then {
			_cameraMoveRestrictions = +_cameraMoveRestrictionsByDefault;
		};
		_cameraMoveRestrictions resize [4, 0];
		
		_initialDir = if (_isDroneFeed) then {
			DEF_DIR
		} else {
			if (_isStaticCam) exitWith {
				_pointParams param [1, vectorDir _turretObject];
			};
			vectorDir _turretObject;
		};

		// interface
		([_operator, _turretIndex, _objClass, _isMavic, _isFPV, _isDroneFeed] call CFM_fnc_defineInterfaceData) params [["_interfaceClassDef", ""], ["_interfaceFuncDef", {}], ["_initInterfaceFuncDef", {}]];
		if ((_interfaceClass isEqualTo -1) || {!IS_STR(_interfaceClass)}) then {
			_interfaceClass = _interfaceClassDef;
		};
		if ((_interfaceFunc isEqualTo -1) || {!IS_FUNC(_interfaceFunc)}) then {
			_interfaceFunc = _interfaceFuncDef;
		};
		if ((_initInterfaceFunc isEqualTo -1) || {!IS_FUNC(_initInterfaceFunc)}) then {
			_initInterfaceFunc = _initInterfaceFuncDef;
		};
		// signal func
		([_operator, _turretIndex, _objClass, _isMavic, _isFPV, _isDroneFeed] call CFM_fnc_defineSignalEffectFunc) params [["_signalFuncDef", {}], ["_effectFuncDef", ""]];
		if ((_signalFunc isEqualTo -1) || {!IS_FUNC(_signalFunc) || {!(call {
			private _signalFuncTest = missionNamespace getVariable [_signalFunc, {}];
			private _testFuncRes = [player, _operator] call _signalFuncTest;
			if (isNil "_testFuncRes") exitWith {false};
			_testFuncRes isEqualType 1
		})}}) then {
			_signalFunc = _signalFuncDef;
		};
		// effect func
		if ((_effectFunc isEqualTo -1) || {!IS_FUNC(_effectFunc)}) then {
			_effectFunc = _effectFuncDef;
		};
		// VALIDATION
		if !(IS_FUNC(_signalFunc)) then {
			_signalFunc = {1};
		};
		if !(IS_FUNC(_effectFunc)) then {
			_effectFunc = {};
		};
		if !(IS_STR(_interfaceClass)) then {
			_interfaceClass = "";
		};
		if !(IS_FUNC(_interfaceFunc)) then {
			_interfaceFunc = {};
		};
		if !(IS_FUNC(_initInterfaceFunc)) then {
			_initInterfaceFunc = {};
		};
		true
	};
    METHOD("setPointParams") {
		params[["_params", []]];

		if (!(_params isEqualType []) || {(_params isEqualTo [])}) then {
			_params = [_objClass, _turretIndex] call CFM_fnc_getDefaultPointAlignment;
		};

		_pointParams = [_ppType, _pointParams, _params] call CFM_fnc_validatePointParams;

		SET_SELFVARG(_pointParams);

		_pointParams
    };
	METHOD("setDefaultPointAlignment") {
		[_self, _turretIndex, -1] call CFM_fnc_setPointAlignment;
	};
	METHOD("TurretChanged") {
		params["_monitor", ["_global", true], ["_globalUpdOp", true], ["_reset", false]];

		private _zoomMax = _zoomTable getOrDefault ["max", 1];
		_zoomMax = if (_zoomMax isEqualType 1) then {_zoomMax} else {1};

		_cameraMoveRestrictions resize [4, 0];

		_monitor setVariable ["CFM_currentTurret", [_turretIndex], _global];
		_monitor setVariable ["CFM_connectedTurretObject", _turretObject, _global];
		_monitor setVariable ["CFM_zoomMax", _zoomMax, _global];
		_monitor setVariable ["CFM_zoomTable", _zoomTable, _global];
		_monitor setVariable ["CFM_cameraPosFunc", _camPosFunc, _global];
		_monitor setVariable ["CFM_turretLocal", _isLocal, _global];
		_monitor setVariable ["CFM_currentCamPointParams", _pointParams, _global];
		_monitor setVariable ["CFM_currentTiTable", _tiParams, _global];
		_monitor setVariable ["CFM_currentNvgParam", _nvgParam, _global];
		_monitor setVariable ["CFM_currentCameraIsStatic", _isStaticCam, _global];
		_monitor setVariable ["CFM_currentCameraCanMove", _canMoveCamera, _global];
		_monitor setVariable ["CFM_currentCameraMoves", _currentCameraMoves, _global];
		_monitor setVariable ["CFM_currentCameraMoveRestrictions", _cameraMoveRestrictions, _global];
		_monitor setVariable ["CFM_doUpdateCamera", [true, _pointParams] select _isStaticCam, _global];
		_monitor setVariable ["CFM_currentCameraSmoothZoom", _smoothZoom, _global];
		_monitor setVariable ["CFM_camInterp_lastDir", nil, _global];
		_monitor setVariable ["CFM_camInterp_lastUp", nil, _global];
		[_monitor, true] call CFM_fnc_setOperatorInfo;

		_monitor setVariable ["CFM_camDoInterpolation", _doInterpolation, _global];

		private _uiParams = if (IS_STR(_interfaceClass)) then {
			[_interfaceClass, _interfaceFunc, _initInterfaceFunc, _effectFunc, _signalFunc]
		} else {[]};
		["startRendering", [_reset, _uiParams]] CALL_OBJCLASS("DisplayHandler", _monitor);

		true
	};
	METHOD("TurretChangedLocalOperator") {
		params["_monitor"];

		private _prevTurret = _monitor getVariable ["CFM_currentTurret", -2];

		["removeMonitor", [_monitor, _prevTurret]] CALL_OBJCLASS("Operator", _operator);
		["addMonitor", [_monitor, _turretIndex]] CALL_OBJCLASS("Operator", _operator);

		if (_self isNotEqualTo _operator) then {
			CFM_operatorsToUpdate = _operator;
			"CFM_operatorsToUpdate" call EFL_fnc_publicVariableServer;
			[_operator, _turretIndex, _self] call CFM_fnc_addActiveTurret;
		};

		true
	};
	METHOD("moveCamera") {
		params[["_axisAngles", [0,0], [[]], 2]];

		if (_isDroneFeed) exitWith {
			if !(missionNamespace getVariable ["CFM_canMoveDroneCameras", false]) exitWith {false};
			["moveDroneCamera", [_axisAngles]] SPAWN_OBJINSTANCE("Turret", _instanceIndex, _self);
			true
		};

		if (_axisAngles isEqualTo [0,0]) exitWith {false};

		if !(_ppType in [PP_STATIC, PP_VEH_STATIC, PP_VEH_TURRET]) exitWith {false};

		_axisAngles params [["_horizontal", 0], ["_vertical", 0]];
			
		private _done = switch (_ppType) do {
			case PP_STATIC: {
				_pointParams params [["_pos", [], [[]], 3], ["_dir", DEF_DIR, [[]], 3], ["_up", DEF_UP, [[]], 3]];

				// global rotation
				private _newDirUp = [_dir, _up, _vertical, _horizontal] call CFM_fnc_transformTurret;
				private _newDir = _newDirUp param [0, _dir];
				private _newUp = _newDirUp param [1, _up];

				_pointParams = [_ppType, _pointParams, [_pos, _newDir, _newUp]] call CFM_fnc_validatePointParams;
				
				true
			};
			case PP_VEH_STATIC: {
				_pointParams params [["_pos", [], [[]], 3], ["_dirUp", [], [[]]]];
				_dirUp params [["_dir", DEF_DIR, [[]], 3], ["_up", DEF_UP, [[]], 3]];

				// global rotation
				private _newDirUp = [_dir, _up, _vertical, _horizontal] call CFM_fnc_transformTurret;
				private _newDir = _newDirUp param [0, _dir];
				private _newUp = _newDirUp param [1, _up];

				_pointParams = [_ppType, _pointParams, [_pos, _newDir, _newUp]] call CFM_fnc_validatePointParams;
				
				true
			};
			case PP_VEH_TURRET: {
				_pointParams params [['_memPoint', ""], ['_alignment', []], ['_lod', "Memory"]];
				_alignment params [["_addArr", []], ["_dirUp", []], ["_setArr", []]];

				// mem point model space rotation
				private _memPointDirUp = _self selectionVectorDirAndUp [_memPoint, _lod];
				_memPointDirUp params [["_mdir", DEF_DIR], ["_mup", DEF_UP]];
				// translate local mem point vector to model space
				private _dirUpMS = [_memPointDirUp, _dirUp] call CFM_fnc_translateLocalVectors;
				_dirUpMS params [["_dirMS", []], ["_upMS", []]];
				// model space translated vector to world space
				private _dirW = _self vectorModelToWorldVisual _dirMS;
				private _upW = _self vectorModelToWorldVisual _upMS;
				// transform dirup world
				private _tarnsDirUp = [_dirW, _upW, _vertical, _horizontal] call CFM_fnc_transformTurret;
				private _tarnsDir = _tarnsDirUp param [0, _dir];
				private _tarnsUp = _tarnsDirUp param [1, _up];
				// transformed dirup in model space
				private _newDirMS = _self vectorWorldToModelVisual _tarnsDir;
				private _newUpMS = _self vectorWorldToModelVisual _tarnsUp;
				// transformed dirup model space to mem point offset

				// Рассчитываем оси базиса мем-поинта
				private _mX = _mdir vectorCrossProduct _mup;

				// Обратная проекция (Model Space -> Local Space)
				private _dir = [
					_newDirMS vectorDotProduct _mX,
					_newDirMS vectorDotProduct _mdir,
					_newDirMS vectorDotProduct _mup
				];

				private _up = [
					_newUpMS vectorDotProduct _mX,
					_newUpMS vectorDotProduct _mdir,
					_newUpMS vectorDotProduct _mup
				];

				_pointParams = [_ppType, _pointParams, [[_memPoint, _lod], _pos, _dir, _up, _setArr]] call CFM_fnc_validatePointParams;

				true
			};
			default {false};
		};

		if !(_done) exitWith {false};

		_currentCameraMoves = [_currentCameraMoves, _axisAngles, _cameraMoveRestrictions] call CFM_fnc_calculateCameraMoves;

		private _targets = MONITOR_VIEWERS_AND_SELF(false);

		private _doUpdCam = if (!_doInterpolation && {(_ppType > 0)}) then {0} else {_pointParams};
		{
			if !(_doInterpolation) then {
				_x setVariable ["CFM_camDoInterpolation", true, _targets];
			};
			_x setVariable ["CFM_currentCamPointParams", +_pointParams, _targets];
			_x setVariable ["CFM_doUpdateCamera", _doUpdCam, _targets];
			_x setVariable ["CFM_currentCameraMoves", +_currentCameraMoves, _targets];
		} forEach _monitorsOnTurret;

		SET_SELFVARG(_currentCameraMoves);
		SET_SELFVARG(_pointParams);

		true
	};
	METHOD("moveDroneCamera") {
		params[["_axisAngles", [0,0], [[]], 2]];

		if (_axisAngles isEqualTo [0,0]) exitWith {false};

		private _isGunnerTurret = _turretIndex isEqualTo 0;
		private _isUAVcontrolled = _isDroneFeed && {[_self, ["DRIVER", "GUNNER"] select (_isGunnerTurret)] call CFM_fnc_isUAVControlled};

		if (_isDroneFeed && {_isUAVcontrolled && {!(missionNamespace getVariable ["CFM_canMoveDroneCameraIfUavControlled", false])}}) exitWith {
			false
		};

		if !(local _operator) exitWith {
			private _target = if (_isGunnerTurret) then {gunner _operator} else {driver _operator};
			if (isNull _target) then {
				_target = _operator;
			};
			[[_self, [_instanceIndex, _axisAngles]], {
				params["_turret", "_args"];
				_args params [["_turretInstanceIndex", -1], ["_axisAngles", [0,0]]];
				["moveDroneCamera", [_axisAngles]] SPAWN_OBJINSTANCE("Turret", _turretInstanceIndex, _turret);
			}, _target, false, true] call CFM_fnc_remoteExec;
			true
		};

		_axisAngles params [["_horizontal", 0], ["_vertical", 0]];

		// calculate moves
		private _turrIdxStr = TURR_INDX_STR(_turretIndex);
		private _dirVarName = "CFM_currentTurretDirMS" + _turrIdxStr;
		private _upVarName = "CFM_currentTurretUpMS" + _turrIdxStr;
		private _dir = _self getVariable [_dirVarName, [0,1,0]];
		private _up = _self getVariable [_upVarName, [0,0,1]];
		_currentCameraMoves = [_initialDirUp, [_dir, _up]] call CFM_fnc_calculateCurrentCameraMoves;
		_currentCameraMoves = [_currentCameraMoves, _axisAngles, _cameraMoveRestrictions] call CFM_fnc_calculateCameraMoves;

		private _hasPrevMove = !(_self getVariable ["CFM_moveDone", true]);
		private _exit = if (_hasPrevMove) then {
			if !(DO_OVERWRITE_CURRENT_MOVE) exitWith {true};
			_self setVariable ["CFM_newMove", true];
			waitUntil { sleep 0.01; _self getVariable ["CFM_moveDone", true] };
			false
		} else {false};
		if (_exit) exitWith {false};
		_self setVariable ["CFM_moveDone", false];

		private _havingNewMove = false;

		private _done = if (_isGunnerTurret) then {
			private _newDirUp = [_dir, _up, _vertical, _horizontal] call CFM_fnc_transformTurret;
			private _newDir = _newDirUp param [0, _dir];
			private _newUp = _newDirUp param [0, _up];
			private _lockPos = (_self modelToWorldVisualWorld (vectorNormalized _newDir));
			private _prevCamLook = [_self, [_turretIndex]] call CFM_fnc_getTurretCameraLock;

			_self lockCameraTo [_lockPos, [_turretIndex]];

			private _waitStart = time;
			waitUntil {
				sleep 0.01;
				[_self, _turretIndex, false] call CFM_fnc_updateTurretCamera;
				_havingNewMove = _self getVariable ["CFM_newMove", false];
				_havingNewMove ||
				{((time - _waitStart) > 2) || {
					[
						[_self, [_turretIndex]] call CFM_fnc_getTurretCameraLock, 
						_lockPos,
						0.01
					] call CFM_fnc_compareVectors
				}}
			};

			if (_havingNewMove) exitWith {true};

			if ([_prevCamLook, [_self, [_turretIndex]] call CFM_fnc_getTurretCameraLock] call CFM_fnc_compareVectors) exitWith {false};

			true
		} else {
			private _prevCamDir = getPilotCameraDirection _self;
			private _prevCamUp = _prevCamDir call CFM_fnc_getVectorUpFromDir;
			private _newDirUp = [_prevCamDir, _prevCamUp, _vertical, _horizontal] call CFM_fnc_transformTurret;
			private _newCamDir = _newDirUp#0;

			private _prevHandle = _self getVariable ["CFM_rotationHandle", scriptNull];
			terminate _prevHandle;

			private _rotationHandle = [_self, _prevCamDir, _newCamDir] spawn CFM_fnc_smoothRotateCam;
			_self setVariable ["CFM_rotationHandle", _rotationHandle];

			private _waitStart = time;
			waitUntil {
				sleep 0.01;
				[_self, -1, false] call CFM_fnc_updateTurretCamera;
				_havingNewMove = _self getVariable ["CFM_newMove", false];
				_havingNewMove ||
				{((time - _waitStart) > 2) || {
					([_newCamDir, getPilotCameraDirection _self, 0.01] call CFM_fnc_compareVectors)
				}}
			};
			
			if (_havingNewMove) exitWith {true};

			if ([_prevCamDir, getPilotCameraDirection _self] call CFM_fnc_compareVectors) exitWith {false};

			true
		};

		_self setVariable ["CFM_moveDone", true];
		_self setVariable ["CFM_newMove", false];

		if !(_done) exitWith {false};

		private _targets = MONITOR_VIEWERS_AND_SELF(false);

		{
			_x setVariable ["CFM_currentCameraMoves", +_currentCameraMoves, _targets];
		} forEach _monitorsOnTurret;

		SET_SELFVARG(_currentCameraMoves);
		
		true
	};
	METHOD("addMonitor") {
		params[["_monitor", objNull]];

		if !(IS_OBJ(_monitor)) exitWith {-1};

		private _res = _monitorsOnTurret pushBackUnique _monitor;
		SET_SELFVARG(_monitorsOnTurret);
		
		_res
	};
	METHOD("removeMonitor") {
		params[["_monitor", objNull]];

		_monitorsOnTurret = _monitorsOnTurret - [_monitor];

		SET_SELFVARG(_monitorsOnTurret);

		true	
	};
	METHOD("getTurretName") {
		_turretName
	};
OBJCLASS_END
