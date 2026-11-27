#define WAIT_FOR_DISPLAY_TIME 10
#define WAIT_BEFORE_DISPLAY_UPD 0.1

#define R2T_DISPLAY_CTRL_ID 956
#define R2T_CTRL_ID 957
#define UI_CTRL_ID 958
#define UP_CTRL_ID 959
#define EFFECT_CTRL_ID 825

PRIVATE LOCAL CLASS(DisplayHandler)

	SET_SELF_VAR("_monitor");
	SET_VARS_PREFIX("_dh");

	// -----------------------------------------------
	// display handler config
	PRIVATE LOCAL FIELD ["_monitorInstanceId", -1];
	PRIVATE LOCAL FIELD ["_textureSelection", NO_TEXTURE_SELECTION];
	PRIVATE LOCAL FIELD ["_monitorUid", ""];
	PRIVATE LOCAL FIELD ["_monitorR2Tid", ""];
	PRIVATE LOCAL FIELD ["_originalTexture", ""];
	PRIVATE LOCAL FIELD ["_isHandMonitor", false];
	PRIVATE LOCAL FIELD ["_turnedOffLocal", false];
	// -----------------------------------------------

	// -----------------------------------------------
	// display & UI controls
	PRIVATE LOCAL FIELD ["_mainDisplay", displayNull];
	PRIVATE LOCAL FIELD ["_displayUiCtrl", controlNull];
	PRIVATE LOCAL FIELD ["_displayUpLayerCtrl", controlNull];
	PRIVATE LOCAL FIELD ["_uiIndex", 0];
	PRIVATE LOCAL FIELD ["_uiDisplayUniqueName", ""];
	PRIVATE LOCAL FIELD ["_uiCtrlCurrentUIDisplay", displayNull];
	PRIVATE LOCAL FIELD ["_uiCtrlUIDisplayName", ""];
	PRIVATE LOCAL FIELD ["_uiCtrlCurrentUIDisplayClass", ""];
	// -----------------------------------------------

	// -----------------------------------------------
	// R2T display & controls
	PRIVATE LOCAL FIELD ["_r2tDisplay", displayNull];
	PRIVATE LOCAL FIELD ["_r2tDisplayName", ""];
	PRIVATE LOCAL FIELD ["_r2tDisplayCtrl", controlNull];
	PRIVATE LOCAL FIELD ["_r2tDisplayR2TCtrl", controlNull];
	// -----------------------------------------------

	// -----------------------------------------------
	// effects layers
	PRIVATE LOCAL FIELD ["_effectsLayersControls", []];
	PRIVATE LOCAL FIELD ["_effectsLayersCount", 0];
	// -----------------------------------------------

	// -----------------------------------------------
	// feed & operator UI state
	PRIVATE LOCAL FIELD ["_connectedOperator", objNull];
	PRIVATE LOCAL FIELD ["_currentFeedIsDisplay", false];
	PRIVATE LOCAL FIELD ["_currentPiPEffect", 0];
	PRIVATE LOCAL FIELD ["_currentUiClasname", ""];
	PRIVATE LOCAL FIELD ["_uiParams", []];
	PRIVATE LOCAL FIELD ["_currentUIDisplayRenderClass", ""];
	PRIVATE LOCAL FIELD ["_currentOperatorSignalFunction", {1}];
	PRIVATE LOCAL FIELD ["_currentOperatorInterfaceFunction", {}];
	PRIVATE LOCAL FIELD ["_currentOperatorInterfaceClass", {}];
	PRIVATE LOCAL FIELD ["_currentOperatorEffectsFunction", {}];
	// -----------------------------------------------

	//----------- Internal -----------
	METHOD("Init") {
		params [["_monInstId", -1]];
		_monitorInstanceId = _monInstId;
		SET_SELFVAR(_monitorInstanceId);

		_textureSelection = MON_GVAR(_monitor, _monitorInstanceId, "CFM_textureSelection", NO_TEXTURE_SELECTION);
		_originalTexture = MON_GVAR(_monitor, _monitorInstanceId, "CFM_originalTexture", "");
		_isHandMonitor = MON_GVAR(_monitor, _monitorInstanceId, "CFM_isHandMonitor", false);
		SET_SELFVAR(_textureSelection);
		SET_SELFVAR(_originalTexture);
		SET_SELFVAR(_isHandMonitor);

		_monitorUid = ["createMonitorUId", [_monitor, _monitorInstanceId]] CALL_CLASS("DbHandler");
		SET_SELFVAR(_monitorUid);
		MON_SVAR(_monitor, _monitorInstanceId, "CFM_monitorUid", _monitorUid);

		_monitorR2Tid = ["createMonitorR2TId", [_monitor, _monitorInstanceId]] CALL_CLASS("DbHandler");
		SET_SELFVAR(_monitorR2Tid);
		MON_SVAR(_monitor, _monitorInstanceId, "CFM_monitorR2Tid", _monitorR2Tid);
	};
	METHOD("updateDisplays") {
		displayUpdate _mainDisplay;
		displayUpdate _r2tDisplay;
		displayUpdate _uiCtrlCurrentUIDisplay;
	};
	METHOD("clearVariables") {
		params[["_reset", false]];
		_mainDisplay = displayNull;
		SET_SELFVAR(_mainDisplay);
		MON_SVAR(_monitor, _monitorInstanceId, "CFM_mainDisplay", nil);
		if !(_reset) then {
			_currentOperatorInterfaceFunction = {};
			_currentOperatorSignalFunction = {1};
			_currentOperatorEffectsFunction = {};
			_r2tDisplayCtrl = controlNull;
			_effectsLayersControls = [];
			_uiParams = [];
			_currentUiClasname = "";
			_currentFeedIsDisplay = false;
			SET_SELFVAR(_currentOperatorInterfaceFunction);
			SET_SELFVAR(_currentOperatorSignalFunction);
			SET_SELFVAR(_currentOperatorEffectsFunction);
			SET_SELFVAR(_r2tDisplayCtrl);
			SET_SELFVAR(_effectsLayersControls);
			SET_SELFVAR(_uiParams);
			SET_SELFVAR(_currentUiClasname);
			SET_SELFVAR(_currentFeedIsDisplay);

			MON_SVAR(_monitor, _monitorInstanceId, "CFM_currentOperatorInterfaceFunction", nil);
			MON_SVAR(_monitor, _monitorInstanceId, "CFM_currentOperatorSignalFunction", nil);
			MON_SVAR(_monitor, _monitorInstanceId, "CFM_currentOperatorEffectsFunction", nil);
			MON_SVAR(_monitor, _monitorInstanceId, "CFM_r2tDisplayCtrl", nil);
			MON_SVAR(_monitor, _monitorInstanceId, "CFM_effectsLayersControls", nil);
			MON_SVAR(_monitor, _monitorInstanceId, "CFM_uiParams", nil);
			MON_SVAR(_monitor, _monitorInstanceId, "CFM_currentUiClasname", nil);
			MON_SVAR(_monitor, _monitorInstanceId, "CFM_currentFeedIsDisplay", nil);
		};
	};
	METHOD("resetRenderEffects") {
		{
			_x ctrlSetText ("");
			_x ctrlCommit 0;
		} forEach _effectsLayersControls;
	};
	//----------- State set -----------
	// generic
	METHOD("startRendering") {
		params[["_reset", false], ["_uiParamsArg", []]];

		if (!hasInterface) exitWith {};

		_uiParams = +_uiParamsArg;
		SET_SELFVAR(_uiParams);
		MON_SVAR(_monitor, _monitorInstanceId, "CFM_uiParams", +_uiParams);

		private _doUiParams = !(missionNamespace getVariable ["CFM_useR2Tsystem", false]) && {!(_uiParams isEqualTo []) && {(_uiParams isEqualType [])}};
		_currentFeedIsDisplay = _doUiParams;
		SET_SELFVAR(_currentFeedIsDisplay);
		MON_SVAR(_monitor, _monitorInstanceId, "CFM_currentFeedIsDisplay", _doUiParams);

		private _camera = MON_GVAR(_monitor, _monitorInstanceId, "CFM_currentFeedCam", objNull);
		_camera cameraEffect ["Internal", "BACK", _monitorR2Tid];

		_turnedOffLocal = MON_GVAR(_monitor, _monitorInstanceId, "CFM_turnedOffLocal", false);
		SET_SELFVAR(_turnedOffLocal);
		if (_turnedOffLocal) exitWith {};

		if (!_isHandMonitor && {_doUiParams}) then {
			["startRenderingUI", _reset] SPAWN_SELF;
		} else {
			["startRenderingR2T", _reset] CALL_SELF;
		};
	};
	METHOD("stopRendering") {
		params[["_reset", false]];

		if (!hasInterface) exitWith {};
		if (_currentFeedIsDisplay) then {
			if (canSuspend) then {
				["stopRenderingUI", [_reset]] CALL_SELF;
			} else {
				["stopRenderingUI", [_reset]] SPAWN_SELF;
			};
		} else {
			["stopRenderingR2T"] CALL_SELF;
			["clearVariables", _reset] CALL_SELF;
		};
	};
	METHOD("toggleMonitorLocal") {
		params[["_on", true, [true]]];

		_turnedOffLocal = !_on;
		SET_SELFVAR(_turnedOffLocal);
		MON_SVAR(_monitor, _monitorInstanceId, "CFM_turnedOffLocal", _turnedOffLocal);

		if (missionNamespace getVariable ["CFM_useR2Tsystem", false]) then {
			if (_on) then {
				[[_monitor, _monitorInstanceId], true, _monitorR2Tid] call CFM_fnc_setR2TTexture;
			} else {
				[[_monitor, _monitorInstanceId], false, "", true] call CFM_fnc_setR2TTexture;
			};
		} else {
			private _prevHndl = MON_GVAR(_monitor, _monitorInstanceId, "CFM_monitorMainHndl", scriptNull);
			if (!isNull _prevHndl && {!(scriptDone _prevHndl)}) then {
				terminate _prevHndl;
			};
			private _hndl = if (_on) then {
				["startRendering", [true, _uiParams]] SPAWN_SELF
			} else {
				["stopRendering", [true]] SPAWN_SELF
			};
			MON_SVAR(_monitor, _monitorInstanceId, "CFM_monitorMainHndl", _hndl);
		};
	};
	// UI render version
	METHOD("setupDisplay") {
		params[["_reset", false]];

		private _monPair = [_monitor, _monitorInstanceId];
		private _screenRes = [_monPair] call CFM_fnc_getMonitorScreenResolution;
		private _uiDisplaysMap = uiNamespace getVariable ["CFM_uiDisplayMonitorsMap", createHashMap];
		_uiDisplaysMap set [_monitorUid, _monPair];
		uiNamespace setVariable ["CFM_uiDisplayMonitorsMap", _uiDisplaysMap];

		private _size = missionNamespace getVariable ["CFM_displaySize", 1024];
		if (_textureSelection >= 0) then {
			_monitor setObjectTexture [_textureSelection, format["#(rgb,%1,%1,1)ui(RscDisplayMainDisplayCFM,%2)", _size, _monitorUid]];
		};

		private _waitStart = time;
		waitUntil {
			!(isNull (findDisplay _monitorUid)) ||
			{(time - _waitStart) > WAIT_FOR_DISPLAY_TIME}
		};
		_mainDisplay = findDisplay _monitorUid;

		if (isNull _mainDisplay) exitWith {
			format["DisplayHandler.setupDisplay: ERROR: can't create main display for monitor: %1", _monPair] WARN
		};
		_mainDisplay setVariable ["CFM_monitor", _monPair];
		_mainDisplay setVariable ["CFM_screenResolution", _screenRes];

		// control that renders picture of r2t display
		_r2tDisplayCtrl = _mainDisplay ctrlCreate ["RscPicture", R2T_DISPLAY_CTRL_ID];
		_r2tDisplayName = _monitorUid + "r2t";
		_uiDisplaysMap set [_r2tDisplayName, _monPair];
		_r2tDisplayCtrl ctrlSetPosition [0, 0, 1, 1];
		_r2tDisplayCtrl ctrlSetText (format ["#(rgb,%1,%1,1)ui(RscDisplayR2TDisplayCFM,%2)", _size, _r2tDisplayName]);
		_r2tDisplayCtrl ctrlCommit 0;

		_waitStart = time;
		waitUntil {
			!(isNull (findDisplay _r2tDisplayName)) ||
			{(time - _waitStart) > WAIT_FOR_DISPLAY_TIME}
		};
		_r2tDisplay = findDisplay _r2tDisplayName;

		if (isNull _r2tDisplay) exitWith {
			format["DisplayHandler.setupDisplay: ERROR: can't create r2t display for monitor: %1", _monPair] WARN
		};
		_r2tDisplay setVariable ["CFM_monitor", _monPair];
		_r2tDisplay setVariable ["CFM_screenResolution", _screenRes];

		// control that renders r2t picture on r2t display
		_r2tDisplayR2TCtrl = _r2tDisplay ctrlCreate ["RscPicture", R2T_CTRL_ID];
		_r2tDisplayR2TCtrl ctrlSetPosition [0, 0, 1, 1];
		_r2tDisplayR2TCtrl ctrlCommit 0;

		_effectsLayersCount = missionNamespace getVariable ["CFM_displayEffectLayerCount", 3];
		for "_i" from 1 to (_effectsLayersCount) do {
			private _effectCtrl = _mainDisplay ctrlCreate ["RscPicture", EFFECT_CTRL_ID + _i];
			_effectCtrl ctrlSetPosition [0, 0, 1, 1];
			_effectCtrl ctrlCommit 0;
			_effectsLayersControls pushBack _effectCtrl;
		};

		_displayUiCtrl = _mainDisplay ctrlCreate ["RscPicture", UI_CTRL_ID];
		_displayUiCtrl ctrlSetPosition [0, 0, 1, 1];
		_displayUiCtrl ctrlCommit 0;

		_displayUpLayerCtrl = _mainDisplay ctrlCreate ["RscPicture", UP_CTRL_ID];
		_displayUpLayerCtrl ctrlSetPosition [0, 0, 1, 1];
		_displayUpLayerCtrl ctrlCommit 0;

		SET_SELFVAR(_mainDisplay);
		SET_SELFVAR(_r2tDisplay);
		SET_SELFVAR(_r2tDisplayName);
		SET_SELFVAR(_r2tDisplayR2TCtrl);
		SET_SELFVAR(_effectsLayersCount);
		SET_SELFVAR(_effectsLayersControls);
		SET_SELFVAR(_displayUiCtrl);
		SET_SELFVAR(_displayUpLayerCtrl);

		MON_SVAR(_monitor, _monitorInstanceId, "CFM_mainDisplay", _mainDisplay);
		MON_SVAR(_monitor, _monitorInstanceId, "CFM_r2tDisplayCtrl", _r2tDisplayCtrl);
		MON_SVAR(_monitor, _monitorInstanceId, "CFM_effectsLayersControls", _effectsLayersControls);

		_uiCtrlUIDisplayName = _monitorUid + "ui";
		SET_SELFVAR(_uiCtrlUIDisplayName);

		uiSleep WAIT_BEFORE_DISPLAY_UPD;

		["stopRenderingUI"] CALL_SELF;
	};
	METHOD("startRenderingUI") {
		params[["_reset", false], ["_ctrl", controlNull], ["_uiParamsSet", []]];

		_uiParams params [
			["_displayClass", ""],
			["_interfaceFunc", {}],
			["_interfaceInitFunc", {}],
			["_effectFunc", {}],
			["_signalFunc", {1}],
			["_isExplicitHud", false],
			["_customBindings", []]
		];

		private _monPair = [_monitor, _monitorInstanceId];
		private _lockWaitStart = diag_tickTime;
		waitUntil {
			!(uiNamespace getVariable ["CFM_creatingUiDisplayLock", false]) ||
			{(diag_tickTime - _lockWaitStart) > WAIT_FOR_DISPLAY_TIME}
		};
		uiNamespace setVariable ["CFM_creatingUiDisplayLock", true];
		uiNamespace setVariable ["CFM_creatingUiMonitor", _monPair];

		private _screenRes = [_monPair] call CFM_fnc_getMonitorScreenResolution;
		private _size = missionNamespace getVariable ["CFM_displaySize", 1024];
		private _resW = (_screenRes param [0, DEFAULT_UI_SIZE_W]) max 1;
		private _resH = (_screenRes param [1, DEFAULT_UI_SIZE_H]) max 1;
		private _resAspect = _resW / _resH;
		private _texW = _size;
		private _texH = _size;
		if (_resAspect >= 1.5) then {
			if (_size < 2048) then {
				_texW = _size * 2;
				_texH = _size;
			} else {
				_texW = _size;
				_texH = (_size / 2) max 256;
			};
		} else {
			if (_resAspect <= 0.67) then {
				if (_size < 2048) then {
					_texW = _size;
					_texH = _size * 2;
				} else {
					_texW = (_size / 2) max 256;
					_texH = _size;
				};
			};
		};
		_uiDisplayUniqueName = _monitorUid + str _uiIndex;

		private _uiDisplaysMap = uiNamespace getVariable ["CFM_uiDisplayMonitorsMap", createHashMap];
		_uiDisplaysMap set [_uiDisplayUniqueName, _monPair];
		uiNamespace setVariable ["CFM_uiDisplayMonitorsMap", _uiDisplaysMap];

		([_displayClass] call CFM_fnc_resolveDisplayConfig) params ["_resolvedCfg", "", "", "", "_isNativeCfm"];
		private _hostDisplayClass = if (_isNativeCfm) then {_displayClass} else {"RscDisplayR2TDisplayCFM"};

		if !(isNull _ctrl) then {
			_ctrl ctrlSetText (format["#(argb,%1,%2,1)ui(%3,%4)", _texW, _texH, _hostDisplayClass, _uiDisplayUniqueName]);
		} else {
			if (_textureSelection >= 0) then {
				_monitor setObjectTexture [_textureSelection, format["#(argb,%1,%2,1)ui(%3,%4)", _texW, _texH, _hostDisplayClass, _uiDisplayUniqueName]];
			};
		};

		private _waitStart = time;
		waitUntil {
			!(isNull (findDisplay _uiDisplayUniqueName)) ||
			{(time - _waitStart) > WAIT_FOR_DISPLAY_TIME}
		};
		_mainDisplay = findDisplay _uiDisplayUniqueName;
		uiNamespace setVariable ["CFM_creatingUiDisplayLock", false];

		if (isNull _mainDisplay) exitWith {
			format["DisplayHandler.startRenderingUI: ERROR: can't create main display for monitor: %1", _monPair] WARN
		};
		_mainDisplay setVariable ["CFM_monitor", _monPair];
		_mainDisplay setVariable ["CFM_screenResolution", _screenRes];
		_mainDisplay setVariable ["CFM_uiTexResolution", [_texW, _texH]];
		_mainDisplay setVariable ["CFM_dynamicHudClass", _displayClass];
		_mainDisplay setVariable ["CFM_dynamicHudExplicit", _isExplicitHud];
		_mainDisplay setVariable ["CFM_hudCustomBindings", _customBindings];

		private _initRes = if (_isNativeCfm) then {
			if !(_interfaceInitFunc isEqualTo {}) then {
				[_monitor, _mainDisplay, _uiDisplayUniqueName] call _interfaceInitFunc
			} else {
				[_monitor, _mainDisplay, _uiDisplayUniqueName] call (missionNamespace getVariable ["CFM_fnc_drone_initInterface", {}])
			}
		} else {
			if !(isNull _resolvedCfg) then {
				private _dynRes = [_monPair, _mainDisplay, _displayClass, _uiDisplayUniqueName, _isExplicitHud] call CFM_fnc_buildDynamicDisplay;
				private _dynInitFnc = missionNamespace getVariable ["CFM_fnc_initDynamicHud", {}];
				private _droneInitFnc = missionNamespace getVariable ["CFM_fnc_drone_initInterface", {}];
				if (
					!(_interfaceInitFunc isEqualTo {}) &&
					{!(_interfaceInitFunc isEqualTo _dynInitFnc)} &&
					{!(_interfaceInitFunc isEqualTo _droneInitFnc)}
				) then {
					[_monitor, _mainDisplay, _uiDisplayUniqueName] call _interfaceInitFunc;
				};
				private _droneUpdFnc = missionNamespace getVariable ["CFM_fnc_drone_updateInterface", {}];
				if ((_interfaceFunc isEqualTo {}) || {_interfaceFunc isEqualTo _droneUpdFnc}) then {
					_interfaceFunc = missionNamespace getVariable ["CFM_fnc_updateDynamicHud", {}];
				};
				_dynRes
			} else {
				format["DisplayHandler.startRenderingUI: WARN: display class '%1' not found, falling back to raw R2T", _displayClass] WARN;
				[_monitor, _mainDisplay, _uiDisplayUniqueName] call (missionNamespace getVariable ["CFM_fnc_drone_initInterface", {}])
			}
		};

		_uiIndex = _uiIndex + 1;
		_currentUiClasname = _displayClass;
		_currentOperatorInterfaceFunction = _interfaceFunc;
		_currentOperatorSignalFunction = _signalFunc;
		_currentOperatorEffectsFunction = _effectFunc;

		SET_SELFVAR(_uiDisplayUniqueName);
		SET_SELFVAR(_uiIndex);
		SET_SELFVAR(_mainDisplay);
		SET_SELFVAR(_currentUiClasname);
		SET_SELFVAR(_currentOperatorInterfaceFunction);
		SET_SELFVAR(_currentOperatorSignalFunction);
		SET_SELFVAR(_currentOperatorEffectsFunction);

		MON_SVAR(_monitor, _monitorInstanceId, "CFM_uiDisplayUniqueName", _uiDisplayUniqueName);
		MON_SVAR(_monitor, _monitorInstanceId, "CFM_uiIndex", _uiIndex);
		MON_SVAR(_monitor, _monitorInstanceId, "CFM_mainDisplay", _mainDisplay);
		MON_SVAR(_monitor, _monitorInstanceId, "CFM_currentUiClasname", _displayClass);
		MON_SVAR(_monitor, _monitorInstanceId, "CFM_currentOperatorInterfaceFunction", _interfaceFunc);
		MON_SVAR(_monitor, _monitorInstanceId, "CFM_currentOperatorSignalFunction", _signalFunc);
		MON_SVAR(_monitor, _monitorInstanceId, "CFM_currentOperatorEffectsFunction", _effectFunc);

		_initRes params [["_r2tDisplayCtrlNew", controlNull], ["_effectsLayersControlsNew", []]];
		_r2tDisplayCtrl = _r2tDisplayCtrlNew;
		_effectsLayersControls = _effectsLayersControlsNew;
		{
			if !(isNull _x) then {
				if ((ctrlText _x) isEqualTo "") then {
					_x ctrlShow true;
					_x ctrlCommit 0;
				};
			};
		} forEach _effectsLayersControls;
		SET_SELFVAR(_r2tDisplayCtrl);
		SET_SELFVAR(_effectsLayersControls);
		MON_SVAR(_monitor, _monitorInstanceId, "CFM_r2tDisplayCtrl", _r2tDisplayCtrl);
		MON_SVAR(_monitor, _monitorInstanceId, "CFM_effectsLayersControls", _effectsLayersControls);

		_size = missionNamespace getVariable ["CFM_r2tSize", 512];
		_r2tDisplayCtrl ctrlSetText (format ["#(argb,%1,%1,1)r2t(%2,1.0)", _size, _monitorR2Tid]);
		_r2tDisplayCtrl ctrlCommit 0;

		[_monPair, MON_GVAR(_monitor, _monitorInstanceId, "CFM_currentPiPEffect", _currentPiPEffect), false] call CFM_fnc_setMonitorPiPEffect;
	};
	METHOD("stopRenderingUI") {
		params[["_reset", true]];

		private _disp = MON_GVAR(_monitor, _monitorInstanceId, "CFM_mainDisplay", _mainDisplay);
		if (!isNull _disp) then {
			_disp closeDisplay 1;
			waitUntil {isNull _disp};
		};
		["stopRenderingR2T"] CALL_SELF;
		["clearVariables", _reset] CALL_SELF;
	};
	METHOD("renderInterface") {
		params[["_operator", _connectedOperator]];

	};
	// R2T render version
	METHOD("startRenderingR2T") {
		params[["_reset", false]];

		["setR2TTexture", [true, _monitorR2Tid]] CALL_SELF;

		[[_monitor, _monitorInstanceId], MON_GVAR(_monitor, _monitorInstanceId, "CFM_currentPiPEffect", _currentPiPEffect), false] call CFM_fnc_setMonitorPiPEffect;
	};
	METHOD("stopRenderingR2T") {
		["setR2TTexture", [false]] CALL_SELF;
	};
	METHOD("setR2TTexture") {
		params[["_render", true], ["_r2t", ""], ["_turnOff", false]];

		if (_render && {_r2t isEqualTo ""}) then {
			_r2t = _monitorR2Tid;
		};
		_render = _render && !(_r2t isEqualTo "");
		if (MON_GVAR(_monitor, _monitorInstanceId, "CFM_isHandMonitor", _isHandMonitor) isEqualTo true) exitWith {
			[[_monitor, _monitorInstanceId], _render] call CFM_fnc_setHandDisplay;
		};

		if (_textureSelection < 0) exitWith {};
		if (_render) then {
			private _size = missionNamespace getVariable ["CFM_r2tSize", 512];
			_monitor setObjectTexture [_textureSelection, format["#(argb,%1,%1,1)r2t(%2,1.0)", _size, _r2t]];
		} else {
			_monitor setObjectTexture [_textureSelection, _originalTexture];
		};
	};
	// set renders
	METHOD("setSignalInterfaceEffectFuncs") {
		params[["_signalFuncName", ""], ["_effectFuncName", ""], ["_interfaceFuncName", ""]];

		private _set = false;
		if (IS_STR(_signalFuncName)) then {
			private _signalFunc = missionNamespace getVariable _signalFuncName;
			if (isNil "_signalFunc") exitWith {};
			if !(_signalFunc isEqualType {}) exitWith {};
			private _testFuncRes = [_selfObj, player] call _signalFunc;
			if (isNil "_testFuncRes") exitWith {false};
			if !(_testFuncRes isEqualType 1) exitWith {false};
			_currentOperatorSignalFunction = _signalFunc;
			SET_SELFVAR(_currentOperatorSignalFunction);
			MON_SVAR(_monitor, _monitorInstanceId, "CFM_currentOperatorSignalFunction", _signalFunc);
			_set = true;
		};
		if (IS_STR(_interfaceFuncName)) then {
			private _interfaceFunc = missionNamespace getVariable _interfaceFuncName;
			if (isNil "_interfaceFunc") exitWith {};
			if !(_interfaceFunc isEqualType {}) exitWith {};
			_currentOperatorInterfaceFunction = _interfaceFunc;
			SET_SELFVAR(_currentOperatorInterfaceFunction);
			MON_SVAR(_monitor, _monitorInstanceId, "CFM_currentOperatorInterfaceFunction", _interfaceFunc);
			_set = true;
		};
		if (IS_STR(_effectFuncName)) then {
			private _effectFunc = missionNamespace getVariable _effectFuncName;
			if (isNil "_effectFunc") exitWith {};
			if !(_effectFunc isEqualType {}) exitWith {};
			_currentOperatorEffectsFunction = _effectFunc;
			SET_SELFVAR(_currentOperatorEffectsFunction);
			MON_SVAR(_monitor, _monitorInstanceId, "CFM_currentOperatorEffectsFunction", _effectFunc);
			_set = true;
		};
		_set
	};
	METHOD("setRenderR2TDisplay") {
		params[["_set", false]];
		if (_set) then {
			private _size = missionNamespace getVariable ["CFM_r2tSize", 512];
			_r2tDisplayR2TCtrl ctrlSetText (format ["#(argb,%1,%1,1)r2t(%2,1.0)", _size, _monitorR2Tid]);
		} else {
			_r2tDisplayR2TCtrl ctrlSetText ("");
		};
		_r2tDisplayR2TCtrl ctrlCommit 0;
	};
	METHOD("setRenderInterfaceDisplay") {
		params[["_set", false], ["_currentUIDisplayRenderClass", ""], ["_currentUIDisplayRenderClassInit", ""]];
		private _monPair = [_monitor, _monitorInstanceId];
		_set = _set && {!(_currentUIDisplayRenderClass isEqualTo "")};
		if (_set) then {
			private _uiDisplaysMap = uiNamespace getVariable ["CFM_uiDisplayMonitorsMap", createHashMap];
			_uiDisplaysMap set [_uiCtrlUIDisplayName, _monPair];
			uiNamespace setVariable ["CFM_uiDisplayMonitorsMap", _uiDisplaysMap];

			private _size = missionNamespace getVariable ["CFM_displaySize", 1024];
			_displayUiCtrl ctrlSetText (format ["#(rgb,%1,%1,1)ui(%2,%3)", _size, _currentUIDisplayRenderClass, _uiCtrlUIDisplayName]);
		} else {
			_currentUIDisplayRenderClass = "";
			_displayUiCtrl ctrlSetText ("");
		};
		SET_SELFVAR(_currentUIDisplayRenderClass);
		_currentOperatorInterfaceClass = _currentUIDisplayRenderClass;
		SET_SELFVAR(_currentOperatorInterfaceClass);

		// init display func
		_currentUIDisplayRenderClassInit = if !(_currentUIDisplayRenderClassInit isEqualType {}) then {
			if !(IS_STR(_currentUIDisplayRenderClassInit)) exitWith {{}};
			missionNamespace getVariable [_currentUIDisplayRenderClassInit, {}];
		} else {_currentUIDisplayRenderClassInit};
		if (_currentUIDisplayRenderClassInit isEqualType {}) then {
			_uiCtrlUIDisplayName spawn _currentUIDisplayRenderClassInit;
		};

		[_selfObj, _monitorInstanceId, _instanceIndex, _uiCtrlUIDisplayName] spawn {
			params ["_selfObj", "_monInstId", "_dhInstId", "_uiCtrlUIDisplayName"];

			private _waitStart = time;
			waitUntil {
				!(isNull (findDisplay _uiCtrlUIDisplayName)) ||
				{(time - _waitStart) > WAIT_FOR_DISPLAY_TIME}
			};
			private _monPair = [_selfObj, _monInstId];
			private _display = findDisplay _uiCtrlUIDisplayName;
			if !(isNull _display) then {
				_display setVariable ["CFM_monitor", _monPair];
				_display setVariable ["CFM_screenResolution", [_monPair] call CFM_fnc_getMonitorScreenResolution];
			};

			MON_SVAR(_selfObj, _dhInstId, "CFM_dh_uiCtrlCurrentUIDisplay", _display);
			MON_SVAR(_selfObj, _monInstId, "CFM_uiCtrlCurrentUIDisplay", _display);
		};

		_displayUiCtrl ctrlCommit 0;
	};
	METHOD("setRenderUpLayer") {
		params[["_set", false]];
		if (_set) then {
			["setOriginalTexture"] CALL_SELF;
		} else {
			_displayUpLayerCtrl ctrlSetText "";
			_displayUiCtrl ctrlCommit 0;
		};
	};
	//----------- Config set -----------
	METHOD("setOriginalTexture") {
		_displayUpLayerCtrl ctrlSetText _originalTexture;
		_displayUpLayerCtrl ctrlCommit 0;
	};
CLASS_END
