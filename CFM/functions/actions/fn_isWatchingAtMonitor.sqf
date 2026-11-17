/*
    Function: CFM_fnc_isWatchingAtMonitor
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_target", PLAYER_]];
(!isNull cursorObject) &&
{cursorObject getVariable ["CFM_isMonitorSet", false]} &&
{!(cursorObject isEqualTo _target)} &&
{([cursorObject] call CFM_fnc_getSelectedMonitorInstance) > 0};
