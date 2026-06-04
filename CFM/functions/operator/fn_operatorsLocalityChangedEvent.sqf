/*
    Function: CFM_fnc_operatorsLocalityChangedEvent
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

["CFM_operatorsLocalityChanged", IF_NIL(_this, []), 0] call CFM_fnc_remoteEvent;

CFM_operatorsLocalityChangedEventFired = true;