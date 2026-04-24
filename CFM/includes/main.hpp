#define PREFX CFM
#define DO_FUNC_RECOMPILE recompile = 1;
#define STR(s) #s
#define MAIN_PATH CFM\functions
#define FUNC_PATH_JOIN(path) MAIN_PATH\##path
#define FUNC_PATH(path) STR(FUNC_PATH_JOIN(path))