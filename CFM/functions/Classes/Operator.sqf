
#define SET_VARS_INIT_GLOBAL true
#define DO_OVERWRITE_CURRENT_MOVE false

OBJCLASS(Operator)

	SET_SELF_VAR("_operator");

	FIELD ["_canSwitchTi", false];
	FIELD ["_canSwitchNvg", false];
	FIELD ["_opHasTurrets", false];
	FIELD ["_turrets", [DRIVER_TURRET_PATH]];
	FIELD ["_cameraType", ""];
	FIELD ["_operatorName", ""];
	FIELD ["_operatorId", -1];
	FIELD ["_hasGoPro", false];
	FIELD ["_canFeed", false];
	FIELD ["_canMoveCameraByDefault", false];
	FIELD ["_cameraMoveRestrictionsByDefault", []]; // [degrees up, degrees down, degrees left, degrees right]
	FIELD ["_cameraZoomSmoothDefault", false]; 
	FIELD ["_classType", ""];
	FIELD ["_objClass", ""];
	FIELD ["_monitorsSet", createHashMap];
	FIELD ["_tiTable", createHashMap];
	FIELD ["_nvgTable", createHashMap];
	FIELD ["_operatorSet", false];
	FIELD ["_isFeeding", false];
	FIELD ["_isDroneFeed", false];	
	FIELD ["_isMavic", false];	
	FIELD ["_isFPV", false];	
	FIELD ["_staticCamOffset", NULL_VECTOR];	
	FIELD ["_isStaticCam", false];	
	FIELD ["_opSides", []];	
	FIELD ["_turretsParams", createHashMap];	
	FIELD ["_opCameraPosFunc", CAM_POS_FUNC_DEF];
	FIELD ["_hasActiveTurretsObjects", -1];
	FIELD ["_activeTurretsObjects", createHashMap];

	/*
		_turretsParams: [[turretIndex, [turretName, turretObject, isLocal, pointParams, initialDirUp, zoomTable, nvgTable, tiTable, isGopro, camPosFunc, doInterpolation, currentCamMove, ppType, cameraMoveRestrictions]]]
		_pointParams: 
			- for CFM_fnc_camPosVehTurret: [_memPoint, [_addArr, [_dir, _up], _setArr]]
			- for CFM_fnc_camPosVehStatic: [_pos, [_dir, _up]]
			- for CFM_fnc_camPosStatic: [_pos, _dir, _up]
	*/

	// PP - point params types
	#define PP_NONE -1
	#define PP_STATIC 0
	#define PP_VEH_STATIC 1
	#define PP_VEH_TURRET 2
	#define TimeToMoveSmoothCoef 0.2

	METHOD("Init") {
		// should be executed globaly
		params[["_sides", []], ["_turrets", []], ["_hasTInNvg", [0, 0]], ["_name", ""], ["_params", []]];

		private _global = SET_VARS_INIT_GLOBAL;

		if !(IS_VALID_OP(_operator)) exitWith {1};

		if (_classType isEqualTo "") then {
			_classType =  [_operator call CFM_fnc_getOperatorClass] call CFM_fnc_validClassType;
		};
		if !(_classType in VALID_CLASS_TYPES) exitWith {"Init Operator: Invalid class type passed" WARN; 2};

		_operator setVariable ["CFM_classType", _classType, _global];


		// CAM TYPE
		_cameraType = [_operator] call CFM_fnc_cameraType;
		_operator setVariable ["CFM_cameraType", _cameraType, _global];

		_operator setVariable ["CFM_canFeed", true, _global];
		switch (_cameraType) do {
			case DRONETYPE: {
				_isDroneFeed = true;
				_operator setVariable ["CFM_isDroneFeed", _isDroneFeed, _global];
			};
			case TYPE_VEH: {
				_operator setVariable ["CFM_isVehFeed", true, _global];
			};
			default {};
		};
		
		// OTHER PARAMS
		if !(_params isEqualType []) then {_params = [_params]};
		_params params [
			["_canMoveCameraByDefaultSet", -1],
			["_cameraZoomSmoothDefault", true, [true]]
		];

		_objClass = toLower (_operator call CFM_fnc_getOperatorClass);
		_operator setVariable ["CFM_objClass", _objClass, _global];

		_isFPV = (("fpv" in _objClass) || {("crocus" in _objClass)});
		_isMavic = ("mavik_3" in _objClass);
		_hasGoPro = _classType in [TYPE_UNIT, TYPE_HELM];
		_operator setVariable ["CFM_hasGoPro", _hasGoPro, _global];
		_operator setVariable ["CFM_isFPV", _isFPV, _global];
		_operator setVariable ["CFM_isMavic", _isMavic, _global];
		
		// CAN MOVE CAMERA
		if ((_classType isEqualTo TYPE_UAV) && {
			!(_canMoveCameraByDefaultSet isEqualTo false) && {
				!_isFPV
			}
		}) then { // && {MGVAR ["CFM_canMoveDroneCameras", false]}
			_canMoveCameraByDefaultSet = true;
		};
		private _moveParams = [_canMoveCameraByDefaultSet, _self] call CFM_fnc_defineCameraMovementOptions;
		_moveParams params [["_canMoveCameraByDefault", false], ["_cameraMoveRestrictionsByDefault", [], [[]]]];
		_operator setVariable ["CFM_canMoveCameraByDefault", _canMoveCameraByDefault, _global];
		_operator setVariable ["CFM_cameraMoveRestrictionsByDefault", +_cameraMoveRestrictionsByDefault, _global];
		_operator setVariable ["CFM_cameraZoomSmoothDefault", !_hasGoPro && _cameraZoomSmoothDefault, _global];

		if (_classType isEqualTo TYPE_STATIC) then {
			_isStaticCam = true;
			_operator setVariable ["CFM_isStaticCam", _isStaticCam, _global];
		};

		// NVG AND TI
		_hasTInNvg params ["_ti", "_nvg"];
		if !(_ti isEqualType true) then {
			_ti = true;
		};
		if !(_nvg isEqualType true) then {
			_nvg = true;
		};
		([_operator] call CFM_fnc_setupNvgAndTI) params [["_tiTable", createHashMap], ["_nvgTable", createHashMap], ["_canSwitchTi", false], ["_canSwitchNvg", false]];
		_canSwitchTi = _ti && _canSwitchTi;
		_canSwitchNvg = _nvg && _canSwitchNvg;
		_operator setVariable ["CFM_tiTable", _tiTable, _global];
		_operator setVariable ["CFM_nvgTable", _nvgTable, _global];
		_operator setVariable ["CFM_canSwitchTi", _canSwitchTi, _global];
		_operator setVariable ["CFM_canSwitchNvg", _canSwitchNvg, _global];


		// TURRETS
		["DefineTurretsParams", [_turrets]] CALL_OBJCLASS("Operator", _self);


		// CHECK NVG TI
		private _turrets = _self getVariable ["CFM_turrets", []];
		private _turrCount = count _turrets;
		if (_turrCount == 1) then {
			// if turrets is one and nvg and ti are two we set ti and nvg for any ti/nvg table turr have it
			private _turr = _turrets#0;
			private _turrIndex = TURRET_INDEX(_turr);
			if (_turrIndex isEqualTo -1) then {
				// TI
				call {
					private _tiForDriver = _tiTable get _turrIndex;
					if (isNil "_tiForDriver") exitWith {};
					if (count _tiForDriver != 0) exitWith {};
					private _tiForGunner = _tiTable get 0;
					if (isNil "_tiForGunner") exitWith {};
					if (count _tiForGunner == 0) exitWith {};
					_tiForGunner = +_tiForGunner;
					_tiTable = createHashMap;
					_tiTable set [-1, _tiForGunner];
				};
				// NVG
				call {
					private _nvgForDriver = _tiTable get _turrIndex;
					if (isNil "_nvgForDriver") exitWith {};
					if (_nvgForDriver isEqualTo true) exitWith {};
					private _nvgForGunner = _tiTable get 0;
					if (isNil "_nvgForGunner") exitWith {};
					if (_nvgForDriver isEqualTo false) exitWith {};
					_nvgForGunner = +_nvgForGunner;
					_nvgTable = createHashMap;
					_nvgTable set [-1, _nvgForGunner];
				};
			};
		};

		// SIDE
		private _defaultSide = [(getNumber (configFile >> "CfgVehicles" >> _objClass >> "side"))] call BIS_fnc_sideType;
		if !(_sides isEqualType []) then {
			_sides = [_sides];
		};
		_sides = _sides select {_x isEqualType west};
		if (_sides isEqualTo []) then {
			_sides = [_defaultSide];
		};
		_operator setVariable ["CFM_opSides", _sides, _global];


		// ADD OP
		["addOperator", [_operator]] CALL_CLASS("DbHandler");

		if (_name isEqualTo "") then {
			_name = switch (_cameraType) do {
				case GOPRO: {
					format["%1: %2", groupId group _self, name _self]
				};
				case TYPE_STATIC: {
					private _operatorId = _self getVariable ["CFM_operatorId", 0];
					_self getVariable ["CFM_staticCameraID", "Camera " + str _operatorId];
				};
				default {
					private _group = groupId group _self;
					private _dispName = getText (configFile >> "CfgVehicles" >> (typeOf _self) >> "displayName");
					if (_group isEqualTo "") then {
						_dispName
					} else {
						format["%1: %2", _group, _dispName]
					};
				};
			};
		};
		_operator setVariable ["CFM_operatorName", _name, _global];

		_operator setVariable ["CFM_operatorSet", true, _global];

		true
	};
	METHOD("DefineTurretsParams") {
		params[["_turretsParamsInit", []]];
		
		if (_turretsParamsInit isEqualTo []) then {
			private _fullCrew = fullCrew [_self, "", true];
			private _crewCount = count _fullCrew;

			if (_crewCount == 0) exitWith {
				if (_cameraType isEqualTo GOPRO) then {
					_turretsParamsInit = [-1];
				};
			};

			private _hasGunner = (_fullCrew findIf {(_x#1) isEqualTo "gunner"}) != -1;
			_turretsParamsInit = [-1];
			if ((_crewCount > 1) && _hasGunner && {_cameraType isEqualTo DRONETYPE}) then {
				_turretsParamsInit = [DRIVER_TURRET_PATH, GUNNER_TURRET_PATH];
			};
		};

		_opHasTurrets = count _turretsParamsInit > 1;
		_operator setVariable ["CFM_opHasTurrets", _opHasTurrets, SET_VARS_INIT_GLOBAL]; 

		private _turrets = [];
		private _validTurretInitParams = [];
		{
			private _turret = _x;
			if !(_turret isEqualType []) then {
				_turret = [_turret];
			};
			if !((_turret#0) isEqualType 1) then {
				private _nextTurret = if (_turrets isEqualTo []) then {-1} else {(_turrets#-1) + 1};
				_turret = [_nextTurret, _turret];
			};
			_turret params [["_turretIndex", -1], ["_params", []]];
			_validTurretInitParams pushBack _turret;
			_turretIndex = TURRET_INDEX(_turretIndex);
			_turrets pushBackUnique _turretIndex;
		} forEach _turretsParamsInit;

		_operator setVariable ["CFM_turrets", _turrets, SET_VARS_INIT_GLOBAL]; 

		{
			_x params [["_turretIndex", -1], ["_params", []]];
			private _turretArgs = [_turretIndex] + _params;
			private _args = [_operator] + _turretArgs;
			_args call CFM_fnc_setTurretParams;
		} forEach _validTurretInitParams;

		if (isServer) then {
			_self call CFM_fnc_checkOperatorTurrets;
		};

		_turretsParams
	};
	METHOD("setTurretParams") {
		params [
			["_turretIndex", -1], 
			["_turretObject", objNull], 
			["_canMoveCamera", -1], 
			["_setZoomTable", []], 
			["_setNvgAndTi", []], 
			["_pointParams", -1],  
			["_doInterpolationSet", true], 
			["_turretName", ""],
			["_smoothZoomSetTurr", -1],
			["_interfaceClass", -1],
			["_interfaceFuncName", -1],
			["_signalFuncName", -1],
			["_effectFuncName", -1]
		];

		_turretIndex = TURRET_INDEX(_turretIndex);
		private _turretParams = _turretsParams getOrDefault [_turretIndex, createHashMap];

		// TURRET OBJECT
		if !(IS_OBJ(_turretObject)) then {
			_turretObject = _self;
		} else {
			if (isServer) then {
				_hasActiveTurretsObjects = 0;
				_self setVariable ["CFM_hasActiveTurretsObjects", _hasActiveTurretsObjects, true];
			};
		};
		_turretParams set ["turretObject", _turretObject];

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
		_turretParams set ["zoomTable", _zoomTable];
		private _smoothZoom = if (_smoothZoomSetTurr isEqualTo -1) then {
			_cameraZoomSmoothDefault && !_hasGoPro
		} else {
			if (_smoothZoomSetTurr isEqualType true) exitWith {_smoothZoomSetTurr};
			_smoothZoomSetTurr isEqualTo 1
		};
		_turretParams set ["smoothZoom", _smoothZoom];

		// NVG AND TI
		if ((_setNvgAndTi isEqualTo []) || (_setNvgAndTi isEqualTo true)) then {
			private _currentTiParam = _tiTable getOrDefault [_turretIndex, []];
			private _currentNvgParam = _nvgTable getOrDefault [_turretIndex, false];
			if (_setNvgAndTi isEqualTo false) then {
				_currentTiParam = [];
				_currentNvgParam = false;
			} else {
				_setNvgAndTi params [["_nvgParam", false], ["_tiParam", []]];
				// NVG
				if (_nvgParam isEqualType false) then {
					_currentNvgParam = _nvgParam;
				};
				// TI
				if (_tiParam isEqualType []) exitWith {
					private _validTIs = values CFM_tiModesTable; 
					_tiParam = _tiParam select {
						_x in _validTIs;
					};
					if (_tiParam isEqualTo []) exitWith {};
					_currentTiParam = _tiParam;
				};
				if (_tiParam isEqualTo false) then {
					_currentTiParam = [];
				};
				if (_tiParam isEqualTo true) then {
					_currentTiParam = [2];
				};
			};
			_tiTable set [_turretIndex, _currentTiParam];
			_nvgTable set [_turretIndex, _currentNvgParam];
			_turretParams set ["tiTable", _tiTable];
			_turretParams set ["nvgTable", _nvgTable];
		};

		// IS LOCAL TURRET
		private _isLocal = [_operator] call CFM_fnc_doCheckTurretLocality;
		_turretParams set ["IsTurretLocal", _isLocal];

		// CAM POS FUNC
		private _ppType = PP_NONE;
		private _fullCrew = fullCrew [_self, "", true];
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
		private _doInterpolation = !_hasGoPro && {!(_ppType > 0) && {_doInterpolationSet && (isMultiplayer || _isStaticCam)}};
		_turretParams set ["camPosFunc", _camPosFunc];
		_turretParams set ["doInterpolation", _doInterpolation];

		// POINT ALIGNMENT
		_turretParams set ["ppType", _ppType];
		if (_ppType != PP_NONE) then {
			_pointParams = [_self, _turretIndex, _pointParams, _ppType, false] call CFM_fnc_setPointAlignment;
		};
		if !(_pointParams isEqualType []) then {
			_pointParams = [];
		};
		_turretParams set ["pointParams", _pointParams];


		// CAN MOVE CAMERA
		private _cameraMoveRestrictionsByDefault = _self getVariable ["CFM_cameraMoveRestrictionsByDefault", []];
		private _moveParams = if (_canMoveCamera isEqualTo -1) then {
			[_canMoveCameraByDefault, +_cameraMoveRestrictionsByDefault]
		} else {
			[_canMoveCamera, _self] call CFM_fnc_defineCameraMovementOptions
		};
		_moveParams params [["_canMoveCamera", _canMoveCameraByDefault], ["_cameraMoveRestrictions", +_cameraMoveRestrictionsByDefault]];
		if (count _cameraMoveRestrictions != 4) then {
			_cameraMoveRestrictions = +_cameraMoveRestrictionsByDefault;
		};
		_turretParams set ["canMoveCamera", _canMoveCamera];
		_turretParams set ["cameraMoveRestrictions", _cameraMoveRestrictions];
		
		private _initialDir = if (_isDroneFeed) then {
			[0,1,0]
		} else {
			if (_isStaticCam) exitWith {
				_pointParams param [1, vectorDir _turretObject];
			};
			vectorDir _turretObject;
		};
		_turretParams set ["initialDirUp", [_initialDir, [0,0,1]]];

		// turret name
		_turretParams set ["turretName", _turretName];

		// interface
		if ((_interfaceClass isEqualTo -1) || {(_interfaceClass isEqualTo "") || {!(_interfaceClass isEqualType "")}}) then {
			private _interfaceData = [] call CFM_fnc_defineInterfaceData;
			_interfaceData params [["_interfaceClass", ""], ["_interfaceFuncNameDef", ""]];
			if ((_interfaceFuncName isEqualTo -1) || {(_interfaceFuncName isEqualTo "") || {!(_interfaceFuncName isEqualType "")}}) then {
				_interfaceFuncName = _interfaceFuncNameDef;
			};
		};
		// signal func
		if ((_signalFuncName isEqualTo -1) || {(_signalFuncName isEqualTo "") || {!(call {
			if !(_signalFuncName isEqualType "") exitWith {false};
			private _signalFunc = missionNamespace getVariable [_signalFuncName, {}];
			private _testFuncRes = [player, _operator] call _signalFunc;
			if (isNil "_testFuncRes") exitWith {false};
			_testFuncRes isEqualType 1
		})}}) then {
			_effectAndSignalFuncs = _operator call CFM_fnc_defineSignalEffectFunc;
			_effectAndSignalFuncs params [["_signalFuncNameDef", ""], ["_effectFuncNameDef", ""]];
			_signalFuncName = _signalFuncNameDef;
			// effect func
			if ((_effectFuncName isEqualTo -1) || {!IS_STR(_effectFuncName)}) then {
				_effectFuncName = _effectFuncNameDef;
			};
		};
		if !(IS_STR(_signalFuncName)) then {
			_signalFuncName = "";
		};
		if !(IS_STR(_effectFuncName)) then {
			_effectFuncName = "";
		};
		if !(IS_STR(_interfaceClass)) then {
			_interfaceClass = "";
		};
		if !(IS_STR(_interfaceFuncName)) then {
			_interfaceFuncName = "";
		};
		_turretParams set ["signalFuncName", _signalFuncName];
		_turretParams set ["effectFuncName", _effectFuncName];
		_turretParams set ["interfaceFuncName", _interfaceFuncName];
		_turretParams set ["interfaceClass", _interfaceClass];

		// set
		_turretsParams set [_turretIndex, _turretParams];
		_self setVariable ["CFM_turretsParams", _turretsParams, SET_VARS_INIT_GLOBAL];

		_turretParams
	};
	METHOD("setPointParams") {
		params[["_turretIndex", -1], ["_params", []], ["_ppType", -2], ["_setVar", true]];

		if (_turretIndex isEqualType []) then {
			_turretIndex = _turretIndex#0;
		};

		if !(_turretIndex isEqualType 1) exitWith {false};

		private _turretParams = _turretsParams getOrDefault [_turretIndex, createHashMap];
		private _prevParams = _turretParams getOrDefault ["pointParams", []];
		_ppType = if (_ppType isEqualTo -2) then {_turretParams getOrDefault ["ppType", -1]} else {_ppType};

		if (!(_params isEqualType []) || {(_params isEqualTo [])}) then {
			_params = [_objClass, _turretIndex] call CFM_fnc_getDefaultPointAlignment;
		};

		private _pointParams = [_ppType, _prevParams, _params] call CFM_fnc_validatePointParams;

		if (_setVar) then {
			_turretParams set ["pointParams", _pointParams];
			_turretsParams set [_turretIndex, _turretParams];
			_self setVariable ["CFM_turretsParams", _turretsParams, true];
		};

		_pointParams
	};
	METHOD("setDefaultPointAlignment") {
		{
			[_self, _x, -1] call CFM_fnc_setPointAlignment;
		} forEach _turrets;
	};
	METHOD("monitorConnected") {
		// should be executed globaly
		params[["_monitor", objNull], ["_turret", [-1]], ["_caller", objNull]];

		if !(IS_OBJ(_monitor)) exitWith {};

		private _callerLocal = IS_OBJ(_caller) && {(local _caller)};

		_self setVariable ["CFM_isFeeding", true];
		_monitor setVariable ["CFM_monitorCanSwitchNvg", _canSwitchNvg];
		_monitor setVariable ["CFM_monitorCanSwitchTi", _canSwitchTi];
		_monitor setVariable ["CFM_currentOpHasTurrets", _opHasTurrets];
		_monitor setVariable ["CFM_currentCameraType", _cameraType];
		_monitor setVariable ["CFM_currentOperatorIsDrone", _isDroneFeed];

		if (local _operator) then {
			["addActiveOperator", [_operator]] CALL_CLASS("DbHandler");
		};

		["TurretChanged", [_monitor, _turret, false, _callerLocal]] CALL_OBJCLASS("Operator", _self);
	};
	METHOD("monitorDisconnected") {
		// should be executed globaly
		params[["_monitor", objNull], ["_turret", [-1]], ["_caller", objNull]];

		if (IS_OBJ(_caller) && {(local _caller)}) then {
			["removeMonitor", [_monitor, _turret]] CALL_OBJCLASS("Operator", _self);
			if !([_self] call CFM_fnc_checkIfOperatorFeedsToAnyMonitor) then {
				["removeActiveOperator", [_operator]] CALL_CLASS("DbHandler");
			};
		};
	};
	METHOD("TurretChanged") {
		params["_monitor", ["_turret", [-1]], ["_global", true], ["_globalUpdOp", true]];

		private _turretIndex = if (_turret isEqualType []) then {_turret#0} else {_turret};

		if !(_turretIndex isEqualType 1) exitWith {false};

		private _turretData = _turretsParams getOrDefault [_turretIndex, createHashMap];
		private _turretObj = _turretData getOrDefault ["turretObject", _self];
		private _isLocal = _turretData getOrDefault ["IsTurretLocal", false];
		private _pointParams = _turretData getOrDefault ["pointParams", []];
		private _camPosFunc = _turretData getOrDefault ["camPosFunc", CAM_POS_FUNC_DEF];
		private _doInterpolation = _turretData getOrDefault ["doInterpolation", false];
		private _canMoveCamera = _turretData getOrDefault ["canMoveCamera", false];
		private _currentCameraMoves = _turretData getOrDefault ["currentCamMove", [0,0,0,0]];
		private _cameraMoveRestrictions = _turretData getOrDefault ["cameraMoveRestrictions", []];
		private _smoothZoom = _turretData getOrDefault ["smoothZoom", true];
		private _zoomTable = _turretData getOrDefault ["zoomTable", createHashMap];
		private _signalFuncName = _turretData getOrDefault ["signalFuncName", ""];
		private _effectFuncName = _turretData getOrDefault ["effectFuncName", ""];
		private _interfaceFuncName = _turretData getOrDefault ["interfaceFuncName", ""];
		private _interfaceClass = _turretData getOrDefault ["interfaceClass", ""];
		private _zoomMax = _zoomTable getOrDefault ["max", 1];
		_zoomMax = if (_zoomMax isEqualType 1) then {_zoomMax} else {1};

		if !(IS_OBJ(_turretObj)) then {
			_turretObj = _self;
		};
		_cameraMoveRestrictions resize [4, 180];
		_turretsParams set [_turretIndex, _turretData];
		_self setVariable ["CFM_turretsParams", _turretsParams];

		private _prevTurret = _monitor getVariable ["CFM_currentTurret", -2];
		_monitor setVariable ["CFM_currentTurret", [_turretIndex], _global];
		_monitor setVariable ["CFM_connectedTurretObject", _turretObj, _global];
		_monitor setVariable ["CFM_zoomMax", _zoomMax, _global];
		_monitor setVariable ["CFM_zoomTable", _zoomTable, _global];
		_monitor setVariable ["CFM_cameraPosFunc", _camPosFunc, _global];
		_monitor setVariable ["CFM_turretLocal", _isLocal, _global];
		_monitor setVariable ["CFM_currentCamPointParams", _pointParams, _global];
		_monitor setVariable ["CFM_currentTiTable", _tiTable, _global];
		_monitor setVariable ["CFM_currentNvgTable", _nvgTable, _global];
		_monitor setVariable ["CFM_currentCameraIsStatic", _isStaticCam, _global];
		_monitor setVariable ["CFM_currentCameraCanMove", _canMoveCamera, _global];
		_monitor setVariable ["CFM_currentCameraMoves", _currentCameraMoves, _global];
		_monitor setVariable ["CFM_currentCameraMoveRestrictions", _cameraMoveRestrictions, _global];
		_monitor setVariable ["CFM_doUpdateCamera", [true, _pointParams] select _isStaticCam, _global];
		_monitor setVariable ["CFM_currentCameraSmoothZoom", _smoothZoom, _global];
		_monitor setVariable ["CFM_camInterp_lastDir", nil, _global];
		_monitor setVariable ["CFM_camInterp_lastUp", nil, _global];
		private _doSetFuncs = IS_STR(_signalFuncName) || {IS_STR(_interfaceFuncName)};
		if (_global) then {
			if (_doSetFuncs) then {
				["setSignalInterfaceEffectFuncs", [_signalFuncName, _effectFuncName, _interfaceFuncName], true] REMOTE_EXEC_OBJCLASS("DisplayHandler", _monitor);
			};
			["setRenderInterfaceDisplay", [true, _interfaceClass], true] REMOTE_EXEC_OBJCLASS("DisplayHandler", _monitor);
		} else {
			if (_doSetFuncs) then {
				["setSignalInterfaceEffectFuncs", [_signalFuncName, _effectFuncName, _interfaceFuncName], true] CALL_OBJCLASS("DisplayHandler", _monitor);
			};
			["setRenderInterfaceDisplay", [true, _interfaceClass]] CALL_OBJCLASS("DisplayHandler", _monitor);
		};
		[_monitor, true] call CFM_fnc_setOperatorInfo;

		// small delay before enabling interpolation so there is no camera movement on spawn
		// if (_doInterpolation) then {
		// 	_monitor setVariable ["CFM_camDoInterpolation", false, _global];
		// 	[_monitor, _doInterpolation, _global, _self] spawn {
		// 		params['_monitor', '_doInterpolation', '_global', '_op'];
		// 		sleep (MGVAR ["CFM_waitCamSetPosForInterpolation", 0.2]);
		// 		private _currentMonOp = _monitor getVariable ["CFM_connectedOperator", objNull];
		// 		if !(_currentMonOp isEqualTo _op) exitWith {};
		// 		_monitor setVariable ["CFM_camDoInterpolation", _doInterpolation, _global];
		// 	};
		// } else {
			_monitor setVariable ["CFM_camDoInterpolation", _doInterpolation, _global];
		// };

		if (_globalUpdOp) then {
			["removeMonitor", [_monitor, _prevTurret]] CALL_OBJCLASS("Operator", _self);
			["addMonitor", [_monitor, _turret]] CALL_OBJCLASS("Operator", _self);
		};

		if (_globalUpdOp && {!(_turretObj isEqualTo _self)}) then {
			CFM_operatorsToUpdate = _self;
			publicVariableServer "CFM_operatorsToUpdate";
			[_self, _turretIndex, _turretObj] call CFM_fnc_addActiveTurret;
		};

		true
	};
	METHOD("NextTurret") {
		params["_monitor", ["_currentTurret", [-1]]];

		private _curTurrIndex = TURRET_INDEX(_currentTurret);

		private _turretsIndexes = _turrets apply {TURRET_INDEX(_x)};
		private _turretsCount = count _turretsIndexes;

		private _currIndex = _turretsIndexes findIf {_x isEqualTo _curTurrIndex};
		private _nextIndex = _currIndex + 1;

		if ((_nextIndex + 1) > _turretsCount) then {
			_nextIndex = 0;
		};
		private _nextTurretIndex = _turretsIndexes select _nextIndex;

		["TurretChanged", [_monitor, [_nextTurretIndex], true, true]] CALL_OBJCLASS("Operator", _self);

		true
	};
	METHOD("addMonitor") {
		params[["_monitor", objNull], ["_turret", [-1]]];

		if !(IS_OBJ(_monitor)) exitWith {-1};

		private _turretIndex = TURRET_INDEX(_turret);
		private _monitorsOnTurret = _monitorsSet getOrDefault [_turretIndex, []];
		private _i = _monitorsOnTurret pushBackUnique _monitor;
		_monitorsSet set [_turretIndex, _monitorsOnTurret];
		_self setVariable ["CFM_monitorsSet", _monitorsSet, true];
		_i
	};
	METHOD("removeMonitor") {
		params[["_monitor", objNull], ["_turret", [-1]]];

		private _turretIndex = TURRET_INDEX(_turret);
		private _monitorsOnTurret = _monitorsSet getOrDefault [_turretIndex, []];
		_monitorsOnTurret = _monitorsOnTurret - [_monitor];
		_monitorsSet set [_turretIndex, _monitorsOnTurret];
		_self setVariable ["CFM_monitorsSet", _monitorsSet, true];
		true
	};
	METHOD("checkIfFeedsToAnyMonitor") {
		private _monitorsOnTurretsArray = values _monitorsSet;
		private _activeTurrets = {!(_x isEqualTo [])} count _monitorsOnTurretsArray;
		_activeTurrets > 0
	};
	METHOD("removeActiveTurret") {
		params[["_turretIndex", -1]];

		_activeTurretsObjects deleteAt _turretIndex;
		_hasActiveTurretsObjects = (_hasActiveTurretsObjects - 1) max 0;
		_self setVariable ["CFM_hasActiveTurretsObjects", _hasActiveTurretsObjects, MONITOR_VIEWERS_AND_SELF(false)];
		_self setVariable ["CFM_activeTurretsObjects", _activeTurretsObjects, MONITOR_VIEWERS_AND_SELF(false)];
	};
	METHOD("addActiveTurret") {
		params[["_turretIndex", -1], ["_turretObject", objNull]];

		if (!(IS_OBJ(_turretObject)) || {_turretObject isEqualTo _self}) exitWith {false};

		_activeTurretsObjects set [_turretIndex, _turretObject];
		_hasActiveTurretsObjects = _hasActiveTurretsObjects max 0;
		_hasActiveTurretsObjects = (_hasActiveTurretsObjects + 1) max 0;
		_self setVariable ["CFM_hasActiveTurretsObjects", _hasActiveTurretsObjects, MONITOR_VIEWERS_AND_SELF(false)];
		_self setVariable ["CFM_activeTurretsObjects", _activeTurretsObjects, MONITOR_VIEWERS_AND_SELF(false)];
		true
	};
	METHOD("moveCamera") {
		params[["_turret", -1], ["_axisAngles", [0,0], [[]], 2]];

		if (_isDroneFeed) exitWith {
			if !(missionNamespace getVariable ["CFM_canMoveDroneCameras", false]) exitWith {false};
			["moveDroneCamera", [_turretIndex, _axisAngles]] SPAWN_OBJCLASS("Operator", _self);
			true
		};

		if (_axisAngles isEqualTo [0,0]) exitWith {false};

		private _turretIndex = TURRET_INDEX(_turret);
		private _turretData = _turretsParams getOrDefault [_turretIndex, createHashMap];

		private _ppType = _turretData getOrDefault ["ppType", PP_NONE];
		if !(_ppType in [PP_STATIC, PP_VEH_STATIC, PP_VEH_TURRET]) exitWith {false};

		private _pointParams = _turretData get "pointParams";

		if (isNil "_pointParams") exitWith {false};

		private _monitorsOnTurret = _monitorsSet getOrDefault [_turretIndex, []];

		if (_monitorsOnTurret isEqualTo []) exitWith {false};

		_axisAngles params [["_horizontal", 0], ["_vertical", 0]];
			
		private _done = switch (_ppType) do {
			case PP_STATIC: {
				_pointParams params [["_pos", [], [[]], 3], ["_dir", DEF_DIR, [[]], 3], ["_up", DEF_UP, [[]], 3]];

				// global rotation
				private _newDirUp = [_dir, _up, _vertical, _horizontal] call CFM_fnc_transformTurret;
				private _newDir = _newDirUp param [0, _dir];
				private _newUp = _newDirUp param [1, _up];

				_pointParams = [_ppType, _pointParams, [_pos, _newDir, _newUp]] call CFM_fnc_validatePointParams;
				_turretData set ["pointParams", _pointParams];
				_turretsParams set [_turretIndex, _turretData];
				
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
				_turretData set ["pointParams", _pointParams];
				_turretsParams set [_turretIndex, _turretData];
				
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
				_turretData set ["pointParams", _pointParams];
				_turretsParams set [_turretIndex, _turretData];

				true
			};
			default {false};
		};

		if !(_done) exitWith {false};

		private _restrictions = _turretData getOrDefault ["cameraMoveRestrictions", [0,0,0,0]];
		private _currentMove = _turretData getOrDefault ["currentCamMove", [0,0,0,0]];
		_currentMove = [_currentMove, _axisAngles, _restrictions] call CFM_fnc_calculateCameraMoves;
		_turretData set ["currentCamMove", +_currentMove];

		private _targets = MONITOR_VIEWERS_AND_SELF(false);
		_self setVariable ["CFM_turretsParams", _turretsParams, _targets];

		private _doInterpolation = _turretData getOrDefault ["doInterpolation", false];
		private _doUpdCam = if (!_doInterpolation && {(_ppType > 0)}) then {0} else {_pointParams};
		{
			if !(_doInterpolation) then {
				_x setVariable ["CFM_camDoInterpolation", true, _targets];
			};
			_x setVariable ["CFM_currentCamPointParams", _pointParams, _targets];
			_x setVariable ["CFM_doUpdateCamera", _doUpdCam, _targets];
			_x setVariable ["CFM_currentCameraMoves", +_currentMove, _targets];
		} forEach _monitorsOnTurret;

		true
	};
	METHOD("moveDroneCamera") {
		params[["_turret", -1], ["_axisAngles", [0,0], [[]], 2]];

		if (_axisAngles isEqualTo [0,0]) exitWith {false};

		private _turretIndex = TURRET_INDEX(_turret);
		private _turretData = _turretsParams getOrDefault [_turretIndex, createHashMap];
		private _isGunnerTurret = _turretIndex isEqualTo 0;
		private _isUAVcontrolled = _isDroneFeed && {[_self, ["DRIVER", "GUNNER"] select (_isGunnerTurret)] call CFM_fnc_isUAVControlled};

		if (_isDroneFeed && {_isUAVcontrolled && {!(missionNamespace getVariable ["CFM_canMoveDroneCameraIfUavControlled", false])}}) exitWith {
			false
		};

		private _monitorsOnTurret = _monitorsSet getOrDefault [_turretIndex, []];

		if (_monitorsOnTurret isEqualTo []) exitWith {false};

		if !(local _self) exitWith {
			private _target = if (_isGunnerTurret) then {gunner _self} else {driver _self};
			if (isNull _target) then {
				_target = _self;
			};
			[[_self, [_turretIndex, _axisAngles]], {
				params["_operator", "_args"];
				["moveDroneCamera", _args] SPAWN_OBJCLASS("Operator", _operator);
			}, _target, false, true] call CFM_fnc_remoteExec;
			true
		};

		_axisAngles params [["_horizontal", 0], ["_vertical", 0]];

		// calculate moves
		private _dirVarName = "CFM_currentTurretDirMS" + str _turretIndex;
		private _upVarName = "CFM_currentTurretUpMS" + str _turretIndex;
		private _dir = _self getVariable [_dirVarName, [0,1,0]];
		private _up = _self getVariable [_upVarName, [0,0,1]];
		private _initialDirUp = +(_turretData getOrDefault ["initialDirUp", [[0,1,0], [0,0,1]]]);
		private _restrictions = _turretData getOrDefault ["cameraMoveRestrictions", [0,0,0,0]];
		private _currentMove = [_initialDirUp, [_dir, _up]] call CFM_fnc_calculateCurrentCameraMoves;
		_currentMove = [_currentMove, _axisAngles, _restrictions] call CFM_fnc_calculateCameraMoves;

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

		_turretData set ["currentCamMove", +_currentMove];
		_turretsParams set [_turretIndex, _turretData];

		private _targets = MONITOR_VIEWERS_AND_SELF(false);
		_self setVariable ["CFM_turretsParams", _turretsParams, _targets];

		{
			_x setVariable ["CFM_currentCameraMoves", +_currentMove, _targets];
		} forEach _monitorsOnTurret;

		true
	};
	METHOD("setOperatorSides") {
		params[["_sides", civilian]];

		if !(_sides isEqualType []) then {
			_sides = [_sides];
		};
		_sides = _sides select {_x isEqualType west};

		if (_sides isEqualTo []) exitWith {false};

		_opSides = _sides;
		_self setVariable ["CFM_opSides", _sides];
		true
	};
	METHOD("getOperatorName") {
		params[["_turret", -1]];

		private _turrIndex = TURRET_INDEX(_turret);
		private _turretData = _turretsParams get _turrIndex;
		if (isNil "_turretData") exitWith {_operatorName};
		private _turretName = _turretData getOrDefault ["turretName", ""];
		if (isNil "_turretName") exitWith {_operatorName};
		if (_turretName isEqualTo "") exitWith {_operatorName};
		_turretName
	};
OBJCLASS_END