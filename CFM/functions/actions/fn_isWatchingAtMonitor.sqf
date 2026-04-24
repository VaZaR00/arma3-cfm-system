/*
    Function: CFM_fnc_isWatchingAtMonitor
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_target", PLAYER_]];
(!(isNil {cursorObject getVariable "CFM_originalTexture"})) && {!(cursorObject isEqualTo _target)};
