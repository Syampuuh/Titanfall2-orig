
global function InitViewStatsMenu

void function InitViewStatsMenu()
{
	var menu = GetMenu( "ViewStatsMenu" )

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnViewStats_Open )

	var button = Hud_GetChild( menu, "BtnOverview" )
	SetButtonRuiText( button, "#STATS_OVERVIEW" )
	AddButtonEventHandler( button, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "ViewStats_Overview_Menu" ) ) )

	button = Hud_GetChild( menu, "BtnTime" )
	SetButtonRuiText( button, "#STATS_TIME" )
	AddButtonEventHandler( button, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "ViewStats_Time_Menu" ) ) )

	button = Hud_GetChild( menu, "BtnPilotWeapons" )
	SetButtonRuiText( button, "#STATS_PILOT_WEAPONS" )
	AddButtonEventHandler( button, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "ViewStats_Weapons_Menu" ) ) )

	button = Hud_GetChild( menu, "BtnTitans" )
	SetButtonRuiText( button, "#STATS_TITANS" )
	AddButtonEventHandler( button, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "ViewStats_Titans_Menu" ) ) )

	button = Hud_GetChild( menu, "BtnMisc" )
	SetButtonRuiText( button, "#STATS_MISC" )
	AddButtonEventHandler( button, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "ViewStats_Misc_Menu" ) ) )

	AddMenuFooterOption( menu, BUTTON_A, "#A_BUTTON_SELECT" )
	AddMenuFooterOption( menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
}

void function OnViewStats_Open()
{
	UI_SetPresentationType( ePresentationType.DEFAULT )

	//UpdateViewStatsKillsMenu()
	//UpdateViewStatsDistanceMenu()
}
