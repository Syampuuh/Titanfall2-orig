untyped

global function InitViewStatsMenu

void function InitViewStatsMenu()
{
	var menu = GetMenu( "ViewStatsMenu" )

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnOpenViewStats )

	AddEventHandlerToButtonClass( menu, "BtnOverview", UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "ViewStats_Overview_Menu" ) ) )
	AddEventHandlerToButtonClass( menu, "BtnKills", UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "ViewStats_Kills_Menu" ) ) )
	AddEventHandlerToButtonClass( menu, "BtnTime", UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "ViewStats_Time_Menu" ) ) )
	AddEventHandlerToButtonClass( menu, "BtnDistance", UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "ViewStats_Distance_Menu" ) ) )
	AddEventHandlerToButtonClass( menu, "BtnPilotWeapons", UIE_CLICK, WeaponPilotStatsMenuHandler )
	AddEventHandlerToButtonClass( menu, "BtnTitanWeapons", UIE_CLICK, WeaponTitanStatsMenuHandler )
	AddEventHandlerToButtonClass( menu, "BtnMisc", UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "ViewStats_Misc_Menu" ) ) )

	AddMenuFooterOption( menu, BUTTON_A, "#A_BUTTON_SELECT" )
	AddMenuFooterOption( menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
}

void function OnOpenViewStats()
{
	UpdateViewStatsOverviewMenu()
	UpdateViewStatsKillsMenu()
	UpdateViewStatsTimeMenu()
	UpdateViewStatsDistanceMenu()
	UpdateViewStatsWeaponsMenu()
	UpdateViewStatsMiscMenu()

	entity player = GetUIPlayer()
	if ( player == null )
		return

	var menu = GetMenu( "ViewStatsMenu" )

	// XP Bar Panel
	var panel = GetElem( menu, "XPBarPanel" )

	// Player Level
	var elem = Hud_GetChild( panel, "LevelText" )
	Hud_SetText( elem, "#EOG_XP_BAR_LEVEL", player.GetLevel() )

	// Gen Icon
	elem = Hud_GetChild( panel, "GenIcon" )
	elem.SetImage( GetGenImage( GetGen() ) )
	Hud_Show( elem )

	// XP to Next Level
	int nextLevel = minint( player.GetLevel() + 1, GetMaxPlayerLevel() )
	local xpReq = GetXPForLevel( nextLevel ) - player.GetXP()
	elem = Hud_GetChild( panel, "XPText" )
	Hud_SetText( elem, "#EOG_XP_BAR_XPCOUNT", xpReq )
	if ( player.GetLevel() == GetMaxPlayerLevel() )
		Hud_SetText( elem, "#EOG_XP_BAR_XPCOUNT_MAXED" )

	// XP Bar
	Hud_Hide( Hud_GetChild( panel, "BarFillNew" ) )
	Hud_Hide( Hud_GetChild( panel, "BarFillNewColor" ) )
	Hud_Hide( Hud_GetChild( panel, "BarFillFlash" ) )

	var bar = Hud_GetChild( panel, "BarFillPrevious" )
	var barShadow = Hud_GetChild( panel, "BarFillShadow" )
	local startXP = GetXPForLevel( player.GetLevel() )
	float frac = GraphCapped( player.GetXP(), startXP, GetXPForLevel( nextLevel ), 0.0, 1.0 )
	bar.SetScaleX( frac )
	barShadow.SetScaleX( frac )
}

void function WeaponPilotStatsMenuHandler( var button )
{
	uiGlobal.weaponStatListType = "pilot"
	AdvanceMenu( GetMenu( "ViewStats_Weapons_Menu" ) )
}

void function WeaponTitanStatsMenuHandler( var button )
{
	uiGlobal.weaponStatListType = "titan"
	AdvanceMenu( GetMenu( "ViewStats_Weapons_Menu" ) )
}