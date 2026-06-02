class InfoBox_Base: ctrlControlsGroupNoScrollBars
{
	idc=-1;
	x=0;
	y=0;
	w=EVAL_UI(( ( 2.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ));
	h=EVAL_UI(( ( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) ));
	class controls
	{
		class WhiteBackGround: ctrlStaticBackGround
		{
			idc=-1;
			colorBackGround[]={1,1,1,1};
			x=0;
			y=0;
			w=EVAL_UI(( ( 2.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ));
			h=EVAL_UI(( ( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) ));
		};
		class TopBackGround: ctrlStaticBackGround
		{
			idc=-1;
			colorBackGround[]={0,0,0,1};
			x=EVAL_UI(( ( 0.1 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ));
			y=EVAL_UI(( ( 0.1 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) ));
			w=EVAL_UI(( ( 2.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ) - 2*( ( 0.1 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ));
			h=EVAL_UI(( ( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) ) - 2*( ( 0.1 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) ));
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
			size=EVAL_UI(( ( 1.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) ));
			x=0;
			y=EVAL_UI(( ( 1.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) ) / 2 - ( ( 1.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) ) / 2);
			w=EVAL_UI(( ( 2.5 * ( STATIC_GRID_SCALE * STATIC_PIXEL_W * 2 )) ));
			h=EVAL_UI(( ( 1.0 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) ));
		};
	};
};
class Zala16_UI_BaseBox: ctrlControlsGroupNoScrollBars
{
	idc=-1;
	x=0;
	y=0;
	w=0;
	h=EVAL_UI(( ( 1.4 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) ));
	class controls
	{
		class BackGround: ctrlStaticBackGround
		{
			idc=-1;
			colorBackGround[]={0,0,0,0.69999999};
			x=0;
			y=0;
			w=0;
			h=EVAL_UI(( ( 1.4 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) ));
		};
		class Text: ctrlStructuredText
		{
			idc=101;
			class Attributes
			{
				font="EtelkaMonospacePro";
			};
			shadow=0;
			size=EVAL_UI(( 1.2 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )));
			x=0;
			y=0;
			w=0;
			h=EVAL_UI(( ( 1.4 * ( STATIC_GRID_SCALE * STATIC_PIXEL_H * 2 )) ));
		};
	};
};