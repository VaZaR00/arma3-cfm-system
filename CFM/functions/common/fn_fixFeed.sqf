/*
    Function: CFM_fnc_fixFeed
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

private _monitors = missionNamespace getVariable ["CFM_Monitors", []];
{
	[_x] spawn CFM_fnc_resetFeed;
} forEach _monitors;

hint "
If you still have no feed try reseting PIP setting value!
Якщо досі немає картинки, спробуйте переставити параметр PIP в налаштуваннях!
";