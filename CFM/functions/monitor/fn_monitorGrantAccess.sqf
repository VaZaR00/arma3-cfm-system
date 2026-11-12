/*
    Function: CFM_fnc_monitorGrantAccess
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_monitor", ["_plrId", ""]];
["grantAccess", _plrId] CALL_OBJCLASS("Monitor", _monitor);
