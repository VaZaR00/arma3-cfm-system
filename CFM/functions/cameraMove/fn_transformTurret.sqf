/*
    Function: CFM_fnc_transformTurret
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params ["_dir", "_up", "_pitch", "_yaw"];

// 1. Глобальный Yaw (вокруг оси [0, 0, 1])
if (_yaw != 0) then {
    private _worldZ = [0, 0, 1];
    _dir = [_dir, _worldZ, _yaw] call CFM_fnc_rotateAroundAxis;
    _up = [_up, _worldZ, _yaw] call CFM_fnc_rotateAroundAxis;
};

// 2. Локальный Pitch
if (_pitch != 0) then {
    // Вычисляем "право" ПОСЛЕ поворота по Yaw, чтобы оно было актуальным
    private _side = _dir vectorCrossProduct _up;

    _dir = [_dir, _side, _pitch] call CFM_fnc_rotateAroundAxis;
    _up = [_up, _side, _pitch] call CFM_fnc_rotateAroundAxis;
};

[_dir, _up]
