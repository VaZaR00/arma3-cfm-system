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

// Dynamic pixelW and pixelH (Parsed from config and evaluated in CFM_fnc_repositionControls)
#define fnc_pixelW (call {comment ""PW""; 1})
#define fnc_pixelH (call {comment ""PH""; 1})
#define STATIC_PIXEL_W fnc_pixelW
#define STATIC_PIXEL_H fnc_pixelH

// Replacement for pixelGridNoUIScale
// This prevents UI distortion regardless of the player's "Interface Size" game settings
#define STATIC_GRID_SCALE 7

// Dynamic UI dimension and position helpers (Parsed from config and evaluated in CFM_fnc_repositionControls)
#define fnc_width(VAL) (call {comment ""W""; VAL})
#define fnc_height(VAL) (call {comment ""H""; VAL})
#define fnc_posX(VAL) (call {comment ""X""; VAL})
#define fnc_posY(VAL) (call {comment ""Y""; VAL})

// ============================================================================
