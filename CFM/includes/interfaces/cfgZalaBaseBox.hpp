class InfoBox_Base: ctrlControlsGroupNoScrollBars
{
	idc=-1;
	x=0;
	y=0;
	w=EVAL_UI(fnc_width(2.5));
	h=EVAL_UI(fnc_height(1.5));
	class controls
	{
		class WhiteBackGround: ctrlStaticBackGround
		{
			idc=-1;
			colorBackGround[]={1,1,1,1};
			x=0;
			y=0;
			w=EVAL_UI(fnc_width(2.5));
			h=EVAL_UI(fnc_height(1.5));
		};
		class TopBackGround: ctrlStaticBackGround
		{
			idc=-1;
			colorBackGround[]={0,0,0,1};
			x=EVAL_UI(fnc_width(0.1));
			y=EVAL_UI(fnc_height(0.1));
			w=EVAL_UI(fnc_width(2.5) - 2 * fnc_width(0.1));
			h=EVAL_UI(fnc_height(1.5) - 2 * fnc_height(0.1));
		};
		class MainText: ctrlStructuredText
		{
			idc=-1;
			class Attributes
			{
				font="PuristaLight";
				align="center";
				valign="middle";
			};
			size=EVAL_UI(fnc_height(1.0));
			x=0;
			y=EVAL_UI(fnc_height(1.5) / 2 - fnc_height(1.0) / 2);
			w=EVAL_UI(fnc_width(2.5));
			h=EVAL_UI(fnc_height(1.0));
		};
	};
};
class Zala16_UI_BaseBox: ctrlControlsGroupNoScrollBars
{
	idc=-1;
	x=0;
	y=0;
	w=0;
	h=EVAL_UI(fnc_height(1.4));
	class controls
	{
		class BackGround: ctrlStaticBackGround
		{
			idc=-1;
			colorBackGround[]={0,0,0,0.69999999};
			x=0;
			y=0;
			w=0;
			h=EVAL_UI(fnc_height(1.4));
		};
		class Text: ctrlStructuredText
		{
			idc=101;
			class Attributes
			{
				font="EtelkaMonospacePro";
			};
			shadow=0;
			size=EVAL_UI(fnc_height(1.2));
			x=0;
			y=0;
			w=0;
			h=EVAL_UI(fnc_height(1.4));
		};
	};
};
