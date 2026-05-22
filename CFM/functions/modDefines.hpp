
#include "Classes\classDefinesVer1.hpp"
#ifdef DEV
#include "..\..\..\OOP_proj\OOP\includes\classDefines.hpp"
#endif
#ifndef DEV
#include "z\oop_system\addons\oop\includes\classDefines.hpp"
#endif


#define OPTIMIZE_MONITOR_FEED_DIST "20"

#define DO_CAM_INTERPOLATION false

#define SET_LOCAL_CAM_VECTORS_TIMEOUT 0.05
#define DEFAULT_PIP_SETTINGS [0.3, 1, 0.8]
#define DEFAULT_PIP_SETTINGS_STR STR(DEFAULT_PIP_SETTINGS)
#define GOPRO "gopro"
#define DRONETYPE "droneTurret"
#define DEF_FOV_GOPRO 0.85
#define STATIC_ATTACHED_CAMS_TYPES [DRONETYPE]
#define GOPRO_MEMPOINT "neck"
#define OBJ_LOD(o) (o getVariable ["CFM_lod", call {private _lod = (((allLODs o) select {((_x select 1) isEqualTo "memory")}) select 0) select 0; o setVariable ["CFM_lod", _lod];_lod}]) 
#define OBJ_LOD_VAR(var, o) private var = OBJ_LOD(o); o setVariable ["CFM_lod", var];
#define DRIVER_TURRET_IDX -1
#define GUNNER_TURRET_IDX 0
#define DRIVER_TURRET_PATH [-1]
#define GUNNER_TURRET_PATH [0]
#define ACTION_RADIUS 5
#define DEF_CAM_MOVE_RESTR [85,85,180,180]
#define MONITOR_ACTION_RADIUS(mon) (mon getVariable ["CFM_actionsRadius", ACTION_RADIUS]) 
#define FEED_ACTION_CONDITION "((_target getVariable ['CFM_feedActive', false])"
#define DIST_ACTION_CONDITION "((_target distance PLAYER_) < 5)"
#define BASIC_ACTION_CONDITION (format["%1 && %2", FEED_ACTION_CONDITION, DIST_ACTION_CONDITION])
#define IS_VALID_OP(op) (IS_OBJ(op))
#define TYPE_VEH "veh"
#define TYPE_UAV "uav"
#define TYPE_WEAP "weap"
#define TYPE_HELM "helm"
#define TYPE_UNIT "unit"
#define TYPE_STATIC "static"
#define PP_NONE -1
#define PP_STATIC 0
#define PP_VEH_STATIC 1
#define PP_VEH_TURRET 2
#define MGVAR missionNamespace getVariable
#define VALID_CLASS_TYPES [TYPE_VEH, TYPE_UAV, TYPE_WEAP, TYPE_HELM, TYPE_UNIT, TYPE_STATIC]
#define CHECK_EX(c) if (c) exitWith {false};
#define IS_VALID_R2T(s) ((IS_STR(s) && {!(s isEqualTo "") && {(RENDER_TARGET_STR in s)}}))
#define CAM_POS_FUNC_DEF {[NULL_VECTOR, [DEF_DIR, DEF_UP]]}
#define TURRET_INDEX(t) (if (t isEqualType []) then {t select 0} else {t})
#define HAND_MON_CONDITION if ([_target] call CFM_fnc_handMonitorMenuActionCondition) exitWith {false};
#define IS_MONITOR_ON ;
#define IS_MONITOR_ON if ((_target getVariable ["CFM_isHandMonitor", false]) && {_target getVariable ['CFM_turnedOffLocal', false]}) exitWith {false};
#define CAMERA_MOVE_DIRECTIONS ["up", "down", "left", "right"]
#define CAMERA_MOVE_STEP 5
#define GET_MON (call CFM_fnc_getTargetMonitor)
#define VALIDATE_NUM_VAR(var, def) (call {private _val = (MGVAR [var, "5"]); if (_val isEqualType "") then {parseNumber _val} else {_val}})

#define MONITOR_VIEWERS(islocal) (if (islocal) then {false} else {missionNamespace getVariable ["CFM_ActiveMonitorViewers", [2]]})
#define MONITOR_VIEWERS_AND_SELF(islocal) (if (islocal) then {false} else {private _viewers = +(missionNamespace getVariable ["CFM_ActiveMonitorViewers", [2]]); _viewers pushBackUnique clientOwner; _viewers})


#define WAIT_FOR_DISPLAY_TIME 10
#define DISP_CTRL _display displayCtrl
#define GET_CTRL(name, id) uiNamespace setVariable [name + _uiDisplayUniqueName, _display displayCtrl id];
#define GET_CTRL_GRP(name, grpid, ctrlid) uiNamespace setVariable [name + _uiDisplayUniqueName, (_display displayCtrl grpid) controlsGroupCtrl ctrlid];


#define TURR_INDX_STR(idx) ((if (idx < 0) then {"n" + (str (abs idx))} else {str idx}))
#define TURR_INDX_VAR(name, idx) (format["%1%2", name, TURR_INDX_STR(idx)])

#define RENDER_TARGET_STR "cfmrendertarget"
#define UI_RENDER_ID_STR "cfmrenderuiid"
#define ACTIONS_PRIORITY 956

#define FULLSCREEN_HINT_NL(nl) (format["TO EXIT FULLSCREEN MOVE BY MOUSE OR KEYBOARD! %1 АБИ ВИЙТИ З ПОВНОЕКРАННОГО РЕЖИМУ ПОВОРУХНІТСЯ (МИШКОЮ АБО КЛАВІШАМИ)!", nl])
#define FULLSCREEN_HINT FULLSCREEN_HINT_NL(endl)
#define FULLSCREEN_TEMPCAM_HINT_NL(nl) (format["%2 %1 %3", nl, FULLSCREEN_TEMPCAM_HINT_ENG, FULLSCREEN_TEMPCAM_HINT_UKR])
#define FULLSCREEN_TEMPCAM_HINT_ENG "TO EXIT FULLSCREEN PRESS 'CTRL + E' OR YOUR BIND."
#define FULLSCREEN_TEMPCAM_HINT_UKR "АБИ ВИЙТИ З ПОВНОЕКРАННОГО РЕЖИМУ НАТИСНІТЬ 'CTRL + E' АБО СВІЙ БІНД."
#define FULLSCREEN_TEMPCAM_HINT FULLSCREEN_TEMPCAM_HINT_NL(endl)
#define CHECK_OP_COND_FREQ 2
#define DUMMY_CLASSNAME "Land_HelipadEmpty_F"
#define DO_INTERPOLATE_STATIC_CAMS true
#define DO_INTERPOLATE_TOLERANCE 0.0001

#define SET_MON_OP_REMOTE_EXEC


#define SIGNAL_WEAK_CONNECTION_THREASHOLD 0.1
#define SIGNAL_LOST 0


#define TURRET_VAR(name, def) (IVAR(_turretObject, "Turret", name, def))
#define TURRET_INSTANCE(index) (_turretsInstances getOrDefault [index, [-1, objNull]])
#define TURRET_INSTANCE_ID(index) ((TURRET_INSTANCE(index)) select 0)
#define TURRET_INSTANCE_OBJECT(index) ((TURRET_INSTANCE(index)) select 1)
#define CALL_TURRET_INSTANCE(index) call {private _turrIdx = TURRET_INDEX(index); private _turrInst = TURRET_INSTANCE(_turrIdx); CALL_OBJINSTANCE("Turret", (_turrInst select 0), (_turrInst select 1))};
