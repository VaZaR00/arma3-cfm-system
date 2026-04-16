#include "defines.hpp"

CFM_updateEachFrame = true;

if (CFM_updateEachFrame) then {
	[] call CFM_fnc_setupDraw3dEH;
};

[] call CFM_fnc_initActionConditions;
[] call CFM_fnc_initDefaultPointsAlignment;

CFM_max_zoom_gopro = 2;
CFM_max_zoom_drone = 5;
CFM_allHandMonitorsAreDisplays = false;
CFM_canHackDrone = false;

// CBA settings
["CFM_PIPsettings",  "EDITBOX",  ["PIP Settings", "PIP size and position settings: [size (number or [sizeX, sizeY]), posX, posY]"], "CFM Settings", DEFAULT_PIP_SETTINGS_STR] call CBA_fnc_addSetting;
["CFM_useScrollMenuForConnection",  "CHECKBOX",  ["Use scroll menu", "Use scroll menu for connection"], "CFM Settings", true] call CBA_fnc_addSetting;
["CFM_optimizeByDistance",  "EDITBOX",  ["Optimize by Distance", "Distance to monitor threshold for optimizing PIP settings. -1 for unlimited"], "CFM Settings", OPTIMIZE_MONITOR_FEED_DIST] call CBA_fnc_addSetting;

["CFM", "CFM_exitFullScreenKey", ["Exit Fullscreen Mode", "Exit Fullscreen Mode"], {call CFM_fnc_exitFullScreen}, "", [18, [false, true, false]]] call CBA_fnc_addKeybind;
["CFM", "CFM_zoomInKey", ["Zoom In", "Zoom In"], {[cursorObject, +1] call CFM_fnc_zoom}, "", [52, [false, true, false]]] call CBA_fnc_addKeybind;
["CFM", "CFM_zoomOutKey", ["Zoom Out", "Zoom Out"], {[cursorObject, -1] call CFM_fnc_zoom}, "", [51, [false, true, false]]] call CBA_fnc_addKeybind;
["CFM", "CFM_resetZoomKey", ["Reset zoom", "Reset Zoom"], {[cursorObject, "reset"] call CFM_fnc_zoom}, "", [54, [false, true, false]]] call CBA_fnc_addKeybind;
["CFM", "CFM_operatorZoomKey", ["Use operator zoom", "Use operator zoom"], {[cursorObject, "op"] call CFM_fnc_zoom}, "", [53, [false, true, false]]] call CBA_fnc_addKeybind;
["CFM", "CFM_takeUavControlKey", ["Take UAV control", "Take UAV control"], {[cursorObject] spawn CFM_fnc_takeUAVcontorls}, "", [53, [false, false, true]]] call CBA_fnc_addKeybind;
["CFM", "CFM_switchTiKey", ["Switch TI modes", "Switch Thermal Image modes"], {[cursorObject] call CFM_fnc_monitorSwitchTi}, "", [49, [false, true, false]]] call CBA_fnc_addKeybind;
["CFM", "CFM_toggleNVGKey", ["Toggle NVG mode", "Toggle Night Vission mode"], {[cursorObject] call CFM_fnc_monitorToggleNVG}, "", [49, [false, false, false]]] call CBA_fnc_addKeybind;
["CFM", "CFM_disconnectOperatorKey", ["Disconnect Operator", "Disconnect monitor from Operator"], {[cursorObject, PLAYER_] call CFM_fnc_disconnectMonitorFromOperatorKeybind}, "", [48, [false, true, false]]] call CBA_fnc_addKeybind;
["CFM", "CFM_fixFeedKey", ["Fix/reset feed", "Fix/reset feed"], {[] call CFM_fnc_fixFeedKeybind}, "", [33, [false, true, false]]] call CBA_fnc_addKeybind;
["CFM", "CFM_turnOnOffKey", ["Toggle on/off Monitor (Localy)", "Toggle on/off Monitor (Localy)"], {[cursorObject] call CFM_fnc_turnOnOffMonitorLocalKeybind}, "", [20, [false, true, false]]] call CBA_fnc_addKeybind;

// Classes
#include "Classes\DbHandler.sqf"
#include "Classes\Monitor.sqf"
#include "Classes\Operator.sqf"
#include "Classes\CameraManager.sqf"

NEW_INSTANCE("DbHandler");
NEW_INSTANCE("CameraManager");


CFM_inited = true;