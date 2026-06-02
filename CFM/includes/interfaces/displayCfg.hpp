
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
	class controlsBackground
	{
		class R2TPicture: RscPicture
		{
			idc = 1488;
			onLoad = "uiNamespace setVariable [""CFM_r2t_r2tPicture"", _this # 0];";
			text = "";
			x = EVAL_UI(safeZoneXAbs);
			y = EVAL_UI(STATIC_SZ_Y);
			w = EVAL_UI(STATIC_SZ_W);
			h = EVAL_UI(STATIC_SZ_H);
			show = 1;
		};
		class EffectPicture: R2TPicture
		{
			idc = 1489;
			onLoad = "uiNamespace setVariable [""CFM_r2t_effectPicture"", _this # 0];";
			show = 0;
		};
	};
};
class RscDisplayUIDisplayCFM: RscDisplayEmpty
{
    idd = 170;
    onLoad = "_this call (missionNamespace getVariable ['CFM_fnc_onUIDisplayLoad', {}])";
    onUnload = "_this call (missionNamespace getVariable ['CFM_fnc_onUIDisplayUnload', {}])";
};