untyped

global function InitViewStatsOverviewMenu
global function UpdateViewStatsOverviewMenu

const IMAGE_TITAN_STRYDER = $"ui/menu/personal_stats/ps_titan_icon_stryder"
const IMAGE_TITAN_ATLAS = $"ui/menu/personal_stats/ps_titan_icon_atlas"
const IMAGE_TITAN_OGRE = $"ui/menu/personal_stats/ps_titan_icon_ogre"

void function InitViewStatsOverviewMenu()
{
	PrecacheHUDMaterial( IMAGE_TITAN_STRYDER )
	PrecacheHUDMaterial( IMAGE_TITAN_ATLAS )
	PrecacheHUDMaterial( IMAGE_TITAN_OGRE )

	var menu = GetMenu( "ViewStats_Overview_Menu" )

	AddMenuFooterOption( menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
}

function UpdateViewStatsOverviewMenu()
{
	entity player = GetUIPlayer()
	if ( player == null )
		return

	var menu = GetMenu( "ViewStats_Overview_Menu" )
	local nextIndex = 0

	//#########################
	// 		  Games
	//#########################

	local gamesPlayed = GetPlayerStat_AllCompetitiveModesAndMapsInt( player, "game_stats", "game_completed" )
	local gamesWon = GetPlayerStat_AllCompetitiveModesAndMapsInt( player, "game_stats", "game_won" )
	local winPercent = GetPercent( gamesWon, gamesPlayed, 0 )
	local timesMVP = GetPlayerStatInt( player, "game_stats", "mvp_total" )
	local timesTop3 = GetPlayerStat_AllCompetitiveModesAndMapsInt( player, "game_stats", "top3OnTeam" )

	SetStatsLabelValue( menu, "GamesStatName" + nextIndex, 		"#STATS_GAMES_PLAYED" )
	SetStatsLabelValue( menu, "GamesStatValue" + nextIndex, 	gamesPlayed )
	nextIndex++
	SetStatsLabelValue( menu, "GamesStatName" + nextIndex, 		"#STATS_GAMES_WON" )
	SetStatsLabelValue( menu, "GamesStatValue" + nextIndex, 	gamesWon )
	nextIndex++
	SetStatsLabelValue( menu, "GamesStatName" + nextIndex, 		"#STATS_GAMES_WIN_PERCENT" )
	SetStatsLabelValue( menu, "GamesStatValue" + nextIndex, 	[ "#STATS_PERCENTAGE", winPercent ] )
	nextIndex++
	SetStatsLabelValue( menu, "GamesStatName" + nextIndex, 		"#STATS_GAMES_MVP" )
	SetStatsLabelValue( menu, "GamesStatValue" + nextIndex, 	timesMVP )
	nextIndex++
	SetStatsLabelValue( menu, "GamesStatName" + nextIndex, 		"#STATS_GAMES_TOP3" )
	SetStatsLabelValue( menu, "GamesStatValue" + nextIndex, 	timesTop3 )

	//#########################
	// 		   Modes
	//#########################

	local gameModePlayedVar = GetStatVar( "game_stats", "mode_played" )
	local basicModes = [ "tdm", "cp", "at", "lts", "ctf" ]

	local timesPlayedArray = []
	local gameModeNamesArray = []
	local otherGameModesPlayed = 0
	local gameModesArray = GetPersistenceEnumAsArray( "gameModes" )

	foreach ( modeName in gameModesArray )
	{
		expect string( modeName )

		local gameModePlaysVar = StringReplace( expect string( gameModePlayedVar ), "%gamemode%", modeName )
		local timesPlayed = player.GetPersistentVar( gameModePlaysVar )

		if ( basicModes.contains( modeName ) )  //Don't really like doing ArrayContains, but Chad prefers not storing a separate enum in persistence that contains the "other" gamemodes
		{
			timesPlayedArray.append( timesPlayed )
			gameModeNamesArray.append( GAMETYPE_TEXT[ modeName] )
		}
		else
		{
			otherGameModesPlayed += timesPlayed
		}
	}

	//Add Other game modes' data to the end of the arrays
	gameModeNamesArray.append( "#GAMEMODE_OTHER"  )
	timesPlayedArray.append( otherGameModesPlayed )

	local data = {}
	data.names <- gameModeNamesArray
	data.values <- timesPlayedArray
	//data.sum <- 5

	SetPieChartData( menu, "ModesPieChart", "#GAME_MODES_PLAYED", data )

	//#########################
	// 		Completion
	//#########################

	// Challenges complete
	//local challengeData = GetChallengeCompleteData()
	//SetStatsBarValues( menu, "CompletionBar0", "#STATS_COMPLETION_CHALLENGES", 		0, challengeData.total, challengeData.complete )

	// Item unlocks
	//local itemUnlockData = GetItemUnlockCountData()
	//SetStatsBarValues( menu, "CompletionBar1", "#STATS_COMPLETION_WEAPONS", 	0, itemUnlockData["weapons"].total, 	itemUnlockData["weapons"].unlocked )
	//SetStatsBarValues( menu, "CompletionBar2", "#STATS_COMPLETION_ATTACHMENTS", 0, itemUnlockData["attachments"].total, itemUnlockData["attachments"].unlocked )
	//SetStatsBarValues( menu, "CompletionBar3", "#STATS_COMPLETION_MODS", 		0, itemUnlockData["mods"].total, 		itemUnlockData["mods"].unlocked )
	//SetStatsBarValues( menu, "CompletionBar4", "#STATS_COMPLETION_ABILITIES", 	0, itemUnlockData["abilities"].total, 	itemUnlockData["abilities"].unlocked )
	//SetStatsBarValues( menu, "CompletionBar5", "#STATS_COMPLETION_GEAR", 		0, itemUnlockData["gear"].total, 		itemUnlockData["gear"].unlocked )

	//#########################
	// 		  Weapons
	//#########################

	local weaponData = GetOverviewWeaponData()

	string tableIndex
	var weaponImageElem
	var weaponNameElem
	var weaponDescElem
	var noDataElem

	// Weapon with most kills
	tableIndex = "most_kills"
	weaponImageElem = GetElem( menu, "WeaponImage0" )
	weaponNameElem = GetElem( menu, "WeaponName0" )
	weaponDescElem = GetElem( menu, "WeaponDesc0" )
	noDataElem = GetElem( menu, "WeaponImageTextOverlay0" )
	if ( weaponData[ tableIndex ].ref != null )
	{
		weaponImageElem.SetImage( GetItemImage( expect string( weaponData[ tableIndex ].ref ) ) )
		Hud_Show( weaponImageElem )
		Hud_SetText( weaponNameElem, weaponData[ tableIndex ].printName )
		Hud_Show( weaponNameElem )
		Hud_SetText( weaponDescElem, "#STATS_MOST_KILLS_VALUE", weaponData[ tableIndex ].val )
		Hud_Show( weaponDescElem )
		Hud_Hide( noDataElem )
	}
	else
	{
		Hud_Hide( weaponImageElem )
		Hud_Hide( weaponNameElem )
		Hud_Hide( weaponDescElem )
		Hud_Show( noDataElem )
	}

	// Most Used Weapon
	tableIndex = "most_used"
	weaponImageElem = GetElem( menu, "WeaponImage1" )
	weaponNameElem = GetElem( menu, "WeaponName1" )
	weaponDescElem = GetElem( menu, "WeaponDesc1" )
	noDataElem = GetElem( menu, "WeaponImageTextOverlay1" )
	if ( weaponData[ tableIndex ].ref != null )
	{
		weaponImageElem.SetImage( GetItemImage( expect string( weaponData[ tableIndex ].ref ) ) )
		Hud_Show( weaponImageElem )
		Hud_SetText( weaponNameElem, weaponData[ tableIndex ].printName )
		Hud_Show( weaponNameElem )
		SetStatsLabelValue( menu, "WeaponDesc1", HoursToTimeString( weaponData[ tableIndex ].val ) )
		Hud_Show( weaponDescElem )
		Hud_Hide( noDataElem )
	}
	else
	{
		Hud_Hide( weaponImageElem )
		Hud_Hide( weaponNameElem )
		Hud_Hide( weaponDescElem )
		Hud_Show( noDataElem )
	}

	// Weapon with highest KPM
	tableIndex = "highest_kpm"
	weaponImageElem = GetElem( menu, "WeaponImage2" )
	weaponNameElem = GetElem( menu, "WeaponName2" )
	weaponDescElem = GetElem( menu, "WeaponDesc2" )
	noDataElem = GetElem( menu, "WeaponImageTextOverlay2" )
	if ( weaponData[ tableIndex ].ref != null )
	{
		weaponImageElem.SetImage( GetItemImage( expect string( weaponData[ tableIndex ].ref ) ) )
		Hud_Show( weaponImageElem )
		Hud_SetText( weaponNameElem, weaponData[ tableIndex ].printName )
		Hud_Show( weaponNameElem )
		Hud_SetText( weaponDescElem, "#STATS_MOST_EFFICIENT_VALUE", weaponData[ tableIndex ].val )
		Hud_Show( weaponDescElem )
		Hud_Hide( noDataElem )
	}
	else
	{
		Hud_Hide( weaponImageElem )
		Hud_Hide( weaponNameElem )
		Hud_Hide( weaponDescElem )
		Hud_Show( noDataElem )
	}

	//#########################
	// 		Titan Unlocks
	//#########################

	Assert( player == GetUIPlayer() )
	Assert( player != null )

	int unlockedCount = 0

	//var imageLabel = GetElem( menu, "TitanUnlockImage0" )
	//if ( !IsItemLocked( player, "titan_stryder" ) )
	//{
	//	imageLabel.SetImage( IMAGE_TITAN_STRYDER )
	//	unlockedCount++
	//}
	//else
	//	imageLabel.SetImage( $"ui/menu/personal_stats/ps_titan_icon_locked" )
	//
	//imageLabel = GetElem( menu, "TitanUnlockImage1" )
	//if ( !IsItemLocked( player, "titan_atlas" ) )
	//{
	//	imageLabel.SetImage( IMAGE_TITAN_ATLAS )
	//	unlockedCount++
	//}
	//else
	//	imageLabel.SetImage( $"ui/menu/personal_stats/ps_titan_icon_locked" )
	//
	//imageLabel = GetElem( menu, "TitanUnlockImage2" )
	//if ( !IsItemLocked( player, "titan_ogre" ) )
	//{
	//	imageLabel.SetImage( IMAGE_TITAN_OGRE )
	//	unlockedCount++
	//}
	//else
	//	imageLabel.SetImage( $"ui/menu/personal_stats/ps_titan_icon_locked" )
	//
	//var unlockCountLabel = GetElem( menu, "TitanUnlocksCount" )
	//Hud_SetText( unlockCountLabel, "#STATS_CHASSIS_UNLOCK_COUNT", string( unlockedCount ) )
}