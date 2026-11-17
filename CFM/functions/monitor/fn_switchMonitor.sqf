/*
    Function: CFM_fnc_switchMonitor
    Author: Vazar
    Description: Switches selected monitor instance on _monitor via MonitorHost.
*/

#include "defines.hpp"

params [
	["_monitor", objNull],
	["_targetInstId", -1]
];

if !(IS_OBJ(_monitor)) exitWith {-1};
["switchMonitor", [_targetInstId], -1] CALL_OBJCLASS("MonitorHost", _monitor)
