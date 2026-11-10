#include "includes\defines.hpp"

class CfgPatches {
	class PREFX {
		name = "CFM Modules";
		author = "Vazar";
		requiredAddons[] = {
			"A3_Functions_F",
			"cba_common",
#ifdef FINAL
			"CFM"
#endif
		};
		units[] = {
			"CFM_Module_Monitor",
			"CFM_Module_Camera"
		};
		weapons[] = {};
        skipWhenMissingDependencies = 1;
	};
};

#ifdef FINAL
#include "includes\CfgFunctions.hpp"
#include "includes\ExtendedEventHandlers.hpp"
#endif

#include "includes\cfgRemoteExec.hpp"
#include "includes\configIncludes.hpp"
#include "includes\display3DEN.hpp"