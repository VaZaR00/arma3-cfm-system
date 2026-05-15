/*
    Function: CFM_fnc_calculateCurrentCameraMoves
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_initialDirUp", [[0,1,0], [0,0,1]]], ["_currentDirUp", [[0,1,0], [0,0,1]]]];

if (_initialDirUp isEqualTo _currentDirUp) exitWith {[0,0,0,0]};

private _initialDir = _initialDirUp select 0;
private _initialUp = _initialDirUp select 1;
private _currentDir = _currentDirUp select 0;
private _currentUp = _currentDirUp select 1;

private _worldZ = [0,0,1];

private _initialFlat = [_initialDir select 0, _initialDir select 1, 0];
private _currentFlat = [_currentDir select 0, _currentDir select 1, 0];

private _yaw = 0;
if ((vectorMagnitude _initialFlat > 0.001) && (vectorMagnitude _currentFlat > 0.001)) then {
	private _initialFlatN = vectorNormalized _initialFlat;
	private _currentFlatN = vectorNormalized _currentFlat;
	private _dotYaw = ((_initialFlatN vectorDotProduct _currentFlatN) min 1) max -1;
	private _signYaw = ((_initialFlatN vectorCrossProduct _currentFlatN) select 2);
	_yaw = acos _dotYaw;
	if (_signYaw < 0) then {_yaw = -_yaw};
} else {
	private _initialDirN = vectorNormalized _initialDir;
	private _currentDirN = vectorNormalized _currentDir;
	private _dotYaw = ((_initialDirN vectorDotProduct _currentDirN) min 1) max -1;
	private _signYaw = ((_initialDirN vectorCrossProduct _currentDirN) select 2);
	_yaw = acos _dotYaw;
	if (_signYaw < 0) then {_yaw = -_yaw};
};

private _rotDir = [_initialDir, _worldZ, _yaw] call CFM_fnc_rotateAroundAxis;
private _rotUp = [_initialUp, _worldZ, _yaw] call CFM_fnc_rotateAroundAxis;
private _side = _rotDir vectorCrossProduct _rotUp;
if (vectorMagnitude _side == 0) then {_side = [1,0,0]};

private _rotDirN = vectorNormalized _rotDir;
private _currentDirN = vectorNormalized _currentDir;
private _dotPitch = ((_rotDirN vectorDotProduct _currentDirN) min 1) max -1;
private _pitch = acos _dotPitch;
private _signPitch = ((_rotDirN vectorCrossProduct _currentDirN) vectorDotProduct _side);
if (_signPitch < 0) then {_pitch = -_pitch};

private _degPitch = _pitch;
private _degYaw = _yaw;

[_degPitch, -_degPitch, _degYaw, -_degYaw]
