#define WAIT_FOR_DISPLAY_TIME 10
#define WAIT_BEFORE_DISPLAY_UPD 0.1

#define R2T_DISPLAY_CTRL_ID 956
#define R2T_CTRL_ID 957
#define UI_CTRL_ID 958
#define UP_CTRL_ID 959
#define EFFECT_CTRL_ID 825

OBJCLASS(DisplayHandler)

	SET_SELF_VAR("_monitor");

	FIELD ["_monitorUid", ""];
	FIELD ["_monitorR2Tid", ""];
	FIELD ["_originalTexture", ""];
	FIELD ["_mainDisplay", displayNull];
	FIELD ["_r2tDisplayName", ""];
	FIELD ["_r2tDisplay", displayNull];
	FIELD ["_r2tDisplayCtrl", controlNull];
	FIELD ["_displayUiCtrl", controlNull];
	FIELD ["_uiCtrlCurrentUIDisplay", displayNull];
	FIELD ["_uiCtrlUIDisplayName", ""];
	FIELD ["_uiCtrlCurrentUIDisplayClass", ""];
	FIELD ["_displayUpLayerCtrl", controlNull];
	FIELD ["_r2tDisplayR2TCtrl", controlNull];
	FIELD ["_effectsLayersControls", []];
	FIELD ["_effectsLayersCount", 0];
	FIELD ["_turnedOffLocal", false];
	
	FIELD ["_connectedOperator", objNull];
	FIELD ["_currentPiPEffect", 0];
	FIELD ["_currentOperatorSignalFunction", {1}];
	FIELD ["_currentOperatorInterfaceFunction", {}];
	FIELD ["_currentOperatorInterfaceClass", {}];
	FIELD ["_currentOperatorEffectsFunction", {}];
	FIELD ["_currentUIDisplayRenderClass", ""];

	METHOD("Init") {
		_monitorUid = ["createMonitorUId", _monitor] CALL_CLASS("DbHandler");
		_monitor setVariable ["CFM_monitorUid", _monitorUid];
		_monitorR2Tid = ["createMonitorR2TId", _monitor] CALL_CLASS("DbHandler");
		_monitor setVariable ["CFM_monitorR2Tid", _monitorR2Tid];

		if !(missionNamespace getVariable ["CFM_useR2Tsystem", false]) then {
			["setupDisplay"] SPAWN_OBJCLASS("DisplayHandler", _monitor);
		};
	};
	METHOD("startRendering") {
		params[["_reset", false]];

		if (missionNamespace getVariable ["CFM_useR2Tsystem", false]) then {
			["startRenderingR2T", _reset] CALL_OBJCLASS("DisplayHandler", _monitor);
		} else {
			["startRenderingUI", _reset] SPAWN_OBJCLASS("DisplayHandler", _monitor);
		};
	};
	METHOD("stopRendering") {
		if (missionNamespace getVariable ["CFM_useR2Tsystem", false]) then {
			["stopRenderingR2T"] CALL_OBJCLASS("DisplayHandler", _monitor);
		} else {
			["stopRenderingUI"] CALL_OBJCLASS("DisplayHandler", _monitor);
		};
	};
	//----------- UI render version -----------
	METHOD("setupDisplay") {
		params[["_reset", false]];

		private _size = missionNamespace getVariable ["CFM_displaySize", 1024];
		_monitor setObjectTexture [0, format["#(rgb,%1,%1,1)ui(RscDisplayMainDisplayCFM,%2)", _size, _monitorUid]];  

		private _waitStart = time;
		waitUntil {
			!(isNull (findDisplay _monitorUid)) ||
			{(time - _waitStart) > WAIT_FOR_DISPLAY_TIME}
		};
		_mainDisplay = findDisplay _monitorUid;

		if (isNull _mainDisplay) exitWith {
			format["DisplayHandler.setupDisplay: ERROR: can't create main display for monitor: %1", _self] WARN
		};

		// control that renders picture of r2t display
		private _r2tDisplayCtrl = _mainDisplay ctrlCreate ["RscPicture", R2T_DISPLAY_CTRL_ID];
		private _r2tDisplayName = _monitorUid + "r2t";
		_r2tDisplayCtrl ctrlSetPosition [0, 0, 1, 1];
		_r2tDisplayCtrl ctrlSetText (format ["#(rgb,%1,%1,1)ui(RscDisplayR2TDisplayCFM,%2)", _size, _r2tDisplayName]);
		_r2tDisplayCtrl ctrlCommit 0;

		private _waitStart = time;
		waitUntil {
			displayUpdate _mainDisplay;
			!(isNull (findDisplay _r2tDisplayName)) ||
			{(time - _waitStart) > WAIT_FOR_DISPLAY_TIME}
		};
		_r2tDisplay = findDisplay _r2tDisplayName;

		if (isNull _r2tDisplay) exitWith {
			format["DisplayHandler.setupDisplay: ERROR: can't create r2t display for monitor: %1", _self] WARN
		};

		// control that renders r2t picture on r2t display
		private _r2tDisplayR2TCtrl = _r2tDisplay ctrlCreate ["RscPicture", R2T_CTRL_ID];
		_r2tDisplayR2TCtrl ctrlSetPosition [0, 0, 1, 1];
		_r2tDisplayR2TCtrl ctrlCommit 0;

		_effectsLayersCount = missionNamespace getVariable ["CFM_displayEffectLayerCount", 3];
		for "_i" from 1 to (_effectsLayersCount) do {
			private _effectCtrl = _mainDisplay ctrlCreate ["RscPicture", EFFECT_CTRL_ID + _i];
			_effectCtrl ctrlSetPosition [0, 0, 1, 1];
			_effectCtrl ctrlCommit 0;
			_effectsLayersControls pushBack _effectCtrl;
		};

		private _displayUiCtrl = _mainDisplay ctrlCreate ["RscPicture", UI_CTRL_ID];
		_displayUiCtrl ctrlSetPosition [0, 0, 1, 1];
		_displayUiCtrl ctrlCommit 0;


		private _displayUpLayerCtrl = _mainDisplay ctrlCreate ["RscPicture", UP_CTRL_ID];
		_displayUpLayerCtrl ctrlSetPosition [0, 0, 1, 1];
		_displayUpLayerCtrl ctrlCommit 0;

		_self setVariable ["CFM_mainDisplay", _mainDisplay];
		_self setVariable ["CFM_displayR2TDisplayCtrl", _r2tDisplayCtrl];
		_self setVariable ["CFM_r2tDisplay", _r2tDisplay];
		_self setVariable ["CFM_r2tDisplayName", _r2tDisplayName];
		_self setVariable ["CFM_r2tDisplayR2TCtrl", _r2tDisplayR2TCtrl];
		_self setVariable ["CFM_effectsLayersCount", _effectsLayersCount];
		_self setVariable ["CFM_effectsLayersControls", _effectsLayersControls];
		_self setVariable ["CFM_displayUiCtrl", _displayUiCtrl];
		_self setVariable ["CFM_displayUpLayerCtrl", _displayUpLayerCtrl];

		_uiCtrlUIDisplayName = _monitorUid + "ui";
		_self setVariable ["CFM_uiCtrlUIDisplayName", _uiCtrlUIDisplayName];
		
		uiSleep WAIT_BEFORE_DISPLAY_UPD;

		["stopRenderingUI"] CALL_OBJCLASS("DisplayHandler", _monitor);
	};
	METHOD("startRenderingUI") {
		params[["_reset", false]];

		["setRenderR2TDisplay", true] CALL_OBJCLASS("DisplayHandler", _monitor);
		["setRenderUpLayer", false] CALL_OBJCLASS("DisplayHandler", _monitor);
		["renderInterface", _connectedOperator] CALL_OBJCLASS("DisplayHandler", _monitor);
		
		if (_reset) then {
			[_monitor, _currentPiPEffect] call CFM_fnc_setMonitorPiPEffect;
		};

		uiSleep WAIT_BEFORE_DISPLAY_UPD;

		["updateDisplays"] CALL_OBJCLASS("DisplayHandler", _monitor);
	};
	METHOD("stopRenderingUI") {
		["setRenderR2TDisplay", false] CALL_OBJCLASS("DisplayHandler", _monitor);
		["setRenderInterfaceDisplay", false] CALL_OBJCLASS("DisplayHandler", _monitor);
		["resetRenderEffects"] CALL_OBJCLASS("DisplayHandler", _monitor);
		["setRenderUpLayer", true] CALL_OBJCLASS("DisplayHandler", _monitor);

		uiSleep WAIT_BEFORE_DISPLAY_UPD;

		["updateDisplays"] CALL_OBJCLASS("DisplayHandler", _monitor);
	};
	METHOD("updateDisplays") {
		displayUpdate _mainDisplay;
		displayUpdate _r2tDisplay;
		displayUpdate _uiCtrlCurrentUIDisplay;
	};
	METHOD("renderInterface") {
		params[["_operator", _connectedOperator]];

	};
	// set renders
	METHOD("setSignalInterfaceEffectFuncs") {
		params[["_signalFuncName", ""], ["_effectFuncName", ""], ["_interfaceFuncName", ""]];

		private _set = false;
		if (IS_STR(_signalFuncName)) then {
			private _signalFunc = missionNamespace getVariable _signalFuncName;
			if (isNil "_signalFunc") exitWith {};
			if !(_signalFunc isEqualType {}) exitWith {};
			private _testFuncRes = [_self, player] call _signalFunc;
			if (isNil "_testFuncRes") exitWith {false};
			if !(_testFuncRes isEqualType 1) exitWith {false};
			_self setVariable ["CFM_currentOperatorSignalFunction", _signalFunc];
			_set = true;
		};
		if (IS_STR(_interfaceFuncName)) then {
			private _interfaceFunc = missionNamespace getVariable _interfaceFuncName;
			if (isNil "_interfaceFunc") exitWith {};
			if !(_interfaceFunc isEqualType {}) exitWith {};
			_self setVariable ["CFM_currentOperatorInterfaceFunction", _interfaceFunc];
			_set = true;
		};
		if (IS_STR(_effectFuncName)) then {
			private _effectFunc = missionNamespace getVariable _effectFuncName;
			if (isNil "_effectFunc") exitWith {};
			if !(_effectFunc isEqualType {}) exitWith {};
			_self setVariable ["_currentOperatorEffectsFunction", _effectFunc];
			_set = true;
		};
		_set
	};
	METHOD("setRenderR2TDisplay") {
		params[["_set", false]];
		if (_set) then {
			private _size = missionNamespace getVariable ["CFM_displaySize", 1024];
			_r2tDisplayR2TCtrl ctrlSetText (format ["#(argb,%1,%1,1)r2t(%2,1.0)", _size, _monitorR2Tid]);
		} else {
			_r2tDisplayR2TCtrl ctrlSetText ("");
		};
		_r2tDisplayR2TCtrl ctrlCommit 0;
	};
	METHOD("setRenderInterfaceDisplay") {
		params[["_set", false], ["_currentUIDisplayRenderClass", ""]];
		_set = _set && {!(_currentUIDisplayRenderClass isEqualTo "")};
		if (_set) then {
			private _size = missionNamespace getVariable ["CFM_displaySize", 1024];
			_displayUiCtrl ctrlSetText (format ["#(rgb,%1,%1,1)ui(%2,%3)", _size, _currentUIDisplayRenderClass, _uiCtrlUIDisplayName]);
		} else {
			_currentUIDisplayRenderClass = "";
			_displayUiCtrl ctrlSetText ("");
		};
		_self setVariable ["CFM_currentOperatorInterfaceClass", _currentUIDisplayRenderClass];
		_self setVariable ["CFM_currentUIDisplayRenderClass", _currentUIDisplayRenderClass];
		_displayUiCtrl ctrlCommit 0;
	};
	METHOD("resetRenderEffects") {
		{
			_x ctrlSetText ("");
			_x ctrlCommit 0;
		} forEach _effectsLayersControls;
	};
	METHOD("setRenderUpLayer") {
		params[["_set", false]];
		if (_set) then {
			["setOriginalTexture"] CALL_OBJCLASS("DisplayHandler", _monitor);
		} else {
			_displayUpLayerCtrl ctrlSetText "";
			_displayUiCtrl ctrlCommit 0;
		};
	};
	METHOD("setOriginalTexture") {
		_displayUpLayerCtrl ctrlSetText _originalTexture;
		_displayUpLayerCtrl ctrlCommit 0;
	};
	//----------- R2T render version -----------
	METHOD("startRenderingR2T") {
		params[["_reset", false]];

		["setR2TTexture", [true, _monitorR2Tid]] CALL_OBJCLASS("DisplayHandler", _monitor);
		
		if (_reset) then {
			[_monitor, _currentPiPEffect] call CFM_fnc_setMonitorPiPEffect;
		};
	};
	METHOD("stopRenderingR2T") {
		["setR2TTexture", [false]] CALL_OBJCLASS("DisplayHandler", _monitor);
	};
	METHOD("setR2TTexture") {
		params[["_render", true], ["_r2t", ""], ["_turnOff", false]];

		// if !(hasInterface) exitWith {};

		if (_render && {_r2t isEqualTo ""}) then {
			_r2t = _monitorR2Tid;
		};
		_render = _render && !(_r2t isEqualTo "");
		if ((_monitor getVariable ["CFM_isHandMonitor", false]) isEqualTo true) exitWith {
			[_monitor, _render] call CFM_fnc_setHandDisplay;
		};

		if (_render) then {
			private _size = missionNamespace getVariable ["CFM_displaySize", 1024];
			_monitor setObjectTexture [0, format["#(argb,%1,%1,1)r2t(%2,1.0)", _size, _r2t]];  
		} else {
			_monitor setObjectTexture [0, _originalTexture];
		};
	};
	//-------------------------------------
	METHOD("toggleMonitorLocal") {
		params[["_on", true, [true]]];

		if (missionNamespace getVariable ["CFM_useR2Tsystem", false]) then {
			if (_on) then {
				[_monitor] call CFM_fnc_setR2TTexture;
			} else {
				[_monitor, false, "", true] call CFM_fnc_setR2TTexture;
			};
		} else {
			if (_on) then {
				["startRenderingUI", false] SPAWN_OBJCLASS("DisplayHandler", _monitor);
			} else {
				["stopRenderingUI"] SPAWN_OBJCLASS("DisplayHandler", _monitor);
			};
		};
		_monitor setVariable ["CFM_turnedOffLocal", !_on];
	};
OBJCLASS_END