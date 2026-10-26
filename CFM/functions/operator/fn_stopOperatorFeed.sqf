/*
    Function: CFM_fnc_stopOperatorFeed
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 


params ["_monitor", ["_reset", false], ["_isOptimize", false]];
["stopFeed", [_reset, _isOptimize]] CALL_OBJCLASS("Monitor", _monitor);
