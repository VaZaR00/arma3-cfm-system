/*
    Function: CFM_fnc_smoothRotateCam
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_veh", "_from", "_to"];

private _nextVector = +_from;
while {!([_nextVector, _to] call CFM_fnc_compareVectors)} do {
	sleep 0.01;
	_nextVector = +([_nextVector, _to, 8] call CFM_fnc_timeInterpolate);
	_veh setPilotCameraDirection _nextVector;
};
