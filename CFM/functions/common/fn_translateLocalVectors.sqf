/*
    Function: CFM_fnc_translateLocalVectors
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params ["_dirUp1", "_dirUp2"];
_dirUp1 params ["_dir1", "_up1"];
_dirUp2 params ["_dir2", "_up2"];

// 1. Вычисляем базисные векторы первой системы (DirUp1)
private _yAxis = _dir1;
private _zAxis = _up1;
private _xAxis = _yAxis vectorCrossProduct _zAxis; // Ось X (право)

// 2. Функция для перевода вектора из локала DirUp1 в Model Space
// Формула: V_world = (X * V_local.x) + (Y * V_local.y) + (Z * V_local.z)
private _transformVector = {
	params ["_v", "_x", "_y", "_z"];
	private _res = [0,0,0];
	_res = _res vectorAdd (_x vectorMultiply (_v select 0));
	_res = _res vectorAdd (_y vectorMultiply (_v select 1));
	_res = _res vectorAdd (_z vectorMultiply (_v select 2));
	_res
};

// 3. Применяем трансформацию для Dir2 и Up2
private _finalDir = [_dir2, _xAxis, _yAxis, _zAxis] call _transformVector;
private _finalUp = [_up2, _xAxis, _yAxis, _zAxis] call _transformVector;

// Нормализуем для порядка (хотя векторные команды часто делают это сами)
_finalDir = vectorNormalized _finalDir;
_finalUp = vectorNormalized _finalUp;

// Результат: [_finalDir, _finalUp]
[_finalDir, _finalUp]
