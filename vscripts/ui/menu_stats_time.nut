untyped

global function InitViewStatsTimeMenu
global function UpdateViewStatsTimeMenu

void function InitViewStatsTimeMenu()
{
	var menu = GetMenu( "ViewStats_Time_Menu" )

	AddMenuFooterOption( menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
}

function UpdateViewStatsTimeMenu()
{
	entity player = GetUIPlayer()
	if ( player == null )
		return

	var menu = GetMenu( "ViewStats_Time_Menu" )

	//#########################################
	// 		  Time By Class Pie Chart
	//#########################################

	local hoursAsPilot = GetPlayerStatFloat( player, "time_stats", "hours_as_pilot" )
	local hoursAsTitan = GetPlayerStatFloat( player, "time_stats", "hours_as_titan" )

	local data = {}
	data.names <- [ "#STATS_HEADER_PILOT", "#STATS_HEADER_TITAN" ]
	data.values <- [ hoursAsPilot, hoursAsTitan ]
	data.labelColor <- [ 195, 208, 217, 255 ]
	data.timeBased <- true

	SetPieChartData( menu, "ClassPieChart", "#STATS_HEADER_TIME_BY_CLASS", data )

	//#########################################
	// 		 Time By Chassis Pie Chart
	//#########################################

	local hoursAsIon = GetPlayerStatFloat( player, "time_stats", "hours_as_titan_ion" )
	local hoursAsScorch = GetPlayerStatFloat( player, "time_stats", "hours_as_titan_scorch" )
	local hoursAsNorthstar = GetPlayerStatFloat( player, "time_stats", "hours_as_titan_northstar" )
	local hoursAsRonin = GetPlayerStatFloat( player, "time_stats", "hours_as_titan_ronin" )
	local hoursAsTone = GetPlayerStatFloat( player, "time_stats", "hours_as_titan_tone" )
	local hoursAsLegion = GetPlayerStatFloat( player, "time_stats", "hours_as_titan_legion" )

	data = {}
	data.names <- [ "#TITAN_ION", "#TITAN_SCORCH", "#TITAN_NORTHSTAR", "#TITAN_RONIN", "#TITAN_TONE", "#TITAN_LEGION" ]
	data.values <- [ hoursAsIon, hoursAsScorch, hoursAsNorthstar, hoursAsRonin, hoursAsTone, hoursAsLegion ]
	data.labelColor <- [ 195, 208, 217, 255 ]
	data.timeBased <- true
	data.colorShift <- 2

	SetPieChartData( menu, "ChassisPieChart", "#STATS_HEADER_TIME_BY_CHASSIS", data )

	//#########################################
	// 				Time Stats
	//#########################################

	SetStatsLabelValue( menu, "GamesStatName0", 		"#STATS_HEADER_TIME_PLAYED" )
	SetStatsLabelValue( menu, "GamesStatValue0", 		StatToTimeString( "time_stats", "hours_total" ) )

	SetStatsLabelValue( menu, "GamesStatName1", 		"#STATS_HEADER_TIME_IN_AIR" )
	SetStatsLabelValue( menu, "GamesStatValue1", 		StatToTimeString( "time_stats", "hours_inAir" ) )

	SetStatsLabelValue( menu, "GamesStatName2", 		"#STATS_HEADER_TIME_WALLRUNNING" )
	SetStatsLabelValue( menu, "GamesStatValue2", 		StatToTimeString( "time_stats", "hours_wallrunning" ) )

	SetStatsLabelValue( menu, "GamesStatName3", 		"#STATS_HEADER_TIME_WALLHANGING" )
	SetStatsLabelValue( menu, "GamesStatValue3", 		StatToTimeString( "time_stats", "hours_wallhanging" ) )
}