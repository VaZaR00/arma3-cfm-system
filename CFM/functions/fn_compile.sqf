#include "defines.hpp" 

CFM_fnc_checkTurretsLocality = {
	params [["_operator", objNull]];
	
	private _turrets = allTurrets _operator;
	private _hasLocalTurret = false;
	{
		_hasLocalTurret = _operator turretLocal _x;
		if (_hasLocalTurret) exitWith {break};
	} forEach _turrets;
	_hasLocalTurret
};
