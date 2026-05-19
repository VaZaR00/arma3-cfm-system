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

#include "includes\CfgFunctions.hpp"
#include "includes\cfgRemoteExec.hpp"
#include "includes\configIncludes.hpp"