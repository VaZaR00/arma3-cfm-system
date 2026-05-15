/*
    Function: CFM_fnc_fpv_handleBattery
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_uav", "_controlPicture", "_controlText"];

private _currentBattery = fuel _uav;

private _picture = "";

switch (true) do {
	case (_currentBattery > 0.75): { _picture = "\fpv_ua\pictures\A100.paa" };
	case (_currentBattery > 0.5): { _picture = "\fpv_ua\pictures\A75.paa" };
	case (_currentBattery > 0.25): { _picture = "\fpv_ua\pictures\A50.paa" };
	case (_currentBattery > 0): { _picture = "\fpv_ua\pictures\A25.paa" };
	case (_currentBattery <= 0): { _picture = "\fpv_ua\pictures\A0.paa" };
	default { _picture = "\fpv_ua\pictures\A75.paa" };
};

_controlPicture ctrlSetText _picture;
_controlText ctrlSetText str(round(_currentBattery * 100));
