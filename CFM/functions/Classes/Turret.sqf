OBJCLASS(Turret)

    SET_SELF_VAR("_turret");

    FIELD ["_operator", objNull];
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

		IVAR(_operator, _isFPV, false);
		IVAR(_operator, _isMavic, false);
		IVAR(_operator, _hasGoPro, false);
		IVAR(_operator, _objClass, "");
		IVAR(_operator, _classType, "");
		IVAR(_operator, _cameraZoomSmoothDefault, true);
		IVAR(_operator, _canMoveCameraByDefault, false);
		IVAR(_operator, _cameraMoveRestrictionsByDefault, []);

		_turretIndex = TURRET_INDEX(_turretIndex);

		_turretObject = if (_self getVariable ["OOP_isDummy", false]) then {
			_operator
		} else {_self};

		// ZOOM
		private _zoomTable = createHashMap;
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
		private _smoothZoom = if (_smoothZoomSetTurr isEqualTo -1) then {
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
		private _camPosFunc = if (!_hasGoPro && {_isFPV && {_isDriverTurr}}) then {
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
			["setPointParams", [_pointParams]] CALL_OBJCLASS("Turret", _self);
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
		
		_initialDir = if (_isDroneFeed) then {
			DEF_DIR
		} else {
			if (_isStaticCam) exitWith {
				_pointParams param [1, vectorDir _turretObject];
			};
			vectorDir _turretObject;
		};

		// interface
		_interfaceData params [["_interfaceClassDef", ""], ["_interfaceFuncDef", {}], ["_initInterfaceFuncDef", {}]];
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
		_effectAndSignalFuncsDef params [["_signalFuncDef", {}], ["_effectFuncDef", ""]];
		if ((_signalFunc isEqualTo -1) || {!IS_FUNC(_signalFunc) || {!(call {
			private _signalFunc = missionspace getVariable [_signalFunc, {}];
			private _testFuncRes = [player, _operator] call _signalFunc;
			if (isNil "_testFuncRes") exitWith {false};
			_testFuncRes isEqualType 1
		})}}) then {
			_signalFunc = _signalFuncDef;
		};
		// effect func
		if ((_effectFunc isEqualTo -1) || {!IS_FUNC(_effectFunc)}) then {
			_effectFunc = _effectFuncDef;
		};
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
	};

    METHOD("setPointParams") {
        params[["_params", []], ["_ppType", -2], ["_setVar", true]];

        private _prevParams = _self getVariable ["_pointParams", []];
        _ppType = if (_ppType isEqualTo -2) then {_self getVariable ["_ppType", -1]} else {_ppType};

        if (!(_params isEqualType []) || {(_params isEqualTo [])}) then {
            // Handle empty params
        };

        private _pointParams = [_ppType, _prevParams, _params] call CFM_fnc_validatePointParams;

        if (_setVar) then {
            _self setVariable ["_pointParams", _pointParams];
            _self setVariable ["_ppType", _ppType];
        };

        _pointParams
    };

    METHOD("setDefaultPointAlignment") {
        // This method might need to be adjusted based on context, as it was calling on _turrets in Operator
        // For now, assuming it's for this turret
        [_self, -1] call CFM_fnc_setPointAlignment;
    };

    METHOD("TurretChanged") {
        params["_monitor", ["_global", true], ["_globalUpdOp", true], ["_reset", false]];

        private _turretObj = _self getVariable ["_turretObject", _self];
        private _isLocal = _self getVariable ["_isLocal", false];
        private _pointParams = _self getVariable ["_pointParams", []];
        private _camPosFunc = _self getVariable ["_camPosFunc", CAM_POS_FUNC_DEF];
        private _doInterpolation = _self getVariable ["_doInterpolation", false];
        private _canMoveCamera = _self getVariable ["_canMoveCamera", false];
        private _currentCameraMoves = _self getVariable ["_currentCamMove", [0,0,0,0]];
        private _cameraMoveRestrictions = _self getVariable ["_cameraMoveRestrictions", []];
        private _smoothZoom = _self getVariable ["_smoothZoom", true];
        private _zoomTable = _self getVariable ["_zoomTable", createHashMap];
        private _signalFunc = _self getVariable ["_signalFunc", {1}];
        private _effectFunc = _self getVariable ["_effectFunc", {}];
        private _interfaceFunc = _self getVariable ["_interfaceFunc", {}];
        private _interfaceClass = _self getVariable ["_interfaceClass", ""];
        private _initInterfaceFunc = _self getVariable ["_initInterfaceFunc", {}];
        private _zoomMax = _zoomTable getOrDefault ["max", 1];
        _zoomMax = if (_zoomMax isEqualType 1) then {_zoomMax} else {1};

        if !(IS_OBJ(_turretObj)) then {
            // Handle invalid turret object
        };
        _cameraMoveRestrictions resize [4, 180];

        _monitor setVariable ["CFM_currentTurret", [_self getVariable "_turretIndex"], _global];
        _monitor setVariable ["CFM_connectedTurretObject", _turretObj, _global];
        _monitor setVariable ["CFM_zoomMax", _zoomMax, _global];
        _monitor setVariable ["CFM_zoomTable", _zoomTable, _global];
        _monitor setVariable ["CFM_cameraPosFunc", _camPosFunc, _global];
        _monitor setVariable ["CFM_turretLocal", _isLocal, _global];
        _monitor setVariable ["CFM_currentCamPointParams", _pointParams, _global];
        _monitor setVariable ["CFM_currentTiTable", _self getVariable "_tiTable", _global];
        _monitor setVariable ["CFM_currentNvgTable", _self getVariable "_nvgTable", _global];
        _monitor setVariable ["CFM_currentCameraIsStatic", _self getVariable "_isStaticCam", _global];
        _monitor setVariable ["CFM_currentCameraCanMove", _canMoveCamera, _global];
        _monitor setVariable ["CFM_currentCameraMoves", _currentCameraMoves, _global];
        _monitor setVariable ["CFM_currentCameraMoveRestrictions", _cameraMoveRestrictions, _global];
        _monitor setVariable ["CFM_doUpdateCamera", [true, _pointParams] select (_self getVariable "_isStaticCam"), _global];
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

        ["removeMonitor", [_monitor, _prevTurret]] CALL_OBJCLASS("Operator", _self);
        ["addMonitor", [_monitor, _self getVariable "_turretIndex"]] CALL_OBJCLASS("Operator", _self);

        private _turretObj = _self getVariable ["_turretObject", _self];
        if (!(_turretObj isEqualTo _self)) then {
            // Additional logic
        };

        true
    };

    METHOD("moveCamera") {
        params[["_axisAngles", [0,0], [[]], 2]];

        if (_self getVariable ["_isDroneFeed", false]) exitWith {
            // Handle drone feed
        };

        if (_axisAngles isEqualTo [0,0]) exitWith {false};

        private _ppType = _self getVariable ["_ppType", PP_NONE];
        if !(_ppType in [PP_STATIC, PP_VEH_STATIC, PP_VEH_TURRET]) exitWith {false};

        private _pointParams = _self getVariable "_pointParams";

        if (isNil "_pointParams") exitWith {false};

        private _monitorsOnTurret = _self getVariable "_monitorsSet";

        if (_monitorsOnTurret isEqualTo []) exitWith {false};

        _axisAngles params [["_horizontal", 0], ["_vertical", 0]];
            
        private _done = switch (_ppType) do {
            case PP_STATIC: {
                _pointParams params ["_pos", "_dir", "_up"];
                private _turretObj = _self getVariable "_turretObject";
                private _newDir = [_dir, _vertical, _horizontal] call CFM_fnc_rotateVector;
                _newDir = [_newDir, _up] call CFM_fnc_ensureUpVector;
                _pointParams set [1, _newDir];
                true
            };
            case PP_VEH_STATIC: {
                _pointParams params ["_pos", "_dir", "_up"];
                private _turretObj = _self getVariable "_turretObject";
                private _newDir = [_dir, _vertical, _horizontal] call CFM_fnc_rotateVector;
                _newDir = [_newDir, _up] call CFM_fnc_ensureUpVector;
                _pointParams set [1, _newDir];
                true
            };
            case PP_VEH_TURRET: {
                private _turretObj = _self getVariable "_turretObject";
                private _turretIndex = _self getVariable "_turretIndex";
                private _newDir = [_turretObj, _turretIndex, _vertical, _horizontal] call CFM_fnc_rotateTurretVector;
                true
            };
            default {false};
        };

        if !(_done) exitWith {false};

        private _restrictions = _self getVariable ["_cameraMoveRestrictions", [0,0,0,0]];
        private _currentMove = _self getVariable ["_currentCamMove", [0,0,0,0]];
        _currentMove = [_currentMove, _axisAngles, _restrictions] call CFM_fnc_calculateCameraMoves;
        _self setVariable ["_currentCamMove", +_currentMove];

        private _targets = MONITOR_VIEWERS_AND_SELF(false);
        // Since _turretsParams is now the turret object, adjust accordingly
        _self setVariable ["CFM_turretsParams", _self, _targets];

        private _doInterpolation = _self getVariable ["_doInterpolation", false];
        private _doUpdCam = if (!_doInterpolation && {(_ppType > 0)}) then {0} else {_pointParams};
        {
            _x setVariable ["CFM_doUpdateCamera", _doUpdCam, _targets];
            _x setVariable ["CFM_currentCameraMoves", +_currentMove, _targets];
        } forEach _monitorsOnTurret;

        true
    };

    METHOD("moveDroneCamera") {
        params[["_axisAngles", [0,0], [[]], 2]];

        if (_axisAngles isEqualTo [0,0]) exitWith {false};

        private _isGunnerTurret = _self getVariable ["_turretIndex", -1] isEqualTo 0;
        private _isUAVcontrolled = _self getVariable ["_isDroneFeed", false] && {[_self, ["DRIVER", "GUNNER"] select (_isGunnerTurret)] call CFM_fnc_isUAVControlled};

        if (_self getVariable ["_isDroneFeed", false] && {_isUAVcontrolled && {!(missionNamespace getVariable ["CFM_canMoveDroneCameraIfUavControlled", false])}}) exitWith {
            // Handle UAV controlled
        };

        private _monitorsOnTurret = _self getVariable "_monitorsSet";

        if (_monitorsOnTurret isEqualTo []) exitWith {false};

        if !(local _self) exitWith {
            // Handle not local
        };

        _axisAngles params [["_horizontal", 0], ["_vertical", 0]];

        // calculate moves
        private _turretIndex = _self getVariable "_turretIndex";
		private _turrIdxStr = TURR_INDX_STR(_turretIndex);
        private _dirVarName = "CFM_currentTurretDirMS" + _turrIdxStr;
        private _upVarName = "CFM_currentTurretUpMS" + _turrIdxStr;
        private _dir = _self getVariable [_dirVarName, [0,1,0]];
        private _up = _self getVariable [_upVarName, [0,0,1]];
        private _newDir = [_dir, _vertical, _horizontal] call CFM_fnc_rotateVector;
        _newDir = [_newDir, _up] call CFM_fnc_ensureUpVector;
        _self setVariable [_dirVarName, _newDir];
        _self setVariable [_upVarName, _up];

        private _targets = MONITOR_VIEWERS_AND_SELF(false);
        _self setVariable ["CFM_turretsParams", _self, _targets];

        {
            _x setVariable ["CFM_doUpdateCamera", _newDir, _targets];
        } forEach _monitorsOnTurret;

        true
    };

OBJCLASS_END