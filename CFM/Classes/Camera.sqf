CLASS(Camera)

	SET_SELF_VAR(_camera);

	VARIABLE(_operator, objNull);
	VARIABLE(_zoom, 1);

	METHODS

	METHOD("init") {
		params[["_initOperator", objNull]];

		if !(IS_OBJ(_initOperator)) exitWith {
			deleteVehicle _self;
		};

		_operator = _initOperator;

		_self setVariable ["CFM_operator", _operator];

		["addCameraToPool", [_self]] CALL_CLASS(_self);
	};
	METHOD("addCameraToPool") {
		params[["_cam", _self]];
		["addCameraToPool", [_cam]] CALL_CLASS(DbHandler);
	};
CLASS_END