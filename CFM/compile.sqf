#define GOPRO "gopro"
#define DRONETYPE "droneTurret"
#define DEF_FOV_GOPRO 0.85
#define STATIC_ATTACHED_CAMS_TYPES [DRONETYPE]
#define GOPRO_MEMPOINT "head"
#define START_MONITOR_FEED_DIST 150



CFM_fnc_init = {
	if !(isNil "CFM_EH_id") exitWith {};

	if (false) then {
		private _id = addMissionEventHandler ["Draw3D", {
			if (missionNamespace getVariable ["CFM_stopUpdate", false]) exitWith {};

			private _monitors = missionNamespace getVariable ["CFM_currentMonitors", []];
			{
				private _isActive = _x getVariable ["CFM_operatorFeedActive", false];
				if !(_isActive isEqualTo true) then {continue};
				[_x] call CFM_fnc_updateCamera;
			} forEach _monitors;
		}];
		CFM_EH_id = _id;
	};

	CFM_max_zoom_gopro = 2;
	CFM_max_zoom_drone = 5;

	CFM_goPro_zoomTable = createHashMapFromArray [[2, 0.25]];
	CFM_drone_zoomTable = createHashMapFromArray [[2, 0.5], [3, 0.2], [4, 0.09], [5, 0.07]];

	CFM_inited = true;
};

CFM_fnc_setMonitor = { 
	params [
		"_monitor", 
		["_canZoom", true],
		["_canConnectDrone", true],
		["_canFix", true],
		["_canSwitchTurret", true],
		["_canTurnOffLocal", true]
	]; 
		
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
			private _type = _x getVariable ["CFM_cameraType", GOPRO];
			private _name = switch (_type) do {
				case GOPRO: {
					format["%1: %2", groupId group _x, name _x]
				};
				default {format["%1: %2", groupId group _x, (getText (configFile >> "CfgVehicles" >> (typeOf _x) >> "displayName"))]};
			};
			private _id = _target addAction [format["        <t color='#3e99fa'>[Connect]</t>: %1", _name], { 
				params ["_t", "_c", "_i", "_p"]; 
				[[netId _t, netId (_p select 0), true], "CFM_fnc_syncState", true, _t] call CFM_fnc_remoteExec; 
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
		[[netId _target, "", false], "CFM_fnc_syncState", true, _target] call CFM_fnc_remoteExec; 
		_target setVariable ['CFM_menuActive', false];
	}, nil, 1.5, true, false, "", "_target getVariable ['CFM_operatorFeedActive', false]"]; 

	_actions append [_actionMenu, _actionDisc];

	if (_canZoom) then {
		private _actionZoomIn = _monitor addAction ["<t color='#c5dafa'>Zoom In</t>", { 
			params ["_target"]; 
			private _zoom = _target getVariable ['CFM_zoom', 1];
			if !(_zoom isEqualType 1) then {
				_zoom = 1;
			};
			private _newzoom = (_zoom + 1) max 1;
			_target setVariable ['CFM_zoom', _newzoom, true];

			private _type = _target getVariable ["CFM_cameraType", GOPRO];
			private _maxZoom = switch (_type) do {
				case GOPRO: {missionNamespace getVariable ["CFM_max_zoom_gopro", 2]};
				case DRONETYPE: {missionNamespace getVariable ["CFM_max_zoom_drone", 5]};
				default {1};
			};

			if (_newzoom >= _maxZoom) then {
				_target setVariable ['CFM_maxZoomed', true, true];
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

			_target setVariable ['CFM_maxZoomed', false, true];
		}, nil, 1.5, true, false, "", "_target getVariable ['CFM_operatorFeedActive', false]"]; 
	
		private _actionZoomDefault = _monitor addAction ["<t color='#45d9b9'>Reset Zoom</t>", { 
			params ["_target"]; 

			_target setVariable ['CFM_zoom', "def", true];

			_target setVariable ['CFM_maxZoomed', false, true];
		}, nil, 1.5, true, false, "", "_target getVariable ['CFM_operatorFeedActive', false]"]; 

		_actions append [_actionZoomIn, _actionZoomOut, _actionZoomDefault];
	};

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

			private _bot = driver _drone;
			private _currTurret = _target getVariable ["CFM_currentTurret", [0]]; 
			if (_currTurret isEqualTo [1]) then {
				_bot = gunner _drone;
				if (isNull _bot) then {
					_bot = driver _drone;
				};
			};

			player remoteControl (_bot);
			_drone switchCamera "internal";
		}, nil, 1.5, true, false, "", "
			(_target getVariable ['CFM_operatorFeedActive', false]) && {
				(_target getVariable ['CFM_isDroneFeed', false]) &&
				{'terminal' in (toLower (player getSlotItemName 612))}
			}
		"]; 
		_actions append [_connectDroneAction];
	};

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

	if (_canSwitchTurret) then {
		private _actionSwitchTurret = _monitor addAction ["<t color='#ffba4a'>Switch to Turret Camera</t>", { 
			params ["_target"]; 
			
			private _op = _target getVariable ["CFM_connectedOperator", objNull];
			[[netId _target, "", false], "CFM_fnc_syncState", true, _target] call CFM_fnc_remoteExec;
			if ((_op isEqualTo objNull) || !(_op isEqualType objNull)) exitWith {};
			[[netId _target, netId _op, true, [1]], "CFM_fnc_syncState", true, _target] call CFM_fnc_remoteExec;
		}, nil, 1.5, true, false, "", "
			(_target getVariable ['CFM_operatorFeedActive', false]) && {
				(_target getVariable ['CFM_opHasTurrets', false]) && {
					((_target getVariable ['CFM_currentTurret', [0]]) isEqualTo [0])
				}
			}
		"]; 
		private _actionSwitchDriver = _monitor addAction ["<t color='#ffba4a'>Switch to Pilot Camera</t>", { 
			params ["_target"]; 

			private _op = _target getVariable ["CFM_connectedOperator", objNull];
			[[netId _target, "", false], "CFM_fnc_syncState", true, _target] call CFM_fnc_remoteExec;
			if ((_op isEqualTo objNull) || !(_op isEqualType objNull)) exitWith {};
			[[netId _target, netId _op, true, [0]], "CFM_fnc_syncState", true, _target] call CFM_fnc_remoteExec;
		}, nil, 1.5, true, false, "", "
			(_target getVariable ['CFM_operatorFeedActive', false]) && {
				(_target getVariable ['CFM_opHasTurrets', false]) && {
					((_target getVariable ['CFM_currentTurret', [0]]) isEqualTo [1])
				}
			}
		"]; 
		_actions append [_actionSwitchTurret, _actionSwitchDriver];
	};

	if (_canTurnOffLocal) then {
		private _actionTurnOffLocal = _monitor addAction ["<t color='#8a3200'>Turn off feed (local)</t>", { 
			params ["_target"]; 
			
			_target setObjectTexture [0, ""];  
			_target setVariable ["CFM_turnedOffLocal", true]; 
		}, nil, 1.5, true, false, "", "(_target getVariable ['CFM_operatorFeedActive', false]) && {!(_target getVariable ['CFM_turnedOffLocal', false])}"]; 
		private _actionTurnOnLocal = _monitor addAction ["<t color='#036900'>Turn on feed (local)</t>", { 
			params ["_target"]; 
			
			[_target] call CFM_fnc_setMonitorTexture;
			_target setVariable ["CFM_turnedOffLocal", false];  
		}, nil, 1.5, true, false, "", "(_target getVariable ['CFM_operatorFeedActive', false]) && {(_target getVariable ['CFM_turnedOffLocal', false])}"]; 
		_actions append [_actionTurnOffLocal];
	};

	_monitor setVariable ["CFM_mainActions", _actions];
	_monitor setVariable ["CFM_isSet", true];
};

CFM_fnc_cameraCondition = {
	private _type = _this getVariable ["CFM_cameraType", GOPRO];

	switch (_type) do {
		case GOPRO: {
			private _hasGoPro = _this getVariable ["CFM_hasGoPro", false];
			private _goprohelms = missionNamespace getVariable ["CFM_goProHelmets", []];
			if (_goprohelms isEqualTo []) exitWith {_hasGoPro};
			private _playerHelm = headgear _this;
			_playerHelm in _goprohelms;
		};
		case DRONETYPE: {
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
	params ["_monitor", ["_setup", false], ["_justZoom", false]];  
	private _op = _monitor getVariable ["CFM_connectedOperator", objNull];  
	private _type = _op getVariable ["CFM_cameraType", GOPRO];

	private _cam = _monitor getVariable ["CFM_operatorCam", objNull];  
	private _turret = _monitor getVariable ["CFM_currentTurret", [0]];  

	if ((isNull _op) || !(_op call CFM_fnc_cameraCondition) || (isNull _cam)) exitWith {
		[_monitor] call CFM_fnc_stopOperatorFeed;
		false
	};  

	private _zoom = _monitor getVariable ["CFM_zoom", 1];
	([_op, _cam, _zoom, _turret, _justZoom] call CFM_fnc_getCamPos) params [["_pos", [0,0,0]], ["_dir", [0,0,0]], ["_up", [0,0,0]], ["_fov", 1]];
		
	if (_setup) then {
		if ((count _pos) == 3) then {
			_cam setPosASL _pos; 
		};
		_cam setVectorDirAndUp [_dir, _up];  
	};
	_cam camSetFov _fov;  
	_cam camCommit 0;  
};

CFM_fnc_getUAVCameraPoints = {  
    params ["_vehicle", ["_turretPath", [0]]]; 

    private _droneType = toLower (typeOf _vehicle);

	if ("mavik" in _droneType) exitWith {
		["pos_pilotcamera", "pos_pilotcamera_dir"]
	};
	if ("uav_01" in _droneType) exitWith {
		if (_turretPath isEqualTo [0]) exitWith {
			["pip_pilot_pos", "pip_pilot_dir"]
		};
		["pip0_pos", "pip0_dir"]
	};

    private _camPos = "uavCameraGunnerPos";  
    private _camDir = "uavCameraGunnerDir";

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
        } forEach ["PiP0_pos", "PiP1_pos", "pip0_pos", "pip1_pos", "pip_pilot_pos"];  
    };  
    if (_dirPoint == "") then {  
        {  
            private _testDir = _vehicle selectionPosition _x;  
            if (!(_testDir isEqualTo [0,0,0])) exitWith {_dirPoint = _x;};  
        } forEach ["PiP0_dir", "PiP1_dir", "pip0_dir", "pip1_dir", "flir", "pip_pilot_dir"];  
    };  
    [_posPoint, _dirPoint]  
};  

CFM_fnc_getCamPos = {
	params["_obj", "_cam", ["_zoom", 1], ["_turretPath", [0]], ["_justZoom", false]];

	private _prevTurret = _obj getVariable ["CFM_prevTurret", _turretPath];
	_obj setVariable ["CFM_prevTurret", _turretPath];

	private _type = _obj getVariable ["CFM_cameraType", GOPRO];

	private _zoomDefault = !(_zoom isEqualType 1);

	switch (_type) do {
		case GOPRO: {
			private _pos = [];
			private _dir = [];
			private _up = [];
			if !(_justZoom) then {
				private _eyeP = eyePos _obj; 
				_dir = eyeDirection _obj; 
				_up = _obj vectorModelToWorldVisual [0,0,1]; 
				_pos = _eyeP vectorAdd [(_dir select 0) * 0.12, (_dir select 1) * 0.12, 0.08]; 

				_obj setVariable ["CFM_camPosPoint", GOPRO_MEMPOINT];
			};

			private _fov = if !(_zoomDefault) then {
				_zoom = _zoom min (missionNamespace getVariable ["CFM_max_zoom_gopro", 2]);
				private _zoomfov = [_zoom, _type] call CFM_fnc_getZoomFov;
				if (_zoomfov > DEF_FOV_GOPRO) then {DEF_FOV_GOPRO} else {_zoomfov};
			} else {DEF_FOV_GOPRO};
			[_pos, _dir, _up, _fov]
		};
		case DRONETYPE: {
			private _pos = [];
			private _dir = [];
			private _up = [];
			if !(_justZoom) then {
				private _posPoint = _obj getVariable ["CFM_camPosPoint", ""];  
				private _dirPoint = _obj getVariable ["CFM_camDirPoint", ""];  

				if (((_posPoint isEqualTo "") || {!(_posPoint isEqualType "")}) || !(_prevTurret isEqualTo _turretPath)) then {
					private _points = [_obj, _turretPath] call CFM_fnc_getUAVCameraPoints;
					_posPoint = _points#0;
					_dirPoint = _points#1;
					_obj setVariable ["CFM_camPosPoint", _posPoint];
					_obj setVariable ["CFM_camDirPoint", _dirPoint];
				};

				private _startRelObj = _obj selectionPosition [_posPoint, "Memory"];  
				private _endRelObj = _obj selectionPosition [_dirPoint, "Memory"]; 
				private _startAbs = _obj modelToWorldWorld _startRelObj;
				private _endAbs = _obj modelToWorldWorld _endRelObj;
				private _dirUp = [_startAbs, _endAbs] call BIS_fnc_findLookAt;  

				_dir = _dirUp#0;
				_up = _dirUp#1;
				_pos = _startAbs;
			};

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
	params["_zoom", ["_type", GOPRO]];

	private _table = missionNamespace getVariable [(switch (_type) do {
		case GOPRO: {
			"CFM_goPro_zoomTable"
		};
		case DRONETYPE: {
			"CFM_drone_zoomTable"
		};
		default {"CFM_nullvar"};
	}), createHashMap];

	if !(_table isEqualType createHashMap) exitWith {1};

	_table getOrDefault [_zoom, 1];
};

CFM_fnc_startOperatorFeed = {  
	params ["_monitor", "_operator", ["_turret", [0]]];  
	private _renderTarget = _monitor getVariable ["CFM_operatorRenderTarget", "rendertarget0"];  
	private _cam = "camera" camCreate [0,0,0];  
	_cam cameraEffect ["internal", "back", _renderTarget];  
	[_monitor] call CFM_fnc_setMonitorTexture;
	_monitor setVariable ["CFM_operatorCam", _cam];  
	_monitor setVariable ["CFM_connectedOperator", _operator];  
	_monitor setVariable ["CFM_operatorFeedActive", true];  

	if ((isNil {_monitor getVariable ["CFM_currentTurret", nil]}) && {("uav_01" in (toLower (typeOf _operator)))}) then {
		// will be triggered only on monitor init
		// sets default turret as gunner if has
		_turret = [1];
		_monitor setVariable ["CFM_opHasTurrets", true];  
	};
	_monitor setVariable ["CFM_currentTurret", _turret];  

	private _type = _operator getVariable ["CFM_cameraType", GOPRO];
	_monitor setVariable ["CFM_cameraType", _type];  
	
	[_monitor, _operator, _cam, _turret] call CFM_fnc_attachCam;

	switch (_type) do {
		case DRONETYPE: {
			_monitor setVariable ["CFM_isDroneFeed", true];
		};
		default { };
	};

	[_monitor] spawn {  
		params ["_monitor"];  
		private _cam = _monitor getVariable ["CFM_operatorCam", objNull];   
		private _renderTarget = _monitor getVariable ["CFM_operatorRenderTarget", "rendertarget0"];  
		waitUntil {
			[_monitor, false, true] call CFM_fnc_updateCamera;
			!(_monitor getVariable ["CFM_operatorFeedActive", false]) || {(isNull _cam) || {(isNull _monitor)}}
		};
		_cam cameraEffect ["terminate", "back", _renderTarget]; 
		camDestroy _cam;  
	};  
}; 

CFM_fnc_attachCam = {
	params["_monitor", "_obj", "_cam", ["_turretPath", [0]]];

	[_monitor, true] call CFM_fnc_updateCamera;

	private _relPos = _obj worldToModel (getPos _cam);
	private _memPoint = _obj getVariable ["CFM_camPosPoint", ""];
	private _orient = [_cam, _obj] call (missionNamespace getVariable "BIS_fnc_vectorDirAndUpRelative");

	if (_memPoint isEqualTo GOPRO_MEMPOINT) then {
		private _headRelPos = _obj selectionPosition [GOPRO_MEMPOINT, "Memory"];
		_relPos = _relPos vectorDiff _headRelPos;
		_relPos = _relPos vectorAdd [0,0,0.1];
	};

	_cam attachTo [_obj, _relPos, _memPoint, true];
	_cam setVectorDirAndUp _orient;
};

CFM_fnc_setMonitorTexture = {
	params["_monitor"];
	private _renderTarget = _monitor getVariable ["CFM_operatorRenderTarget", "rendertarget0"];  
	_monitor setObjectTexture [0, "#(argb,512,512,1)r2t(" + _renderTarget + ",1.0)"];  
};

CFM_fnc_resetFeed = {
	params["_monitor"];
	private _op = _monitor getVariable ["CFM_connectedOperator", objNull];  
	private _turret = _monitor getVariable ["CFM_currentTurret", [0]];  
	[_monitor] call CFM_fnc_stopOperatorFeed;
	if ((_op isEqualTo objNull) || !(_op isEqualType objNull)) exitWith {};
	[_monitor, _op, _turret] call CFM_fnc_startOperatorFeed;
};

CFM_fnc_stopOperatorFeed = {  
	params ["_monitor"];  
	_monitor setVariable ["CFM_operatorFeedActive", false];  
	_monitor setVariable ["CFM_connectedOperator", nil]; 
	_monitor setVariable ["CFM_isDroneFeed", nil];
	_monitor setVariable ["CFM_currentTurret", nil]; 
	_monitor setVariable ["CFM_opHasTurrets", nil];  
	_monitor setObjectTexture [0, ""];  
}; 

CFM_fnc_remoteExec = {
	params[["_args", []], ["_func", "call"], ["_targets", 0], ["_jip", 0]];

	if (_targets isEqualType true) then {
		if (_targets isEqualTo true) then {
			_targets = 0;
		} else {
			_targets = 2;
		};
	};
	if (_jip isEqualType objNull) then {
		private _netid = netId _jip;
		private _idArr = (_netid splitString ":");
		private _id = "0";
		if (count _idArr > 1) then {
			_id = _idArr#1;
			if !(_id isEqualType "") then {
				_id = str _id;
			};
		};
		_jip = "CFM_jip_remote_exec_id_" + _id;
	};

	_args remoteExec [_func, _targets, _jip];
};

CFM_fnc_syncState = { 
	params ["_mNetId", "_oNetId", "_start", ["_turret", [0]]]; 

	if !(hasInterface) exitWith {};

	private _m = objectFromNetId _mNetId; 
	private _o = objectFromNetId _oNetId; 
	private _isWaiting = _m getVariable ["CFM_waitingForStart", false]; 

	if (_isWaiting && _start) exitWith {};

	_m setVariable ["CFM_waitingForStart", _start];

	if (_start) then {
		waitUntil {
			private _dist = _m distance player;
			private _isClose = _dist <= START_MONITOR_FEED_DIST;
			_start = _m getVariable ["CFM_waitingForStart", true];
			if (_isClose) exitWith {true};
			if !(_start) exitWith {true};
			sleep 1;
			_isClose
		};
	};
	if (_start) then { 
		[_m, _o, _turret] call CFM_fnc_startOperatorFeed 
	} else {
		[_m] call CFM_fnc_stopOperatorFeed;
	}; 
}; 

