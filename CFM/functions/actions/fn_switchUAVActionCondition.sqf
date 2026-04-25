/*
    Function: CFM_fnc_switchUAVActionCondition
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_target"];
HAND_MON_CONDITION
IS_MONITOR_ON
(_target getVariable ['CFM_feedActive', false]) && {
	(_target getVariable ['CFM_isHandMonitor', false]) && {
        private _currentUav = vehicle (remoteControlled _target);
		IS_OBJ(_currentUav)
    }
}