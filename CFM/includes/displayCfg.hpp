
class RscDisplayCFMEmpty: RscDisplayEmpty
{
    idd = 167;
    onLoad = "";
    onUnload = "_this call (missionNamespace getVariable ['CFM_fnc_onTempDisplayUnload', {}])";
};