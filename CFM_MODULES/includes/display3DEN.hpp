class ctrlMenuStrip;
class display3DEN
{
	class Controls
	{
		class MenuStrip : ctrlMenuStrip
		{
			class Items
			{
				class Tools
				{
					items[] += { "CFM_EditorToolsFolder" }; // += must be used; you want to expand the array, not override it!
				};

				class CFM_EditorToolsFolder
				{
					text = "CFM Tools"; // Folder name
					items[] = { "CFM_setCameraModuleOnEdenCamera" }; // Links to items inside the folder
				};

				class CFM_setCameraModuleOnEdenCamera
				{
					text = "$STR_CFM_MODULE_3DEN_TOOL_setCameraModuleOnEdenCamera"; // Item text
					action = "[] call CFM_fnc_setCameraModuleOnEdenCamera;"; // Expression called upon clicking;
					shortcuts[]=
					{
						"512 + 0x24"
					};
				};
			};
		};
	};
};