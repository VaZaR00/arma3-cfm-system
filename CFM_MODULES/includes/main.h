#define PREFX CFM
#define ADDON_NAME CFM_MODULES

#define STR(s) #s
#define DOUBLE(v1, v2) v1##v2
#define TRIPLE(v1, v2, v3) v1##v2##v3

#define CFG_FUNCTIONS_PATH_ ADDON_NAME##\functions
#define CFG_FUNCTIONS_PATH STR(CFG_FUNCTIONS_PATH_)
#define CFG_FUNCTIONS_PATH_FOLDER_(f) TRIPLE(CFG_FUNCTIONS_PATH_,\,f)
#define CFG_FUNCTIONS_PATH_FOLDER(f) STR(CFG_FUNCTIONS_PATH_FOLDER_(f))

#define REMOTE_CALL_FUNC "call"

#define DO_FUNC_RECOMPILE recompile = 1;
#define FUNC_PRE_START preStart = 1;
#define STR(s) #s
#define MAIN_PATH_MODULES CFM_MODULES\functions
#define FUNC_PATH_JOIN(path) MAIN_PATH\##path
#define FUNC_PATH(path) STR(FUNC_PATH_JOIN(path))