/*
    Function: CFM_fnc_getPositionByVectors
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params [
	["_startPos", [0,0,0], [[]], [3]],
	["_vectorDir", DEF_DIR, [[]], [3]],
	["_distance", 0, [0]]
];

// 1. Нормализуем вектор (приводим его длину к 1), чтобы избежать ошибок,
// если переданный вектор имеет произвольную длину.
private _normalizedDir = vectorNormalized _vectorDir;

// 2. Умножаем нормализованный вектор на нужную дистанцию.
private _offset = _normalizedDir vectorMultiply _distance;

// 3. Складываем начальную позицию с полученным смещением.
private _finalPos = _startPos vectorAdd _offset;

_finalPos
