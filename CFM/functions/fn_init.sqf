#include "defines.hpp"

CFM_updateEachFrame = true;

if (CFM_updateEachFrame) then {
	[] call CFM_fnc_setupDraw3dEH;
};

if (isServer) then {
	call CFM_fnc_setupOpSyncVarEH;
	CFM_serverLoop_handle = 0 spawn CFM_fnc_serverLoop;
};

[] call CFM_fnc_initDefaultPointsAlignment;

CFM_max_zoom_gopro = 2;
CFM_max_zoom_drone = 5;
CFM_allHandMonitorsAreDisplays = false;
CFM_canHackDrone = false;

// CBA settings
["CFM_PIPsettings",  "EDITBOX",  ["PIP Settings", "PIP size and position settings: [size (number or [sizeX, sizeY]), posX, posY]"], "CFM Settings", DEFAULT_PIP_SETTINGS_STR] call CBA_fnc_addSetting;
["CFM_useScrollMenuForConnection",  "CHECKBOX",  ["Use scroll menu", "Use scroll menu for connection"], "CFM Settings", true] call CBA_fnc_addSetting;
["CFM_canFullscreen",  "CHECKBOX",  ["Can fullscreen", "Viewers can enter fullscreen"], "CFM Settings", true, 1] call CBA_fnc_addSetting;
["CFM_optimizeByDistance",  "EDITBOX",  ["Optimize by Distance", "Distance to monitor threshold for optimizing PIP settings. -1 for unlimited"], "CFM Settings", OPTIMIZE_MONITOR_FEED_DIST] call CBA_fnc_addSetting;
["CFM_menuShowOperatorGrid",  "CHECKBOX",  ["Show operator map grid position", "Show operator map grid position"], "CFM Settings", false] call CBA_fnc_addSetting;
["CFM_menuShowOperatorDistance",  "CHECKBOX",  ["Show operator distance to monitor", "Show operator distance to monitor"], "CFM Settings", false] call CBA_fnc_addSetting;
["CFM_allHandMonitorsAreDisplays",  "CHECKBOX",  ["All hand monitors are fullscreen displays", "All hand monitors are fullscreen displays"], "CFM Settings", false] call CBA_fnc_addSetting;
["CFM_fullscreenIsPip",  "CHECKBOX",  ["Fullscreen is PIP", "Fullscreen is Picture In Picture window"], "CFM Settings", true] call CBA_fnc_addSetting;
["CFM_cameraMoveSensitivity",  "SLIDER",  ["Camera Move Sensitivity", "Sensitivity of camera movement"], "CFM Settings", [0, 50, 5, 1, false]] call CBA_fnc_addSetting;
["CFM_camInterpolation_tightnessOffset",  "EDITBOX",  ["Camera Rotation Tightness", "Tightness of camera rotation interpolation. Lower is more smooth"], "CFM Settings", "5", 1] call CBA_fnc_addSetting;
["CFM_camInterpolation_tightnessZoom",  "EDITBOX",  ["Camera Zoom Tightness", "Tightness of camera zoom interpolation. Lower is more smooth"], "CFM Settings", "10", 1] call CBA_fnc_addSetting;
["CFM_canInterceptUAVcontrol",  "CHECKBOX",  ["Can intercept UAV control", "Can intercept UAV control so if someone already controlling drone then he will be disconnected"], "CFM Settings", false, 1] call CBA_fnc_addSetting;

["CFM", "CFM_exitFullScreenKey", ["Exit Fullscreen Mode", "Exit Fullscreen Mode"], {call CFM_fnc_onDisplayUnload}, "", [18, [false, true, false]]] call CBA_fnc_addKeybind;
["CFM", "CFM_zoomInKey", ["Zoom In", "Zoom In"], {[(call CFM_fnc_getTargetMonitor), +1] call CFM_fnc_zoom}, "", [52, [false, true, false]]] call CBA_fnc_addKeybind;
["CFM", "CFM_zoomOutKey", ["Zoom Out", "Zoom Out"], {[(call CFM_fnc_getTargetMonitor), -1] call CFM_fnc_zoom}, "", [51, [false, true, false]]] call CBA_fnc_addKeybind;
["CFM", "CFM_resetZoomKey", ["Reset zoom", "Reset Zoom"], {[(call CFM_fnc_getTargetMonitor), "reset"] call CFM_fnc_zoom}, "", [54, [false, true, false]]] call CBA_fnc_addKeybind;
["CFM", "CFM_operatorZoomKey", ["Use operator zoom", "Use operator zoom"], {[(call CFM_fnc_getTargetMonitor), "op"] call CFM_fnc_zoom}, "", [53, [false, true, false]]] call CBA_fnc_addKeybind;
["CFM", "CFM_takeUavControlKey", ["Take UAV control", "Take UAV control"], {[(call CFM_fnc_getTargetMonitor)] spawn CFM_fnc_takeUAVcontorls}, "", [53, [false, false, true]]] call CBA_fnc_addKeybind;
["CFM", "CFM_switchTiKey", ["Switch TI modes", "Switch Thermal Image modes"], {[(call CFM_fnc_getTargetMonitor)] call CFM_fnc_monitorSwitchTi}, "", [49, [false, true, false]]] call CBA_fnc_addKeybind;
["CFM", "CFM_toggleNVGKey", ["Toggle NVG mode", "Toggle Night Vission mode"], {[(call CFM_fnc_getTargetMonitor)] call CFM_fnc_monitorToggleNVG}, "", [49, [false, false, false]]] call CBA_fnc_addKeybind;
["CFM", "CFM_disconnectOperatorKey", ["Disconnect Operator", "Disconnect monitor from Operator"], {[(call CFM_fnc_getTargetMonitor), PLAYER_] call CFM_fnc_disconnectMonitorFromOperatorKeybind}, "", [48, [false, true, false]]] call CBA_fnc_addKeybind;
["CFM", "CFM_fixFeedKey", ["Fix/reset feed", "Fix/reset feed"], {[] call CFM_fnc_fixFeedKeybind}, "", [33, [false, true, false]]] call CBA_fnc_addKeybind;
["CFM", "CFM_turnOnOffKey", ["Toggle on/off Monitor (Localy)", "Toggle on/off Monitor (Localy)"], {[(call CFM_fnc_getTargetMonitor)] call CFM_fnc_turnOnOffMonitorLocalKeybind}, "", [20, [false, true, false]]] call CBA_fnc_addKeybind;

["CFM", "CFM_cameraTurnUpKey", ["Turn Camera Up", "Turn Camera Up"], {[(call CFM_fnc_getTargetMonitor)] call CFM_fnc_monitorCameraTurnUp}, "", [72, [false, false, true]]] call CBA_fnc_addKeybind;
["CFM", "CFM_cameraTurnDownKey", ["Turn Camera Down", "Turn Camera Down"], {[(call CFM_fnc_getTargetMonitor)] call CFM_fnc_monitorCameraTurnDown}, "", [80, [false, false, true]]] call CBA_fnc_addKeybind;
["CFM", "CFM_cameraTurnRightKey", ["Turn Camera Right", "Turn Camera Right"], {[(call CFM_fnc_getTargetMonitor)] call CFM_fnc_monitorCameraTurnRight}, "", [77, [false, false, true]]] call CBA_fnc_addKeybind;
["CFM", "CFM_cameraTurnLeftKey", ["Turn Camera Left", "Turn Camera Left"], {[(call CFM_fnc_getTargetMonitor)] call CFM_fnc_monitorCameraTurnLeft}, "", [75, [false, false, true]]] call CBA_fnc_addKeybind;

// Classes
#include "Classes\DbHandler.sqf"
#include "Classes\Monitor.sqf"
#include "Classes\Operator.sqf"
#include "Classes\CameraManager.sqf"

NEW_INSTANCE("DbHandler");
NEW_INSTANCE("CameraManager");


CFM_inited = true;