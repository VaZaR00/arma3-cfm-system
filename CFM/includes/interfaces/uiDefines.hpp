// ============================================================================
// DYNAMIC UI GRID FOR CUSTOM MONITOR RESOLUTION
// ============================================================================

// Default UI GRID SIZE
#define UI_SIZE_W 512
#define UI_SIZE_H UI_SIZE_W 

// Helper macro for stringification
// Arma 3 engine requires UI coordinates to be strings when using mathematical formulas
#define EVAL_UI(EXPR) #EXPR

// Replacements for safeZoneX and safeZoneY (Origin coordinates at the top-left corner of the square)
#define STATIC_SZ_X 0
#define STATIC_SZ_Y 0

// Replacements for safeZoneW and safeZoneH (Total available width and height equals 1)
#define STATIC_SZ_W 1
#define STATIC_SZ_H 1

// Dynamic pixelW and pixelH (Calculated from the monitor's ScreenResolution)
#define fnc_pixelW (call (missionNamespace getVariable ['CFM_fnc_pixelW', {0}]))
#define fnc_pixelH (call (missionNamespace getVariable ['CFM_fnc_pixelH', {0}]))
#define STATIC_PIXEL_W fnc_pixelW
#define STATIC_PIXEL_H fnc_pixelH

// Replacement for pixelGridNoUIScale
// This prevents UI distortion regardless of the player's "Interface Size" game settings
#define STATIC_GRID_SCALE 7

// Dynamic UI dimension and position helpers
#define fnc_width(VAL) ((VAL) call (missionNamespace getVariable ['CFM_fnc_width', {0}]))
#define fnc_height(VAL) ((VAL) call (missionNamespace getVariable ['CFM_fnc_height', {0}]))
#define fnc_posX(VAL) ((VAL) call (missionNamespace getVariable ['CFM_fnc_posX', {0}]))
#define fnc_posY(VAL) ((VAL) call (missionNamespace getVariable ['CFM_fnc_posY', {0}]))

// ============================================================================
