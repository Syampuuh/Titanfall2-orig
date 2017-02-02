
global function InitViewStatsMiscMenu
global function UpdateViewStatsMiscMenu

void function InitViewStatsMiscMenu()
{
	var menu = GetMenu( "ViewStats_Misc_Menu" )

	AddMenuFooterOption( menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
}

void function UpdateViewStatsMiscMenu()
{
	entity player = GetUIPlayer()
	if ( player == null )
		return

	var menu = GetMenu( "ViewStats_Misc_Menu" )

	SetStatsLabelValue( menu, "GamesStatValue0", 		GetPlayerStatInt( player, "misc_stats", "titanFalls" ) )
	SetStatsLabelValue( menu, "GamesStatValue1", 		GetPlayerStatInt( player, "misc_stats", "spectreLeeches" ) )
	SetStatsLabelValue( menu, "GamesStatValue2", 		GetPlayerStatInt( player, "misc_stats", "burnCardsSpent" ) )
	SetStatsLabelValue( menu, "GamesStatValue3", 		GetPlayerStatInt( player, "misc_stats", "timesEjected" ) )
	SetStatsLabelValue( menu, "GamesStatValue4", 		GetPlayerStatInt( player, "misc_stats", "evacsAttempted" ) )
	SetStatsLabelValue( menu, "GamesStatValue5", 		GetPlayerStatInt( player, "misc_stats", "evacsSurvived" ) )
	SetStatsLabelValue( menu, "GamesStatValue6", 		GetPlayerStatInt( player, "misc_stats", "flagsCaptured" ) )
	SetStatsLabelValue( menu, "GamesStatValue7", 		GetPlayerStatInt( player, "misc_stats", "flagsReturned" ) )
}