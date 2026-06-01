#include "defines.hpp"

CFM_updateEachFrame = true;
CFM_initSetDefPointAlignments = true;

if (CFM_updateEachFrame) then {
	[] call CFM_fnc_setupDraw3dEH;
};

if (isServer) then {
	call CFM_fnc_setupOpSyncVarEH;
	CFM_serverLoop_handle = 0 spawn CFM_fnc_serverLoop;
} else {
	if (didJIP) then {
		// make data sync for JIP clients
		CFM_makeCamDataSync = true;
		["CFM_makeCamDataSync", [true, [clientOwner]]] call EFL_fnc_publicVariableServer;
		[clientOwner, {call CFM_fnc_serverSyncVariables}, 2, false, true] call CFM_fnc_remoteExec;
	};
};
CFM_ActiveOperators_PublicEH = {
	if !(hasInterface) exitWith {}; 
	// [] call CFM_fnc_updateActiveOperatorsLocalTurrets;
	MSVAR ["CFM_makeUpdateOperatorsLocalTurrets", true, true];
};

// update operators local turrets loop
if (hasInterface) then {
	CFM_updateOperatorsLocalTurretsHandle = 0 spawn {
		// wait for player
		waitUntil {sleep 1; !(isNull player)};
		// wait when player gets control of other unit so that we dont loop unneccesary
		waitUntil {sleep 0.5; (focusOn isNotEqualTo player)};

		private _timeUpdate = 0;
		private _lastFocusOn = focusOn;
		private _makeUpdate = false;
		while {MGVAR ["CFM_doLoopUpdateOperatorsLocalTurrets", true]} do {
			sleep (MGVAR ["CFM_updateOperatorsLocalTurretsLoopSleep", 0.1]);

			if (MGVAR ["CFM_stopUpdateOperatorsLocalTurrets", false]) then {continue};

			// check if focusOn changed
			if (focusOn != _lastFocusOn) then {
				_lastFocusOn = focusOn;
				_makeUpdate = true;
				// send over network that we need to update operators local turrets
				MSVAR ["CFM_makeUpdateOperatorsLocalTurrets", _makeUpdate, true];
			} else {
				_makeUpdate = MGVAR ["CFM_makeUpdateOperatorsLocalTurrets", false];
			};

			if !(_makeUpdate) then {
				// if ((time - _timeUpdate) < (MGVAR ["CFM_updateOperatorsLocalTurretsFreq", 1])) then {continue};
				// _timeUpdate = time;
				continue;
			};

			call CFM_fnc_updateActiveOperatorsLocalTurrets;

			// reset make update var localy
			_makeUpdate = false;
			MSVAR ["CFM_makeUpdateOperatorsLocalTurrets", _makeUpdate];
		};
	};
};

// default point alignments
if (CFM_initSetDefPointAlignments) then {
	private _pointSetDef = parsingNamespace getVariable ["CFM_classesPointAlignmentSet", createHashMap];
	if (_pointSetDef isEqualTo createHashMap) then {
		[] call CFM_fnc_initDefaultPointsAlignment;
		_pointSetDef = parsingNamespace getVariable ["CFM_classesPointAlignmentSet", createHashMap];
		missionNamespace setVariable ["CFM_classesPointAlignmentSet", _pointSetDef];
	} else {
		missionNamespace setVariable ["CFM_classesPointAlignmentSet", _pointSetDef];
	};
};

CFM_max_zoom_gopro = 2;
CFM_max_zoom_drone = 5;

// Classes
call CFM_fnc_compileClasses;

NEW_INSTANCE("DbHandler");
NEW_INSTANCE("CameraManager");


CFM_inited = true;