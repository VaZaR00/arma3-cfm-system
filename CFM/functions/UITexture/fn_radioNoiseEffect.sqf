/*
    Function: CFM_fnc_radioNoiseEffect
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_signal", 1], ["_effectLayerCtrl", controlNull], ["_effectAdjust", 1]];

private _serverTime = serverTime;
private _intX = _serverTime - (_serverTime - ((_serverTime mod 20)));
private _randInt1 = [_signal - 0.1, (-_intX - 1), -_signal, 220] call CFM_fnc_randInt;
private _randInt2 = [-_signal + 1, _intX, _signal + 2, 220] call CFM_fnc_randInt;
private _effectStrenght = (((1 - _signal) max 0) * 2) * _effectAdjust;

_effectLayerCtrl ctrlSetText (format["#(ai,128,128,1)perlinNoise(%2,%3,0,%1)", _effectStrenght, _randInt1, _randInt2]);
