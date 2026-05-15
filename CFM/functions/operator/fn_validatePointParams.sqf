/*
    Function: CFM_fnc_validatePointParams
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_ppType", -1], ["_prevParams", []], ["_params", []]];

#define VALID_VECTOR(vec) ((vec isEqualType []) && {(count vec) == 3})
#define VALIDATE_VECTOR_SET_DEF(vec) if !(VALID_VECTOR(vec)) then {vec = [0,0,0]};
#define VALIDATE_VECTOR_SET_DEF_DIR(vec) if !(VALID_VECTOR(vec)) then {vec = DEF_DIR};
#define VALIDATE_VECTOR_SET_DEF_UP(vec) if !(VALID_VECTOR(vec)) then {vec = DEF_UP};

switch (_ppType) do {
	case PP_STATIC: {
		_prevParams params [['_prevpos', []], ['_prevdir', []], ['_prevup', []]];
		_params params [['_pos', []], ['_dir', []], ['_up', []]];

		VALIDATE_VECTOR_SET_DEF(_prevpos)
		VALIDATE_VECTOR_SET_DEF_DIR(_prevdir)
		VALIDATE_VECTOR_SET_DEF_UP(_prevup)

		if !(VALID_VECTOR(_pos)) then {
			_pos = +_prevpos;
		};
		if !(VALID_VECTOR(_dir)) then {
			_dir = +_prevdir;
		};
		if !(VALID_VECTOR(_up)) then {
			_up = +_prevup;
		};
		[_pos, _dir, _up]
	};
	case PP_VEH_STATIC: {
		_prevParams params [['_prevpos', []], ['_prevdir', []], ['_prevup', []]];
		_params params [['_pos', []], ['_dir', []], ['_up', []]];

		if ((_pos isEqualType "") || {(_pos#0) isEqualType ""}) then {
			// case if we need to convert params for PP_VEH_TURRET into PP_VEH_STATIC
			_params params[["_memPoint", ""], ["_addArr", []], ["_sdir", []], ["_sup", []], ["_setArr", []]];
			_pos = _addArr;
			_dir = _sdir;
			_up = _sup;
		};

		VALIDATE_VECTOR_SET_DEF(_prevpos)
		VALIDATE_VECTOR_SET_DEF_DIR(_prevdir)
		VALIDATE_VECTOR_SET_DEF_UP(_prevup)

		if !(VALID_VECTOR(_pos)) then {
			_pos = +_prevpos;
		};
		if !(VALID_VECTOR(_dir)) then {
			_dir = +_prevdir;
		};
		if !(VALID_VECTOR(_up)) then {
			_up = +_prevup;
		};
		[_pos, [_dir, _up]]
	};
	case PP_VEH_TURRET: {
		_prevParams params [['_prevMemPoint', ""], ['_prevAlignment', []], ['_prevlod', "Memory"]];
		_prevAlignment params [["_prevAddArr", []], ["_prevDirUp", []], ["_prevSetArr", []]];
		_prevDirUp params [["_prevDir", []], ["_prevUp", []]];

		_params params[["_memPoint", ""], ["_addArr", []], ["_dir", []], ["_up", []], ["_setArr", []]];
		private _lod = "";

		if (_memPoint isEqualType []) then {
			_lod = _memPoint param [1,"memory"];
			_memPoint = _memPoint param [0,""];
		};

		if !(VALID_VECTOR(_prevSetArr)) then {_prevSetArr = [-1,-1,-1]};
		if !((_memPoint isEqualType "") && !(_memPoint isEqualTo "")) then {_prevMemPoint = ""};
		VALIDATE_VECTOR_SET_DEF(_prevAddArr)
		VALIDATE_VECTOR_SET_DEF_DIR(_prevDir)
		VALIDATE_VECTOR_SET_DEF_UP(_prevUp)

		if !(VALID_VECTOR(_addArr)) then {
			_addArr = +_prevAddArr;
		};
		if !(VALID_VECTOR(_setArr)) then {
			_setArr = +_prevSetArr;
		};
		if !(VALID_VECTOR(_dir)) then {
			_dir = +_prevDir;
		};
		if !(VALID_VECTOR(_up)) then {
			_up = +_prevUp;
		};
		if !((_memPoint isEqualType "") && !(_memPoint isEqualTo "")) then {
			_memPoint = _prevMemPoint;
		};
		if !((_lod isEqualType "") && !(_lod isEqualTo "")) then {
			_lod = _prevlod;
		};
		[_memPoint, [_addArr, [_dir, _up], _setArr], _lod]
	};
	default {[]};
};
