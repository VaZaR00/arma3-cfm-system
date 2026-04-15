import RscDisplayEmpty;

class RscDisplayCFM: RscDisplayEmpty
{
    onLoad = "";
    onUnload = "_this call (missionNamespace getVariable ['CFM_fnc_onDisplayUnload', {}])";
};