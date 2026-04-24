class Main
{
    class compile {
        file = FUNC_PATH(fn_compile.sqf);
        DO_FUNC_RECOMPILE
        preInit = 1;
    };
    class getStaticCameraOffset {
        file = FUNC_PATH(fn_getStaticCameraOffset.sqf);
        DO_FUNC_RECOMPILE
    };
    class init {
        file = FUNC_PATH(fn_init.sqf);
        DO_FUNC_RECOMPILE
        postInit = 1;
    };
    class setMonitor {
        file = FUNC_PATH(fn_setMonitor.sqf);
        DO_FUNC_RECOMPILE
    };
    class setOperator {
        file = FUNC_PATH(fn_setOperator.sqf);
        DO_FUNC_RECOMPILE
    };
    class setStaticCamera {
        file = FUNC_PATH(fn_setStaticCamera.sqf);
        DO_FUNC_RECOMPILE
    };
};