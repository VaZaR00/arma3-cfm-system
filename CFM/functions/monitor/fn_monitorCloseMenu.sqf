/*
    Function: CFM_fnc_monitorCloseMenu
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_monitor", objNull]];

{ _monitor removeAction _x } forEach (_monitor getVariable ["CFM_tempActions", []]); 
_monitor setVariable ['CFM_menuActive', false];