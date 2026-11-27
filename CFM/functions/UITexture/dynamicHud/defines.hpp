#include "..\defines.hpp"

#ifdef FINAL
#define UI_CACHE_NAMESPACE parsingNamespace
#else
#define UI_CACHE_NAMESPACE missionNamespace
#endif

#define DYN_HUD_SYNTHETIC_IDC_BASE 45000
#define DYN_HUD_RANGE_THROTTLE 0.15

// Allowed renderable control types:
// 0 = CT_STATIC, 8 = CT_PROGRESS, 11 = CT_ACTIVETEXT,
// 13 = CT_STRUCTURED_TEXT, 15 = CT_CONTROLS_GROUP,
// 100 = CT_MAP, 101 = CT_MAP_MAIN
#define DYN_HUD_ALLOWED_CTRL_TYPES [0, 8, 11, 13, 15, 100, 101]

// Interactive / unsupported types skipped when discovering addon HUDs
#define DYN_HUD_INTERACTIVE_CTRL_TYPES [1, 2, 4, 5, 7, 12, 16, 42, 43, 77]
