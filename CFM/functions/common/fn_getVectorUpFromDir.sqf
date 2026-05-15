/*
    Function: CFM_fnc_getVectorUpFromDir
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

private _dir = _this;
private _worldUp = [0, 0, 1];

// Вычисляем вектор "вправо" относительно направления и мира
private _right = _dir vectorCrossProduct _worldUp;

// Если направление смотрит строго вверх или вниз,
// векторное произведение со [0,0,1] даст [0,0,0]. Нужно это учесть:
if (vectorMagnitude _right == 0) then {
	_right = [1, 0, 0]; // Берем произвольную ось X
};

// Вычисляем финальный VectorUp
private _up = _right vectorCrossProduct _dir;
vectorNormalized _up
