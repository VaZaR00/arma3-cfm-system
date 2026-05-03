/*
    Function: CFM_fnc_camPosVehTurret
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_obj", ["_pointParams", []]];

// _pointParams: [_memPoint, [_addArr, [_dir, _up], _setArr]]

_pointParams params [["_memPoint", ""], ["_alignment", []]];

private _doAlign = !(_alignment isEqualTo []);
private _pointOffset = if (_doAlign) then {
	[_obj, _memPoint, _alignment] call CFM_fnc_memoryPointAlignment;
} else {
	[
        _obj selectionPosition [_memPoint, "Memory"],
        _obj selectionVectorDirAndUp [_memPoint, "Memory"]
    ]
};

[
    _obj modelToWorldVisualWorld (_pointOffset#0), 
    _obj vectorModelToWorldVisual (_pointOffset#1#0), 
    _obj vectorModelToWorldVisual (_pointOffset#1#1)
]
