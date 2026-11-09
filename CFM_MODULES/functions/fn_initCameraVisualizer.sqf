/*
	Function: CFM_fnc_initCameraVisualizer

	Author: Vazar

	Description:
		Creates a local simple object visualization for the camera module in 3DEN editor
		and maintains a single EachFrame event handler to update its position and orientation.

	Parameters:
		0: OBJECT - Camera module logic entity

	Returns:
		OBJECT - Created visualizer object, or objNull
*/

#include "defines.hpp"

if (!is3DEN) exitWith { objNull };

params [["_module", objNull, [objNull]]];

if (isNull _module) exitWith { objNull };

if (isNil "CFM_cameraVisualizerList") then {
	CFM_cameraVisualizerList = [];
};

if (isNil "CFM_cameraVisualizerHandler") then {
	CFM_cameraVisualizerHandler = -1;
};

if (isNil "CFM_cameraVisualizerScale") then {
	CFM_cameraVisualizerScale = 0.2;
};

// Проверяем, существует ли уже визуализатор для данного модуля
private _existingIdx = CFM_cameraVisualizerList findIf { (_x select 0) isEqualTo _module };
if (_existingIdx != -1) then {
	private _existingObj = (CFM_cameraVisualizerList select _existingIdx) select 1;
	if (!isNull _existingObj) exitWith {
		_existingObj
	};
	CFM_cameraVisualizerList deleteAt _existingIdx;
};

// Получаем путь к 3D-модели из конфига модуля
private _model = getText (configFile >> "CfgVehicles" >> typeOf _module >> "model");
if (_model isEqualTo "" || {"empty" in toLower _model}) then {
	_model = "\a3\data_f\camera.p3d";
};

// Создаем локальный simple object без физики и симуляции
private _pos = getPosASLVisual _module;
private _visObj = createSimpleObject [_model, _pos, false];

if (isNull _visObj) exitWith {
	format ["CFM_fnc_initCameraVisualizer: Failed to create simple object with model '%1'", _model] WARN;
	objNull
};

_visObj enableSimulation false;
_visObj disableCollisionWith _module;
_visObj setPosASL _pos;
_visObj setObjectScale CFM_cameraVisualizerScale; // Масштабируем визуализатор, чтобы он был меньше 
_visObj setVectorDirAndUp [vectorDirVisual _module, vectorUpVisual _module];

CFM_cameraVisualizerList pushBack [_module, _visObj];

// Запускаем единый per-frame обработчик, если он еще не активен
if (CFM_cameraVisualizerHandler isEqualTo -1) then {
	CFM_cameraVisualizerHandler = addMissionEventHandler ["EachFrame", {
		// Проверка: если мы вышли из 3DEN (например, запуск миссии/превью),
		// удаляем хендлер и все созданные временные объекты
		if (!is3DEN) exitWith {
			removeMissionEventHandler ["EachFrame", _thisEventHandler];
			CFM_cameraVisualizerHandler = -1;
			{
				_x params ["", "_vis"];
				if (!isNull _vis) then {
					deleteVehicle _vis;
				};
			} forEach (missionNamespace getVariable ["CFM_cameraVisualizerList", []]);
			CFM_cameraVisualizerList = [];
		};

		private _list = missionNamespace getVariable ["CFM_cameraVisualizerList", []];
		if (_list isEqualTo []) exitWith {
			removeMissionEventHandler ["EachFrame", _thisEventHandler];
			CFM_cameraVisualizerHandler = -1;
		};

		private _toRemove = [];

		{
			_x params ["_mod", "_vis"];

			if (isNull _mod) then {
				// Модуль удален в редакторе - удаляем временный объект
				if (!isNull _vis) then {
					deleteVehicle _vis;
				};
				_toRemove pushBack _forEachIndex;
			} else {
				if (isNull _vis) then {
					_toRemove pushBack _forEachIndex;
				} else {
					// Синхронизируем положение и направление с модулем в реальном времени
					_vis setPosASL (_mod modelToWorldVisualWorld [0, 0, 0]);
					_vis setVectorDirAndUp [vectorDirVisual _mod, vectorUpVisual _mod];
					_vis setObjectScale CFM_cameraVisualizerScale;
				};
			};
		} forEach _list;

		if (_toRemove isNotEqualTo []) then {
			for "_i" from ((count _toRemove) - 1) to 0 step -1 do {
				_list deleteAt (_toRemove select _i);
			};
		};
	}];
};

_visObj
