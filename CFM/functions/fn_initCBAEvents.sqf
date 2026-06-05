#include "defines.hpp"

// #define LOG_CBA_EVENT [_NIL(_eventName), time, _NIL(_this), clientOwner] RLOG
#define LOG_CBA_EVENT 

["CFM_syncMonitorState", {
    LOG_CBA_EVENT
	_this spawn CFM_fnc_syncState
}] call CBA_fnc_addEventHandler;

["CFM_serverSyncVariables", {
    LOG_CBA_EVENT
	_this call CFM_fnc_serverSyncVariables
}] call CBA_fnc_addEventHandler;

["CFM_clientSyncVariables", {
    LOG_CBA_EVENT
	isNil {
		missionNamespace setVariable ["CFM_Operators", _this param [0, []]];
		missionNamespace setVariable ["CFM_Monitors", _this param [1, []]];
		missionNamespace setVariable ["CFM_OperatorsIds", _this param [2, createHashMap]];
		missionNamespace setVariable ["CFM_ActiveOperators", _this param [3, []]];
		missionNamespace setVariable ["CFM_ActiveMonitorViewers", _this param [4, []]];
	};
}] call CBA_fnc_addEventHandler;

["CFM_newMonitorInstance", {
    LOG_CBA_EVENT
	_this spawn {
		waitUntil { sleep 1; !(isNil "CFM_inited") };
		_this SPAWN_NEW_OBJINSTANCE("Monitor");
	};
}] call CBA_fnc_addEventHandler;

["CFM_operatorMonitorConnected", {
    LOG_CBA_EVENT
	_this call CFM_fnc_operatorMonitorConnectedEvent;
}] call CBA_fnc_addEventHandler;

["CFM_operatorMonitorDisconnected", {
    LOG_CBA_EVENT
	_this call CFM_fnc_operatorMonitorDisconnectedEvent;
}] call CBA_fnc_addEventHandler;

["CFM_checkForNewOperators", {
    LOG_CBA_EVENT
	_this call CFM_fnc_checkForNewOperators;
}] call CBA_fnc_addEventHandler;

["CFM_setOperator", {
    LOG_CBA_EVENT
	private _reset = false;
	_this call CFM_fnc_setOperator;
}] call CBA_fnc_addEventHandler;

["CFM_operatorsLocalityChanged", {
    LOG_CBA_EVENT
	(IF_NIL(_this, [])) call (MGVAR ["CFM_ActiveOperators_PublicEH", {}])
}] call CBA_fnc_addEventHandler;

["CFM_moveDroneCamera", {
    LOG_CBA_EVENT
	params["_turret", "_args"];
	_args params [["_turretInstanceIndex", -1], ["_axisAngles", [0,0]]];
	["moveDroneCamera", [_axisAngles]] SPAWN_OBJINSTANCE("Turret", _turretInstanceIndex, _turret);
}] call CBA_fnc_addEventHandler;

["CFM_mavicDroppedGren", {
    LOG_CBA_EVENT
	params[["_drone", objNull]];
	if !(IS_OBJ(_drone)) exitWith {};
	{
		private _monitor = _x;
		if !(IS_OBJ(_monitor)) exitWith {};
		if !(_monitor getVariable ["CFM_feedActive", false]) exitWith {};
		private _op = _monitor getVariable ["CFM_connectedOperator", objNull];
		if !(IS_OBJ(_op)) exitWith {};
		if !(_op isEqualTo _drone) exitWith {};

		private _uiDisplayUniqueName = _monitor getVariable ["CFM_uiDisplayUniqueName", ""];
		private _group = uiNamespace getVariable ["DB_mavic_DetachGrenade" + _uiDisplayUniqueName, controlNull];

		if (isNull _group) exitWith {};
		if !(ctrlShown _group) exitWith {};

		private _controls = (allControls _group) + [_group];

		{
			_x ctrlSetFade 0;
			_x ctrlCommit 0.5;
		} forEach _controls;

		[{
			_this params ["_controls"];

			{
				_x ctrlSetFade 1;
				_x ctrlCommit 0.0;
			} forEach _controls;
		}, [_controls], 1.5] call CBA_fnc_waitAndExecute;
	} forEach (missionNamespace getVariable ["CFM_ActiveMonitors", []]);
}] call CBA_fnc_addEventHandler;

["CFM_droneRecreateCrew", {
    LOG_CBA_EVENT
	params ["_drone", "_side", "_netId"];
	deleteVehicleCrew _drone;
	_side createVehicleCrew _drone;
}] call CBA_fnc_addEventHandler;

// VARIABLES EVENTS
["CFM_" + "addMonitor", {
    LOG_CBA_EVENT
	["addToList", [_this, "CFM_Monitors"]] CALL_CLASS("DbHandler");
}] call CBA_fnc_addEventHandler;

["CFM_" + "addOperator", {
    LOG_CBA_EVENT
	["addToList", [_this, "CFM_Operators"]] CALL_CLASS("DbHandler");
}] call CBA_fnc_addEventHandler;

["CFM_" + "removeOperator", {
    LOG_CBA_EVENT
	["removeFromList", [_this, "CFM_Operators"]] CALL_CLASS("DbHandler");
}] call CBA_fnc_addEventHandler;

["CFM_" + "addActiveOperator", {
    LOG_CBA_EVENT
	["addToList", [_this, "CFM_ActiveOperators"]] CALL_CLASS("DbHandler");
}] call CBA_fnc_addEventHandler;

["CFM_" + "removeActiveOperator", {
    LOG_CBA_EVENT
	["removeFromList", [_this, "CFM_ActiveOperators"]] CALL_CLASS("DbHandler");
}] call CBA_fnc_addEventHandler;

["CFM_" + "addOperatorId", {
    LOG_CBA_EVENT
	params["_nextId", "_operator"];
	["addToHashMap", [_nextId, _operator, "CFM_OperatorsIds"]] CALL_CLASS("DbHandler");
}] call CBA_fnc_addEventHandler;

["CFM_" + "addOperatorClass", {
    LOG_CBA_EVENT
	params["_opClass", "_mainArgs"];
	["addToHashMap", [_opClass, _mainArgs, "CFM_OperatorClasses"]] CALL_CLASS("DbHandler");
}] call CBA_fnc_addEventHandler;

["CFM_" + "addGoProHelmetClass", {
    LOG_CBA_EVENT
	["addToList", [_this, "CFM_goProHelmets"]] CALL_CLASS("DbHandler");
}] call CBA_fnc_addEventHandler;

["CFM_" + "addActiveViewer", {
    LOG_CBA_EVENT
	["addToList", [_this, "CFM_ActiveMonitorViewers"]] CALL_CLASS("DbHandler");
}] call CBA_fnc_addEventHandler;

["CFM_" + "removeActiveViewer", {
    LOG_CBA_EVENT
	["removeFromList", [_this, "CFM_ActiveMonitorViewers"]] CALL_CLASS("DbHandler");
}] call CBA_fnc_addEventHandler;

["CFM_" + "monitorAddActiveViewer", {
    LOG_CBA_EVENT
	params["_monitor", "_viewer"];
	[_monitor, "CFM_ActiveMonitorViewers", _viewer, true, true] call CFM_fnc_pushBack;
}] call CBA_fnc_addEventHandler;

["CFM_" + "monitorRemoveActiveViewer", {
    LOG_CBA_EVENT
	params["_monitor", "_viewer"];
	[_monitor, "CFM_ActiveMonitorViewers", _viewer, false, true] call CFM_fnc_removeFromArray;
}] call CBA_fnc_addEventHandler;

["CFM_" + "addTurretInstanceToOperator", {
    LOG_CBA_EVENT
	params["_self", "_turretIndex", "_data"];
	[_self, "CFM_turretsInstances", _turretIndex, _data, true] call CFM_fnc_hashSet;
}] call CBA_fnc_addEventHandler;