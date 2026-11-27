/*
    Function: CFM_fnc_initDynamicHud
    Author: Vazar & Gemini
    Description:
        Initializes a dynamically parsed HUD display instance on a monitor.
        Compatible with Turret::_initInterfaceFunc signature.
    Parameters:
        0: _monitor [Object] - Monitor object.
        1: _display [Display] - Active display instance.
        2: _uiDisplayUniqueName [String] - Unique display identifier.
    Returns:
        [Array] - [_r2tPictureCtrl, [_effectCtrl1, _effectCtrl2]]
*/

#include "defines.hpp"

params [["_monitor", objNull], ["_display", displayNull], ["_uiDisplayUniqueName", ""]];

if (isNull _display) exitWith {[controlNull, []]};

private _monPair = _display getVariable ["CFM_monitor", [_monitor, -1]];
private _hudClass = _display getVariable ["CFM_dynamicHudClass", ""];
private _isExplicit = _display getVariable ["CFM_dynamicHudExplicit", false];

[_monPair, _display, _hudClass, _uiDisplayUniqueName, _isExplicit] call CFM_fnc_buildDynamicDisplay
