CFM_fnc_init = {
	if !(isNil "CFM_EH_id") exitWith {};

	private _id = addMissionEventHandler ["Draw3D", {
		if (missionNamespace getVariable ["CFM_stopSystem", false]) exitWith {};

		private _monitors = missionNamespace getVariable ["CFM_currentMonitors", []];
		{
			private _isActive = _x getVariable ["CFM_operatorFeedActive", false];
			if !(_isActive isEqualTo true) then {continue};
			[_x] call CFM_fnc_updateCamera;
		} forEach _monitors;
	}];

	CFM_EH_id = _id;
	CFM_max_zoom_gopro = 2;
	CFM_max_zoom_drone = 5;

	CFM_goPro_zoomTable = createHashMapFromArray [[2, 0.25]];
	CFM_drone_zoomTable = createHashMapFromArray [[2, 0.5], [3, 0.2], [4, 0.09], [5, 0.07]];

	CFM_inited = true;
};

CFM_fnc_setMonitor = { 
	params ["_monitor"]; 
		
	if ((_monitor getVariable ["CFM_isSet", false]) isEqualTo true) exitWith {};

	if (isNil "CFM_Cam_Idx") then { CFM_Cam_Idx = 0 }; 
	private _rTarget = format["cfmrtarget%1", CFM_Cam_Idx]; 
	CFM_Cam_Idx = CFM_Cam_Idx + 1; 
	_monitor setVariable ["CFM_operatorRenderTarget", _rTarget, true]; 

	private _mons = missionNamespace getVariable ["CFM_currentMonitors", []];
	_mons pushBackUnique _monitor;
	missionNamespace setVariable ["CFM_currentMonitors", _mons];

	private _actions = [];

	private _actionMenu = _monitor addAction ["<t color='#00FF00'>Camera System Menu</t>", { 
		params ["_target", "_caller"]; 
		private _ops = call CFM_fnc_getActiveCameras; 
		if (count _ops == 0) exitWith { hint "No active cameras!" }; 
			
		private _tempIDs = []; 
		{  
			private _type = _x getVariable ["CFM_cameraType", "gopro"];
			private _name = switch (_type) do {
				case "gopro": {
					format["%1: %2", groupId group _x, name _x]
				};
				default {format["%1: %2", groupId group _x, (getText (configFile >> "CfgVehicles" >> (typeOf _x) >> "displayName"))]};
			};
			private _id = _target addAction [format["        <t color='#3e99fa'>[Connect]</t>: %1", _name], { 
				params ["_t", "_c", "_i", "_p"]; 
				[[netId _t, netId (_p select 0), true], "CFM_fnc_syncState", true] call BIS_fnc_MP; 
				{ _t removeAction _x } forEach (_t getVariable ["CFM_tempActions", []]); 
			}, [_x], 10]; 
			_tempIDs pushBack _id; 
		} forEach _ops; 

		private _closeID = _target addAction ["<t color='#ff6600'>   [Close Menu]</t>", { 
			params ["_t"]; 
			{ _t removeAction _x } forEach (_t getVariable ["CFM_tempActions", []]); 
			_t setVariable ['CFM_menuActive', false];
		}, nil, 9.9]; 
		_tempIDs pushBack _closeID; 
			
		_target setVariable ["CFM_tempActions", _tempIDs]; 
		_target setVariable ['CFM_menuActive', true];
			
		[_target, _tempIDs] spawn { 
			params["_target", "_tempIDs"];
			waitUntil {sleep 1; (_target distance player) > 5;};
			{ _target removeAction _x } forEach _tempIDs; 
			_target setVariable ['CFM_menuActive', false];
		}; 
	}, nil, 1.5, true, false, "", "!((_target getVariable ['CFM_operatorFeedActive', false]) || (_target getVariable ['CFM_menuActive', false]))"]; 

	private _actionDisc = _monitor addAction ["<t color='#FF0000'>Disconnect Camera</t>", { 
		params ["_target"]; 
		[[netId _target, "", false], "CFM_fnc_syncState", true] call BIS_fnc_MP; 
		_target setVariable ['CFM_menuActive', false];
	}, nil, 1.5, true, false, "", "_target getVariable ['CFM_operatorFeedActive', false]"]; 

	_actions append [_actionMenu, _actionDisc];

	private _canZoom = true;

	if (_canZoom) then {
		private _actionZoomIn = _monitor addAction ["<t color='#c5dafa'>Zoom In</t>", { 
			params ["_target"]; 
			private _zoom = _target getVariable ['CFM_zoom', 1];
			if !(_zoom isEqualType 1) then {
				_zoom = 1;
			};
			private _newzoom = (_zoom + 1) max 1;
			_target setVariable ['CFM_zoom', _newzoom, true];

			private _type = _target getVariable ["CFM_cameraType", "gopro"];
			private _maxZoom = switch (_type) do {
				case "droneTurret": {missionNamespace getVariable ["CFM_max_zoom_gopro", 2]};
				case "gopro": {missionNamespace getVariable ["CFM_max_zoom_drone", 5]};
				default {1};
			};

			if (_newzoom >= _maxZoom) then {
				_target setVariable ['CFM_maxZoomed', true];
			};
		}, nil, 1.5, true, false, "", "(_target getVariable ['CFM_operatorFeedActive', false]) && !(_target getVariable ['CFM_maxZoomed', false])"]; 

		private _actionZoomOut = _monitor addAction ["<t color='#c5dafa'>Zoom Out</t>", { 
			params ["_target"]; 

			private _zoom = _target getVariable ['CFM_zoom', 1];
			if !(_zoom isEqualType 1) then {
				_zoom = 1;
			};
			private _newzoom = (_zoom - 1) max 1;

			_target setVariable ['CFM_zoom', _newzoom, true];
			_target setVariable ['CFM_maxZoomed', false];
		}, nil, 1.5, true, false, "", "_target getVariable ['CFM_operatorFeedActive', false]"]; 
	
		private _actionZoomDefault = _monitor addAction ["<t color='#45d9b9'>Reset Zoom</t>", { 
			params ["_target"]; 

			_target setVariable ['CFM_zoom', "def", true];
			_target setVariable ['CFM_maxZoomed', false, true];
		}, nil, 1.5, true, false, "", "_target getVariable ['CFM_operatorFeedActive', false]"]; 

		_actions append [_actionZoomIn, _actionZoomOut, _actionZoomDefault];
	};

	private _canConnectDrone = true;
	if (_canConnectDrone) then {
		private _connectDroneAction = _monitor addAction ["<t color='#1c399e'>Take drone controls</t>", { 
			params ["_target"]; 

			private _drone = _target getVariable ["CFM_connectedOperator", objNull]; 
			private _errtext = "Can't connect to drone";

			if ((_drone isEqualTo objNull) || !(_drone isEqualType objNull)) exitWith {
				hint _errtext;
			};

			private _controler = remoteControlled _drone;

			if (!(_controler isEqualTo objNull) || !(_controler isEqualType objNull)) exitWith {
				hint _errtext;
			};

			private _connect = player connectTerminalToUAV _drone;

			if !(_connect) exitWith {
				hint _errtext;
			};

			player remoteControl (driver _drone);
			_drone switchCamera "internal";
		}, nil, 1.5, true, false, "", "
			(_target getVariable ['CFM_operatorFeedActive', false]) && {
				(_target getVariable ['CFM_isDroneFeed', false]) &&
				{'terminal' in (toLower (player getSlotItemName 612))}
			}
		"]; 
		_actions append [_connectDroneAction];
	};

	private _canFix = true;
	if (_canFix) then {
		private _actionFix = _monitor addAction ["<t color='#690707'>Fix feed (local)</t>", { 
			params ["_target"]; 
			
			private _monitors = missionNamespace getVariable ["CFM_currentMonitors", []];
			{
				[_x] call CFM_fnc_resetFeed;
			} forEach _monitors;
		}, nil, 1.5, true, false, "", "(_target getVariable ['CFM_operatorFeedActive', false])"]; 
		_actions append [_actionFix];
	};

	_monitor setVariable ["CFM_mainActions", _actions];
	_monitor setVariable ["CFM_isSet", true];
};

CFM_fnc_cameraCondition = {
	private _type = _this getVariable ["CFM_cameraType", "gopro"];

	switch (_type) do {
		case "gopro": {
			private _hasGoPro = _this getVariable ["CFM_hasGoPro", false];
			private _goprohelms = missionNamespace getVariable ["CFM_goProHelmets", []];
			if (_goprohelms isEqualTo []) exitWith {_hasGoPro};
			private _playerHelm = headgear _this;
			_playerHelm in _goprohelms;
		};
		case "droneTurret": {
			_this getVariable ["CFM_canFeed", false];
		};
		default {false};
	};
};

CFM_fnc_getActiveCameras = {
	private _obj = [];
	if (missionNamespace getVariable ["CFM_hasGoPros", false]) then {
		_obj append allUnits;
	}; 
	if (missionNamespace getVariable ["CFM_hasUavsCams", false]) then {
		_obj append allUnitsUAV;
	}; 
	if (missionNamespace getVariable ["CFM_hasVehCams", false]) then {
		_obj append vehicles;
	}; 
	private _playerSide = side player;
	_obj select {  
		(((side _x) isEqualTo _playerSide) || side _x == civilian) &&  
		alive _x &&  
		(_x call CFM_fnc_cameraCondition)  
	}  
}; 

CFM_fnc_updateCamera = {  
	params ["_monitor"];  
	private _cam = _monitor getVariable ["CFM_operatorCam", objNull];  
	private _op = _monitor getVariable ["CFM_connectedOperator", objNull];  

	if ((isNull _op) || !(alive _op) || !(_op call CFM_fnc_cameraCondition) || (isNull _cam)) exitWith {
		[_monitor] call CFM_fnc_stopOperatorFeed;
		false
	};  

	private _zoom = _monitor getVariable ["CFM_zoom", 1];
	([_op, _zoom] call CFM_fnc_getCamPos) params [["_pos", [0,0,0]], ["_dir", [0,0,0]], ["_up", [0,0,0]], ["_fov", 1]];
		
	_cam setPosASL _pos; 
	_cam setVectorDirAndUp [_dir, _up];  
	_cam camSetFov _fov;  
	_cam camCommit 0;  
};

CFM_fnc_getUAVCameraPoints = {  
    params ["_vehicle", ["_turretPath", [0]]];  
    private _camPos = "uavCameraGunnerPos";  
    private _camDir = "uavCameraGunnerDir";
    private _droneType = typeOf _vehicle;

    if (_turretPath isEqualTo [-1]) then {  
        if ("mavik" in _droneType) exitWith {};
        _camPos = "uavCameraDriverPos";  
        _camDir = "uavCameraDriverDir";  
    };

    private _config = configFile >> "CfgVehicles" >> typeOf _vehicle;  
    private _posPoint = getText (_config >> _camPos);  
    private _dirPoint = getText (_config >> _camDir);  
    if (_posPoint == "") then {  
        {  
            private _testPos = _vehicle selectionPosition _x;  
            if (!(_testPos isEqualTo [0,0,0])) exitWith {_posPoint = _x;};  
        } forEach ["PiP0_pos", "PiP1_pos", "pip0_pos", "pip1_pos", "flir"];  
    };  
    if (_dirPoint == "") then {  
        {  
            private _testDir = _vehicle selectionPosition _x;  
            if (!(_testDir isEqualTo [0,0,0])) exitWith {_dirPoint = _x;};  
        } forEach ["PiP0_dir", "PiP1_dir", "pip0_dir", "pip1_dir", "turret"];  
    };  
    [_posPoint, _dirPoint]  
};  

CFM_fnc_getCamPos = {
	params["_obj", ["_zoom", 1], ["_turretPath", [0]]];

	private _type = _obj getVariable ["CFM_cameraType", "gopro"];

	private _zoomDefault = !(_zoom isEqualType 1);

	switch (_type) do {
		case "gopro": {
			private _eyeP = eyePos _obj; 
			private _dir = eyeDirection _obj; 
			private _up = _obj vectorModelToWorldVisual [0,0,1]; 
			private _finalPos = _eyeP vectorAdd [(_dir select 0) * 0.12, (_dir select 1) * 0.12, 0.08]; 

			private _fov = if !(_zoomDefault) then {
				_zoom = _zoom min (missionNamespace getVariable ["CFM_max_zoom_gopro", 2]);
				private _zoomfov = [_zoom, _type] call CFM_fnc_getZoomFov;
				if (_zoomfov > 0.85) then {0.85} else {_zoomfov};
			} else {0.85};
			[_finalPos, _dir, _up, _fov]
		};
		case "droneTurret": {
			private _posPoint = _obj getVariable ["CFM_camPosPoint", ""];  
			private _dirPoint = _obj getVariable ["CFM_camDirPoint", ""];  

			if ((_posPoint isEqualTo "") || {!(_posPoint isEqualType "")}) then {
				private _points = [_obj, _turretPath] call CFM_fnc_getUAVCameraPoints;
				_posPoint = _points#0;
				_dirPoint = _points#1;
				_obj setVariable ["CFM_camPosPoint", _posPoint];
				_obj setVariable ["CFM_camDirPoint", _dirPoint];
			};

			private _start = _obj selectionPosition _posPoint;  
			private _end = _obj selectionPosition _dirPoint; 

			private _dir = _start vectorFromTo _end;  
			private _up = _dir vectorCrossProduct [-(_dir select 1), _dir select 0, 0];
			private _pos = _obj modelToWorldWorld _start;

			private _fov = if !(_zoomDefault) then {
				_zoom = _zoom min (missionNamespace getVariable ["CFM_max_zoom_drone", 5]);
				private _zoomfov = [_zoom, _type] call CFM_fnc_getZoomFov;
				if (_zoomfov > 1) then {getObjectFOV _obj} else {_zoomfov};
			} else {getObjectFOV _obj};

			[_pos, _dir, _up, _fov]
		};
		default {[]};
	};
};

CFM_fnc_getZoomFov = {
	params["_zoom", ["_type", "gopro"]];

	private _table = missionNamespace getVariable [(switch (_type) do {
		case "gopro": {
			"CFM_goPro_zoomTable"
		};
		case "droneTurret": {
			"CFM_drone_zoomTable"
		};
		default {"CFM_nullvar"};
	}), createHashMap];

	if !(_table isEqualType createHashMap) exitWith {1};

	_table getOrDefault [_zoom, 1];
};

CFM_fnc_startOperatorFeed = {  
	params ["_monitor", "_operator"];  
	private _renderTarget = _monitor getVariable ["CFM_operatorRenderTarget", "rendertarget0"];  
	private _cam = "camera" camCreate [0,0,0];  
	_cam cameraEffect ["internal", "back", _renderTarget];  
	[_monitor] call CFM_fnc_setMonitorTexture;
	_monitor setVariable ["CFM_operatorCam", _cam];  
	_monitor setVariable ["CFM_connectedOperator", _operator];  
	_monitor setVariable ["CFM_operatorFeedActive", true];  

	private _type = _operator getVariable ["CFM_cameraType", "gopro"];

	switch (_type) do {
		case "droneTurret": {
			_monitor setVariable ["CFM_isDroneFeed", true];
		};
		default { };
	};

	[_monitor] spawn {  
		params ["_monitor"];  
		private _cam = _monitor getVariable ["CFM_operatorCam", objNull];   
		private _renderTarget = _monitor getVariable ["CFM_operatorRenderTarget", "rendertarget0"];  
		waitUntil {!(_monitor getVariable ["CFM_operatorFeedActive", false]) || (isNull _cam) || (isNull _monitor)};
		_cam cameraEffect ["terminate", "back", _renderTarget]; 
		camDestroy _cam;  
	};  
}; 

CFM_fnc_setMonitorTexture = {
	params["_monitor"];
	private _renderTarget = _monitor getVariable ["CFM_operatorRenderTarget", "rendertarget0"];  
	_monitor setObjectTextureGlobal [0, "#(argb,512,512,1)r2t(" + _renderTarget + ",1.0)"];  
};

CFM_fnc_resetFeed = {
	params["_monitor"];
	private _op = _monitor getVariable ["CFM_connectedOperator", objNull];  
	[_monitor] call CFM_fnc_stopOperatorFeed;
	if ((_op isEqualTo objNull) || !(_op isEqualType objNull)) exitWith {};
	[_monitor, _op] call CFM_fnc_startOperatorFeed;
};

CFM_fnc_stopOperatorFeed = {  
	params ["_monitor"];  
	_monitor setVariable ["CFM_operatorFeedActive", false];  
	_monitor setVariable ["CFM_isDroneFeed", nil];
	_monitor setObjectTextureGlobal [0, ""];  
}; 

CFM_fnc_syncState = { 
	params ["_mNetId", "_oNetId", "_start"]; 
	private _m = objectFromNetId _mNetId; 
	private _o = objectFromNetId _oNetId; 
	if (_start) then { [_m, _o] call CFM_fnc_startOperatorFeed } else { [_m] call CFM_fnc_stopOperatorFeed }; 
}; 

