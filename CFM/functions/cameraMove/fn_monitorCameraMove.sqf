/*
    Function: CFM_fnc_monitorCameraMove
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_monitor", ["_direction", ""]];

private _canMove = _monitor getVariable ["CFM_currentCameraCanMove", false];
if !(_canMove isEqualTo true) exitWith {false};

private _directionIndex = CAMERA_MOVE_DIRECTIONS find _direction;
if (_directionIndex == -1) exitWith {false};

private _camera = _monitor getVariable ["CFM_currentFeedCam", objNull];
private _operator = _monitor getVariable ["CFM_connectedOperator", objNull];

if (!IS_OBJ(_camera)) exitWith {false};

private _currZoom = _monitor getVariable ["CFM_zoomFov", 1];
if !(_currZoom isEqualType 1) then {
    _currZoom = _operator getVariable ['CFM_prevZoomLocalFov', getObjectFov _operator];
};
private _sensitivity = (MGVAR ["CFM_cameraMoveSensitivity", 5]);
private _step = _sensitivity * _currZoom;
private _movementRestrictions = _monitor getVariable ["CFM_currentCameraMoveRestrictions", [85,85,180,180]];
private _currentCameraMoves = _monitor getVariable ["CFM_currentCameraMoves", [0,0,0,0]];
private _directionRestriction = _movementRestrictions param [_directionIndex, 0];
private _currentCameraMove = _currentCameraMoves param [_directionIndex, 0];
private _newMove = (_currentCameraMove + _step);

if ((_currentCameraMove < _directionRestriction) && {_newMove > _directionRestriction}) then {
    _newMove = _directionRestriction; // snap to max
};

if (_directionRestriction < 1) exitWith {false};
if ((_directionRestriction < 180) && {_newMove > _directionRestriction}) exitWith {false};

private _turretIndex = _monitor getVariable ["CFM_currentTurret", [-1]];

[_operator, _turretIndex, _direction, _step] call CFM_fnc_cameraMove;
