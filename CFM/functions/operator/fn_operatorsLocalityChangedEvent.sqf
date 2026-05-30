/*
    Function: CFM_fnc_operatorsLocalityChangedEvent
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

[IF_NIL(_this, []), {_this call (MGVAR ["CFM_ActiveOperators_PublicEH", {}])}] call CFM_fnc_remoteExec;

CFM_operatorsLocalityChangedEventFired = true;