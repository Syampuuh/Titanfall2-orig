untyped

global function UpdateViewStatsWeaponsMenu


//ToDo: Kills Per Minute stat

const MAX_LIST_ITEMS = 40
const PWS_SCROLL_START_TOP = 2
const WEAPON_LIST_VISIBLE = 6
const PWS_MENU_MOVE_TIME = 0.15
const BUTTON_POPOUT_FRACTION = 0.19

table pws = {
	weaponMenuInitComplete = false,

	allPilotWeapons = [],
	allTitanWeapons = [],

	buttonElems = [],
	buttonSpacing = null,
	buttonPopOutDist = null,
	selectedIndex = 0,
	numListButtonsUsed = MAX_LIST_ITEMS,

	bindings = false
}

struct
{
	array<ItemDisplayData> allPilotWeapons
	array<ItemDisplayData> allTitanWeapons
} file

void function OnOpenViewStatsWeapons()
{
	var menu = GetMenu( "ViewStats_Weapons_Menu" )
	var titleLabel = Hud_GetChild( menu, "MenuTitle" )

	if ( uiGlobal.weaponStatListType == "pilot" )
	{
		UpdateButtons( file.allPilotWeapons )
		Hud_SetText( titleLabel, "#STATS_PILOT_WEAPONS" )
	}
	else if ( uiGlobal.weaponStatListType == "titan" )
	{
		UpdateButtons( file.allTitanWeapons )
		Hud_SetText( titleLabel, "#STATS_TITAN_WEAPONS" )
	}
	else
		Assert(0, "invalid " + uiGlobal.weaponStatListType )

	UpdateButtonsForSelection( 0, true )

	if ( !pws.bindings )
	{
		pws.bindings = true
		RegisterButtonPressedCallback( MOUSE_WHEEL_UP, WeaponSelectNextUp )
		RegisterButtonPressedCallback( MOUSE_WHEEL_DOWN, WeaponSelectNextDown )
		RegisterButtonPressedCallback( KEY_UP, WeaponSelectNextUp )
		RegisterButtonPressedCallback( KEY_DOWN, WeaponSelectNextDown )
	}
}

void function OnCloseViewStatsWeapons()
{
	if ( pws.bindings )
	{
		DeregisterButtonPressedCallback( MOUSE_WHEEL_UP, WeaponSelectNextUp )
		DeregisterButtonPressedCallback( MOUSE_WHEEL_DOWN, WeaponSelectNextDown )
		DeregisterButtonPressedCallback( KEY_UP, WeaponSelectNextUp )
		DeregisterButtonPressedCallback( KEY_DOWN, WeaponSelectNextDown )
		pws.bindings = false
	}
}

// TODO: This effectively only runs once, but to make it a real Init function requires moving the call for UI InitItems().
function UpdateViewStatsWeaponsMenu()
{
	if ( pws.weaponMenuInitComplete )
		return

	var menu = GetMenu( "ViewStats_Weapons_Menu" )

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnOpenViewStatsWeapons )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, OnCloseViewStatsWeapons )

	var buttonPanel = GetElem( menu, "WeaponButtonsNestedPanel" )
	for ( int i = 0; i < MAX_LIST_ITEMS; i++ )
	{
		var button = Hud_GetChild( buttonPanel, "BtnWeapon" + i )
		Assert( button != null )

		button.s.dimOverlay <- Hud_GetChild( button, "DimOverlay" )
		button.s.weaponImageNormal <- Hud_GetChild( button, "WeaponImageNormal" )
		button.s.weaponImageFocused <- Hud_GetChild( button, "WeaponImageFocused" )
		button.s.weaponImageSelected <- Hud_GetChild( button, "WeaponImageSelected" )
		button.s.ref <- null

		Hud_AddEventHandler( button, UIE_CLICK, WeaponButtonClicked )
		Hud_AddEventHandler( button, UIE_GET_FOCUS, WeaponButtonFocused )

		pws.buttonElems.append( button )
	}

	Hud_AddEventHandler( GetElem( menu, "BtnScrollUpPC" ), UIE_CLICK, WeaponSelectNextUp )
	Hud_AddEventHandler( GetElem( menu, "BtnScrollDownPC" ), UIE_CLICK, WeaponSelectNextDown )

	AddMenuFooterOption( menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )

	pws.buttonSpacing = pws.buttonElems[1].GetBasePos()[1] - pws.buttonElems[0].GetBasePos()[1]
	pws.buttonPopOutDist = pws.buttonElems[0].GetBaseWidth() * BUTTON_POPOUT_FRACTION

	// Get Pilot weapon list
	file.allPilotWeapons = GetVisibleItemsOfType( eItemTypes.PILOT_PRIMARY )
	file.allPilotWeapons.extend( GetVisibleItemsOfType( eItemTypes.PILOT_SECONDARY ) )
	//file.allPilotWeapons.extend( GetVisibleItemsOfType( eItemTypes.PILOT_ORDNANCE ) )
	//file.allPilotWeapons.extend( GetVisibleItemsOfType( eItemTypes.PILOT_SPECIAL ) )

	// Get Titan weapon list
	file.allTitanWeapons = GetVisibleItemsOfType( eItemTypes.TITAN_PRIMARY )
	file.allTitanWeapons.extend( GetVisibleItemsOfType( eItemTypes.TITAN_ORDNANCE ) )
	//file.allTitanWeapons.extend( GetVisibleItemsOfType( eItemTypes.TITAN_SPECIAL ) )

	pws.weaponMenuInitComplete = true
}

function WeaponButtonClicked( button )
{
	int id = int( Hud_GetScriptID( button ) )
	if ( !IsControllerModeActive() )
		UpdateButtonsForSelection( id )
}

function WeaponButtonFocused( button )
{
	int id = int( Hud_GetScriptID( button ) )
	if ( IsControllerModeActive() )
		UpdateButtonsForSelection( id )
}

function WeaponSelectNextUp( button )
{
	if ( pws.selectedIndex == 0 )
		return
	UpdateButtonsForSelection( pws.selectedIndex - 1 )
}

function WeaponSelectNextDown( button )
{
	if ( pws.selectedIndex + 1 >= pws.numListButtonsUsed )
		return
	UpdateButtonsForSelection( pws.selectedIndex + 1 )
}

function UpdateButtons( array<ItemDisplayData> weaponList )
{
	Assert( weaponList.len() > 0 && weaponList.len() < MAX_LIST_ITEMS )
	pws.numListButtonsUsed = 0

	entity player = GetUIPlayer()
	if ( player == null )
		return

	foreach ( index, item in weaponList )
	{
		if ( !PersistenceEnumValueIsValid( "loadoutWeaponsAndAbilities", item.ref ) )
			continue

		local button = pws.buttonElems[ index ]
		Hud_SetEnabled( button, true )
		Hud_Show( button )

		button.s.ref = item.ref
		local image = GetItemImage( item.ref )
		Assert( image != null )
		button.s.weaponImageNormal.SetImage( image )
		button.s.weaponImageFocused.SetImage( image )
		button.s.weaponImageSelected.SetImage( image )

		if ( IsItemLocked( player, item.ref ) )
		{
			Hud_SetAlpha( button.s.weaponImageNormal, 200 )
			Hud_SetAlpha( button.s.weaponImageFocused, 200 )
			Hud_SetAlpha( button.s.weaponImageSelected, 200 )
		}
		else
		{
			Hud_SetAlpha( button.s.weaponImageNormal, 255 )
			Hud_SetAlpha( button.s.weaponImageFocused, 255 )
			Hud_SetAlpha( button.s.weaponImageSelected, 255 )
		}

		pws.numListButtonsUsed++
	}

	// Hide / Disable buttons we wont be using
	for ( local i = pws.numListButtonsUsed ; i < MAX_LIST_ITEMS ; i++ )
	{
		local button = pws.buttonElems[ i ]
		Hud_SetEnabled( button, false )
		Hud_Hide( button )
	}
}

function UpdateButtonsForSelection( index, instant = false )
{
	if ( !IsFullyConnected() )
		return

	Assert( pws.selectedIndex < pws.buttonElems.len() )
	EmitUISound( "EOGSummary.XPBreakdownPopup" )

	//pws.buttonElems[ pws.selectedIndex ].s.selectOverlay.Hide()
	//pws.buttonElems[ index ].s.selectOverlay.Show()
	pws.selectedIndex = index

	pws.buttonElems[ pws.selectedIndex ].SetScale( 1.5, 1.5 )

	foreach( index, button in pws.buttonElems )
	{
		local distFromSelection = abs( index - pws.selectedIndex )

		local isSelected = index == pws.selectedIndex ? true : false
		Hud_SetSelected( button, isSelected )

		// Button dim
		float dimAlpha = GraphCapped( distFromSelection, 0, 5, 0, 150 )
		Hud_SetAlpha( button.s.dimOverlay, dimAlpha )

		// Figure out button positioning
		local baseX = pws.buttonElems[0].GetBasePos()[0]
		local topY = pws.buttonElems[0].GetBasePos()[1]
		local shiftCount = max( 0, pws.selectedIndex - PWS_SCROLL_START_TOP )
		local maxShiftCount = pws.numListButtonsUsed - WEAPON_LIST_VISIBLE
		shiftCount = clamp( shiftCount, 0, maxShiftCount )
		local shiftDist = pws.buttonSpacing * shiftCount
		if ( index < pws.selectedIndex )
			shiftDist += pws.buttonSpacing * 0.25
		else if ( index > pws.selectedIndex )
			shiftDist -= pws.buttonSpacing * 0.25

		// Button popout
		local goalPosX = baseX
		if ( distFromSelection == 0 )
			goalPosX += pws.buttonPopOutDist
		else if ( distFromSelection == 1 )
			goalPosX += pws.buttonPopOutDist * 0.2

		// Button scroll pos
		local baseY = topY + ( pws.buttonSpacing * index )
		local goalPosY = baseY - shiftDist

		if ( instant )
			button.SetPos( goalPosX, goalPosY )
		else
			button.MoveOverTime( goalPosX, goalPosY, PWS_MENU_MOVE_TIME, INTERPOLATOR_DEACCEL )
	}

	// Update stats pane to match the button ref item
	UpdateStatsForWeapon( expect string( pws.buttonElems[ pws.selectedIndex ].s.ref ) )
}

function UpdateStatsForWeapon( string weaponRef )
{
	entity player = GetUIPlayer()
	if ( player == null )
		return

	var menu = GetMenu( "ViewStats_Weapons_Menu" )

	// Get required data needed for some calculations
	local hoursUsed = GetPlayerStatFloat( player, "weapon_stats", "hoursUsed", weaponRef )
	local shotsFired = GetPlayerStatInt( player, "weapon_stats", "shotsFired", weaponRef )
	local shotsHit = GetPlayerStatInt( player, "weapon_stats", "shotsHit", weaponRef )
	local headshots = GetPlayerStatInt( player, "weapon_stats", "headshots", weaponRef )
	local crits = GetPlayerStatInt( player, "weapon_stats", "critHits", weaponRef )

	// Name
	Hud_SetText( Hud_GetChild( menu, "WeaponName" ), GetItemName( weaponRef ) )

	// Image
	local image = GetItemImage( weaponRef )
	var weaponImageElem = Hud_GetChild( menu, "WeaponImageLarge" )
	weaponImageElem.SetImage( image )
	Hud_SetAlpha( weaponImageElem, 255 )

	// Locked info
	var lockLabel = GetElementsByClassname( menu, "LblWeaponLocked" )[0]
	int levelReq = GetUnlockLevelReq( weaponRef )
	Hud_Hide( lockLabel )
	if ( levelReq > player.GetLevel() )
	{
		Hud_SetAlpha( weaponImageElem, 200 )
		Hud_SetText( lockLabel, "#LOUADOUT_UNLOCK_REQUIREMENT_LEVEL", levelReq )
		Hud_Show( lockLabel )
	}

	// Time Used
	SetStatsLabelValue( menu, "TimeUsed", 				StatToTimeString( "weapon_stats", "hoursEquipped", weaponRef ) )

	// Shots Fired / Accuracy
	SetStatsLabelValue( menu, "ShotsFired", 			shotsFired )
	SetStatsLabelValue( menu, "Accuracy", 				[ "#STATS_PERCENTAGE", GetPercent( shotsHit, shotsFired, 0 ) ] )

	// Headshots / Accuracy
	local headshotWeapon = GetWeaponInfoFileKeyField_Global( weaponRef, "allow_headshots" ) == 1
	if ( headshotWeapon )
	{
		SetStatsLabelValue( menu, "Headshots", 				headshots )
		SetStatsLabelValue( menu, "HeadshotAccuracy", 		[ "#STATS_PERCENTAGE", GetPercent( headshots, shotsFired, 0 ) ] )
	}
	else
	{
		SetStatsLabelValue( menu, "Headshots", 				"#STATS_NOT_APPLICABLE" )
		SetStatsLabelValue( menu, "HeadshotAccuracy", 		"#STATS_NOT_APPLICABLE" )
	}

	// Crits / Accuracy
	local critHitWeapon = GetWeaponInfoFileKeyField_Global( weaponRef, "critical_hit" ) == 1
	if ( critHitWeapon )
	{
		SetStatsLabelValue( menu, "CriticalHits", 			crits )
		SetStatsLabelValue( menu, "CriticalHitAccuracy", 	[ "#STATS_PERCENTAGE", GetPercent( crits, shotsFired, 0 ) ] )
	}
	else
	{
		SetStatsLabelValue( menu, "CriticalHits", 			"#STATS_NOT_APPLICABLE" )
		SetStatsLabelValue( menu, "CriticalHitAccuracy", 	"#STATS_NOT_APPLICABLE" )
	}

	// Total Kills Stats
	SetStatsLabelValue( menu, "Column0Value0", 				GetPlayerStatInt( player, "weapon_kill_stats", "total", weaponRef ) )
	SetStatsLabelValue( menu, "Column0Value1", 				GetPlayerStatInt( player, "weapon_kill_stats", "pilots", weaponRef ) )
	SetStatsLabelValue( menu, "Column0Value2", 				GetPlayerStatInt( player, "weapon_kill_stats", "grunts", weaponRef ) )
	SetStatsLabelValue( menu, "Column0Value3", 				GetPlayerStatInt( player, "weapon_kill_stats", "spectres", weaponRef ) )
	SetStatsLabelValue( menu, "Column0Value4", 				GetPlayerStatInt( player, "weapon_kill_stats", "marvins", weaponRef ) )

	{
		// Titan Kills Stats
		local kills_ion = GetPlayerStatInt( player, "weapon_kill_stats", "titans_ion", weaponRef )
		local kills_scorch = GetPlayerStatInt( player, "weapon_kill_stats", "titans_scorch", weaponRef )
		local kills_northstar = GetPlayerStatInt( player, "weapon_kill_stats", "titans_northstar", weaponRef )
		local kills_ronin = GetPlayerStatInt( player, "weapon_kill_stats", "titans_ronin", weaponRef )
		local kills_tone = GetPlayerStatInt( player, "weapon_kill_stats", "titans_tone", weaponRef )
		local kills_legion = GetPlayerStatInt( player, "weapon_kill_stats", "titans_legion", weaponRef )
		local kills_titan_total = kills_ion + kills_scorch + kills_northstar + kills_ronin + kills_tone + kills_legion

		SetStatsLabelValue( menu, "Column1Value0", 				kills_titan_total )
		//SetStatsLabelValue( menu, "Column1Value1", 				kills_stryder )
		//SetStatsLabelValue( menu, "Column1Value2", 				kills_atlas )
		//SetStatsLabelValue( menu, "Column1Value3", 				kills_ogre )
	}

	{
		// NPC Titan Kills Stats

		local kills_ion = GetPlayerStatInt( player, "weapon_kill_stats", "npcTitans_ion", weaponRef )
		local kills_scorch = GetPlayerStatInt( player, "weapon_kill_stats", "npcTitans_scorch", weaponRef )
		local kills_northstar = GetPlayerStatInt( player, "weapon_kill_stats", "npcTitans_northstar", weaponRef )
		local kills_ronin = GetPlayerStatInt( player, "weapon_kill_stats", "npcTitans_ronin", weaponRef )
		local kills_tone = GetPlayerStatInt( player, "weapon_kill_stats", "npcTitans_tone", weaponRef )
		local kills_legion = GetPlayerStatInt( player, "weapon_kill_stats", "npcTitans_legion", weaponRef )
		local kills_titan_total = kills_ion + kills_scorch + kills_northstar + kills_ronin + kills_tone + kills_legion

		SetStatsLabelValue( menu, "Column2Value0", 				kills_titan_total )
		//SetStatsLabelValue( menu, "Column2Value1", 				kills_npc_stryder )
		//SetStatsLabelValue( menu, "Column2Value2", 				kills_npc_atlas )
		//SetStatsLabelValue( menu, "Column2Value3", 				kills_npc_ogre )
	}
}


/*
//local killCount = GetPlayerStatInt( player, "weapon_kill_stats", "total", weaponRef )
//local killsPerMinute = 0
//if ( hoursUsed > 0 )
//	killsPerMinute = format( "%.2f", killCount / ( hoursUsed * 60.0 ) )

UpdateScrollBarPosition( shiftCount, maxShiftCount, instant )
*/