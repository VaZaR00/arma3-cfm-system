class InfoBox_Base: ctrlControlsGroupNoScrollBars
{
	idc=-1;
	x=0;
	y=0;
	w="( ( 2.5 * ( pixelGridNoUIScale * pixelW * 2 )) )";
	h="( ( 1.5 * ( pixelGridNoUIScale * pixelH * 2 )) )";
	class controls
	{
		class WhiteBackGround: ctrlStaticBackGround
		{
			idc=-1;
			colorBackGround[]={1,1,1,1};
			x=0;
			y=0;
			w="( ( 2.5 * ( pixelGridNoUIScale * pixelW * 2 )) )";
			h="( ( 1.5 * ( pixelGridNoUIScale * pixelH * 2 )) )";
		};
		class TopBackGround: ctrlStaticBackGround
		{
			idc=-1;
			colorBackGround[]={0,0,0,1};
			x="( ( 0.1 * ( pixelGridNoUIScale * pixelW * 2 )) )";
			y="( ( 0.1 * ( pixelGridNoUIScale * pixelH * 2 )) )";
			w="( ( 2.5 * ( pixelGridNoUIScale * pixelW * 2 )) ) - 2*( ( 0.1 * ( pixelGridNoUIScale * pixelW * 2 )) )";
			h="( ( 1.5 * ( pixelGridNoUIScale * pixelH * 2 )) ) - 2*( ( 0.1 * ( pixelGridNoUIScale * pixelH * 2 )) )";
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
			size="( ( 1.0 * ( pixelGridNoUIScale * pixelH * 2 )) )";
			x=0;
			y="( ( 1.5 * ( pixelGridNoUIScale * pixelH * 2 )) ) / 2 - ( ( 1.0 * ( pixelGridNoUIScale * pixelH * 2 )) ) / 2";
			w="( ( 2.5 * ( pixelGridNoUIScale * pixelW * 2 )) )";
			h="( ( 1.0 * ( pixelGridNoUIScale * pixelH * 2 )) )";
		};
	};
};
class Zala16_UI_BaseBox: ctrlControlsGroupNoScrollBars
{
	idc=-1;
	x=0;
	y=0;
	w=0;
	h="( ( 1.4 * ( pixelGridNoUIScale * pixelH * 2 )) )";
	class controls
	{
		class BackGround: ctrlStaticBackGround
		{
			idc=-1;
			colorBackGround[]={0,0,0,0.69999999};
			x=0;
			y=0;
			w=0;
			h="( ( 1.4 * ( pixelGridNoUIScale * pixelH * 2 )) )";
		};
		class Text: ctrlStructuredText
		{
			idc=101;
			class Attributes
			{
				font="EtelkaMonospacePro";
			};
			shadow=0;
			size="( 1.2 * ( pixelGridNoUIScale * pixelH * 2 ))";
			x=0;
			y=0;
			w=0;
			h="( ( 1.4 * ( pixelGridNoUIScale * pixelH * 2 )) )";
		};
	};
};