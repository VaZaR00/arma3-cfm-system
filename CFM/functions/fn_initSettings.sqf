#include "\a3\ui_f\hpp\definedikcodes.inc"
#include "defines.hpp"
#define CFM_CATEGORY CFM_STR_SETTINGS_CATEGORY
#define OPTIMIZE_MONITOR_FEED_DIST "20"

// CBA settings
["CFM_allUavsAreFeedingByDefault",  "CHECKBOX",  [CFM_STR_ALL_UAVS_FEED_BY_DEFAULT, CFM_STR_DESC_ALL_UAVS_FEED_BY_DEFAULT], CFM_CATEGORY, false, 1] call CBA_fnc_addSetting;
["CFM_PIPsettings",  "EDITBOX",  [CFM_STR_PIP_SETTINGS, CFM_STR_DESC_PIP_SETTINGS], CFM_CATEGORY, DEFAULT_PIP_SETTINGS_STR] call CBA_fnc_addSetting;
["CFM_useScrollMenuForConnection",  "CHECKBOX",  [CFM_STR_USE_SCROLL_MENU, CFM_STR_DESC_USE_SCROLL_MENU], CFM_CATEGORY, true] call CBA_fnc_addSetting;
["CFM_canFullscreen",  "CHECKBOX",  [CFM_STR_CAN_FULLSCREEN, CFM_STR_DESC_CAN_FULLSCREEN], CFM_CATEGORY, false, 1] call CBA_fnc_addSetting;
["CFM_optimizeByDistance",  "EDITBOX",  [CFM_STR_OPTIMIZE_BY_DISTANCE, CFM_STR_DESC_OPTIMIZE_BY_DISTANCE], CFM_CATEGORY, OPTIMIZE_MONITOR_FEED_DIST] call CBA_fnc_addSetting;
["CFM_menuShowOperatorGrid",  "CHECKBOX",  [CFM_STR_SHOW_OPERATOR_GRID, CFM_STR_DESC_SHOW_OPERATOR_GRID], CFM_CATEGORY, false] call CBA_fnc_addSetting;
["CFM_menuShowOperatorDistance",  "CHECKBOX",  [CFM_STR_SHOW_OPERATOR_DISTANCE, CFM_STR_DESC_SHOW_OPERATOR_DISTANCE], CFM_CATEGORY, false] call CBA_fnc_addSetting;
["CFM_allHandMonitorsAreDisplays",  "CHECKBOX",  [CFM_STR_ALL_HAND_MONITORS_FULLSCREEN, CFM_STR_DESC_ALL_HAND_MONITORS_FULLSCREEN], CFM_CATEGORY, true, 1] call CBA_fnc_addSetting;
["CFM_fullscreenIsPip",  "CHECKBOX",  [CFM_STR_FULLSCREEN_IS_PIP, CFM_STR_DESC_FULLSCREEN_IS_PIP], CFM_CATEGORY, true] call CBA_fnc_addSetting;
["CFM_cameraMoveSensitivity",  "SLIDER",  [CFM_STR_CAMERA_MOVE_SENSITIVITY, CFM_STR_DESC_CAMERA_MOVE_SENSITIVITY], CFM_CATEGORY, [0, 50, 5, 1, false]] call CBA_fnc_addSetting;
["CFM_camInterpolation_tightnessOffset",  "EDITBOX",  [CFM_STR_CAMERA_ROTATION_TIGHTNESS, CFM_STR_DESC_CAMERA_ROTATION_TIGHTNESS], CFM_CATEGORY, "5", 1] call CBA_fnc_addSetting;
["CFM_camInterpolation_tightnessZoom",  "EDITBOX",  [CFM_STR_CAMERA_ZOOM_TIGHTNESS, CFM_STR_DESC_CAMERA_ZOOM_TIGHTNESS], CFM_CATEGORY, "10", 1] call CBA_fnc_addSetting;
["CFM_canInterceptUAVcontrol",  "CHECKBOX",  [CFM_STR_CAN_INTERCEPT_UAV_CONTROL, CFM_STR_DESC_CAN_INTERCEPT_UAV_CONTROL], CFM_CATEGORY, false, 1] call CBA_fnc_addSetting;
["CFM_canMoveDroneCameras",  "CHECKBOX",  [CFM_STR_CAN_MOVE_UAV_CAMERAS, CFM_STR_DESC_CAN_MOVE_UAV_CAMERAS], CFM_CATEGORY, true, 1] call CBA_fnc_addSetting;
["CFM_canMoveDroneCameraIfUavControlled",  "CHECKBOX",  [CFM_STR_CAN_INTERCEPT_MOVE_UAV_CAMERAS, CFM_STR_DESC_CAN_INTERCEPT_MOVE_UAV_CAMERAS], CFM_CATEGORY, false, 1] call CBA_fnc_addSetting;
["CFM_canHackDrone",  "CHECKBOX",  [CFM_STR_CAN_HACK_UAV, CFM_STR_DESC_CAN_HACK_UAV], CFM_CATEGORY, true, 1] call CBA_fnc_addSetting;
["CFM_canChangeZoomOnDrones",  "CHECKBOX",  [CFM_STR_CAN_CHANGE_ZOOM_ON_UAV, CFM_STR_DESC_CAN_CHANGE_ZOOM_ON_UAV], CFM_CATEGORY, true, 1] call CBA_fnc_addSetting;
["CFM_Mavic_dropShowMessageEH",  "CHECKBOX",  [CFM_STR_MAVIC_SHOW_GRENADE_DROP_MESSAGE, CFM_STR_DESC_MAVIC_SHOW_GRENADE_DROP_MESSAGE], CFM_CATEGORY, true, 1] call CBA_fnc_addSetting;
["CFM_useR2Tsystem",  "CHECKBOX",  [CFM_STR_USE_R2T_SYSTEM, CFM_STR_DESC_USE_R2T_SYSTEM], CFM_CATEGORY, false, 1] call CBA_fnc_addSetting;

[CFM_CATEGORY, "CFM_enterFullScreenKey", [CFM_STR_ENTER_FULLSCREEN_MODE, CFM_STR_ENTER_FULLSCREEN_MODE], {call CFM_fnc_enterFullscreenKeybind}, "", [DIK_F, [true, false, false]]] call CBA_fnc_addKeybind;
[CFM_CATEGORY, "CFM_exitFullScreenKey", [CFM_STR_EXIT_FULLSCREEN_MODE, CFM_STR_EXIT_FULLSCREEN_MODE], {call CFM_fnc_exitFullscreenKeybind}, "", [18, [false, true, false]]] call CBA_fnc_addKeybind;
[CFM_CATEGORY, "CFM_zoomInKey", [CFM_STR_ZOOM_IN, CFM_STR_ZOOM_IN], {call CFM_fnc_zoomInKeybind}, "", [52, [false, true, false]]] call CBA_fnc_addKeybind;
[CFM_CATEGORY, "CFM_zoomOutKey", [CFM_STR_ZOOM_OUT, CFM_STR_ZOOM_OUT], {call CFM_fnc_zoomOutKeybind}, "", [51, [false, true, false]]] call CBA_fnc_addKeybind;
[CFM_CATEGORY, "CFM_resetZoomKey", [CFM_STR_RESET_ZOOM, CFM_STR_RESET_ZOOM], {call CFM_fnc_zoomResetKeybind}, "", [54, [false, true, false]]] call CBA_fnc_addKeybind;
[CFM_CATEGORY, "CFM_operatorZoomKey", [CFM_STR_USE_OPERATOR_ZOOM, CFM_STR_USE_OPERATOR_ZOOM], {call CFM_fnc_zoomOperatorKeybind}, "", [53, [false, true, false]]] call CBA_fnc_addKeybind;
[CFM_CATEGORY, "CFM_takeUavControlKey", [CFM_STR_TAKE_UAV_CONTROL, CFM_STR_TAKE_UAV_CONTROL], {call CFM_fnc_takeUavCtrlKeybind}, "", [53, [false, false, true]]] call CBA_fnc_addKeybind;
[CFM_CATEGORY, "CFM_switchTurret", [CFM_STR_SWITCH_TURRETS, CFM_STR_DESC_SWITCH_TURRETS], {call CFM_fnc_nextTurretKeybind}, "", [83, [false, false, true]]] call CBA_fnc_addKeybind;
[CFM_CATEGORY, "CFM_switchTiKey", [CFM_STR_SWITCH_TI_MODES, CFM_STR_DESC_SWITCH_TI_MODES], {call CFM_fnc_monitorSwitchTIKeybind}, "", [49, [false, true, false]]] call CBA_fnc_addKeybind;
[CFM_CATEGORY, "CFM_toggleNVGKey", [CFM_STR_TOGGLE_NVG_MODE, CFM_STR_DESC_TOGGLE_NVG_MODE], {call CFM_fnc_monitorSwitchNVGKeybind}, "", [49, [false, false, false]]] call CBA_fnc_addKeybind;
[CFM_CATEGORY, "CFM_disconnectOperatorKey", [CFM_STR_DISCONNECT_OPERATOR, CFM_STR_DESC_DISCONNECT_OPERATOR], {call CFM_fnc_disconnectMonitorFromOperatorKeybind}, "", [48, [false, true, false]]] call CBA_fnc_addKeybind;
[CFM_CATEGORY, "CFM_fixFeedKey", [CFM_STR_FIX_RESET_FEED, CFM_STR_FIX_RESET_FEED], {[cursorObject] call CFM_fnc_fixFeedKeybind}, "", [33, [false, true, false]]] call CBA_fnc_addKeybind;
[CFM_CATEGORY, "CFM_fixAllMonitorsFeedKey", [CFM_STR_FIX_RESET_ALL_MONITORS, CFM_STR_FIX_RESET_ALL_MONITORS], {[] call CFM_fnc_fixFeedKeybind}, "", [33, [false, false, true]]] call CBA_fnc_addKeybind;
[CFM_CATEGORY, "CFM_turnOnOffKey", [CFM_STR_TOGGLE_MONITOR_LOCAL, CFM_STR_TOGGLE_MONITOR_LOCAL], {call CFM_fnc_turnOnOffMonitorLocalKeybind}, "", [20, [false, true, false]]] call CBA_fnc_addKeybind;

[CFM_CATEGORY, "CFM_cameraTurnUpKey", [CFM_STR_TURN_CAMERA_UP, CFM_STR_TURN_CAMERA_UP], {call CFM_fnc_cameraTurnUpKeybind}, "", [72, [false, false, true]]] call CBA_fnc_addKeybind;
[CFM_CATEGORY, "CFM_cameraTurnDownKey", [CFM_STR_TURN_CAMERA_DOWN, CFM_STR_TURN_CAMERA_DOWN], {call CFM_fnc_cameraTurnDownKeybind}, "", [80, [false, false, true]]] call CBA_fnc_addKeybind;
[CFM_CATEGORY, "CFM_cameraTurnRightKey", [CFM_STR_TURN_CAMERA_RIGHT, CFM_STR_TURN_CAMERA_RIGHT], {call CFM_fnc_cameraTurnRightKeybind}, "", [77, [false, false, true]]] call CBA_fnc_addKeybind;
[CFM_CATEGORY, "CFM_cameraTurnLeftKey", [CFM_STR_TURN_CAMERA_LEFT, CFM_STR_TURN_CAMERA_LEFT], {call CFM_fnc_cameraTurnLeftKeybind}, "", [75, [false, false, true]]] call CBA_fnc_addKeybind;
