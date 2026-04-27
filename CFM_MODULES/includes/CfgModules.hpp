#define STR_PREF STR_CFM_Module_
#define SSTR_N(s) $##STR_PREF##s
#define SSTR_DESC_N(s) $##STR_PREF##DESC_##s
#define SSTR(s) STR(SSTR_N(s))
#define SSTR_DESC(s) STR(SSTR_DESC_N(s))

#define PARAMETER(paramName, type, default) class paramName \
{ \
    displayName = SSTR(paramName); \
    description = SSTR_DESC(paramName); \
    typeName = type; \
    defaultValue = default; \
};

#define PARAMETER_SELECT(paramName, default) class paramName \
{ \
    displayName = SSTR(paramName); \
    description = SSTR_DESC(paramName); \
    typeName = "NUMBER"; \
    defaultValue = default; \
    class values \
    { \
        class Yes    {name = SSTR(Yes); value = 1;}; \
        class No   {name = SSTR(No); value = 0;}; \
    }; \
};
#define PARAMETER_SELECT_DEFAULT(paramName, default) class paramName \
{ \
    displayName = SSTR(paramName); \
    description = SSTR_DESC(paramName); \
    typeName = "NUMBER"; \
    defaultValue = default; \
    class values \
    { \
        class Default   {name = SSTR(Default); value = -1;}; \
        class Yes    {name = SSTR(Yes); value = 1;}; \
        class No   {name = SSTR(No); value = 0;}; \
    }; \
};

class CfgFactionClasses
{
	class CFM
	{
		displayName="Camera System";
		priority=0;
		side=7;
	};
};
class ArgumentsBaseUnits;
class CfgVehicles
{
    class Logic;
    class Module_F: Logic
    {
        class ModuleDescription
        {
            class AnyBrain;
        };
    };
    class CFM_Module_Monitor: Module_F
    {
        scope = 2;
        author = "Vazar";
        displayName = "Monitor";
        category = "CFM";
        function = "CFM_fnc_initModuleMonitor";
        icon = "\A3\modules_f\data\portraitStrategicMapImage_ca.paa";
        portrait = "\A3\modules_f\data\portraitStrategicMapImage_ca.paa";
        functionPriority = 2;
        isGlobal = 2;
        isTriggerActivated = 0;

        class Arguments: ArgumentsBaseUnits
        {
            PARAMETER(monitorObject, "STRING", "")
            PARAMETER(monitorSides, "STRING", "west")
            PARAMETER_SELECT(IsHandMonitorDisplay, 0)
            PARAMETER_SELECT(monitorcanSwitchNvg, 1)
            PARAMETER_SELECT(monitorCanSwitchTi, 1)
            PARAMETER_SELECT(monitorCanSwitchTurret, 1)
            PARAMETER_SELECT(monitorCanZoom, 1)
            PARAMETER_SELECT(monitorCanFullScreen, 1)
            PARAMETER_SELECT(monitorCanConnectDrone, 1)
        };
    };
    class CFM_Module_Operator: Module_F
    {
        scope = 2;
        author = "Vazar";
        displayName = "Operator";
        category = "CFM";
        function = "CFM_fnc_initModuleOperator";
        icon = "IconCamera";
        portrait = "IconCamera";
        functionPriority = 2;
        isGlobal = 0;
        isTriggerActivated = 0;

        class Arguments: ArgumentsBaseUnits
        {
            PARAMETER(operatorObject, "STRING", "")
            PARAMETER(operatorName, "STRING", "")
            PARAMETER(operatorSides, "STRING", "")
            PARAMETER_SELECT_DEFAULT(operatorCanMoveCamera, -1)
            PARAMETER(operatorTurretsCustom, "STRING", "")
            PARAMETER_SELECT_DEFAULT(operatorHasTI, -1)
            PARAMETER_SELECT_DEFAULT(operatorHasNvg, -1)
            PARAMETER_SELECT(operatorSmoothZoom, 1)
        };
    };
    class CFM_Module_StaticCamera: Module_F
    {
        scope = 2;
        author = "Vazar";
        displayName = "Static Camera";
        category = "CFM";
        function = "CFM_fnc_initModuleStaticCamera";
        icon = "IconCamera";
        portrait = "IconCamera";
        functionPriority = 2;
        isGlobal = 0;
        isTriggerActivated = 0;

        class Arguments: ArgumentsBaseUnits
        {
            PARAMETER_SELECT(isStaticCameraTurret, 0) // if true this module is proccesed as turret of synced static cam module
            PARAMETER(cameraName, "STRING", "Camera 1")
            PARAMETER(cameraSides, "STRING", "west")
            PARAMETER(cameraPosAndOffsetsTurretsCustom, "STRING", "this")
            PARAMETER(cameraObject, "STRING", "")
            PARAMETER_SELECT(cameraHasTI, 1)
            PARAMETER_SELECT(cameraHasNvg, 1)
            PARAMETER_SELECT(cameraCanMoveCamera, 1)
            PARAMETER_SELECT(cameraSmoothZoom, 1)
            PARAMETER(turretIndex, "STRING", "")
            PARAMETER(zoomParams, "STRING", "")
        };
    };
    // Change priority to default module for create diary
    class ModuleCreateDiaryRecord_F : Module_F
    {
        functionPriority = 5;
    };
};
