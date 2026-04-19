OBJCLASS(Operator)

	SET_SELF_VAR(_operator);

	OBJ_VARIABLE(_canSwitchTi, false);
	OBJ_VARIABLE(_canSwitchNvg, false);
	OBJ_VARIABLE(_opHasTurrets, false);
	OBJ_VARIABLE(_turrets, [DRIVER_TURRET_PATH]);
	OBJ_VARIABLE(_cameraType, "");
	OBJ_VARIABLE(_hasGoPro, false);
	OBJ_VARIABLE(_canFeed, false);
	OBJ_VARIABLE(_classType, "");
	OBJ_VARIABLE(_objClass, "");
	OBJ_VARIABLE(_monitorsSet, createHashMap);
	OBJ_VARIABLE(_tiTable, createHashMap);
	OBJ_VARIABLE(_nvgTable, createHashMap);
	OBJ_VARIABLE(_operatorSet, false);
	OBJ_VARIABLE(_isFeeding, false);
	OBJ_VARIABLE(_isDroneFeed, false);	
	OBJ_VARIABLE(_staticCamOffset, NULL_VECTOR);	
	OBJ_VARIABLE(_opSides, []);	
	OBJ_VARIABLE(_turretsParams, createHashMap);	
	OBJ_VARIABLE(_opCameraPosFunc, CAM_POS_FUNC_DEF);	

	/*
		_turretsParams: [[turretIndex, [isLocal, pointParams, zoomTable, nvgTable, tiTable, isStatic, isGopro, camPosFunc]]]
		pointParams: [memPoint, [addArr, setArr]]
	*/

	METHODS

	METHOD("Init") {
		// should be executed globaly
		params[["_sides", []], ["_turrets", []], ["_hasTInNvg", [0, 0]], ["_params", []]];

		if !(IS_OBJ(_operator)) exitWith {false};

		if (_classType isEqualTo "") then {
			_classType =  [typeOf _operator] call CFM_fnc_validClassType;
		};
		if !(_classType in VALID_CLASS_TYPES) exitWith {WARN "Init Operator: Invalid class type passed"; false};
		_operator setVariable ["CFM_classType", _classType];

		_hasGoPro = _classType in [TYPE_UNIT, TYPE_HELM];
		_operator setVariable ["CFM_hasGoPro", _hasGoPro];

		_objClass = toLower (typeOf _operator);
		_operator setVariable ["CFM_objClass", _objClass];

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
		_operator setVariable ["CFM_tiTable", _tiTable];
		_operator setVariable ["CFM_nvgTable", _nvgTable];
		_operator setVariable ["CFM_canSwitchTi", _canSwitchTi];
		_operator setVariable ["CFM_canSwitchNvg", _canSwitchNvg];


		// CAM TYPE
		_cameraType = [_operator] call CFM_fnc_cameraType;
		_operator setVariable ["CFM_cameraType", _cameraType];


		// TURRETS
		["DefineTurretsParams", [_turrets]] CALL_OBJCLASS("Operator", _self);


		// SIDE
		private _defaultSide = [(getNumber (configFile >> "CfgVehicles" >> _objClass >> "side"))] call BIS_fnc_sideType;
		if !(_sides isEqualType []) then {
			_sides = [_sides];
		};
		_sides = _sides select {_x isEqualType west};
		if (_sides isEqualTo []) then {
			_sides = [_defaultSide];
		};
		_operator setVariable ["CFM_opSides", _sides];


		// ADD OP
		_operator setVariable ["CFM_isCameraSet", true];
		["addOperator", [_operator]] CALL_CLASS("DbHandler");

		switch (_cameraType) do {
			case DRONETYPE: {
				_operator setVariable ["CFM_canFeed", true];
				_operator setVariable ["CFM_isDroneFeed", true];
			};
			case TYPE_VEH: {
				_operator setVariable ["CFM_canFeed", true];
				_operator setVariable ["CFM_isVehFeed", true];
			};
			default {};
		};
		_operator setVariable ["CFM_operatorSet", true];

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
		_operator setVariable ["CFM_opHasTurrets", _opHasTurrets]; 

		private _turrets = [];
		{
			private _turret = _x;
			if !(_turret isEqualType []) then {
				_turret = [_turret];
			};
			_turret params [["_turretIndex", -1], ["_params", []]];
			_turretIndex = TURRET_INDEX(_turretIndex);
			_turrets pushBackUnique _turretIndex;
		} forEach _turretsParamsInit;

		_operator setVariable ["CFM_turrets", _turrets]; 

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

		_turretsParams
	};
	METHOD("setTurretParams") {
		params [["_turretIndex", -1], ["_setZoomTable", []], ["_setNvgAndTi", []], ["_pointParams", []], ["_isStatic", false]];

		_turretIndex = TURRET_INDEX(_turretIndex);
		private _turretParams = _turretsParams getOrDefault [_turretIndex, createHashMap];

		// POINT ALIGNMENT
		if (_pointParams isEqualTo false) then {
			_isStatic = true;
		};
		if (!_isStatic && {((_pointParams isEqualType []) && {!(_pointParams isEqualTo [])})}) then {
			_pointParams params [["_memPoint", ""], ["_alignment", []]];
			_alignment params [["_addArr", []], ["_setArr", []]];
			[_operator, [_turretIndex, _addArr, _memPoint, _setArr]] call CFM_fnc_setPointAlignment;
		};
		_turretParams set ["isStatic", _isStatic];

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
					default {_zoomTable};
				});
			};
		};
		private _zooms = (keys _zoomTable) select {_x isEqualType 1};
		_zooms sort false;
		private _max = if (count _zooms != 0) then {_zooms#0} else {1};
		if (isNil "_max") then {_max = 1};
		_zoomTable set ["max", _max];
		_turretParams set ["zoomTable", _zoomTable];

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
			_self setVariable ["CFM_tiTable", _tiTable];
			_self setVariable ["CFM_nvgTable", _nvgTable];
		};

		// IS LOCAL TURRET
		private _isLocal = [_operator] call CFM_fnc_doCheckTurretLocality;
		_turretParams set ["IsTurretLocal", _isLocal];

		// CAM POS FUNC
		private _fullCrew = fullCrew [_self, "", true];
		private _isVehWithTurrets = (_fullCrew findIf {(_x#1) isEqualTo "gunner"}) != -1;
		private _isFpv = (("fpv" in _objClass) || {("crocus" in _objClass)});
		private _isDriverTurr = _turretIndex in DRIVER_TURRET_PATH;
		private _camPosFunc = if ((_isStatic && !_hasGoPro) || (_isFpv && _isDriverTurr)) then {
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
				case TYPE_VEH: {
					if (_isVehWithTurrets) then {
						CFM_fnc_camPosVehTurret
					} else {
						CFM_fnc_camPosVehStatic
					};
				};
				default {CFM_fnc_camPosVehStatic};
			};
		};
		_turretParams set ["camPosFunc", _camPosFunc];

		_turretsParams set [_turretIndex, _turretParams];
		_self setVariable ["CFM_turretsParams", _turretsParams];

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
		_self setVariable ["CFM_turretsParams", _turretsParams];

		+_res
	};
	METHOD("setDefaultPointAlignment") {
		private _pointSet = missionNamespace getVariable ["CFM_classesPointAlignmentSet", createHashMap];

		private _predefinedAlignment = _pointSet get _objClass;

		if ((isNil "_predefinedAlignment") || {!(_predefinedAlignment isEqualType createHashMap)}) then {
			_predefinedAlignment = createHashMap;
		};

		{
			private _turrIndex = TURRET_INDEX(_x);
			private _turrParams = _turretsParams getOrDefault [_turrIndex, createHashMap];
			private _pointParams = _turrParams getOrDefault ["pointParams", []];

			private _predefinedAlignmentTurr = _predefinedAlignment getOrDefault [_turrIndex, []];
			_predefinedAlignmentTurr params [["_pAddArr", []], ["_pMemPoint", ""], ["_pSetArr", []]];
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
			[_operator, [_turrIndex, _addArr, _memPoint, _setArr]] call CFM_fnc_setPointAlignment;
		} forEach _turrets;

		_predefinedAlignment
	};
	METHOD("monitorConnected") {
		// should be executed globaly
		params[["_monitor", objNull], ["_turret", [-1]], ["_caller", objNull]];

		if !(IS_OBJ(_monitor)) exitWith {};

		if (IS_OBJ(_caller) && {(local _caller)}) then {
			["addMonitor", [_monitor, _turret]] CALL_OBJCLASS("Operator", _self);
		};

		_self setVariable ["CFM_isFeeding", true];
		_monitor setVariable ["CFM_monitorCanSwitchNvg", _canSwitchNvg];
		_monitor setVariable ["CFM_monitorCanSwitchTi", _canSwitchTi];
		_monitor setVariable ["CFM_currentOpHasTurrets", _opHasTurrets];
		_monitor setVariable ["CFM_currentCameraType", _currentCameraType];
		_monitor setVariable ["CFM_currentOperatorIsDrone", _isDroneFeed];

		["TurretChanged", [_monitor, _turret, false]] CALL_OBJCLASS("Operator", _self);
	};
	METHOD("monitorDisconnected") {
		// should be executed globaly
		params[["_monitor", objNull], ["_turret", [-1]], ["_caller", objNull]];

		if (IS_OBJ(_caller) && {(local _caller)}) then {
			["removeMonitor", [_monitor, _turret]] CALL_OBJCLASS("Operator", _self);
		};
	};
	METHOD("TurretChanged") {
		params["_monitor", ["_turret", [-1]], ["_global", true]];

		private _turrIndex = if (_turret isEqualType []) then {_turret#0} else {_turret};

		if !(_turrIndex isEqualType 1) exitWith {false};

		private _turretIndex = if (_turret isEqualType []) then {_turret#0} else {_turret};
		private _turretData = _turretsParams getOrDefault [_turretIndex, createHashMap];
		private _isLocal = _turretData getOrDefault ["IsTurretLocal", false];
		private _zoomTable = _turretData getOrDefault ["zoomTable", createHashMap];
		private _isStatic = _turretData getOrDefault ["isStatic", false];
		private _pointParams = _turretData getOrDefault ["pointParams", []];
		private _camPosFunc = _turretData getOrDefault ["camPosFunc", CAM_POS_FUNC_DEF];
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

		_monitor setVariable ["CFM_zoomMax", _zoomMax, _global];
		_monitor setVariable ["CFM_zoomTable", _zoomTable, _global];
		_monitor setVariable ["CFM_cameraPosFunc", _camPosFunc, _global];
		_monitor setVariable ["CFM_turretLocal", _isLocal, _global];
		_monitor setVariable ["CFM_currentCamPointParams", _pointParams, _global];
		_monitor setVariable ["CFM_currentTiTable", _tiTable, _global];
		_monitor setVariable ["CFM_currentNvgTable", _nvgTable, _global];

		true
	};
	METHOD("addMonitor") {
		// should be executed globaly
		params[["_monitor", objNull], ["_turret", [-1]]];

		if !(IS_OBJ(_monitor)) exitWith {-1};

		private _turretIndex = _turret#0;
		private _monitorsOnTurret = _monitorsSet getOrDefault [_turretIndex, []];
		private _i = _monitorsOnTurret pushBackUnique _monitor;
		_monitorsSet set [_turretIndex, _monitorsOnTurret];
		_self setVariable ["CFM_monitorsSet", _monitorsSet, true];
		_i
	};
	METHOD("removeMonitor") {
		// should be executed globaly
		params[["_monitor", objNull], ["_turret", [-1]]];

		private _turretIndex = _turret#0;
		private _monitorsOnTurret = _monitorsSet getOrDefault [_turretIndex, []];
		_monitorsOnTurret = _monitorsOnTurret - [_monitor];
		_monitorsSet set [_turretIndex, _monitorsOnTurret];
		_self setVariable ["CFM_monitorsSet", _monitorsSet, true];
		true
	};
CLASS_END