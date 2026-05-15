#define PREFX CFM

#define STR(s) #s
#define SPREFX STR(PREFX)
#define DO_FUNC_RECOMPILE recompile = 1;
#define FUNC_PRE_START preStart = 1;
#define ADDON_PATH CFM\functions
#define FUNC_PATH_JOIN(path) ADDON_PATH\##path
#define FUNC_PATH(path) STR(FUNC_PATH_JOIN(path))

// #define FINAL
// #define ADDON