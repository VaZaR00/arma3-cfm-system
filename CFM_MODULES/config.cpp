#include "includes\defines.hpp"

class CfgPatches {
	class PREFX {
		name = "CFM Modules";
		author = "Vazar";
		requiredAddons[] = {
			"A3_Functions_F",
			"cba_common"
		};
		units[] = {};
		weapons[] = {};
        skipWhenMissingDependencies = 1;
	};
};

#ifdef FINAL
#include "includes\CfgFunctions.hpp"
#endif

#include "includes\cfgRemoteExec.hpp"
#include "includes\configIncludes.hpp"