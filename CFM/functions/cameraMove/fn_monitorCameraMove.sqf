/*
    Function: CFM_fnc_monitorCameraMove
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_monArg", ["_direction", ""]];
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};

private _canMove = MON_GVAR(_monitor, _instId, "CFM_currentCameraCanMove", false);
if !(_canMove isEqualTo true) exitWith {false};

private _directionIndex = CAMERA_MOVE_DIRECTIONS find _direction;
if (_directionIndex == -1) exitWith {false};

private _camera = MON_GVAR(_monitor, _instId, "CFM_currentFeedCam", objNull);
private _operator = MON_GVAR(_monitor, _instId, "CFM_connectedOperator", objNull);

if (!IS_OBJ(_camera)) exitWith {false};

private _currZoom = MON_GVAR(_monitor, _instId, "CFM_zoomFov", 1);
if !(_currZoom isEqualType 1) then {
    _currZoom = _operator getVariable ['CFM_prevZoomLocalFov', getObjectFov _operator];
};
private _sensitivity = (MGVAR ["CFM_cameraMoveSensitivity", 5]);
private _step = _sensitivity * _currZoom;
private _movementRestrictions = MON_GVAR(_monitor, _instId, "CFM_currentCameraMoveRestrictions", [85 I 85 I 180 I 180]);
private _currentCameraMoves = MON_GVAR(_monitor, _instId, "CFM_currentCameraMoves", [0 I 0 I 0 I 0]);
private _directionRestriction = _movementRestrictions param [_directionIndex, 0];
private _currentCameraMove = _currentCameraMoves param [_directionIndex, 0];
private _newMove = (_currentCameraMove + _step);

if ((_currentCameraMove < _directionRestriction) && {_newMove > _directionRestriction}) then {
    _newMove = _directionRestriction; // snap to max
    _step = _directionRestriction - _currentCameraMove;
};

if (_directionRestriction < 1) exitWith {false};
if ((_directionRestriction < 180) && {_newMove > _directionRestriction}) exitWith {false};

private _turretIndex = MON_GVAR(_monitor, _instId, "CFM_currentTurret", [-1]);

[_operator, _turretIndex, _direction, _step] call CFM_fnc_cameraMove;
