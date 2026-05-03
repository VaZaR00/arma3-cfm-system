
class RscDisplayCFMEmpty: RscDisplayEmpty
{
    idd = 167;
    onLoad = "";
    onUnload = "_this call (missionNamespace getVariable ['CFM_fnc_onTempDisplayUnload', {}])";
};
class RscDisplayMainDisplayCFM: RscDisplayEmpty
{
    idd = 168;
    onLoad = "_this call (missionNamespace getVariable ['CFM_fnc_onMainDisplayLoad', {}])";
    onUnload = "_this call (missionNamespace getVariable ['CFM_fnc_onMainDisplayUnload', {}])";
};
class RscDisplayR2TDisplayCFM: RscDisplayEmpty
{
    idd = 169;
    onLoad = "_this call (missionNamespace getVariable ['CFM_fnc_onR2TDisplayLoad', {}])";
    onUnload = "_this call (missionNamespace getVariable ['CFM_fnc_onR2TDisplayUnload', {}])";
};
class RscDisplayUIDisplayCFM: RscDisplayEmpty
{
    idd = 170;
    onLoad = "_this call (missionNamespace getVariable ['CFM_fnc_onUIDisplayLoad', {}])";
    onUnload = "_this call (missionNamespace getVariable ['CFM_fnc_onUIDisplayUnload', {}])";
};