/*
    Function: CFM_fnc_fpv_handleSignal
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_uav", "_signal", "_controlPicture", "_controlText"];

private _picture = "";

switch (true) do {
	case (_signal > 0.75): { _picture = "\fpv_ua\pictures\100.paa"; };
	case (_signal > 0.5): { _picture = "\fpv_ua\pictures\75.paa" };
	case (_signal > 0.25): { _picture = "\fpv_ua\pictures\50.paa" };
	case (_signal > 0): { _picture = "\fpv_ua\pictures\25.paa" };
	case (_signal <= 0): { _picture = "\fpv_ua\pictures\0.paa" };
	default { _picture = "\fpv_ua\pictures\100.paa" };
};

_controlPicture ctrlSetText _picture;
_controlText ctrlSetText str(round(_signal * 100));
