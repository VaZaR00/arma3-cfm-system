/*
    Function: CFM_fnc_isPilotControlled
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params ["_veh", ["_by", objNull]];
private _crew = crew _veh;
if (_crew isEqualTo []) exitWith {false};
private _driver = _crew#0;
if (_driver isEqualTo objNull) exitWith {false};
private _remoteControlledDriver = remoteControlled _driver;
if (IS_OBJ(_by)) exitWith {(_remoteControlledDriver isEqualTo _by)};
!(_remoteControlledDriver isEqualTo objNull)
