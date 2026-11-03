#define PREFX CFM
#define EFL_PREF CFM_EFL
#define OOP_PREFX CFM_OOP

#define ADDON_PATH z\cfm\addons\##PREFX##\functions
#ifdef DEV
#define ADDON_PATH mods\CFM_proj\CFM\functions
#endif