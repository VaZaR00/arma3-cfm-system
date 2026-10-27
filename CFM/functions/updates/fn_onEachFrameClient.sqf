/*
    Function: CFM_fnc_onEachFrameClient
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

if !(missionNamespace getVariable ["CFM_updateEachFrame", false]) exitWith {};


private _player = PLAYER_;
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

// ---------- UPDATE MONITORS ----------
private _optimizeDistance = GET_OPTIMIZE_DIST;
private _doOptimize = _optimizeDistance > 0;
private ["_monitor", "_condition", "_isHandMonitor", "_dist", "_operator", "_turret"];
private _remMonF = {CFM_ActiveMonitors = _monitorsParams - [_monitor]};
{
	_monitor = _x;
	if ((_monitor getVariable ["CFM_isVehTablet", false]) && {!([_monitor] call CFM_fnc_inVehicleTabletSeatCondition)}) then {
		[_monitor, false, true] call CFM_fnc_stopOperatorFeed;
		["clearVariables"] CALL_OBJCLASS("Monitor", _monitor);
		call _remMonF;
		continue;
	};
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

// 7. Без изменений: игрок на ногах
if (((isNull _currentVeh) || {(_currentVeh isEqualTo _player)}) && {isNull _lastVeh}) exitWith {};

// Игрок покинул технику
if (isNull _currentVeh) exitWith {
	private _lastSeatKey = _player getVariable ["CFM_activeSeatKey", ""];
	_player setVariable ["CFM_currentVeh", objNull];
	_player setVariable ["CFM_currentSeatRole", []];

	// 2. Вылез из техники с места С планшетом
	if !(_lastSeatKey isEqualTo "") then {
		_player setVariable ["CFM_activeSeatKey", ""];
		["deactivateSeat"] CALL_SEAT_TABLET_INSTANCE(_lastVeh, _lastSeatKey);
	};
	// 1. Вылез из техники с места БЕЗ планшета (сброс переменных выше)
};

// 7. Без изменений: игрок сидит в той же технике на том же месте
private _currentRole = assignedVehicleRole _player;
if (_currentVeh isEqualTo _lastVeh && {_currentRole isEqualTo (_player getVariable ["CFM_currentSeatRole", []])}) exitWith {};

// --- Если дошли сюда, произошло изменение (сели в машину / сменили место) ---
_player setVariable ["CFM_currentSeatRole", _currentRole];

private _lastSeatKey = _player getVariable ["CFM_activeSeatKey", ""];
private _isVehTablet = _currentVeh getVariable ["CFM_isVehTablet", false];

// Проверяем, есть ли на новом месте планшет
private _curSeatKey = if (_isVehTablet && {[_currentVeh] call CFM_fnc_inVehicleTabletSeatCondition}) then {
	[_currentVeh, _player] call CFM_fnc_getUnitVehicleSeatKey
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

// Обработка перехода между местами
if !(_lastSeatKey isEqualTo _curSeatKey) then {
	// 5 или 6 (пересадка с места С планшетом): деактивируем прошлый планшет
	if !(_lastSeatKey isEqualTo "") then {
		["deactivateSeat"] CALL_SEAT_TABLET_INSTANCE(_currentVeh, _lastSeatKey);
	};

	_player setVariable ["CFM_activeSeatKey", _curSeatKey];

	// 3 или 6 (посадка/пересадка на место С планшетом): активируем новый планшет
	if !(_curSeatKey isEqualTo "") then {
		["activateSeat"] CALL_SEAT_TABLET_INSTANCE(_currentVeh, _curSeatKey);
	};
	// 4 или 5 (на место БЕЗ планшета): _curSeatKey == "", планшет не активируется
};
// -------------------------------------