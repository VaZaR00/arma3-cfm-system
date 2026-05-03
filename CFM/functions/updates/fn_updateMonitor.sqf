/*
    Function: CFM_fnc_updateMonitor
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_monitor", objNull]];

// private _monitorDisplayId = _monitor getVariable ["CFM_monitorUid", ""];
// private _monitorDisplay = findDisplay _monitorDisplayId;
// private _monitorUIdisplay = findDisplay (_monitorDisplayId + "_ui");
// private _monitorEffectsDisplay = findDisplay (_monitorDisplayId + "_effects");
// private _monitorRenderDisplay = findDisplay (_monitorDisplayId + "_render");

// //----------------- UPDATE SIGNAL -----------------------
// //-------------------------------------------------------

// if (_weakConnection) exitWith {
// 	[] call CFM_fnc_monitorWeakConnection;
// 	0
// };
// if (_signalLost) exitWith {false};

//----------------- UPDATE EFFECTS -----------------------
//-------------------------------------------------------

//----------------- UPDATE CAMERA -----------------------
_monitor call CFM_fnc_updateMonitorCamera;
//-------------------------------------------------------