/*
	Name: CFM_fnc_getStaticCameraOffset

	Description: 
		Gets camera offset params [pos, [dir, up]] for setting it as static camera

	Return: [pos, [dir, up]]

	Arguments: none
*/


#include "defines.hpp"

// params [];

private _camera = get3DENCamera;
if !(is3DEN) then {
	_camera = curatorCamera;
	if (isNull _camera) exitWith {
		_camera = player;
	};
};

private _pos = getPosASL _camera;
private _vdirup = [vectorDir _camera, vectorUp _camera];

[_pos, _vdirup]