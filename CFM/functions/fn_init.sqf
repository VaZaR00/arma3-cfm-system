#include "defines.hpp"

CFM_updateEachFrame = true;

if (CFM_updateEachFrame) then {
	[] call CFM_fnc_setupDraw3dEH;
};

if (isServer) then {
	call CFM_fnc_setupOpSyncVarEH;
	CFM_serverLoop_handle = 0 spawn CFM_fnc_serverLoop;
} else {
	if (didJIP) then {
		CFM_makeCamDataSync = true;
		publicVariableServer "CFM_makeCamDataSync";
	};
};
CFM_ActiveOperators_PublicEH = {call CFM_fnc_setupLocalActiveOperators};
"CFM_ActiveOperators" addPublicVariableEventHandler {call CFM_ActiveOperators_PublicEH};

// default point alignments
private _pointSetDef = parsingNamespace getVariable ["CFM_classesPointAlignmentSet", createHashMap];
if (_pointSetDef isEqualTo createHashMap) then {
	[] call CFM_fnc_initDefaultPointsAlignment;
	_pointSetDef = parsingNamespace getVariable ["CFM_classesPointAlignmentSet", createHashMap];
	missionNamespace setVariable ["CFM_classesPointAlignmentSet", _pointSetDef];
} else {
	missionNamespace setVariable ["CFM_classesPointAlignmentSet", _pointSetDef];
};

CFM_max_zoom_gopro = 2;
CFM_max_zoom_drone = 5;

// Classes
call CFM_fnc_compileClasses;

NEW_INSTANCE("DbHandler");
NEW_INSTANCE("CameraManager");


CFM_inited = true;