
global function InitViewStatsTimeMenu

const MAX_MODE_ROWS = 8

struct
{
	var menu
} file

void function InitViewStatsTimeMenu()
{
	var menu = GetMenu( "ViewStats_Time_Menu" )
	file.menu = menu

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnStatsTime_Open )

	AddMenuFooterOption( menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
}

void function OnStatsTime_Open()
{
	UI_SetPresentationType( ePresentationType.NO_MODELS )

	UpdateViewStatsTimeMenu()
}

void function UpdateViewStatsTimeMenu()
{
	entity player = GetUIPlayer()
	if ( player == null )
		return

	//#########################################
	// 		  Time By Class Pie Chart
	//#########################################

	float hoursAsPilot = GetPlayerStatFloat( player, "time_stats", "hours_as_pilot" )
	float hoursAsTitan = GetPlayerStatFloat( player, "time_stats", "hours_as_titan" )

	array<PieChartEntry> classes

	if ( hoursAsPilot > 0 )
		AddPieChartEntry( classes, "#STATS_HEADER_PILOT", hoursAsPilot )

	if ( hoursAsTitan > 0 )
		AddPieChartEntry( classes, "#STATS_HEADER_TITAN", hoursAsTitan )

	classes.sort( ComparePieChartEntryValues )

	PieChartData classTimeData
	classTimeData.entries = classes
	classTimeData.labelColor = [ 255, 255, 255, 255 ]
	classTimeData.timeBased = true
	SetPieChartData( file.menu, "ClassPieChart", "#STATS_HEADER_TIME_BY_CLASS", classTimeData )

	//#########################################
	// 		 Time By Chassis Pie Chart
	//#########################################

	float hoursAsIon = GetPlayerStatFloat( player, "time_stats", "hours_as_titan_ion" )
	float hoursAsScorch = GetPlayerStatFloat( player, "time_stats", "hours_as_titan_scorch" )
	float hoursAsNorthstar = GetPlayerStatFloat( player, "time_stats", "hours_as_titan_northstar" )
	float hoursAsRonin = GetPlayerStatFloat( player, "time_stats", "hours_as_titan_ronin" )
	float hoursAsTone = GetPlayerStatFloat( player, "time_stats", "hours_as_titan_tone" )
	float hoursAsLegion = GetPlayerStatFloat( player, "time_stats", "hours_as_titan_legion" )

	array<PieChartEntry> titans

	if ( hoursAsIon > 0 )
		AddPieChartEntry( titans, "#TITAN_ION", hoursAsIon )

	if ( hoursAsScorch > 0 )
		AddPieChartEntry( titans, "#TITAN_SCORCH", hoursAsScorch )

	if ( hoursAsNorthstar > 0 )
		AddPieChartEntry( titans, "#TITAN_NORTHSTAR", hoursAsNorthstar )

	if ( hoursAsRonin > 0 )
		AddPieChartEntry( titans, "#TITAN_RONIN", hoursAsRonin )

	if ( hoursAsTone > 0 )
		AddPieChartEntry( titans, "#TITAN_TONE", hoursAsTone )

	if ( hoursAsLegion > 0 )
		AddPieChartEntry( titans, "#TITAN_LEGION", hoursAsLegion )

	titans.sort( ComparePieChartEntryValues )

	PieChartData chassisTimeData
	chassisTimeData.entries = titans
	chassisTimeData.labelColor = [ 255, 255, 255, 255 ]
	chassisTimeData.timeBased = true
	//chassisTimeData.colorShift = 2
	SetPieChartData( file.menu, "ChassisPieChart", "#STATS_HEADER_TIME_BY_CHASSIS", chassisTimeData )

	//#########################################
	// 		  Time By Mode Pie Chart
	//#########################################

	array<string> gameModesArray = GetPersistenceEnumAsArray( "gameModes" )

	array<PieChartEntry> modes
	foreach ( modeName in gameModesArray )
	{
		string gameModePlaysVar = GetStatVar( "game_stats", "mode_played", modeName )
		int playCount = player.GetPersistentVarAsInt( gameModePlaysVar )
		if ( playCount > 0 )
			AddPieChartEntry( modes, GAMETYPE_TEXT[ modeName ], float( playCount ) )
	}

	if ( modes.len() > 0 )
	{
		modes.sort( ComparePieChartEntryValues )

		if ( modes.len() > MAX_MODE_ROWS )
		{
			float otherValue
			for ( int i = MAX_MODE_ROWS-1; i < modes.len() ; i++ )
				otherValue += modes[i].numValue

			modes.resize( MAX_MODE_ROWS-1 )
			AddPieChartEntry( modes, "#GAMEMODE_OTHER", otherValue )
		}
	}

	PieChartData modesPlayedData
	modesPlayedData.entries = modes
	modesPlayedData.labelColor = [ 255, 255, 255, 255 ]
	SetPieChartData( file.menu, "ModesPieChart", "#GAME_MODES_PLAYED", modesPlayedData )

	//#########################################
	// 				Time Stats
	//#########################################

	SetStatBoxDisplay( Hud_GetChild( file.menu, "Stat0" ), Localize( "#STATS_HEADER_TIME_PLAYED" ), 		StatToTimeString( "time_stats", "hours_total" ) )
	SetStatBoxDisplay( Hud_GetChild( file.menu, "Stat1" ), Localize( "#STATS_HEADER_TIME_IN_AIR" ), 		StatToTimeString( "time_stats", "hours_inAir" ) )
	SetStatBoxDisplay( Hud_GetChild( file.menu, "Stat2" ), Localize( "#STATS_HEADER_TIME_WALLRUNNING" ), 	StatToTimeString( "time_stats", "hours_wallrunning" ) )
}

void function AddPieChartEntry( array<PieChartEntry> entries, string displayName, float numValue )
{
	PieChartEntry newEntry
	newEntry.displayName = displayName
	newEntry.numValue = numValue

	entries.append( newEntry )
}