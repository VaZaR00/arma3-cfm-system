#define SET_VARS_INIT_GLOBAL true

OBJCLASS(Operator)

	SET_SELF_VAR(_operator);

	OBJ_VARIABLE(_canSwitchTi, false);
	OBJ_VARIABLE(_canSwitchNvg, false);
	OBJ_VARIABLE(_opHasTurrets, false);
	OBJ_VARIABLE(_turrets, [DRIVER_TURRET_PATH]);
	OBJ_VARIABLE(_cameraType, "");
	OBJ_VARIABLE(_operatorName, "");
	OBJ_VARIABLE(_operatorId, -1);
	OBJ_VARIABLE(_hasGoPro, false);
	OBJ_VARIABLE(_canFeed, false);
	OBJ_VARIABLE(_canMoveCameraByDefault, false);
	OBJ_VARIABLE(_cameraMoveRestrictionsByDefault, []); // [degrees up, degrees down, degrees left, degrees right]
	OBJ_VARIABLE(_cameraZoomSmoothDefault, false); 
	OBJ_VARIABLE(_classType, "");
	OBJ_VARIABLE(_objClass, "");
	OBJ_VARIABLE(_monitorsSet, createHashMap);
	OBJ_VARIABLE(_tiTable, createHashMap);
	OBJ_VARIABLE(_nvgTable, createHashMap);
	OBJ_VARIABLE(_operatorSet, false);
	OBJ_VARIABLE(_isFeeding, false);
	OBJ_VARIABLE(_isDroneFeed, false);	
	OBJ_VARIABLE(_isMavic, false);	
	OBJ_VARIABLE(_isFPV, false);	
	OBJ_VARIABLE(_staticCamOffset, NULL_VECTOR);	
	OBJ_VARIABLE(_isStaticCam, false);	
	OBJ_VARIABLE(_opSides, []);	
	OBJ_VARIABLE(_turretsParams, createHashMap);	
	OBJ_VARIABLE(_opCameraPosFunc, CAM_POS_FUNC_DEF);
	OBJ_VARIABLE(_hasActiveTurretsObjects, -1);
	OBJ_VARIABLE(_activeTurretsObjects, createHashMap);

	/*
		_turretsParams: [[turretIndex, [turretObject, isLocal, pointParams, zoomTable, nvgTable, tiTable, isStaticVeh, isGopro, camPosFunc, doInterpolation, currentCamMove]]]
		pointParams: [memPoint, [addArr, setArr]]
	*/

	METHODS

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


		// CAM TYPE
		_cameraType = [_operator] call CFM_fnc_cameraType;
		_operator setVariable ["CFM_cameraType", _cameraType, _global];


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

		switch (_cameraType) do {
			case DRONETYPE: {
				_operator setVariable ["CFM_canFeed", true, _global];
				_operator setVariable ["CFM_isDroneFeed", true, _global];
			};
			case TYPE_VEH: {
				_operator setVariable ["CFM_canFeed", true, _global];
				_operator setVariable ["CFM_isVehFeed", true, _global];
			};
			default {};
		};
		if (_name isEqualTo "") then {
			_name = switch (_cameraType) do {
				case GOPRO: {
					format["%1: %2", groupId group _self, name _self]
				};
				case TYPE_STATIC: {
					_self getVariable ["CFM_staticCameraID", "Camera"];
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
			_turretIndex = TURRET_INDEX(_turretIndex);
			_turrets pushBackUnique _turretIndex;
		} forEach _turretsParamsInit;

		_operator setVariable ["CFM_turrets", _turrets, SET_VARS_INIT_GLOBAL]; 

		[_operator] call CFM_fnc_setDefaultPointAlignment;

		{
			private _turret = _x;
			if !(_turret isEqualType []) then {
				_turret = [_turret];
			};
			_turret params [["_turretIndex", -1], ["_params", []]];
			private _turretArgs = [_turretIndex] + _params;
			private _args = [_operator] + _turretArgs;
			_args call CFM_fnc_setTurretParams;
		} forEach _turretsParamsInit;

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
			["_pointParams", []], 
			["_isStaticVeh", false], 
			["_doInterpolationSet", true], 
			["_turretName", ""],
			["_smoothZoomSetTurr", -1]
		];

		_turretIndex = TURRET_INDEX(_turretIndex);
		private _turretParams = _turretsParams getOrDefault [_turretIndex, createHashMap];

		// POINT ALIGNMENT
		if (_pointParams isEqualTo false) then {
			_isStaticVeh = true;
		};
		if (!_isStaticVeh && !_isStaticCam && {((_pointParams isEqualType []) && {!(_pointParams isEqualTo [])})}) then {
			_pointParams params [["_memPoint", ""], ["_alignment", []]];
			_alignment params [["_addArr", []], ["_setArr", []]];
			[_operator, [_turretIndex, _addArr, _memPoint, _setArr]] call CFM_fnc_setPointAlignment;
		};
		if (_isStaticCam) then {
			_turretParams set ["pointParams", _pointParams];
		};

		// ZOOM
		private _zoomTable = createHashMap;
		if (_setZoomTable isEqualType 1) then {
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
		private _smoothZoom = if (_smoothZoomSetTurr == -1) then {
			_cameraZoomSmoothDefault && !_hasGoPro
		} else {
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
		private _fullCrew = fullCrew [_self, "", true];
		private _isVehWithTurrets = (_fullCrew findIf {(_x#1) isEqualTo "gunner"}) != -1;
		private _isDriverTurr = _turretIndex in DRIVER_TURRET_PATH;
		private _camPosFunc = if ((_isStaticVeh && !_hasGoPro) || (_isFPV && _isDriverTurr)) then {
			CFM_fnc_camPosVehStatic
		} else {
			switch (_classType) do {
				case TYPE_UAV: {
					// if (_isDriverTurr) then {
					// 	CFM_fnc_camPosPilotTurret
					// } else {
					// 	CFM_fnc_camPosVehTurret
					// };
					CFM_fnc_camPosVehTurret
				};
				case TYPE_UNIT: {
					CFM_fnc_camPosGoPro
				};
				case TYPE_STATIC: {
					CFM_fnc_camPosStatic
				};
				case TYPE_VEH: {
					if (_isVehWithTurrets) then {
						CFM_fnc_camPosVehTurret
					} else {
						CFM_fnc_camPosVehStatic
					};
				};
				default {
					CFM_fnc_camPosVehStatic
				};
			};
		};
		private _doInterpolation = _doInterpolationSet && (isMultiplayer || _isStaticCam) && {!_hasGoPro && {!(_camPosFunc isEqualTo CFM_fnc_camPosVehStatic)}};
		_turretParams set ["camPosFunc", _camPosFunc];
		_turretParams set ["doInterpolation", _doInterpolation];
		_isStaticVeh = _isStaticVeh || {_camPosFunc in [CFM_fnc_camPosVehStatic, CFM_fnc_camPosStatic]};
		_turretParams set ["isStaticVeh", _isStaticVeh];

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

		// CAN MOVE CAMERA
		private _cameraMoveRestrictionsByDefault = _self getVariable ["CFM_cameraMoveRestrictionsByDefault", []];
		private _moveParams = if (_canMoveCamera isEqualTo -1) then {
			[_canMoveCameraByDefault, +_cameraMoveRestrictionsByDefault]
		} else {
			[_canMoveCamera] call CFM_fnc_defineCameraMovementOptions
		};
		_moveParams params [["_canMoveCamera", _canMoveCameraByDefault], ["_cameraMoveRestrictions", +_cameraMoveRestrictionsByDefault]];
		if (count _cameraMoveRestrictions != 4) then {
			_cameraMoveRestrictions = +_cameraMoveRestrictionsByDefault;
		};
		_turretParams set ["canMoveCamera", _canMoveCamera];
		_turretParams set ["cameraMoveRestrictions", _cameraMoveRestrictions];

		_turretsParams set [_turretIndex, _turretParams];
		_self setVariable ["CFM_turretsParams", _turretsParams, SET_VARS_INIT_GLOBAL];

		_turretParams
	}; 
	METHOD("setPointAlignment") {
		params[["_turretIndex", -1], ["_offset", []], ["_newMemPoint", ""], ["_setPos", []]];
		// _setPos can be [vectorDir, vectorUp] for CFM_fnc_camPosVehStatic

		if (_turretIndex isEqualType []) then {
			_turretIndex = _turretIndex#0;
		};

		if !(_turretIndex isEqualType 1) exitWith {false};

		private _turretParams = _turretsParams getOrDefault [_turretIndex, createHashMap];
		private _prevParams = _turretParams getOrDefault ["pointParams", []];

		if !(_prevParams isEqualType []) then {
			_prevParams = [];
		};

		_prevParams params [["_memPoint", ""], ["_alignment", []]];
		_alignment params [["_addArr", []], ["_setArr", []]];
		
		if !(_offset isEqualType []) then {
			_offset = NULL_VECTOR;
		};
		if !(_setPos isEqualType []) then {
			_setPos = NULL_VECTOR;
		};
		if (count _offset == 3) then {
			_addArr = +_offset;
		};
		if (count _setPos == 3) then {
			_setArr = +_setPos;
		};
		if ((count _setPos > 0) && {((_setPos#0) isEqualType [])}) then {
			// case for CFM_fnc_camPosVehStatic
			_setPos params [["_vdir", []], ["_vup", []]];
			if ((_vdir isEqualType []) || {(count _vdir != 3)}) then {
				_vdir = NULL_VECTOR;
			};
			if ((_vup isEqualType []) || {(count _vup != 3)}) then {
				_vup = NULL_VECTOR;
			};
			_addArr = +_offset;
			_setArr = [+_vdir, +_vup];
		};
		if ((IS_STR(_newMemPoint)) && {!(_newMemPoint isEqualTo "")}) then {
			if (_newMemPoint isEqualTo "_none_") then {
				_newMemPoint = "";
			};
			_memPoint = _newMemPoint;
		};

		private _res = [_memPoint, [_addArr, _setArr]];
		_turretParams set ["pointParams", _res];
		_turretsParams set [_turretIndex, _turretParams];
		_self setVariable ["CFM_turretsParams", _turretsParams, true];

		+_res
	};
	METHOD("setDefaultPointAlignment") {
		private _pointSet = missionNamespace getVariable ["CFM_classesPointAlignmentSet", createHashMap];

		private _predefinedAlignment = _pointSet get _objClass;

		if ((isNil "_predefinedAlignment") || {(_predefinedAlignment isEqualTo [])}) then {
			_predefinedAlignment = createHashMap;
		};
		if !(_predefinedAlignment isEqualType createHashMap) then {
			_predefinedAlignment = createHashMapFromArray _predefinedAlignment;
		};
		if ((isNil "_predefinedAlignment") || {!(_predefinedAlignment isEqualType createHashMap)}) then {
			_predefinedAlignment = createHashMap;
		};

		{
			private _turrIndex = TURRET_INDEX(_x);
			private _turrParams = _turretsParams getOrDefault [_turrIndex, createHashMap];
			private _pointParams = _turrParams getOrDefault ["pointParams", []];

			private _predefinedAlignmentTurr = _predefinedAlignment getOrDefault [_turrIndex, []];
			_predefinedAlignmentTurr params [["_pAddArr", []], ["_pMemPoint", ""], ["_pSetArr", []]];
			private _dir = [0,0,0];
			private _up = [0,0,0];
			private _isStatic = false;
			if (_pMemPoint isEqualType []) then {
				_isStatic = true;
				_dir = +_pMemPoint;
			};
			if (_isStatic) then {
				_up = +_pSetArr;
			};
			_pointParams params [["_addArr", []], ["_memPoint", ""], ["_setArr", []]];
			// FIRST DEFAULT
			private _defaultMemPointParams = ([_operator, _turrIndex, _cameraType] call CFM_fnc_getCameraPoints)#1;
			if !(_defaultMemPointParams isEqualType []) then {
				_defaultMemPointParams = [_defaultMemPointParams];
			};
			_defaultMemPointParams params [["_defMemPoint", ""], ["_defAddArr", []], ["_defSetArr", []]];
			if (_memPoint isEqualTo "") then {
				_memPoint = _defMemPoint;
			};
			if (count _addArr != 3) then {
				_addArr = _defAddArr;
			};
			if (count _setArr != 3) then {
				_setArr = _defSetArr;
			};
			// SECOND PREDEFINED
			if !(_pMemPoint isEqualTo "") then {
				_memPoint = _pMemPoint;
			};
			if (count _pAddArr == 3) then {
				_addArr = _pAddArr;
			};
			if (count _pSetArr == 3) then {
				_setArr = _pSetArr;
			};
			if (_isStatic) then {
				_setArr = +[_dir, _up];
			};
			[_operator, [_turrIndex, _addArr, _memPoint, _setArr]] call CFM_fnc_setPointAlignment;
		} forEach _turrets;

		_predefinedAlignment
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
		_monitor setVariable ["CFM_currentCameraType", _currentCameraType];
		_monitor setVariable ["CFM_currentOperatorIsDrone", _isDroneFeed];

		["TurretChanged", [_monitor, _turret, false, _callerLocal]] CALL_OBJCLASS("Operator", _self);
	};
	METHOD("monitorDisconnected") {
		// should be executed globaly
		params[["_monitor", objNull], ["_turret", [-1]], ["_caller", objNull]];

		if (IS_OBJ(_caller) && {(local _caller)}) then {
			["removeMonitor", [_monitor, _turret]] CALL_OBJCLASS("Operator", _self);
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
		private _zoomMax = _zoomTable getOrDefault ["max", 1];
		_zoomMax = if (_zoomMax isEqualType 1) then {_zoomMax} else {1};

		if (_camPosFunc isEqualTo CFM_fnc_camPosVehStatic) then {
			private _checkedPointParams = +_pointParams;
			private _checkPointParams = call {
				if !(_pointParams isEqualType []) exitWith {false};
				if ((count _pointParams) != 2) exitWith {false};
				_pointParams params [["_m", ""], ["_offsets", []]];
				if !(_offsets isEqualType []) exitWith {false};
				_offsets params [["_pos", []], ["_vdup", []]];
				if !(_pos isEqualType []) exitWith {false};
				if (count _pos != 3) exitWith {false};
				if !(_vdup isEqualType []) exitWith {
					_checkedPointParams = [_m, [_pos, [NULL_VECTOR, NULL_VECTOR]]];
					true
				};
				_vdup params [["_dir", []], ["_up", []]];
				if (!(_dir isEqualType []) || {(count _dir != 3)}) then {
					_dir = NULL_VECTOR;
				};
				if (!(_up isEqualType []) || {(count _up != 3)}) then {
					_up = NULL_VECTOR;
				};
				_checkedPointParams = [_m, [_pos, [_dir, _up]]];
				true
			};
			if !(_checkPointParams) then {
				_pointParams = ["", [NULL_VECTOR, [NULL_VECTOR, NULL_VECTOR]]];
			} else {
				_pointParams = +_checkedPointParams;
			};
		};
		if (_camPosFunc isEqualTo CFM_fnc_camPosVehTurret) then {
			private _checkedPointParams = +_pointParams;
			private _checkPointParams = call {
				if !(_pointParams isEqualType []) exitWith {false};
				_pointParams params [["_memPoint", []], ["_align", []]];
				if !(_memPoint isEqualType "") then {
					_memPoint = "";
				};
				private _defAdd = [0,0,0];
				private _defSet = [-1,-1,-1];
				private _defAddSet = [+_defAdd, +_defSet];
				if (!(_align isEqualType []) || {(_align isEqualTo [])}) exitWith {
					_checkedPointParams = [_memPoint, +_defAddSet];
					true
				};
				_align params [["_add", []], ["_set", []]];
				if (!(_add isEqualType []) || {(count _add != 3)}) then {
					_add = +_defAdd;
				};
				if (!(_set isEqualType []) || {(count _set != 3)}) then {
					_set = +_defSet;
				};
				_checkedPointParams = [_memPoint, [_add, _set]];
				true
			};
			if !(_checkPointParams) then {
				_pointParams = ["", [NULL_VECTOR, NULL_VECTOR]];
			} else {
				_pointParams = +_checkedPointParams;
			};
		};
		if (_camPosFunc isEqualTo CFM_fnc_camPosStatic) then {
			private _checkedPointParams = +_pointParams;
			private _checkPointParams = call {
				if !(_pointParams isEqualType []) exitWith {false};
				_pointParams params [["_pos", []], ["_dir", []], ["_up", []]];
				if (!(_pos isEqualType []) || {(count _pos != 3)}) then {
					_pos = NULL_VECTOR;
				};
				if (!(_dir isEqualType []) || {(count _dir != 3)}) then {
					_dir = NULL_VECTOR;
				};
				if (!(_up isEqualType []) || {(count _up != 3)}) then {
					_up = NULL_VECTOR;
				};
				_checkedPointParams = [_pos, _dir, _up];
				true
			};
			if !(_checkPointParams) then {
				_pointParams = [NULL_VECTOR, NULL_VECTOR, NULL_VECTOR];
			} else {
				_pointParams = +_checkedPointParams;
			};
		};
		if !(IS_OBJ(_turretObj)) then {
			_turretObj = _self;
		};
		_cameraMoveRestrictions resize [4, 180];

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

		private _turretIndex = if (_turret isEqualType []) then {_turret#0} else {_turret};
		private _monitorsOnTurret = _monitorsSet getOrDefault [_turretIndex, []];
		private _i = _monitorsOnTurret pushBackUnique _monitor;
		_monitorsSet set [_turretIndex, _monitorsOnTurret];
		_self setVariable ["CFM_monitorsSet", _monitorsSet, true];
		_i
	};
	METHOD("removeMonitor") {
		params[["_monitor", objNull], ["_turret", [-1]]];

		private _turretIndex = _turret#0;
		private _monitorsOnTurret = _monitorsSet getOrDefault [_turretIndex, []];
		_monitorsOnTurret = _monitorsOnTurret - [_monitor];
		_monitorsSet set [_turretIndex, _monitorsOnTurret];
		_self setVariable ["CFM_monitorsSet", _monitorsSet, true];
		true
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
		};

		if (_axisAngles isEqualTo [0,0]) exitWith {false};

		private _turretIndex = TURRET_INDEX(_turret);
		private _turretData = _turretsParams getOrDefault [_turretIndex, createHashMap];
		private _isStaticVeh = _turretData getOrDefault ["isStaticVeh", true];

		if (_isStaticVeh && !_isStaticCam) exitWith {false};

		private _pointParams = _turretData get "pointParams";

		if (isNil "_pointParams") exitWith {false};

		private _monitorsOnTurret = _monitorsSet getOrDefault [_turretIndex, []];

		if (_monitorsOnTurret isEqualTo []) exitWith {false};

		_pointParams params [["_pos", []], ["_dir", [0,0,0], [[]], 3], ["_up", [0,0,0], [[]], 3]];

		_axisAngles params [["_horizontal", 0], ["_vertical", 0]];

		private _newDirUp = [_dir, _up, _vertical, _horizontal] call CFM_fnc_transformTurret;
		private _newDir = _newDirUp param [0, _dir];
		private _newUp = _newDirUp param [1, _up];

		private _currentMove = _turretData getOrDefault ["currentCamMove", [0,0,0,0]];
		private _vertUp = (_currentMove#0) + _vertical;
		private _vertDown = (_currentMove#1) - _vertical;
		private _vertLeft = (_currentMove#2) + _horizontal;
		private _vertRight = (_currentMove#3) - _horizontal;
		_currentMove = [_vertUp, _vertDown, _vertLeft, _vertRight];
		_turretData set ["currentCamMove", +_currentMove];

		_pointParams = [_pos, _newDir, _newUp];
		_turretData set ["pointParams", +_pointParams];
		_turretsParams set [_turretIndex, _turretData];

		private _targets = MONITOR_VIEWERS_AND_SELF(false);
		_self setVariable ["CFM_turretsParams", _turretsParams, _targets];

		// private _doInterpolation = _turretData getOrDefault ["doInterpolation", false];

		{
			// if (_doInterpolation) then {
			// 	_x setVariable ["CFM_camDoInterpolation", _doInterpolation, _targets];
			// };
			_x setVariable ["CFM_currentCamPointParams", _pointParams, _targets];
			_x setVariable ["CFM_doUpdateCamera", _pointParams, _targets];
			_x setVariable ["CFM_currentCameraMoves", +_currentMove, _targets];
		} forEach _monitorsOnTurret;

		true
	};
	METHOD("moveDroneCamera") {
		params[["_turret", -1], ["_axisAngles", [0,0], [[]], 2]];

		if (_axisAngles isEqualTo [0,0]) exitWith {false};

		private _turretIndex = TURRET_INDEX(_turret);
		private _turretData = _turretsParams getOrDefault [_turretIndex, createHashMap];
		private _isStaticVeh = _turretData getOrDefault ["isStaticVeh", true];

		if (_isStaticVeh && !_isStaticCam) exitWith {false};

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
		private _currentMove = +(_turretData getOrDefault ["currentCamMove", [0,0,0,0]]);
		private _vertUp = (_currentMove#0) + _vertical;
		private _vertDown = (_currentMove#1) - _vertical;
		private _vertLeft = (_currentMove#2) + _horizontal;
		private _vertRight = (_currentMove#3) - _horizontal;
		_currentMove = [_vertUp, _vertDown, _vertLeft, _vertRight];

		private _hasPrevMove = !(_self getVariable ["CFM_moveDone", true]);
		if (_hasPrevMove) then {
			_self setVariable ["CFM_newMove", true];
			waitUntil { sleep 0.01; _self getVariable ["CFM_moveDone", true] };
		};
		_self setVariable ["CFM_moveDone", false];

		private _havingNewMove = false;

		private _done = if (_isGunnerTurret) then {
			private _dirVarName = "CFM_currentTurretDirMS" + str _turretIndex;
			private _upVarName = "CFM_currentTurretUpMS" + str _turretIndex;
			private _dir = _self getVariable [_dirVarName, vectorDir _self];
			private _up = _self getVariable [_upVarName, vectorUp _self];
			private _newDirUp = [_dir, _up, _vertical, _horizontal] call CFM_fnc_transformTurret;
			private _newDir = _newDirUp param [0, _dir];
			private _newUp = _newDirUp param [0, _up];
			private _lockPos = [_self, _newDir, 1] call CFM_fnc_getObjCamOffsetMS;
			private _prevCamLook = [_self, [_turretIndex]] call CFM_fnc_getTurretCameraLock;

			_self lockCameraTo [_lockPos, [_turretIndex]];

			private _waitStart = time;
			waitUntil {
				sleep 0.01;
				[_self] call CFM_fnc_updateOperator;
				_havingNewMove = _self getVariable ["CFM_newMove", false];
				_havingNewMove ||
				{((time - _waitStart) > 2) || {
					[
						[_self, [_turretIndex]] call CFM_fnc_getTurretCameraLock, 
						_newCamLook
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
				[_self] call CFM_fnc_updateOperator;
				_havingNewMove = _self getVariable ["CFM_newMove", false];
				_havingNewMove ||
				{((time - _waitStart) > 2) || {
					([_newCamDir, getPilotCameraDirection _self] call CFM_fnc_compareVectors)
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
CLASS_END