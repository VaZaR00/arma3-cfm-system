CLASS(SeatTablet)

	SET_SELF_VAR("_monitor");
	SET_VARS_PREFIX("_seatTablet");

	FIELD ["_seatKey", ""];
	FIELD ["_connectedOperator", objNull];
	FIELD ["_currentTurret", DRIVER_TURRET_PATH];
	FIELD ["_zoom", 1, ["", 1]];
	FIELD ["_zoomFov", 1, ["", 1]];
	FIELD ["_maxZoomed", false];
	FIELD ["_currentPiPEffect", 0];
	FIELD ["_isInNvg", false];
	FIELD ["_turnedOffLocal", false];

	METHOD("Init") {
		[
			["_seatKey", ""]
		] NP_PARAMS;

		SAVE_VARS
		GLOBAL_SETTER

		true
	};

	METHOD("applyToMonitor") {
		private _turrIdx = TURRET_INDEX(_currentTurret);
		_monitor setVariable ["CFM_connectedOperator", _connectedOperator];
		_monitor setVariable ["CFM_waitingForStartTurret", _turrIdx];
		_monitor setVariable ["CFM_currentTurret", [_turrIdx]];
		_monitor setVariable ["CFM_zoom", _zoom];
		_monitor setVariable ["CFM_zoomFov", _zoomFov];
		_monitor setVariable ["CFM_maxZoomed", _maxZoomed];
		_monitor setVariable ["CFM_currentPiPEffect", _currentPiPEffect];
		_monitor setVariable ["CFM_isInNvg", _isInNvg];
		_monitor setVariable ["CFM_turnedOffLocal", _turnedOffLocal];
		true
	};

	METHOD("saveFromMonitor") {
		if !(IS_OBJ(_connectedOperator)) exitWith {false};
		private _monOp = _monitor getVariable ["CFM_connectedOperator", objNull];
		if (IS_OBJ(_monOp) && {!(_monOp isEqualTo _connectedOperator)}) exitWith {false};

		private _monTurr = _monitor getVariable ["CFM_currentTurret", _currentTurret];
		_currentTurret = [TURRET_INDEX(_monTurr)];
		_zoom = _monitor getVariable ["CFM_zoom", _zoom];
		_zoomFov = _monitor getVariable ["CFM_zoomFov", _zoomFov];
		_maxZoomed = _monitor getVariable ["CFM_maxZoomed", _maxZoomed];
		_currentPiPEffect = _monitor getVariable ["CFM_currentPiPEffect", _currentPiPEffect];
		_isInNvg = _monitor getVariable ["CFM_isInNvg", _isInNvg];
		_turnedOffLocal = _monitor getVariable ["CFM_turnedOffLocal", _turnedOffLocal];

		SET_SELFVARG(_currentTurret);
		SET_SELFVARG(_zoom);
		SET_SELFVARG(_zoomFov);
		SET_SELFVARG(_maxZoomed);
		SET_SELFVARG(_currentPiPEffect);
		SET_SELFVARG(_isInNvg);
		SET_SELFVARG(_turnedOffLocal);
		true
	};

	METHOD("connect") {
		params ["_op", ["_initTurrIdx", -1], ["_caller", objNull]];
		if !(IS_OBJ(_op)) exitWith {false};

		private _prevOp = _connectedOperator;
		private _prevTurr = _currentTurret;

		_initTurrIdx = TURRET_INDEX(_initTurrIdx);
		_connectedOperator = _op;
		_currentTurret = [_initTurrIdx];
		_currentPiPEffect = 0;
		_isInNvg = false;
		_zoom = 1;
		_zoomFov = 1;
		_maxZoomed = false;
		_turnedOffLocal = false;

		SET_SELFVARG(_connectedOperator);
		SET_SELFVARG(_currentTurret);
		SET_SELFVARG(_currentPiPEffect);
		SET_SELFVARG(_isInNvg);
		SET_SELFVARG(_zoom);
		SET_SELFVARG(_zoomFov);
		SET_SELFVARG(_maxZoomed);
		SET_SELFVARG(_turnedOffLocal);

		if (IS_OBJ(_prevOp) && {!(_prevOp isEqualTo _op) || {!(TURRET_INDEX(_prevTurr) isEqualTo _initTurrIdx)}}) then {
			if !([_monitor, _prevOp, _prevTurr] call CFM_fnc_isVehTabletUsingOperator) then {
				["CFM_operatorMonitorDisconnected", [_prevOp, _monitor, _prevTurr], _prevOp] call CBA_fnc_targetEvent;
			};
		};

		["CFM_operatorMonitorConnected", [_op, _monitor, [_initTurrIdx]], _op] call CBA_fnc_targetEvent;

		["applyToMonitor"] CALL_SELF;
		[_monitor, _op, true, [_initTurrIdx], true, _seatKey] spawn CFM_fnc_syncState;
		true
	};

	METHOD("disconnect") {
		params [["_caller", objNull]];
		private _prevOp = _connectedOperator;
		private _prevTurr = _currentTurret;

		_connectedOperator = objNull;
		_currentTurret = DRIVER_TURRET_PATH;
		_currentPiPEffect = 0;
		_isInNvg = false;
		_zoom = 1;
		_zoomFov = 1;
		_maxZoomed = false;
		_turnedOffLocal = false;

		SET_SELFVARG(_connectedOperator);
		SET_SELFVARG(_currentTurret);
		SET_SELFVARG(_currentPiPEffect);
		SET_SELFVARG(_isInNvg);
		SET_SELFVARG(_zoom);
		SET_SELFVARG(_zoomFov);
		SET_SELFVARG(_maxZoomed);
		SET_SELFVARG(_turnedOffLocal);

		if (IS_OBJ(_prevOp)) then {
			if !([_monitor, _prevOp, _prevTurr] call CFM_fnc_isVehTabletUsingOperator) then {
				["CFM_operatorMonitorDisconnected", [_prevOp, _monitor, _prevTurr], _prevOp] call CBA_fnc_targetEvent;
			};
		};

		if (hasInterface && {((PLAYER_ getVariable ["CFM_activeSeatKey", ""]) isEqualTo _seatKey)}) then {
			_monitor setVariable ["CFM_waitingForStart" + _seatKey, false];
			_monitor setVariable ["CFM_waitingForStart", false];
			if (_monitor getVariable ["CFM_feedActive", false]) then {
				[_monitor] call CFM_fnc_stopOperatorFeed;
			} else {
				["clearVariables"] CALL_OBJCLASS("Monitor", _monitor);
			};
		};
		true
	};

	METHOD("activateSeat") {
		if !(hasInterface) exitWith {false};
		if (IS_OBJ(_connectedOperator)) then {
			if !([_connectedOperator, _monitor] call CFM_fnc_operatorCondition) exitWith {
				["disconnect"] CALL_SELF;
				false
			};
			["applyToMonitor"] CALL_SELF;
			[_monitor, _connectedOperator, true, _currentTurret, true, _seatKey] spawn CFM_fnc_syncState;
			true
		} else {
			_monitor setVariable ["CFM_waitingForStart" + _seatKey, false];
			_monitor setVariable ["CFM_waitingForStart", false];
			if (_monitor getVariable ["CFM_feedActive", false]) then {
				[_monitor, false, true] call CFM_fnc_stopOperatorFeed;
			};
			["clearVariables"] CALL_OBJCLASS("Monitor", _monitor);
			false
		};
	};

	METHOD("deactivateSeat") {
		if !(hasInterface) exitWith {false};
		if ((_monitor getVariable ["CFM_feedActive", false]) && {IS_OBJ(_connectedOperator)}) then {
			["saveFromMonitor"] CALL_SELF;
		};
		[_monitor] call CFM_fnc_monitorCloseMenu;
		_monitor setVariable ["CFM_waitingForStart" + _seatKey, false];
		_monitor setVariable ["CFM_waitingForStart", false];
		if (_monitor getVariable ["CFM_feedActive", false]) then {
			[_monitor, false, true] call CFM_fnc_stopOperatorFeed;
		};
		["clearVariables"] CALL_OBJCLASS("Monitor", _monitor);
		true
	};

CLASS_END
