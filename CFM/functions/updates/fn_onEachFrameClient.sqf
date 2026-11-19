/*
    Function: CFM_fnc_onEachFrameClient
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

if !(missionNamespace getVariable ["CFM_updateEachFrame", false]) exitWith {};


private _player = PLAYER_;

// ---------- VEH SEAT TABLETs ---------
/*
LOGIC:
1. player left vehicle in which he had seaten at seat WITHOUT tablet
2. player left vehicle in which he had seaten at seat WITH tablet
3. player sit in vehicle in seat WITH tablet
4. player sit in vehicle in seat WITHOUT tablet
5. player changed seat in vehicle to seat WITHOUT tablet
6. player changed seat in vehicle to seat WITH tablet
7. no changes
*/
private _currentVeh = objectParent _player;
private _lastVeh = _player getVariable ["CFM_currentVeh", objNull];
private _inVeh = !isNull _currentVeh && {!(_currentVeh isEqualTo _player)};

if (!_inVeh) then {
	// 1 & 2. Player left vehicle
	if (!isNull _lastVeh) then {
		private _lastSeatKey = _player getVariable ["CFM_activeSeatKey", ""];
		_player setVariable ["CFM_currentVeh", objNull];
		_player setVariable ["CFM_currentSeatRole", []];
		_player setVariable ["CFM_currentVehMonSet", false];
		_player setVariable ["CFM_activeSeatKey", ""];
		_player setVariable ["CFM_selectedTablet", "hand"];

		// Notify MonitorHost on leaving seat
		if !(_lastSeatKey isEqualTo "") then {
			["onSeatChanged", [_lastSeatKey, ""]] CALL_OBJCLASS("MonitorHost", _lastVeh);
		};
	};
} else {
	private _currentRole = PLAYER_CREW_ROLE(_currentVeh);
	private _curMonSet = _currentVeh getVariable ["CFM_isMonitorSet", false];

	// Only notify MonitorHost when vehicle, seat role, or monitor initialization changes
	if (
		!(_currentVeh isEqualTo _lastVeh)
		|| {!(_curMonSet isEqualTo (_player getVariable ["CFM_currentVehMonSet", false]))}
		|| {!(_currentRole isEqualTo (_player getVariable ["CFM_currentSeatRole", []]))}
	) then {
		_player setVariable ["CFM_currentSeatRole", _currentRole];
		_player setVariable ["CFM_currentVehMonSet", _curMonSet];

		private _lastSeatKey = _player getVariable ["CFM_activeSeatKey", ""];
		private _isVehSeatTablet = _curMonSet && {_currentVeh getVariable ["CFM_isVehSeatTablet", false]};

		private _curSeatKey = if (_isVehSeatTablet) then {
			private _seatCandidate = [_currentRole] call CFM_fnc_getCrewSeatKey;
			private _vehMap = _currentVeh getVariable ["CFM_monitorInstancesMap", createHashMap];
			if (!(_seatCandidate isEqualTo "") && {!((_vehMap getOrDefault [_seatCandidate, []]) isEqualTo [])}) then {
				_seatCandidate
			} else {""}
		} else {
			""
		};

		if !(_currentVeh isEqualTo _lastVeh) then {
			if (!isNull _lastVeh && {!(_lastSeatKey isEqualTo "")}) then {
				["onSeatChanged", [_lastSeatKey, ""]] CALL_OBJCLASS("MonitorHost", _lastVeh);
				_lastSeatKey = "";
			};
			_player setVariable ["CFM_currentVeh", _currentVeh];
		};

		_player setVariable ["CFM_activeSeatKey", _curSeatKey];
		if (_curSeatKey isEqualTo "") then {
			_player setVariable ["CFM_selectedTablet", "hand"];
		} else {
			if (_player getVariable ["CFM_menuActive", false]) then {
				[_player, true] call CFM_fnc_monitorCloseMenu;
			};
			_player setVariable ["CFM_selectedTablet", "veh"];
		};

		if !(_lastSeatKey isEqualTo _curSeatKey) then {
			["onSeatChanged", [_lastSeatKey, _curSeatKey]] CALL_OBJCLASS("MonitorHost", _currentVeh);
		};
	};
};
// -------------------------------------


private _monitorsParams = missionNamespace getVariable ["CFM_ActiveMonitors", []];

// ----------- ACTIVE VIEWER -----------
if (_monitorsParams isEqualTo []) exitWith {
	if (_player getVariable ["CFM_isActiveViewer", false]) then {
		["removeActiveViewer", [_player]] CALL_CLASS("DbHandler");
	};
};
if !(_player getVariable ["CFM_isActiveViewer", false]) then {
	["addActiveViewer", [_player]] CALL_CLASS("DbHandler");
};
// -------------------------------------

// ----- CONTINUOUS CAMERA MOVEMENT ----
call CFM_fnc_updateContinuousCameraMove;
call CFM_fnc_updateContinuousZoom;
// -------------------------------------

// ---------- UPDATE MONITORS ----------
private _optimizeDistance = GET_OPTIMIZE_DIST;
private _doOptimize = _optimizeDistance > 0;
private ["_monPair", "_monitor", "_instId", "_condition", "_isHandMonitor", "_dist", "_operator", "_turret"];
private _remMonF = {CFM_ActiveMonitors = _monitorsParams - [_monPair]};
{
	_monPair = _x;
	if (!(_monPair isEqualType []) || {(count _monPair) < 2}) then {
		call _remMonF;
		continue;
	};
	_monPair params [["_monObj", objNull], ["_monId", -1]];
	_monitor = _monObj;
	_instId = _monId;
	if (!(IS_OBJ(_monitor)) || {_instId < 1}) then {
		call _remMonF;
		continue;
	};

	_condition = _monPair call CFM_fnc_monitorFeedActive;
	if (_condition isEqualTo false) then {
		[_monPair, false, false, false] call CFM_fnc_stopOperatorFeed;
		call _remMonF;
		continue;
	};

	_isHandMonitor = MON_GVAR(_monitor, _instId, "CFM_isHandMonitor", false);
	if (!(_isHandMonitor) && {_doOptimize}) then {
		_dist = _player distance _monitor;
		if (_dist > _optimizeDistance) then {
			_operator = MON_GVAR(_monitor, _instId, "CFM_connectedOperator", objNull);
			_turret = MON_GVAR(_monitor, _instId, "CFM_currentTurret", MON_GVAR(_monitor, _instId, "CFM_waitingForStartTurret", DRIVER_TURRET_PATH));
			[_monPair, false, true, false] call CFM_fnc_stopOperatorFeed;
			[_monPair, _operator, true, _turret, true] spawn CFM_fnc_syncState;
			call _remMonF;
			continue;
		};
	};

	if (_condition) then {
		_condition = if (MON_GVAR(_monitor, _instId, "CFM_currentFeedIsDisplay", false)) then {
			_monPair call CFM_fnc_updateMonitor;
		} else {
			_monPair call CFM_fnc_updateMonitorCamera;
		};
	};
} forEach _monitorsParams;

// -------------------------------------
