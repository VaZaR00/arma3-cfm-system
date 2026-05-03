/*
    Function: CFM_fnc_stopOperatorFeed
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 


params ["_monitor", ["_reset", false]];
["stopFeed", [_reset]] CALL_OBJCLASS("Monitor", _monitor);
