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
	// 1 & 2. Игрок покинул технику
	if (!isNull _lastVeh) then {
		private _lastSeatKey = _player getVariable ["CFM_activeSeatKey", ""];
		_player setVariable ["CFM_currentVeh", objNull];
		_player setVariable ["CFM_currentSeatRole", []];
		_player setVariable ["CFM_currentVehMonSet", false];
		_player setVariable ["CFM_activeSeatKey", ""];
		_player setVariable ["CFM_selectedTablet", "hand"];

		// 2. Вылез из техники с места С планшетом
		if !(_lastSeatKey isEqualTo "") then {
			["deactivateSeat"] CALL_SEAT_TABLET_INSTANCE(_lastVeh, _lastSeatKey);
		};
	};
} else {
	private _currentRole = PLAYER_CREW_ROLE(_currentVeh);
	private _curMonSet = _currentVeh getVariable ["CFM_isMonitorSet", false];

	// Если изменилась машина, место или инициализировался монитор техники
	if (
		!(_currentVeh isEqualTo _lastVeh)
		|| {!(_curMonSet isEqualTo (_player getVariable ["CFM_currentVehMonSet", false]))}
		|| {!(_currentRole isEqualTo (_player getVariable ["CFM_currentSeatRole", []]))}
	) then {
		_player setVariable ["CFM_currentSeatRole", _currentRole];
		_player setVariable ["CFM_currentVehMonSet", _curMonSet];

		private _lastSeatKey = _player getVariable ["CFM_activeSeatKey", ""];
		private _isVehTablet = _curMonSet && {_currentVeh getVariable ["CFM_isVehTablet", false]};

		// Проверяем, есть ли на новом месте планшет
		private _curSeatKey = if (_isVehTablet && {[_currentVeh, _currentRole] call CFM_fnc_isCrewSeatAllowed}) then {
			[_currentRole] call CFM_fnc_getCrewSeatKey
		} else {
			""
		};

		// Обработка смены техники (сели в новую машину или пересели напрямую между машинами)
		if !(_currentVeh isEqualTo _lastVeh) then {
			if (!isNull _lastVeh && {!(_lastSeatKey isEqualTo "")}) then {
				["deactivateSeat"] CALL_SEAT_TABLET_INSTANCE(_lastVeh, _lastSeatKey);
				_lastSeatKey = "";
			};
			_player setVariable ["CFM_currentVeh", _currentVeh];
		};

		// Всегда обновляем CFM_activeSeatKey при любом изменении места
		_player setVariable ["CFM_activeSeatKey", _curSeatKey];
		if (_curSeatKey isEqualTo "") then {
			_player setVariable ["CFM_selectedTablet", "hand"];
		} else {
			if (_player getVariable ["CFM_menuActive", false]) then {
				[_player] call CFM_fnc_monitorCloseMenu;
			};
			_player setVariable ["CFM_selectedTablet", "veh"];
		};

		// Обработка перехода между местами
		if !(_lastSeatKey isEqualTo _curSeatKey) then {
			// 5 или 6 (пересадка с места С планшетом): деактивируем прошлый планшет
			if !(_lastSeatKey isEqualTo "") then {
				["deactivateSeat"] CALL_SEAT_TABLET_INSTANCE(_currentVeh, _lastSeatKey);
			};

			// 3 или 6 (посадка/пересадка на место С планшетом): активируем новый планшет
			if !(_curSeatKey isEqualTo "") then {
				["activateSeat"] CALL_SEAT_TABLET_INSTANCE(_currentVeh, _curSeatKey);
			};
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
private ["_monitor", "_condition", "_isHandMonitor", "_dist", "_operator", "_turret"];
private _remMonF = {CFM_ActiveMonitors = _monitorsParams - [_monitor]};
{
	_monitor = _x;
	_condition = _monitor call CFM_fnc_monitorFeedActive;
	if (_condition isEqualTo false) then {
		[_monitor] call CFM_fnc_stopOperatorFeed;
		call _remMonF;
		continue;
	};
	_isHandMonitor = _monitor getVariable ["CFM_isHandMonitor", false];
	if (!(_isHandMonitor) && {_doOptimize}) then {
		_dist = _player distance _monitor;
		if (_dist > _optimizeDistance) then {
			_operator = _monitor getVariable ["CFM_connectedOperator", objNull];
			_turret = _monitor getVariable ["CFM_currentTurret", _monitor getVariable ["CFM_waitingForStartTurret", DRIVER_TURRET_PATH]];
			[_monitor, false, true] call CFM_fnc_stopOperatorFeed;
			[_monitor, _operator, true, _turret, true] spawn CFM_fnc_syncState;
			call _remMonF;
			continue;
		};
	};
	if (_condition) then {
		_condition = if (_monitor getVariable ["CFM_currentFeedIsDisplay", false]) then {
			_monitor call CFM_fnc_updateMonitor;
		} else {
			_monitor call CFM_fnc_updateMonitorCamera;
		};
	};
} forEach _monitorsParams;

// -------------------------------------
