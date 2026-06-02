// ============================================================================
// STATIC UI GRID FOR CUSTOM RESOLUTION
// ============================================================================

// UI GRID SIZE
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

// Replacements for pixelW and pixelH (Fixed size of a single pixel in a UI_SIZE grid)
#define STATIC_PIXEL_W ((1 / UI_SIZE_W))
#define STATIC_PIXEL_H ((1 / UI_SIZE_H))

// Replacement for pixelGridNoUIScale (Fixes the grid cell size to 4 pixels)
// This prevents UI distortion regardless of the player's "Interface Size" game settings
#define STATIC_GRID_SCALE 7

// ============================================================================