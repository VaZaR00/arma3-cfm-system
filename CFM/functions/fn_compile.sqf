#include "defines.hpp" 

CFM_fnc_isUAVControlled = {
	params["_uav", ["_turret", "DRIVER"]];

	private _controls = UAVControl _uav;
	private _players = _controls select {IS_OBJ(_x) && {alive _x}};

	if (_players isEqualTo []) exitWith {false};

	_turret in _controls;
};