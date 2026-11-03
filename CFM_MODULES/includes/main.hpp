#define PREFX CFM_MODULES

#define ADDON_PATH z\cfm\addons\##PREFX##\functions
#ifdef DEV
#define ADDON_PATH mods\CFM_proj\CFM_MODULES\functions
#endif