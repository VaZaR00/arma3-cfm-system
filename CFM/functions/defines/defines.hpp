#define OPTIMIZE_MONITOR_FEED_DIST "20"

#define DO_CAM_INTERPOLATION false

#define PREFX CFM
#define SPREFX STR(CFM)

#define I ,
#define SET_LOCAL_CAM_VECTORS_TIMEOUT 0.05
#define STR(s) #s
#define DEFAULT_PIP_SETTINGS [0.3, 1, 0.8]
#define DEFAULT_PIP_SETTINGS_STR STR(DEFAULT_PIP_SETTINGS)
#define GOPRO "gopro"
#define DRONETYPE "droneTurret"
#define DEF_FOV_GOPRO 0.85
#define STATIC_ATTACHED_CAMS_TYPES [DRONETYPE]
#define GOPRO_MEMPOINT "neck"
#define OBJ_LOD(o) (o getVariable ["CFM_lod", call {private _lod = (((allLODs o) select {((_x select 1) isEqualTo "memory")}) select 0) select 0; o setVariable ["CFM_lod", _lod];_lod}]) 
#define OBJ_LOD_VAR(var, o) private var = OBJ_LOD(o); o setVariable ["CFM_lod", var];
#define IS_FPV(cls) (("fpv" in cls) || {("crocus" in cls)})
#define IS_MAVIC(cls) ("mavik_3" in cls)
#define DRIVER_TURRET_PATH [-1]
#define GUNNER_TURRET_PATH [0]
#define ACTION_RADIUS 5
#define NULL_VECTOR [0,0,0]
#define DEF_DIR [0,1,0]
#define DEF_UP [0,0,1]
#define MONITOR_ACTION_RADIUS(mon) (mon getVariable ["CFM_actionsRadius", ACTION_RADIUS]) 
#define FEED_ACTION_CONDITION "((_target getVariable ['CFM_feedActive', false])"
#define DIST_ACTION_CONDITION "((_target distance PLAYER_) < 5)"
#define BASIC_ACTION_CONDITION (format["%1 && %2", FEED_ACTION_CONDITION, DIST_ACTION_CONDITION])
#define IS_OBJ(o) (!(o isEqualTo objNull) && {o isEqualType objNull})
#define IS_STR(s) (s isEqualType "")
#define IS_FUNC(f) ((f isEqualType {}) && !(f isEqualTo {}))
#define IS_LOC(l) ((typeName l) isEqualTo "LOCATION")
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
#define VALIDATE_NUM_VAR(var, def) (call {private _val = (MGVAR [var, "5"]); if (_val isEqualType "") then {parseNumber _val} else {_val}})

#define MONITOR_VIEWERS(islocal) (if (islocal) then {false} else {missionNamespace getVariable ["CFM_ActiveMonitorViewers", [2]]})
#define MONITOR_VIEWERS_AND_SELF(islocal) (if (islocal) then {false} else {private _viewers = +(missionNamespace getVariable ["CFM_ActiveMonitorViewers", [2]]); _viewers pushBackUnique clientOwner; _viewers})

#define PLAYER_ (MGVAR ['bis_fnc_moduleremotecontrol_unit', player])
// #define PLAYER_ player
#define PLAYER_STR STR(PLAYER_)

#define RLOG call {_txt = text format["[RLOG]  %3%4 :: %2 :: %1", _this, serverTime, __FILE_SHORT__, if !(isNil "_ooMember") then {format[".%1", _ooMember]} else {""}]; hint _txt; diag_log _txt};
#define DLOG call {_txt = text format["[DLOG]  %3%4 :: %2 :: %1", _this, serverTime, __FILE_SHORT__, if !(isNil "_ooMember") then {format[".%1", _ooMember]} else {""}]; diag_log _txt};
#define VARS_STR call {if !(_this isEqualType []) then {_this = ["", _this]}; params["_txt", ["_varstr", ""]]; if (_varstr isEqualTo "") then {_varstr = _txt}; private _ar = _varstr splitString ",;. "; private _arvs = _ar apply {private _val = call compile format["if !(isNil '%1') then {%1}", _x]; if (isNil "_val") then {""} else {format["%1: %2", _x, _val]}}; _txt + "  :  " + (_arvs joinString "; ")}
#define LOG_VARS ;
#define RLOG_VARS VARS_STR RLOG
#define LOGH hintSilent str
#define HINT hint
#define CLEAR_HINT hint "";
#define _HINT call {hint _this};
#define WARN DLOG
#define LOG_VARS(txt, vars) LOGH ([txt, vars] VARS_STR);