/*
    Function: CFM_fnc_randInt
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params ["_x", "_y", "_r", "_M"];
// Добавляем больше "перемешивания" бит через циклическое умножение
private _val = sin (_x * 2.9898 + _y * 1.223 + _r * 0.123);
_val = _val * 558.5453;
private _frac = _val - floor _val;
_M * _frac
