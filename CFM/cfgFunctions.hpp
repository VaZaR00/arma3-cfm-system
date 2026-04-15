class CfgFunctions
{
	class CFM
	{
		class main
        {
			recompile=1;
            file = "functions";
			class compile {
				preInit = 1;
			};
			class init {
				postInit = 1;
			};
			class setMonitor {};
			class setOperator {};
		};
	};
};