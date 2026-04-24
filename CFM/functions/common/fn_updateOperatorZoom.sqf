/*
    Function: CFM_fnc_updateOperatorZoom
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_obj"];
private _currentFOV = getObjectFOV _obj;
private _prevZoom = _obj getVariable ["CFM_prevZoomLocalFov", -1];
if !(_currentFOV isEqualTo _prevZoom) then {
	_obj setVariable ["CFM_prevZoomLocalFov", _currentFOV, MONITOR_VIEWERS_AND_SELF(false)];
};
_currentFOV
