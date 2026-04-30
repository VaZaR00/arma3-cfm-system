/*
    Function: CFM_fnc_getMemPointOffsetInModelSpace
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params ["_obj", ["_selectionData", ["head", "Memory"]], ["_offset", [0,0,0]]];

_selectionData params [["_selectionName", ""], ["_lod", "Memory"]];

// 1. Получаем позицию селекшна в Model Space
private _selectionPosMS = _obj selectionPosition [_selectionName, _lod];

// 2. Получаем ориентацию селекшна (векторы направления и верха)
private _dirUp = _obj selectionVectorDirAndUp _selectionData;
private _dir = _dirUp#0;
private _up = _dirUp#1;

// 3. Строим правую сторону (вектор Right) для полной системы координат
private _right = _dir vectorCrossProduct _up;

// 4. Трансформируем офсет
// Мы умножаем компоненты офсета на соответствующие векторы ориентации
private _rotatedOffset = [0,0,0];
_rotatedOffset = _rotatedOffset vectorAdd (_right vectorMultiply (_offset select 0)); // X - влево/вправо
_rotatedOffset = _rotatedOffset vectorAdd (_dir   vectorMultiply (_offset select 1)); // Y - вперед/назад
_rotatedOffset = _rotatedOffset vectorAdd (_up    vectorMultiply (_offset select 2)); // Z - вверх/вниз

// 5. Итоговая позиция в Model Space
_selectionPosMS vectorAdd _rotatedOffset
