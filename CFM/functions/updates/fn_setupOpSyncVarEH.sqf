/*
    Function: CFM_fnc_setupOpSyncVarEH
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

"CFM_operatorsToUpdate" addPublicVariableEventHandler {call CFM_fnc_syncOperators};
"CFM_makeCamDataSync" addPublicVariableEventHandler {call CFM_fnc_syncOperators};
