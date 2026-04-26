#include "includes\main.h"

class CfgPatches {
	class CFM_MODULES {
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
class CfgFunctions
{
	class CFM
	{
		#include "includes\CfgFunctions.hpp"
	};
};
#include "includes\CfgModules.hpp"