#include "defines.hpp"
#define CFM_CATEGORY "CFM Camera System Settings"
#define OPTIMIZE_MONITOR_FEED_DIST "20"

// CBA settings
["CFM_allUavsAreFeedingByDefault",  "CHECKBOX",  ["All UAVs feed by default", "All UAVs feed by default"], CFM_CATEGORY, false, 1] call CBA_fnc_addSetting;
["CFM_PIPsettings",  "EDITBOX",  ["PIP Settings", "PIP size and position settings: [size (number or [sizeX, sizeY]), posX, posY]"], CFM_CATEGORY, DEFAULT_PIP_SETTINGS_STR] call CBA_fnc_addSetting;
["CFM_useScrollMenuForConnection",  "CHECKBOX",  ["Use scroll menu", "Use scroll menu for connection"], CFM_CATEGORY, true] call CBA_fnc_addSetting;
["CFM_canFullscreen",  "CHECKBOX",  ["Can fullscreen", "Viewers can enter fullscreen"], CFM_CATEGORY, true, 1] call CBA_fnc_addSetting;
["CFM_optimizeByDistance",  "EDITBOX",  ["Optimize by Distance", "Distance to monitor threshold for optimizing PIP settings. -1 for unlimited"], CFM_CATEGORY, OPTIMIZE_MONITOR_FEED_DIST] call CBA_fnc_addSetting;
["CFM_menuShowOperatorGrid",  "CHECKBOX",  ["Show operator map grid position", "Show operator map grid position"], CFM_CATEGORY, false] call CBA_fnc_addSetting;
["CFM_menuShowOperatorDistance",  "CHECKBOX",  ["Show operator distance to monitor", "Show operator distance to monitor"], CFM_CATEGORY, false] call CBA_fnc_addSetting;
["CFM_allHandMonitorsAreDisplays",  "CHECKBOX",  ["All hand monitors are fullscreen displays", "All hand monitors are fullscreen displays"], CFM_CATEGORY, true, 1] call CBA_fnc_addSetting;
["CFM_fullscreenIsPip",  "CHECKBOX",  ["Fullscreen is PIP", "Fullscreen is Picture In Picture window"], CFM_CATEGORY, true] call CBA_fnc_addSetting;
["CFM_cameraMoveSensitivity",  "SLIDER",  ["Camera Move Sensitivity", "Sensitivity of camera movement"], CFM_CATEGORY, [0, 50, 5, 1, false]] call CBA_fnc_addSetting;
["CFM_camInterpolation_tightnessOffset",  "EDITBOX",  ["Camera Rotation Tightness", "Tightness of camera rotation interpolation. Lower is more smooth"], CFM_CATEGORY, "5", 1] call CBA_fnc_addSetting;
["CFM_camInterpolation_tightnessZoom",  "EDITBOX",  ["Camera Zoom Tightness", "Tightness of camera zoom interpolation. Lower is more smooth"], CFM_CATEGORY, "10", 1] call CBA_fnc_addSetting;
["CFM_canInterceptUAVcontrol",  "CHECKBOX",  ["Can intercept UAV control", "Can intercept UAV control so if someone already controlling drone then he will be disconnected"], CFM_CATEGORY, false, 1] call CBA_fnc_addSetting;
["CFM_canMoveDroneCameras",  "CHECKBOX",  ["Can move UAV cameras", "Can move UAV cameras via monitor"], CFM_CATEGORY, true, 1] call CBA_fnc_addSetting;
["CFM_canMoveDroneCameraIfUavControlled",  "CHECKBOX",  ["Can intercept move UAV cameras", "Can move UAV cameras via monitor even if drone turret is controlled by other player"], CFM_CATEGORY, false, 1] call CBA_fnc_addSetting;
["CFM_canHackDrone",  "CHECKBOX",  ["Can hack UAV", "Can hack UAV if using other side monitor"], CFM_CATEGORY, true, 1] call CBA_fnc_addSetting;

[CFM_CATEGORY, "CFM_exitFullScreenKey", ["Exit Fullscreen Mode", "Exit Fullscreen Mode"], {call CFM_fnc_onDisplayUnload}, "", [18, [false, true, false]]] call CBA_fnc_addKeybind;
[CFM_CATEGORY, "CFM_zoomInKey", ["Zoom In", "Zoom In"], {[(call CFM_fnc_getTargetMonitor), +1] call CFM_fnc_zoom}, "", [52, [false, true, false]]] call CBA_fnc_addKeybind;
[CFM_CATEGORY, "CFM_zoomOutKey", ["Zoom Out", "Zoom Out"], {[(call CFM_fnc_getTargetMonitor), -1] call CFM_fnc_zoom}, "", [51, [false, true, false]]] call CBA_fnc_addKeybind;
[CFM_CATEGORY, "CFM_resetZoomKey", ["Reset zoom", "Reset Zoom"], {[(call CFM_fnc_getTargetMonitor), "reset"] call CFM_fnc_zoom}, "", [54, [false, true, false]]] call CBA_fnc_addKeybind;
[CFM_CATEGORY, "CFM_operatorZoomKey", ["Use operator zoom", "Use operator zoom"], {[(call CFM_fnc_getTargetMonitor), "op"] call CFM_fnc_zoom}, "", [53, [false, true, false]]] call CBA_fnc_addKeybind;
[CFM_CATEGORY, "CFM_takeUavControlKey", ["Take UAV control", "Take UAV control"], {[(call CFM_fnc_getTargetMonitor)] spawn CFM_fnc_takeUAVcontorls}, "", [53, [false, false, true]]] call CBA_fnc_addKeybind;
[CFM_CATEGORY, "CFM_switchTurret", ["Switch Turrets", "Switch between turrets/cameras"], {[(call CFM_fnc_getTargetMonitor)] call CFM_fnc_monitorNextTurretCamera}, "", [83, [false, false, true]]] call CBA_fnc_addKeybind;
[CFM_CATEGORY, "CFM_switchTiKey", ["Switch TI modes", "Switch Thermal Image modes"], {[(call CFM_fnc_getTargetMonitor)] call CFM_fnc_monitorSwitchTi}, "", [49, [false, true, false]]] call CBA_fnc_addKeybind;
[CFM_CATEGORY, "CFM_toggleNVGKey", ["Toggle NVG mode", "Toggle Night Vission mode"], {[(call CFM_fnc_getTargetMonitor)] call CFM_fnc_monitorToggleNVG}, "", [49, [false, false, false]]] call CBA_fnc_addKeybind;
[CFM_CATEGORY, "CFM_disconnectOperatorKey", ["Disconnect Operator", "Disconnect monitor from Operator"], {[(call CFM_fnc_getTargetMonitor), PLAYER_] call CFM_fnc_disconnectMonitorFromOperatorKeybind}, "", [48, [false, true, false]]] call CBA_fnc_addKeybind;
[CFM_CATEGORY, "CFM_fixFeedKey", ["Fix/reset feed", "Fix/reset feed"], {[] call CFM_fnc_fixFeedKeybind}, "", [33, [false, true, false]]] call CBA_fnc_addKeybind;
[CFM_CATEGORY, "CFM_turnOnOffKey", ["Toggle on/off Monitor (Localy)", "Toggle on/off Monitor (Localy)"], {[(call CFM_fnc_getTargetMonitor)] call CFM_fnc_turnOnOffMonitorLocalKeybind}, "", [20, [false, true, false]]] call CBA_fnc_addKeybind;

[CFM_CATEGORY, "CFM_cameraTurnUpKey", ["Turn Camera Up", "Turn Camera Up"], {[(call CFM_fnc_getTargetMonitor)] call CFM_fnc_monitorCameraTurnUp}, "", [72, [false, false, true]]] call CBA_fnc_addKeybind;
[CFM_CATEGORY, "CFM_cameraTurnDownKey", ["Turn Camera Down", "Turn Camera Down"], {[(call CFM_fnc_getTargetMonitor)] call CFM_fnc_monitorCameraTurnDown}, "", [80, [false, false, true]]] call CBA_fnc_addKeybind;
[CFM_CATEGORY, "CFM_cameraTurnRightKey", ["Turn Camera Right", "Turn Camera Right"], {[(call CFM_fnc_getTargetMonitor)] call CFM_fnc_monitorCameraTurnRight}, "", [77, [false, false, true]]] call CBA_fnc_addKeybind;
[CFM_CATEGORY, "CFM_cameraTurnLeftKey", ["Turn Camera Left", "Turn Camera Left"], {[(call CFM_fnc_getTargetMonitor)] call CFM_fnc_monitorCameraTurnLeft}, "", [75, [false, false, true]]] call CBA_fnc_addKeybind;
