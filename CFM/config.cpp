#include "includes\main.hpp"

class CfgPatches {
	class PREFX {
		name = "Camera Feed for Monitors";
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
#include "includes\CfgRemoteExec.hpp"