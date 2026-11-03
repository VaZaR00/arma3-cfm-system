#include "includes\defines.hpp"

class CfgPatches {
	class PREFX {
		name = "Camera Feed for Monitors";
		author = "Vazar";
		requiredAddons[] = {
			"A3_Functions_F",
			"cba_common",
			"CFM_EFL",
			"CFM_OOP"
		};
		units[] = {};
		weapons[] = {};
        skipWhenMissingDependencies = 1;
	};
};

#include "includes\CfgFunctions.hpp"
#include "includes\CfgRemoteExec.hpp"
#include "includes\configIncludes.hpp"
