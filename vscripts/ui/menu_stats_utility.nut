untyped


global function SetPieChartData
global function SetStatsBarValues
global function SetStatsValueInfo
global function SetStatsLabelValue
global function GetPercent
global function GetChallengeCompleteData
global function GetItemUnlockCountData
global function GetOverviewWeaponData
global function StatToTimeString
global function HoursToTimeString
global function StatToDistanceString

function SetPieChartData( menu, panelName, titleString, data )
{
	local maxSlices = 6

	Assert( data.names.len() == data.values.len() )
	Assert( data.names.len() <= maxSlices )

	local backgroundColor = [ 190, 190, 190, 255 ]

	local colors = []
	colors.append( [ 192, 94, 75, 255 ] )
	colors.append( [ 194, 173, 76, 255 ] )
	colors.append( [ 88, 172, 67, 255 ] )
	colors.append( [ 77, 127, 196, 255 ] )
	colors.append( [ 166, 91, 191, 255 ] )
	colors.append( [ 46, 188, 180, 255 ] )

	if ( "colorShift" in data )
	{
		for ( int i = 0; i < data.colorShift; i++ )
		{
			colors.append( colors[0] )
			colors.remove(0)
		}
	}

	Assert( colors.len() == maxSlices )

	// Get nested panel
	var piePanel = GetElem( menu, panelName )

	// Create background
	var background = Hud_GetChild( piePanel, "BarBG" )
	background.SetBarProgress( 1.0 )
	background.SetColor( backgroundColor )

	// Calculate total of all values combined
	if ( !( "sum" in data ) )
	{
		data.sum <- 0
		foreach( value in data.values )
			data.sum += value
	}

	// Calculate bar fraction for each value
	local valueFractions = []
	foreach( value in data.values )
	{
		if ( data.sum > 0 )
			valueFractions.append( value.tofloat() / data.sum.tofloat() )
		else
			valueFractions.append( 0 )
	}

	// Set slice sizes and text data
	var titleLabel = Hud_GetChild( piePanel, "Title" )
	Hud_SetText( titleLabel, titleString )
	if ( "labelColor" in data )
		titleLabel.SetColor( data.labelColor )

	local combinedFrac = 0.0
	foreach( index, frac in valueFractions )
	{
		var barColorGuide = Hud_GetChild( piePanel, "BarColorGuide" + index )
		barColorGuide.SetColor( colors[ index ] )
		Hud_Show( barColorGuide )

		var barColorGuideFrame = Hud_GetChild( piePanel, "BarColorGuideFrame" + index )
		Hud_Show( barColorGuideFrame )

		local percent = GetPercent( frac, 1.0, 0, true )
		var barName = Hud_GetChild( piePanel, "BarName" + index )
		if ( "labelColor" in data )
			barName.SetColor( data.labelColor )

		if ( "timeBased" in data )
			SetStatsLabelValueOnLabel( barName, HoursToTimeString( data.values[ index ], data.names[ index ], percent ) )
		else
			Hud_SetText( barName, "#STATS_TEXT_AND_PERCENTAGE", data.names[ index ], string( percent ) )

		Hud_Show( barName )

		combinedFrac += frac
		var bar = Hud_GetChild( piePanel, "Bar" + index )
		bar.SetBarProgress( combinedFrac )
		bar.SetColor( colors[ index ] )
		Hud_Show( bar )
	}
}

function SetStatsBarValues( menu, panelName, titleString, startValue, endValue, currentValue )
{
	Assert( endValue > startValue )
	Assert( currentValue >= startValue && currentValue <= endValue )

	// Get nested panel
	var panel = GetElem( menu, panelName )

	// Update titel
	var title = Hud_GetChild( panel, "Title" )
	Hud_SetText( title, titleString )

	// Update progress text
	var progressText = Hud_GetChild( panel, "ProgressText" )
	Hud_SetText( progressText, "#STATS_PROGRESS_BAR_VALUE", currentValue, endValue )

	// Update bar progress
	float frac = GraphCapped( currentValue, startValue, endValue, 0.0, 1.0 )

	var barFill = Hud_GetChild( panel, "BarFill" )
	barFill.SetScaleX( frac )

	var barFillShadow = Hud_GetChild( panel, "BarFillShadow" )
	barFillShadow.SetScaleX( frac )
}

function SetStatsValueInfo( menu, valueID, labelText, textString )
{
	var elem = GetElem( menu, "Column0Label" + valueID )
	Assert( elem != null )
	Hud_SetText( elem, labelText )

	elem = GetElem( menu, "Column0Value" + valueID )
	Assert( elem != null )
	SetStatsLabelValueOnLabel( elem, textString )
}

function SetStatsLabelValue( menu, labelName, textString )
{
	var elem = GetElem( menu, labelName )
	Assert( elem != null)
	SetStatsLabelValueOnLabel( elem, textString )
}

function SetStatsLabelValueOnLabel( elem, textString )
{
	if ( type( textString ) == "array" )
	{
		if ( textString.len() == 6 )
			Hud_SetText( elem, string( textString[0] ), textString[1], textString[2], textString[3], textString[4], textString[5] )
		if ( textString.len() == 5 )
			Hud_SetText( elem, string( textString[0] ), textString[1], textString[2], textString[3], textString[4] )
		if ( textString.len() == 4 )
			Hud_SetText( elem, string( textString[0] ), textString[1], textString[2], textString[3] )
		if ( textString.len() == 3 )
			Hud_SetText( elem, string( textString[0] ), textString[1], textString[2] )
		if ( textString.len() == 2 )
			Hud_SetText( elem, string( textString[0] ), textString[1] )
		if ( textString.len() == 1 )
			Hud_SetText( elem, string( textString[0] ) )
	}
	else
	{
		Hud_SetText( elem, string( textString ) )
	}
}

function GetPercent( numerator, denominator, defaultVal, clamp = true )
{
	local percent = defaultVal
	if ( denominator > 0 )
	{
		percent = numerator.tofloat() / denominator.tofloat()
		percent *= 100
		percent += 0.5
		percent = percent.tointeger()
	}

	if ( clamp )
	{
		if ( percent < 0 )
			percent = 0
		if ( percent > 100 )
			percent = 100
	}

	return percent
}

function GetChallengeCompleteData()
{
	/*local Table = {}
	Table.total <- 0
	Table.complete <- 0

	UI_GetAllChallengesProgress()
	var allChallenges = GetLocalChallengeTable()

	foreach( challengeRef, val in allChallenges )
	{
		if ( IsDailyChallenge( challengeRef ) )
			continue
		local tierCount = GetChallengeTierCount( challengeRef )
		Table.total += tierCount
		for ( int i = 0; i < tierCount; i++ )
		{
			if ( IsChallengeTierComplete( challengeRef, i ) )
				Table.complete++
		}
	}

	return Table*/
}

function GetItemUnlockCountData()
{
	entity player = GetUIPlayer()
	if ( player == null )
		return {}

	local Table = {}
	Table[ "weapons" ] <- {}
	Table[ "weapons" ].total <- 0
	Table[ "weapons" ].unlocked <- 0
	Table[ "attachments" ] <- {}
	Table[ "attachments" ].total <- 0
	Table[ "attachments" ].unlocked <- 0
	Table[ "mods" ] <- {}
	Table[ "mods" ].total <- 0
	Table[ "mods" ].unlocked <- 0
	Table[ "abilities" ] <- {}
	Table[ "abilities" ].total <- 0
	Table[ "abilities" ].unlocked <- 0
	Table[ "gear" ] <- {}
	Table[ "gear" ].total <- 0
	Table[ "gear" ].unlocked <- 0
/*
	local tableMapping = {}

	tableMapping[ eItemTypes.PILOT_PRIMARY ] 			<- "weapons"
	tableMapping[ eItemTypes.PILOT_SECONDARY ] 			<- "weapons"
	tableMapping[ eItemTypes.PILOT_ORDNANCE ] 			<- "weapons"
	tableMapping[ eItemTypes.TITAN_PRIMARY ] 			<- "weapons"
	tableMapping[ eItemTypes.TITAN_ORDNANCE ] 			<- "weapons"
	tableMapping[ eItemTypes.PILOT_PRIMARY_ATTACHMENT ] <- "attachments"
	tableMapping[ eItemTypes.PILOT_PRIMARY_MOD ] 		<- "mods"
	tableMapping[ eItemTypes.PILOT_SECONDARY_MOD ] 		<- "mods"
	tableMapping[ eItemTypes.TITAN_PRIMARY_MOD ] 		<- "mods"
	tableMapping[ eItemTypes.PILOT_SPECIAL_MOD ] 		<- "mods"
	tableMapping[ eItemTypes.TITAN_SPECIAL_MOD ] 		<- "mods"
	tableMapping[ eItemTypes.PILOT_SPECIAL ] 			<- "abilities"
	tableMapping[ eItemTypes.TITAN_SPECIAL ] 			<- "abilities"

	local itemRefs = GetAllItemRefs()
	foreach ( data in itemRefs )
	{
		if ( !( data.Type in tableMapping ) )
			continue
		Table[ tableMapping[ data.Type ] ].total++

		if ( !IsItemLocked( player, expect string( data.childRef ), expect string( data.ref ) ) )
			Table[ tableMapping[ data.Type ] ].unlocked++
	}
*/
	return Table
}

function GetOverviewWeaponData()
{
	entity player = GetUIPlayer()
	if ( player == null )
		return

	local Table = {}
	Table[ "most_kills" ] <- {}
	Table[ "most_kills" ].ref <- null
	Table[ "most_kills" ].printName <- null
	Table[ "most_kills" ].val <- 0
	Table[ "most_used" ] <- {}
	Table[ "most_used" ].ref <- null
	Table[ "most_used" ].printName <- null
	Table[ "most_used" ].val <- 0
	Table[ "highest_kpm" ] <- {}
	Table[ "highest_kpm" ].ref <- null
	Table[ "highest_kpm" ].printName <- null
	Table[ "highest_kpm" ].val <- 0

	array<ItemDisplayData> allWeapons = []

	allWeapons.extend( GetVisibleItemsOfType( eItemTypes.PILOT_PRIMARY ) )
	allWeapons.extend( GetVisibleItemsOfType( eItemTypes.PILOT_SECONDARY ) )
	allWeapons.extend( GetVisibleItemsOfType( eItemTypes.TITAN_PRIMARY ) )
	allWeapons.extend( GetVisibleItemsOfType( eItemTypes.TITAN_ORDNANCE ) )

	foreach ( weapon in allWeapons )
	{
		string weaponName = weapon.ref
		string weaponDisplayName = expect string( GetWeaponInfoFileKeyField_Global( weaponName, "printname" ) )

		if ( !PersistenceEnumValueIsValid( "loadoutWeaponsAndAbilities", weaponName ) )
			continue

		int val = GetPlayerStatInt( player, "weapon_kill_stats", "total", weaponName )
		if ( val > Table[ "most_kills" ].val )
		{
			Table[ "most_kills" ].ref = weaponName
			Table[ "most_kills" ].printName = weaponDisplayName
			Table[ "most_kills" ].val = val
		}

		float fVal = GetPlayerStatFloat( player, "weapon_stats", "hoursUsed", weaponName )
		if ( fVal > Table[ "most_used" ].val )
		{
			Table[ "most_used" ].ref = weaponName
			Table[ "most_used" ].printName = weaponDisplayName
			Table[ "most_used" ].val = fVal
		}

		local killsPerMinute = 0
		local hoursEquipped = GetPlayerStatFloat( player, "weapon_stats", "hoursEquipped", weaponName )
		local killCount = GetPlayerStatInt( player, "weapon_kill_stats", "total", weaponName )
		if ( hoursEquipped > 0 )
			killsPerMinute = format( "%.2f", ( killCount / ( hoursEquipped * 60.0 ) ).tofloat() )
		if ( killsPerMinute.tofloat() > Table[ "highest_kpm" ].val.tofloat() )
		{
			Table[ "highest_kpm" ].ref = weaponName
			Table[ "highest_kpm" ].printName = weaponDisplayName
			Table[ "highest_kpm" ].val = killsPerMinute
		}
	}

	return Table
}

function StatToTimeString( string category, string alias, string weapon = "" )
{
	entity player = GetUIPlayer()
	if ( player == null )
		return 0

	//Converts hours float to a formatted time string

	string statString = GetStatVar( category, alias, weapon )
	local savedHours = player.GetPersistentVar( statString )

	return HoursToTimeString( savedHours )
}

function HoursToTimeString( savedHours, pieChartHeader = null, pieChartPercent = null )
{
	local timeString = []
	local minutes = floor( savedHours * 60.0 )

	if ( minutes < 0 )
		minutes = 0

	local days = 0
	local hours = 0

	while( minutes >= 1440 )
	{
		minutes -= 1440
		days++
	}

	while( minutes >= 60 )
	{
		minutes -= 60
		hours++
	}


	if ( days > 0 && hours > 0 && minutes > 0 )
	{
		timeString.append( "#STATS_TIME_STRING_D_H_M" )
		timeString.append( days )
		timeString.append( hours )
		timeString.append( minutes )
	}
	else if ( days > 0 && hours == 0 && minutes == 0 )
	{
		timeString.append( "#STATS_TIME_STRING_D" )
		timeString.append( days )
	}
	else if ( days == 0 && hours > 0 && minutes == 0 )
	{
		timeString.append( "#STATS_TIME_STRING_H" )
		timeString.append( hours )
	}
	else if ( days == 0 && hours == 0 && minutes >= 0 )
	{
		timeString.append( "#STATS_TIME_STRING_M" )
		timeString.append( minutes )
	}
	else if ( days > 0 && hours > 0 && minutes == 0 )
	{
		timeString.append( "#STATS_TIME_STRING_D_H" )
		timeString.append( days )
		timeString.append( hours )
	}
	else if ( days == 0 && hours > 0 && minutes > 0 )
	{
		timeString.append( "#STATS_TIME_STRING_H_M" )
		timeString.append( hours )
		timeString.append( minutes )
	}
	else if ( days > 0 && hours == 0 && minutes > 0 )
	{
		timeString.append( "#STATS_TIME_STRING_D_M" )
		timeString.append( days )
		timeString.append( minutes )
	}
	else
		Assert( 0, "Unhandled time string creation case" )

	if ( pieChartHeader != null )
	{
		Assert( pieChartPercent != null )
		timeString[0] = timeString[0] + "_PIECHART"
		timeString.append( pieChartHeader )
		timeString.append( pieChartPercent )
	}

	return timeString
}

function StatToDistanceString( string category, string alias, string weapon = "" )
{
	entity player = GetUIPlayer()
	if ( player == null )
		return []

	local statString = GetStatVar( category, alias, weapon )
	local kilometers = player.GetPersistentVar( statString )

	local distString = []

	distString.append( "#STATS_KILOMETERS_ABBREVIATION" )

	if ( kilometers % 1 == 0 )
		distString.append( format( "%.0f", kilometers ) )
	else
		distString.append( format( "%.2f", kilometers ) )

	return distString
}
