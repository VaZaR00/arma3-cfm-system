
OBJCLASS(DisplayHandler)

	SET_SELF_VAR("_monitor");

	FIELD ["_monitorUid", ""];
	FIELD ["_monitorR2Tid", ""];
	FIELD ["_originalTexture", ""];
	
	FIELD ["_connectedOperator", objNull];
	FIELD ["_currentPiPEffect", 0];

	METHOD("Init") {
		_monitorUid = ["createMonitorUId", _monitor] CALL_CLASS("DbHandler");
		_monitor setVariable ["CFM_monitorUid", _monitorUid];
		_monitorR2Tid = ["createMonitorR2TId", _monitor] CALL_CLASS("DbHandler");
		_monitor setVariable ["CFM_monitorR2Tid", _monitorR2Tid];
	};
	METHOD("startRendering") {
		params[["_reset", false]];

		["setR2TTexture", [true, _monitorR2Tid]] CALL_OBJCLASS("DisplayHandler", _monitor);
		
		if (_reset) then {
			[_monitor, _currentPiPEffect] call CFM_fnc_setMonitorPiPEffect;
		};
	};
	METHOD("stopRendering") {
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
			_monitor setObjectTexture [0, "#(argb,512,512,1)r2t(" + _r2t + ",1.0)"];  
		} else {
			_monitor setObjectTexture [0, _originalTexture];
		};
	};
OBJCLASS_END