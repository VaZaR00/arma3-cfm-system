/*
    Function: CFM_fnc_getMemPointOffsetInModelSpace
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params [
    "_obj", 
    ["_selectionData", ["head", "Memory"]], 
    ["_offset", [0,0,0]], 
    ["_offsetDirUp", [[0,1,0], [0,0,1]]] // По умолчанию: смотреть туда же, куда селекшн
];

_selectionData params [["_selectionName", ""], ["_lod", "Memory"]];
_offsetDirUp params [["_offDir", [0,1,0]], ["_offUp", [0,0,1]]];

// 1. Получаем базу: позицию и ориентацию селекшна в Model Space
private _selectionPosMS = _obj selectionPosition [_selectionName, _lod];
private _dirUp = _obj selectionVectorDirAndUp _selectionData;
private _sDir = _dirUp # 0;
private _sUp = _dirUp # 1;
private _sRight = _sDir vectorCrossProduct _sUp;

// --- Функция для трансформации вектора из локального пространства селекшна в Model Space ---
private _fnc_transformVector = {
    params ["_vec", "_dir", "_up", "_right"];
    private _out = [0,0,0];
    _out = _out vectorAdd (_right vectorMultiply (_vec # 0)); // X
    _out = _out vectorAdd (_dir   vectorMultiply (_vec # 1)); // Y
    _out = _out vectorAdd (_up    vectorMultiply (_vec # 2)); // Z
    _out
};

// 2. Рассчитываем итоговую позицию (Offset)
private _rotatedOffset = [_offset, _sDir, _sUp, _sRight] call _fnc_transformVector;
private _finalPosMS = _selectionPosMS vectorAdd _rotatedOffset;

// 3. Рассчитываем итоговые векторы направления и верха
// Мы берем локальный оффсет вектора (например [0,1,0]) и поворачиваем его по базису селекшна
private _finalDirMS = [_offDir, _sDir, _sUp, _sRight] call _fnc_transformVector;
private _finalUpMS  = [_offUp,  _sDir, _sUp, _sRight] call _fnc_transformVector;

// Возвращаем массив: [Позиция MS, [VectorDir MS, VectorUp MS]]
[_finalPosMS, [_finalDirMS, _finalUpMS]]