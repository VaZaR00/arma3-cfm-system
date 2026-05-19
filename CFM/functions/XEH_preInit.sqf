
#include "defines.hpp"

#ifndef ADDON
call FUNC(XEH_prep);
#endif

call CFM_fnc_compile;
call CFM_fnc_classSystemCompile;
call CFM_fnc_init;