untyped

globalize_all_functions

void function InitDefaultLoadouts()
{
	PopulateDefaultPilotLoadouts( shGlobal.defaultPilotLoadouts )
	PopulateDefaultTitanLoadouts( shGlobal.defaultTitanLoadouts )
}

PilotLoadoutDef function GetDefaultPilotLoadout( int index )
{
	return shGlobal.defaultPilotLoadouts[ index ]
}

TitanLoadoutDef function GetDefaultTitanLoadout( int index )
{
	return shGlobal.defaultTitanLoadouts[ index ]
}

PilotLoadoutDef[NUM_PERSISTENT_PILOT_LOADOUTS] function GetDefaultPilotLoadouts()
{
	return shGlobal.defaultPilotLoadouts
}

TitanLoadoutDef[NUM_PERSISTENT_TITAN_LOADOUTS] function GetDefaultTitanLoadouts()
{
	return shGlobal.defaultTitanLoadouts
}

void function PopulateDefaultPilotLoadouts( PilotLoadoutDef[ NUM_PERSISTENT_PILOT_LOADOUTS ] loadouts )
{
	var dataTable = GetDataTable( $"datatable/default_pilot_loadouts.rpak" )

	for ( int i = 0; i < NUM_PERSISTENT_PILOT_LOADOUTS; i++ )
	{
		PilotLoadoutDef loadout = loadouts[i]
		loadout.name				= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "name" ) )
		loadout.suit				= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "suit" ) )
		loadout.race 				= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "race" ) )
		loadout.primary 			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "primary" ) )
		loadout.primaryAttachment 	= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "primaryAttachment" ) )
		loadout.primaryMod1 		= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "primaryMod1" ) )
		loadout.primaryMod2 		= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "primaryMod2" ) )
		loadout.primaryMod3 		= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "primaryMod3" ) )
		loadout.secondary			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "secondary" ) )
		loadout.secondaryMod1 		= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "secondaryMod1" ) )
		loadout.secondaryMod2 		= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "secondaryMod2" ) )
		loadout.secondaryMod3 		= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "secondaryMod3" ) )
		loadout.ordnance 			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "ordnance" ) )
		loadout.passive1 			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "passive1" ) )
		loadout.passive2 			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "passive2" ) )

		UpdateDerivedPilotLoadoutData( loadout )

		//loadout.race
		//ValidateDefaultLoadoutData( "pilot", loadout.primary )
		//ValidateWeaponSubitem( loadout.primary, loadout.primaryAttachment, eItemTypes.PILOT_PRIMARY_ATTACHMENT )
		//ValidateWeaponSubitem( loadout.primary, loadout.primaryMod1, eItemTypes.PILOT_PRIMARY_MOD )
		//ValidateWeaponSubitem( loadout.primary, loadout.primaryMod2, eItemTypes.PILOT_PRIMARY_MOD )
		Assert( ( loadout.primaryMod1 == "" && loadout.primaryMod2 == "" ) || ( loadout.primaryMod1 != loadout.primaryMod2 ), "!!! Primary mod1 and mod2 in default pilot loadout: " + loadout.name + " should be different but are both set to: " + loadout.primaryMod1 )

		//ValidateDefaultLoadoutData( "pilot", loadout.secondary )
		//ValidateWeaponSubitem( loadout.secondary, loadout.secondaryMod1, eItemTypes.PILOT_SECONDARY_MOD )
		//ValidateWeaponSubitem( loadout.secondary, loadout.secondaryMod2, eItemTypes.PILOT_SECONDARY_MOD )
		Assert( ( loadout.primaryMod1 == "" && loadout.primaryMod2 == "" ) || ( loadout.secondaryMod1 != loadout.secondaryMod2 ), "!!! Secondary mod1 and mod2 in default pilot loadout: " + loadout.name + " should be different but are both set to: " + loadout.secondaryMod1 )

		//ValidateDefaultLoadoutData( "pilot", loadout.ordnance )
		//ValidateDefaultLoadoutData( "pilot", loadout.special )
		//ValidateDefaultLoadoutData( "pilot", loadout.passive1 )
		//ValidateDefaultLoadoutData( "pilot", loadout.passive2 )
	}
}

void function PopulateDefaultTitanLoadouts( TitanLoadoutDef[ NUM_PERSISTENT_TITAN_LOADOUTS ] loadouts )
{
	var dataTable = GetDataTable( $"datatable/default_titan_loadouts.rpak" )

	for ( int i = 0; i < NUM_PERSISTENT_TITAN_LOADOUTS; i++ )
	{
		TitanLoadoutDef loadout = loadouts[i]
		loadout.name				= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "name" ) )
		loadout.titanClass			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "titanRef" ) )
		loadout.setFile 			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "setFile" ) )
		loadout.primaryMod			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "primaryMod" ) )
		loadout.special				= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "special" ) )
		loadout.antirodeo			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "antirodeo" ) )
		loadout.passive1 			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "passive1" ) )
		loadout.passive2 			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "passive2" ) )
		loadout.passive3 			= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "passive3" ) )
		loadout.voice 				= GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "voice" ) )

		OverwriteLoadoutWithDefaultsForSetFile_ExceptSpecialAndAntiRodeo( loadout )

		//ValidateDefaultLoadoutData( "titan", loadout.setFile )
		////loadout.primaryMod
		//ValidateDefaultLoadoutData( "titan", loadout.special )
		//ValidateDefaultLoadoutData( "titan", loadout.antirodeo )
		//ValidateDefaultLoadoutData( "titan", loadout.passive1 )
		//ValidateDefaultLoadoutData( "titan", loadout.passive2 )
		//ValidateDefaultLoadoutData( "titan", loadout.voice )
	}
}

void function ValidateDefaultLoadoutData( string loadoutType, string itemRef )
{
	if ( itemRef == "" )
		return

	Assert( loadoutType == "pilot" || loadoutType == "titan" )

	string tableFile = "default_" + loadoutType + "_loadouts.csv"

	Assert( ItemDefined( itemRef ), "Datatable \"" + tableFile + "\" contains an unknown item reference: " + itemRef )
	Assert( GetUnlockLevelReq( itemRef ) <= 1, "Datatable \"" + tableFile + "\" item: " + itemRef + " must be unlocked at level 1" )
}

void function ValidateWeaponSubitem( string weaponRef, string itemRef, int itemType )
{
	bool isPlayerLevelLocked = IsItemLockedForPlayerLevel( 1, weaponRef )
	bool isWeaponLevelLocked = IsItemLockedForWeaponLevel( 1, weaponRef, itemRef )

	if ( isPlayerLevelLocked || isWeaponLevelLocked )
	{
		//array<ItemData> subitems = GetAllSubitemsOfType( weaponRef, itemType )
		//foreach ( subitem in subitems )
		//{
		//	if ( !IsItemLockedForWeaponLevel( 1, weaponRef, subitem.ref ) )
		//		printt( "    ", subitem.ref )
		//}

		Assert( 0, "Subitem: " + itemRef + " for item: " + weaponRef + " should either be available by default, or changed to one of the values listed above." )
		CodeWarning( "Subitem: " + itemRef + " for item: " + weaponRef + " should either be available by default, or changed to one of the values listed above." )
	}
}

PilotLoadoutDef function GetPilotLoadoutFromPersistentData( entity player, int loadoutIndex )
{
	PilotLoadoutDef loadout
	PopulatePilotLoadoutFromPersistentData( player, loadout, loadoutIndex )

	return loadout
}

TitanLoadoutDef function GetTitanLoadoutFromPersistentData( entity player, int loadoutIndex )
{
	TitanLoadoutDef loadout
	PopulateTitanLoadoutFromPersistentData( player, loadout, loadoutIndex )

	return loadout
}

void function PopulatePilotLoadoutFromPersistentData( entity player, PilotLoadoutDef loadout, int loadoutIndex )
{
	loadout.name 				= GetPersistentLoadoutValue( player, "pilot", loadoutIndex, "name" )
	loadout.suit 				= GetPersistentLoadoutValue( player, "pilot", loadoutIndex, "suit" )
	loadout.race 				= GetPersistentLoadoutValue( player, "pilot", loadoutIndex, "race" )
	loadout.execution 			= GetPersistentLoadoutValue( player, "pilot", loadoutIndex, "execution" )
	loadout.primary 			= GetPersistentLoadoutValue( player, "pilot", loadoutIndex, "primary" )
	loadout.primaryAttachment	= GetPersistentLoadoutValue( player, "pilot", loadoutIndex, "primaryAttachment" )
	loadout.primaryMod1			= GetPersistentLoadoutValue( player, "pilot", loadoutIndex, "primaryMod1" )
	loadout.primaryMod2			= GetPersistentLoadoutValue( player, "pilot", loadoutIndex, "primaryMod2" )
	loadout.primaryMod3			= GetPersistentLoadoutValue( player, "pilot", loadoutIndex, "primaryMod3" )
	loadout.secondary 			= GetPersistentLoadoutValue( player, "pilot", loadoutIndex, "secondary" )
	loadout.secondaryMod1		= GetPersistentLoadoutValue( player, "pilot", loadoutIndex, "secondaryMod1" )
	loadout.secondaryMod2		= GetPersistentLoadoutValue( player, "pilot", loadoutIndex, "secondaryMod2" )
	loadout.secondaryMod3		= GetPersistentLoadoutValue( player, "pilot", loadoutIndex, "secondaryMod3" )
	loadout.ordnance 			= GetPersistentLoadoutValue( player, "pilot", loadoutIndex, "ordnance" )
	loadout.passive1 			= GetPersistentLoadoutValue( player, "pilot", loadoutIndex, "passive1" )
	loadout.passive2 			= GetPersistentLoadoutValue( player, "pilot", loadoutIndex, "passive2" )
	loadout.skinIndex			= GetPersistentLoadoutValueInt( player, "pilot", loadoutIndex, "skinIndex" )
	loadout.camoIndex			= GetPersistentLoadoutValueInt( player, "pilot", loadoutIndex, "camoIndex" )
	loadout.primarySkinIndex	= GetPersistentLoadoutValueInt( player, "pilot", loadoutIndex, "primarySkinIndex" )
	loadout.primaryCamoIndex	= GetPersistentLoadoutValueInt( player, "pilot", loadoutIndex, "primaryCamoIndex" )
	loadout.secondarySkinIndex	= GetPersistentLoadoutValueInt( player, "pilot", loadoutIndex, "secondarySkinIndex" )
	loadout.secondaryCamoIndex	= GetPersistentLoadoutValueInt( player, "pilot", loadoutIndex, "secondaryCamoIndex" )

	UpdateDerivedPilotLoadoutData( loadout )
}

void function PopulateTitanLoadoutFromPersistentData( entity player, TitanLoadoutDef loadout, int loadoutIndex )
{
	loadout.name 				= GetPersistentLoadoutValue( player, "titan", loadoutIndex, "name" )
	loadout.titanClass			= GetPersistentLoadoutValue( player, "titan", loadoutIndex, "titanClass" )
	loadout.primaryMod			= GetPersistentLoadoutValue( player, "titan", loadoutIndex, "primaryMod" )
	loadout.special 			= GetPersistentLoadoutValue( player, "titan", loadoutIndex, "special" )
	loadout.antirodeo 			= GetPersistentLoadoutValue( player, "titan", loadoutIndex, "antirodeo" )
	loadout.passive1 			= GetPersistentLoadoutValue( player, "titan", loadoutIndex, "passive1" )
	loadout.passive2 			= GetPersistentLoadoutValue( player, "titan", loadoutIndex, "passive2" )
	loadout.passive3 			= GetPersistentLoadoutValue( player, "titan", loadoutIndex, "passive3" )
	loadout.voice 				= GetPersistentLoadoutValue( player, "titan", loadoutIndex, "voice" )
	loadout.skinIndex			= GetPersistentLoadoutValueInt( player, "titan", loadoutIndex, "skinIndex" )
	loadout.camoIndex			= GetPersistentLoadoutValueInt( player, "titan", loadoutIndex, "camoIndex" )
	loadout.decalIndex			= GetPersistentLoadoutValueInt( player, "titan", loadoutIndex, "decalIndex" )
	loadout.primarySkinIndex	= GetPersistentLoadoutValueInt( player, "titan", loadoutIndex, "primarySkinIndex" )
	loadout.primaryCamoIndex	= GetPersistentLoadoutValueInt( player, "titan", loadoutIndex, "primaryCamoIndex" )

	UpdateDerivedTitanLoadoutData( loadout )
	OverwriteLoadoutWithDefaultsForSetFile( loadout )
}

string function GetSetFileForTitanClass( string titanClass )
{
	array<TitanLoadoutDef> legalLoadouts = GetAllowedTitanLoadouts()

	foreach ( loadout in legalLoadouts )
	{
		if ( GetTitanCharacterNameFromSetFile( loadout.setFile ) == titanClass )
			return loadout.setFile
	}

	unreachable
}

string function GetPersistentLoadoutValue( entity player, string loadoutType, int loadoutIndex, string loadoutProperty )
{
	// printt( "=======================================================================================" )
	// printt( "loadoutType:", loadoutType, "loadoutIndex:", loadoutIndex, "loadoutProperty:" , loadoutProperty )
	// printl( "script GetPlayerArray()[0].SetPersistentVar( \"" + loadoutType + "Loadouts[" + loadoutIndex + "]." + loadoutProperty + "\", \"" + value + "\" )" )
	// printt( "=======================================================================================" )

	Assert( loadoutType == "pilot" || loadoutType == "titan" )
	Assert( loadoutIndex < PersistenceGetArrayCount( loadoutType + "Loadouts" ), "Invalid loadoutIndex: " + loadoutIndex )

	var loadoutPropertyEnum = null
	if ( loadoutType == "pilot" )
	{
		Assert( IsValidPilotLoadoutProperty( loadoutProperty ), "Invalid pilot loadoutProperty: " + loadoutProperty )
		loadoutPropertyEnum = GetPilotLoadoutPropertyEnum( loadoutProperty )
	}
	else
	{
		Assert( IsValidTitanLoadoutProperty( loadoutProperty ), "Invalid titan loadoutProperty: " + loadoutProperty )
		loadoutPropertyEnum = GetTitanLoadoutPropertyEnum( loadoutProperty )
	}

	string getString = loadoutType + "Loadouts[" + loadoutIndex + "]." + loadoutProperty
	var value = player.GetPersistentVar( getString )

	#if SERVER
	// This checks if the item data is setup and the player is allowed to use it, not if it's valid persistent data
	// Also checks only primary mods and attachments are valid in itemData and the parent isn't locked
	if ( LoadoutPropertyRequiresItemValidation( loadoutProperty ) && value != null )
	{
		expect string( value )
		if ( !IsRefValid( value ) || !IsLoadoutSubitemValid( player, loadoutType, loadoutIndex, loadoutProperty, value ) )
		{
			value = GetLoadoutPropertyDefault( loadoutType, loadoutProperty )

			if ( value != "" )
			{
				Assert( IsRefValid( value ), "IsRefValid() failed after " + loadoutType + " loadout property: " + loadoutProperty + " reset to value: " + value )
				Assert( IsLoadoutSubitemValid( player, loadoutType, loadoutIndex, loadoutProperty, value ), "IsLoadoutSubitemValid() failed after " + loadoutType + " loadout property: " + loadoutProperty + " reset to value: " + value )
			}

			// TODO: This is dangerous
			// We are within a getter function, we should NOT be modifying loadout data from a getter.
			SetPersistentLoadoutValue( player, loadoutType, loadoutIndex, loadoutProperty, value )
		}
	}
	#endif

	if ( loadoutPropertyEnum != null && value != null ) // TODO: This skips the assert for values that are null, which are sometimes valid.
		Assert( PersistenceEnumValueIsValid( loadoutPropertyEnum, value ), "Invalid loadoutPropertyEnum: " + loadoutPropertyEnum + " or ref value: " + value )

	if ( value == null )
		value = ""

	return string( value )
}


int function GetPersistentLoadoutValueInt( entity player, string loadoutType, int loadoutIndex, string loadoutProperty )
{
	return int( GetPersistentLoadoutValue( player, loadoutType, loadoutIndex, loadoutProperty ) )
}

string function GetPersistentLoadoutPropertyType( string loadoutProperty )
{
	switch ( loadoutProperty )
	{
		case "skinIndex":
		case "camoIndex":
		case "decalIndex":
		case "primarySkinIndex":
		case "primaryCamoIndex":
		case "secondarySkinIndex":
		case "secondaryCamoIndex":
			return "int"
	}

	return "string"
}


#if SERVER
// TODO: If we change a property that has a parent or child relationship, all related properties need updating if invalid
// 		A parent change should validate children and set invalid to defaults
// 		If a child change is invalid for the parent, it should be changed to a valid default based on the parent
function SetPersistentLoadoutValue( entity player, string loadoutType, int loadoutIndex, string loadoutProperty, string value )
{
	// printt( "=======================================================================================" )
	// printt( "SetPersistentLoadoutValue called with loadoutType:", loadoutType, "loadoutIndex:", loadoutIndex, "loadoutProperty:" , loadoutProperty, "value:", value )
	// printl( "script GetPlayerArray()[0].SetPersistentVar( \"" + loadoutType + "Loadouts[" + loadoutIndex + "]." + loadoutProperty + "\", \"" + value + "\" )" )
	// printt( "=======================================================================================" )

	Assert( loadoutType == "pilot" || loadoutType == "titan" )
	Assert( loadoutIndex < PersistenceGetArrayCount( loadoutType + "Loadouts" ), "SetPersistentLoadoutValue() called with invalid loadoutIndex: " + loadoutIndex )

	if ( value == "none" )
		value = ""

	var loadoutPropertyEnum = null
	if ( loadoutType == "pilot" )
	{
		Assert( IsValidPilotLoadoutProperty( loadoutProperty ), "SetPersistentLoadoutValue() called with invalid pilot loadoutProperty: " + loadoutProperty )

		loadoutPropertyEnum = GetPilotLoadoutPropertyEnum( loadoutProperty )
	}
	else
	{
		Assert( IsValidTitanLoadoutProperty( loadoutProperty ), "SetPersistentLoadoutValue() called with invalid titan loadoutProperty: " + loadoutProperty )

		loadoutPropertyEnum = GetTitanLoadoutPropertyEnum( loadoutProperty )
	}

	if ( LoadoutPropertyRequiresItemValidation( loadoutProperty ) && value != "" )
	{
		Assert( IsRefValid( value ), "SetPersistentLoadoutValue() call " + loadoutType + " " + loadoutProperty + " value: " + value + " failed IsRefValid() check!" )
	}

	if ( loadoutPropertyEnum != null && value != "" && !PersistenceEnumValueIsValid( loadoutPropertyEnum, value ) )
	{
		CodeWarning( loadoutType + " " + loadoutProperty + " value: " + value + " not valid in persistent data!" )
		return
	}

	// Only checks primary mods and attachments are valid in itemData and the parent isn't locked
	if ( !IsLoadoutSubitemValid( player, loadoutType, loadoutIndex, loadoutProperty, value ) )
	{
		CodeWarning( loadoutType + " " + loadoutProperty + " value: " + value + " failed IsLoadoutSubitemValid() check! It may not exist in itemData, or it's parent item is locked." )
		return
	}

	if ( GetPersistentLoadoutPropertyType( loadoutProperty ) == "int" )
		player.SetPersistentVar( loadoutType + "Loadouts[" + loadoutIndex + "]." + loadoutProperty, int( value ) )
	else
		player.SetPersistentVar( loadoutType + "Loadouts[" + loadoutIndex + "]." + loadoutProperty, value )

	// Reset child properties when parent changes
	array<string> childProperties = GetChildLoadoutProperties( loadoutType, loadoutProperty )
	if ( childProperties.len() )
	{
		foreach ( childProperty in childProperties )
		{
			Assert( value != "" )
			string childValue = GetLoadoutChildPropertyDefault( loadoutType, childProperty, value )

			if ( GetPersistentLoadoutPropertyType( childProperty ) == "int" )
				player.SetPersistentVar( loadoutType + "Loadouts[" + loadoutIndex + "]." + childProperty, int( childValue ) )
			else
				player.SetPersistentVar( loadoutType + "Loadouts[" + loadoutIndex + "]." + childProperty, childValue )
		}
	}

	#if HAS_THREAT_SCOPE_SLOT_LOCK
		if ( loadoutProperty.tolower() == "primaryattachment" && value == "threat_scope" )
		{
			player.SetPersistentVar( loadoutType + "Loadouts[" + loadoutIndex + "]." + "primaryMod2", "" )
		}
	#endif

	// TEMP client model update method
	bool updateModel = ( loadoutProperty == "suit" || loadoutProperty == "race" || loadoutProperty == "setFile" || loadoutProperty == "primary" || loadoutProperty == "decal" )

	if ( loadoutType == "pilot" )
	{
		player.p.pilotLoadoutChanged = true

		if ( updateModel )
			player.p.pilotModelNeedsUpdate = loadoutIndex
	}
	else
	{
		player.p.titanLoadoutChanged = true

		if ( updateModel )
			player.p.titanModelNeedsUpdate = loadoutIndex
	}

	thread UpdateCachedLoadouts()
}
#endif

#if UI || CLIENT
void function SetCachedPilotLoadoutValue( entity player, int loadoutIndex, string loadoutProperty, string value )
{
	if ( !IsValidPilotLoadoutProperty( loadoutProperty ) )
	{
		CodeWarning( "Tried to set pilot " + loadoutProperty + " to invalid value: " + value )
		return
	}

	// Reset child properties when parent changes
	array<string> childProperties = GetChildLoadoutProperties( "pilot", loadoutProperty )
	if ( childProperties.len() )
	{
		foreach ( childProperty in childProperties )
		{
			Assert( value != "" )
			string childValue = GetLoadoutChildPropertyDefault( "pilot", childProperty, value )
			SetPilotLoadoutValue( shGlobal.cachedPilotLoadouts[ loadoutIndex ], childProperty, childValue )
		}
	}

	#if HAS_THREAT_SCOPE_SLOT_LOCK
	if ( loadoutProperty.tolower() == "primaryattachment" && value == "threat_scope" )
	{
		SetPilotLoadoutValue( shGlobal.cachedPilotLoadouts[ loadoutIndex ], "primaryMod2", "" )
	}
	#endif

	SetPilotLoadoutValue( shGlobal.cachedPilotLoadouts[ loadoutIndex ], loadoutProperty, value )
	UpdateDerivedPilotLoadoutData( shGlobal.cachedPilotLoadouts[ loadoutIndex ] )

	#if UI
		ClientCommand( "SetPersistentLoadoutValue pilot " + loadoutIndex + " " + loadoutProperty + " " + value )
	#endif // UI
}


void function SetCachedTitanLoadoutValue( entity player, int loadoutIndex, string loadoutProperty, string value )
{
	if ( !IsValidTitanLoadoutProperty( loadoutProperty ) )
	{
		CodeWarning( "Tried to set titan " + loadoutProperty + " to invalid value: " + value )
		return
	}

	// Reset child properties when parent changes
	array<string> childProperties = GetChildLoadoutProperties( "titan", loadoutProperty )
	if ( childProperties.len() )
	{
		foreach ( childProperty in childProperties )
		{
			Assert( value != "" )
			string childValue = GetLoadoutChildPropertyDefault( "titan", childProperty, value )
			SetTitanLoadoutValue( shGlobal.cachedTitanLoadouts[ loadoutIndex ], childProperty, childValue )
		}
	}

	SetTitanLoadoutValue( shGlobal.cachedTitanLoadouts[ loadoutIndex ], loadoutProperty, value )
	UpdateDerivedTitanLoadoutData( shGlobal.cachedTitanLoadouts[ loadoutIndex ] )

	#if UI
		ClientCommand( "SetPersistentLoadoutValue titan " + loadoutIndex + " " + loadoutProperty + " " + value )
	#endif // UI
}



// TODO: If we change a property that has a parent or child relationship, all related properties need updating if invalid
// 		A parent change should validate children and set invalid to defaults
// 		If a child change is invalid for the parent, it should be changed to a valid default based on the parent
void function SetCachedLoadoutValue( entity player, string loadoutType, int loadoutIndex, string loadoutProperty, string value )
{
	// Keep CLIENT matching UI
	#if UI
		RunClientScript( "SetCachedLoadoutValue", player, loadoutType, loadoutIndex, loadoutProperty, value )
	#endif // UI

	//printt( "=======================================================================================" )
	//printt( "SetPersistentLoadoutValue called with loadoutType:", loadoutType, "loadoutIndex:", loadoutIndex, "loadoutProperty:" , loadoutProperty, "value:", value )
	//printl( "script GetPlayerArray()[0].SetPersistentVar( \"" + loadoutType + "Loadouts[" + loadoutIndex + "]." + loadoutProperty + "\", \"" + value + "\" )" )
	//printt( "=======================================================================================" )

	if ( loadoutType == "pilot" )
		SetCachedPilotLoadoutValue( player, loadoutIndex, loadoutProperty, value )
	else if ( loadoutType == "titan" )
		SetCachedTitanLoadoutValue( player, loadoutIndex, loadoutProperty, value )
	else
		CodeWarning( "Unhandled loadoutType: " + loadoutType )

	/*
	Assert( loadoutType == "pilot" || loadoutType == "titan" )
	Assert( loadoutIndex < PersistenceGetArrayCount( loadoutType + "Loadouts" ), "Invalid loadoutIndex: " + loadoutIndex )

	if ( value == "null" || value == "" || value == null )
	{
		CodeWarning( "Tried to set " + loadoutType + " " + loadoutProperty + " to invalid value: " + value )
		return
	}

	var loadoutPropertyEnum = null
	if ( loadoutType == "pilot" )
	{
		if ( !IsValidPilotLoadoutProperty( loadoutProperty ) )
		{
			CodeWarning( "Invalid pilot loadoutProperty: " + loadoutProperty )
			return
		}

		loadoutPropertyEnum = GetPilotLoadoutPropertyEnum( loadoutProperty )
	}
	else
	{
		if ( !IsValidTitanLoadoutProperty( loadoutProperty ) )
		{
			CodeWarning( "Invalid titan loadoutProperty: " + loadoutProperty )
			return
		}

		loadoutPropertyEnum = GetTitanLoadoutPropertyEnum( loadoutProperty )
	}

	if ( loadoutPropertyEnum == null )
	{
		CodeWarning( "Couldn't find loadoutPropertyEnum for " + loadoutType + " " + loadoutProperty )
		return
	}

	if ( !PersistenceEnumValueIsValid( loadoutPropertyEnum, value ) )
	{
		CodeWarning( loadoutProperty + " value: " + value + " not valid in persistent data!" )
		return
	}

	// Only checks primary mods and attachments are valid in itemData and the parent isn't locked
	if ( !IsLoadoutSubitemValid( player, loadoutType, loadoutIndex, loadoutProperty, value ) )
	{
		CodeWarning( loadoutProperty + " value: " + value + " failed IsLoadoutSubitemValid() check! It may not exist in itemData, or it's parent item is locked." )
		return
	}

	// Reset child properties when parent changes
	array<string> childProperties = GetChildLoadoutProperties( loadoutType, loadoutProperty )
	if ( childProperties.len() )
	{
		foreach ( childProperty in childProperties )
		{
			Assert( value != "" )
			string childValue = GetLoadoutChildPropertyDefault( loadoutType, childProperty, value )

			if ( loadoutType == "pilot" )
				SetPilotLoadoutValue( shGlobal.cachedPilotLoadouts[ loadoutIndex ], childProperty, childValue )
			else
				SetTitanLoadoutValue( shGlobal.cachedTitanLoadouts[ loadoutIndex ], childProperty, childValue )
		}
	}

	if ( loadoutType == "pilot" )
	{
		SetPilotLoadoutValue( shGlobal.cachedPilotLoadouts[ loadoutIndex ], loadoutProperty, value )
		UpdateDerivedPilotLoadoutData( shGlobal.cachedPilotLoadouts[ loadoutIndex ] )
	}
	else
	{
		SetTitanLoadoutValue( shGlobal.cachedTitanLoadouts[ loadoutIndex ], loadoutProperty, value )
		OverwriteLoadoutWithDefaultsForSetFile_ExceptSpecialAndAntiRodeo( shGlobal.cachedTitanLoadouts[ loadoutIndex ] )
	}

	if ( value == "" || value == "null" )
		ClientCommand( "SetPersistentLoadoutValue " + loadoutType + " " + loadoutIndex + " " + loadoutProperty + " " + null )
	else
		ClientCommand( "SetPersistentLoadoutValue " + loadoutType + " " + loadoutIndex + " " + loadoutProperty + " " + value )
		*/
}
#endif // UI || CLIENT

// SERVER version waits till end of frame to reduce remote calls which can get high when loadouts are first initialized
// CLIENT and UI versions need to wait for persistent data to be ready
// Ideally, UI and CLIENT would have a callback that triggered when persistent loadout data changed.
void function UpdateCachedLoadouts()
{
	#if SERVER
		Signal( level, "EndUpdateCachedLoadouts" )
		EndSignal( level, "EndUpdateCachedLoadouts" )

		WaitEndFrame()

		array<entity> players = GetPlayerArray()

		foreach ( player in players )
		{
			if ( player.p.pilotLoadoutChanged )
			{
				Remote_CallFunction_NonReplay( player, "UpdateAllCachedPilotLoadouts" )
				player.p.pilotLoadoutChanged = false
			}

			if ( player.p.titanLoadoutChanged )
			{
				Remote_CallFunction_NonReplay( player, "UpdateAllCachedTitanLoadouts" )
				player.p.titanLoadoutChanged = false
			}

			// TEMP client model update method
			if ( player.p.pilotModelNeedsUpdate != -1 )
			{
				Remote_CallFunction_NonReplay( player, "ServerCallback_UpdatePilotModel", player.p.pilotModelNeedsUpdate )
				player.p.pilotModelNeedsUpdate = -1
			}

			if ( player.p.titanModelNeedsUpdate != -1 )
			{
				Remote_CallFunction_NonReplay( player, "ServerCallback_UpdateTitanModel", player.p.titanModelNeedsUpdate )
				player.p.titanModelNeedsUpdate = -1
			}
		}
	#elseif UI || CLIENT
		#if UI
			entity player = GetUIPlayer()
		#elseif CLIENT
			entity player = GetLocalClientPlayer()
		#endif

		if ( player == null )
			return

		#if UI
			EndSignal( uiGlobal.signalDummy, "LevelShutdown" )
		#endif // UI

		while ( player.GetPersistentVarAsInt( "initializedVersion" ) < PERSISTENCE_INIT_VERSION )
		{
			WaitFrame()
		}

		UpdateAllCachedPilotLoadouts()
		UpdateAllCachedTitanLoadouts()
		#if CLIENT
			Signal( level, "CachedLoadoutsReady" )
		#endif // CLIENT
	#endif
}

#if UI
	void function InitUISpawnLoadoutIndexes()
	{
		EndSignal( uiGlobal.signalDummy, "LevelShutdown" )

		entity player = GetUIPlayer()

		if ( player == null )
			return

		while ( player.GetPersistentVarAsInt( "initializedVersion" ) < PERSISTENCE_INIT_VERSION )
			WaitFrame()

		uiGlobal.pilotSpawnLoadoutIndex = GetPersistentSpawnLoadoutIndex( player, "pilot" )
		uiGlobal.titanSpawnLoadoutIndex = GetPersistentSpawnLoadoutIndex( player, "titan" )
	}
#endif // UI

// There's no good way to dynamically reference a struct variable
string function GetPilotLoadoutValue( PilotLoadoutDef loadout, string property )
{
	string value

	switch ( property )
	{
		case "name":
			value = loadout.name
			break

		case "suit":
			value = loadout.suit
			break

		case "race":
			value = loadout.race
			break

		case "primary":
			value = loadout.primary
			break

		case "primaryAttachment":
			value = loadout.primaryAttachment
			break

		case "primaryMod1":
			value = loadout.primaryMod1
			break

		case "primaryMod2":
			value = loadout.primaryMod2
			break

		case "primaryMod3":
			value = loadout.primaryMod3
			break

		case "secondary":
			value = loadout.secondary
			break

		case "secondaryMod1":
			value = loadout.secondaryMod1
			break

		case "secondaryMod2":
			value = loadout.secondaryMod2
			break

		case "secondaryMod3":
			value = loadout.secondaryMod3
			break

		case "special":
			value = loadout.special
			break

		case "ordnance":
			value = loadout.ordnance
			break

		case "passive1":
			value = loadout.passive1
			break

		case "passive2":
			value = loadout.passive2
			break

		case "melee":
			value = loadout.melee
			break

		case "execution":
			value = loadout.execution
			break

		case "skinIndex":
			//value = loadout.skinIndex
			break

		case "camoIndex":
			//value = loadout.camoIndex
			break

		case "primarySkinIndex":
			//value = loadout.primarySkinIndex
			break

		case "primaryCamoIndex":
			//value = loadout.primaryCamoIndex
			break

		case "secondarySkinIndex":
			//value = loadout.secondarySkinIndex
			break

		case "secondaryCamoIndex":
			//value = loadout.secondaryCamoIndex
			break
	}

	return value
}

// There's no good way to dynamically reference a struct variable
// If this starts getting called outside of SetPersistentLoadoutValue(), it needs error checking
void function SetPilotLoadoutValue( PilotLoadoutDef loadout, string property, string value )
{
	switch ( property )
	{
		case "name":
			loadout.name = value
			break

		case "suit":
			loadout.suit = value
			break

		case "execution":
			loadout.execution = value
			break

		case "race":
			loadout.race = value
			break

		case "primary":
			loadout.primary = value
			break

		case "primaryAttachment":
			loadout.primaryAttachment = value
			break

		case "primaryMod1":
			loadout.primaryMod1 = value
			break

		case "primaryMod2":
			loadout.primaryMod2 = value
			break

		case "primaryMod3":
			loadout.primaryMod3 = value
			break

		case "secondary":
			loadout.secondary = value
			break

		case "secondaryMod1":
			loadout.secondaryMod1 = value
			break

		case "secondaryMod2":
			loadout.secondaryMod2 = value
			break

		case "secondaryMod3":
			loadout.secondaryMod3 = value
			break

		case "special":
			loadout.special = value
			break

		case "ordnance":
			loadout.ordnance = value
			break

		case "passive1":
			loadout.passive1 = value
			break

		case "passive2":
			loadout.passive2 = value
			break

		case "melee":
			loadout.melee = value
			break

		case "skinIndex":
			loadout.skinIndex = int( value )
			break

		case "camoIndex":
			loadout.camoIndex = int( value )
			break

		case "primarySkinIndex":
			loadout.primarySkinIndex = int( value )
			break

		case "primaryCamoIndex":
			loadout.primaryCamoIndex = int( value )
			break

		case "secondarySkinIndex":
			loadout.secondarySkinIndex = int( value )
			break

		case "secondaryCamoIndex":
			loadout.secondaryCamoIndex = int( value )
			break
	}
}

// There's no good way to dynamically reference a struct variable
string function GetTitanLoadoutValue( TitanLoadoutDef loadout, string property )
{
	string value

	switch ( property )
	{
		case "name":
			value = loadout.name
			break

		case "setFile":
			value = loadout.setFile
			break

		case "coreAbility":
			value = loadout.coreAbility
			break

		case "primary":
			value = loadout.primary
			break

		case "primaryMod":
			value = loadout.primaryMod
			break

		case "special":
			value = loadout.special
			break

		case "antirodeo":
			value = loadout.antirodeo
			break

		case "ordnance":
			value = loadout.ordnance
			break

		case "passive1":
			value = loadout.passive1
			break

		case "passive2":
			value = loadout.passive2
			break

		case "passive3":
			value = loadout.passive3
			break

		case "voice":
			value = loadout.voice
			break

		case "skinIndex":
			//value = loadout.skinIndex
			break

		case "camoIndex":
			//value = loadout.camoIndex
			break

		case "decalIndex":
			//value = loadout.decalIndex
			break

		case "primarySkinIndex":
			//value = loadout.primarySkinIndex
			break

		case "primaryCamoIndex":
			//value = loadout.primaryCamoIndex
			break
	}

	return value
}

// There's no good way to dynamically reference a struct variable
// If this starts getting called outside of SetPersistentLoadoutValue(), it needs error checking
void function SetTitanLoadoutValue( TitanLoadoutDef loadout, string property, string value )
{
	switch ( property )
	{
		case "name":
			loadout.name = value
			break

		case "setFile":
			loadout.setFile = value
			break

		case "primaryMod":
			loadout.primaryMod = value
			break

		case "special":
			loadout.special = value
			break

		case "antirodeo":
			loadout.antirodeo = value
			break

		case "passive1":
			loadout.passive1 = value
			break

		case "passive2":
			loadout.passive2 = value
			break

		case "passive3":
			loadout.passive3 = value
			break

		case "voice":
			loadout.voice = value
			break

		case "skinIndex":
			loadout.skinIndex = int( value )
			break

		case "camoIndex":
			loadout.camoIndex = int( value )
			break

		case "decalIndex":
			loadout.decalIndex = int( value )
			break

		case "primarySkinIndex":
			loadout.primarySkinIndex = int( value )
			break

		case "primaryCamoIndex":
			loadout.primaryCamoIndex = int( value )
			break
	}
}

bool function IsValidPilotLoadoutProperty( string propertyName )
{
	switch ( propertyName )
	{
		case "name":
		case "suit":
		case "race":
		case "execution":
		case "primary":
		case "primaryAttachment":
		case "primaryMod1":
		case "primaryMod2":
		case "primaryMod3":
		case "secondary":
		case "secondaryMod1":
		case "secondaryMod2":
		case "secondaryMod3":
		case "ordnance":
		case "special":
		case "passive1":
		case "passive2":
		case "melee":
		case "skinIndex":
		case "camoIndex":
		case "primarySkinIndex":
		case "primaryCamoIndex":
		case "secondarySkinIndex":
		case "secondaryCamoIndex":
			return true
	}

	return false
}

bool function IsValidTitanLoadoutProperty( string propertyName )
{
	switch ( propertyName )
	{
		case "name":
		case "titanClass":
		case "setFile":
		case "primaryMod":
		case "special":
		case "antirodeo":
		case "passive1":
		case "passive2":
		case "passive3":
		case "voice":
		case "skinIndex":
		case "camoIndex":
		case "decalIndex":
		case "primarySkinIndex":
		case "primaryCamoIndex":
			return true
	}

	return false
}

var function GetPilotLoadoutPropertyEnum( string property )
{
	switch ( property )
	{
		case "suit":
			return "pilotSuit"

		case "race":
			return "pilotRace"

		case "primary":
		case "secondary":
		case "special":
		case "ordnance":
		case "melee":
			return "loadoutWeaponsAndAbilities"

		case "primaryAttachment":
		case "primaryMod1":
		case "primaryMod2":
		case "primaryMod3":
		case "secondaryMod1":
		case "secondaryMod2":
		case "secondaryMod3":
			return "pilotMod"

		case "passive1":
		case "passive2":
			return "pilotPassive"

		case "name":
		default:
			return null
	}
}

var function GetTitanLoadoutPropertyEnum( string property )
{
	switch ( property )
	{
		case "titanClass":
			return "titanClasses"
		case "primary":
		case "special":
		case "antirodeo":
		case "ordnance":
			return "loadoutWeaponsAndAbilities"
		case "primaryMod":
			return "titanMod"
		case "passive1":
		case "passive2":
		case "passive3":
			return "titanPassive"

		case "name":
		default:
			return null
	}
}

int function GetItemTypeFromPilotLoadoutProperty( string loadoutProperty )
{
	int itemType

	switch ( loadoutProperty )
	{
		case "suit":
			itemType = eItemTypes.PILOT_SUIT
			break

		case "primary":
			itemType = eItemTypes.PILOT_PRIMARY
			break

		case "secondary":
			itemType = eItemTypes.PILOT_SECONDARY
			break

		case "special":
			itemType = eItemTypes.PILOT_SPECIAL
			break

		case "ordnance":
			itemType = eItemTypes.PILOT_ORDNANCE
			break

		case "passive1":
			itemType = eItemTypes.PILOT_PASSIVE1
			break

		case "passive2":
			itemType = eItemTypes.PILOT_PASSIVE2
			break

		case "primaryAttachment":
			itemType = eItemTypes.PILOT_PRIMARY_ATTACHMENT
			break

		case "primaryMod1":
		case "primaryMod2":
			itemType = eItemTypes.PILOT_PRIMARY_MOD
			break

		case "secondaryMod1":
		case "secondaryMod2":
			itemType = eItemTypes.PILOT_SECONDARY_MOD
			break

		case "primaryMod3":
		case "secondaryMod3":
			itemType = eItemTypes.PILOT_WEAPON_MOD3
			break

		case "race":
			itemType = eItemTypes.RACE
			break

		case "execution":
			itemType = eItemTypes.PILOT_EXECUTION
			break

		default:
			Assert( false, "Invalid pilot loadout property!" )
	}

	return itemType
}

int function GetItemTypeFromTitanLoadoutProperty( string loadoutProperty, string setFile = "" )
{
	int itemType

	switch ( loadoutProperty )
	{
		case "setFile":
			itemType = eItemTypes.TITAN
			break

		case "coreAbility":
			itemType = eItemTypes.TITAN_CORE_ABILITY
			break

		case "primary":
			itemType = eItemTypes.TITAN_PRIMARY
			break

		case "special":
			itemType = eItemTypes.TITAN_SPECIAL
			break

		case "ordnance":
			itemType = eItemTypes.TITAN_ORDNANCE
			break

		case "antirodeo":
			itemType = eItemTypes.TITAN_ANTIRODEO
			break

		case "passive1":
		case "passive2":
		case "passive3":
			Assert( setFile != "" )
			itemType = GetTitanLoadoutPropertyPassiveType( setFile, loadoutProperty )
			break

		case "voice":
			itemType = eItemTypes.TITAN_OS
			break

		case "primaryMod":
			itemType = eItemTypes.TITAN_PRIMARY_MOD
			break

		case "decal":
			itemType = eItemTypes.TITAN_NOSE_ART
			break

		default:
			Assert( false, "Invalid titan loadout property!" )
	}

	return itemType
}

bool function LoadoutPropertyRequiresItemValidation( string loadoutProperty )
{
	switch ( loadoutProperty )
	{
		case "name":
		case "titanClass":
		case "skinIndex":
		case "camoIndex":
		case "decalIndex":
		case "primarySkinIndex":
		case "primaryCamoIndex":
		case "secondarySkinIndex":
		case "secondaryCamoIndex":
			return false
	}

	return true
}

// Only checks primary mods and attachments are valid in itemData and the parent isn't locked
bool function IsLoadoutSubitemValid( entity player, string loadoutType, int loadoutIndex, string property, string ref )
{
	string childRef = ""

	switch ( property )
	{
		case "primaryAttachment":
		case "primaryMod1":
		case "primaryMod2":
		case "primaryMod3":
		case "secondaryMod1":
		case "secondaryMod2":
		case "secondaryMod3":
			if ( loadoutType == "pilot" )
			{
				string parentProperty = GetParentLoadoutProperty( loadoutType, property )
				string loadoutString = loadoutType + "Loadouts[" + loadoutIndex + "]." + parentProperty
				if ( ref != "" )
					childRef = ref
				ref = expect string( player.GetPersistentVar( loadoutString ) )
			}
			break
		case "skinIndex":
		case "camoIndex":
		case "decalIndex":
		case "primarySkinIndex":
		case "primaryCamoIndex":
		case "secondarySkinIndex":
		case "secondaryCamoIndex":
			return true
			break
	}
	// TODO: Seems bad to pass null childRef on to some of the checks below if the property wasn't one of the above

	// invalid attachment
	if ( childRef != "" && !HasSubitem( ref, childRef ) )
		return false

	//if ( IsItemLocked( player, childRef, expect string( ref ) ) )
	//	return false

	return true
}

string function GetLoadoutChildPropertyDefault( string loadoutType, string propertyName, string parentValue )
{
	Assert( loadoutType == "pilot" || loadoutType == "titan" )

	string resetValue = ""

	if ( loadoutType == "pilot" )
	{
		if ( propertyName == "primaryAttachment" ||
			 propertyName == "primaryMod1" ||
			 propertyName == "primaryMod2" ||
			 propertyName == "primaryMod3" ||
			 propertyName == "secondaryMod1" ||
			 propertyName == "secondaryMod2" ||
			 propertyName == "secondaryMod3" )
			resetValue = GetWeaponBasedDefaultMod( parentValue, propertyName )
		//else if ( propertyName == "passive1" || propertyName == "passive2" )
		//	resetValue = GetSuitBasedDefaultPassive( parentValue, propertyName )
	}

	return resetValue
}

// TODO:
string function GetLoadoutPropertyDefault( string loadoutType, string propertyName )
{
	switch ( propertyName )
	{
		case "skinIndex":
		case "camoIndex":
		case "decalIndex":
		case "primarySkinIndex":
		case "primaryCamoIndex":
		case "secondarySkinIndex":
		case "secondaryCamoIndex":
			return "0"
	}

	return ""

	/*var resetValue

	array<string> childProperties = GetChildLoadoutProperties( loadoutType, propertyName )
	bool isParent = childProperties.len() > 0 ? true : false

	if ( isParent )
	{
		switch ( propertyName )
		{
			case "test":
			default:
				resetValue = "test"
				break
		}
	}
	else
	{
		resetValue = null
	}

	if ( resetValue != null )
		Assert( IsRefValid( resetValue ) ) // TODO: only doing itemdata check

	return resetValue*/
}

// There's no great way to know the dependency heirarchy of persistent loadout data
array<string> function GetChildLoadoutProperties( string loadoutType, string propertyName )
{
	Assert( loadoutType == "pilot" || loadoutType == "titan" )

	array<string> childProperties

	if ( loadoutType == "pilot" )
	{
		switch ( propertyName )
		{
			/*case "suit":
				childProperties.append( "passive1" )
				childProperties.append( "passive2" )
				break*/

			case "primary":
				childProperties.append( "primaryAttachment" )
				childProperties.append( "primaryMod1" )
				childProperties.append( "primaryMod2" )
				childProperties.append( "primaryMod3" )
				childProperties.append( "primaryCamoIndex" )
				break

			case "secondary":
				childProperties.append( "secondaryMod1" )
				childProperties.append( "secondaryMod2" )
				childProperties.append( "secondaryMod3" )
				childProperties.append( "secondaryCamoIndex" )
				break

			/*case "melee":
				childProperties.append( "meleeMods" ) // not in persistent data
				break

			case "ordnance":
				childProperties.append( "ordnanceMods" ) // not in persistent data
				break*/
		}
	}
	else
	{
		switch ( propertyName )
		{
			/*case "setFile":
				childProperties.append( "setFileMods" ) // not in persistent data
				break*/

			case "primary":
				//childProperties.append( "primaryAttachment" ) // not in persistent data
				childProperties.append( "primaryMod" )
				break

			/*case "special":
				childProperties.append( "specialMods" ) // not in persistent data
				break

			case "ordnance":
				childProperties.append( "ordnanceMods" ) // not in persistent data
				break

			case "antirodeo":
				childProperties.append( "antirodeoMods" ) // not in persistent data
				break*/
		}
	}

	return childProperties
}

// There's no great way to know the dependency heirarchy of persistent loadout data
string function GetParentLoadoutProperty( string loadoutType, string propertyName )
{
	Assert( loadoutType == "pilot" || loadoutType == "titan" )

	string parentProperty

	if ( loadoutType == "pilot" )
	{
		switch ( propertyName )
		{
			case "primaryAttachment":
			case "primaryMod1":
			case "primaryMod2":
			case "primaryMod3":
			case "primaryCamoIndex":
				parentProperty = "primary"
				break

			case "secondaryMod1":
			case "secondaryMod2":
			case "secondaryMod3":
			case "secondaryCamoIndex":
				parentProperty = "secondary"
				break

			case "passive1":
			case "passive2":
			case "passive3":
				parentProperty = "special"
				break

			/*case "meleeMods": // not in persistent data
				parentProperty = "melee"
				break

			case "specialMods": // not in persistent data
				parentProperty = "special"
				break

			case "ordnanceMods": // not in persistent data
				parentProperty = "ordnance"
				break*/

			default:
				Assert( 0, "Unknown loadout propertyName: " + propertyName )
		}
	}
	else
	{
		switch ( propertyName )
		{
			//case "primaryAttachment": // not in persistent data
			case "primaryMod":
				parentProperty = "primary"
				break

			/*case "meleeMods": // not in persistent data
				parentProperty = "melee"
				break

			case "specialMods": // not in persistent data
				parentProperty = "special"
				break

			case "ordnanceMods": // not in persistent data
				parentProperty = "ordnance"
				break*/

			default:
				Assert( 0, "Unknown loadout propertyName: " + propertyName )
		}
	}

	return parentProperty
}

int function GetPersistentSpawnLoadoutIndex( entity player, string loadoutType )
{
	return player.GetPersistentVarAsInt( loadoutType + "SpawnLoadout.index" )
}

void function SetPersistentSpawnLoadoutIndex( entity player, string loadoutType, int loadoutIndex )
{
	Assert( loadoutIndex >= 0 )
	player.SetPersistentVar( loadoutType + "SpawnLoadout.index", loadoutIndex )
}

#if UI
	void function SetEditLoadout( string loadoutType, int loadoutIndex )
	{
		uiGlobal.editingLoadoutType = loadoutType
		uiGlobal.editingLoadoutIndex = loadoutIndex
	}

	void function ClearEditLoadout()
	{
		uiGlobal.editingLoadoutType = ""
		uiGlobal.editingLoadoutIndex = -1
	}

	PilotLoadoutDef function GetPilotEditLoadout()
	{
		return GetCachedPilotLoadout( uiGlobal.editingLoadoutIndex )
	}

	TitanLoadoutDef function GetTitanEditLoadout()
	{
		return GetCachedTitanLoadout( uiGlobal.editingLoadoutIndex )
	}

	string function GetPilotLoadoutName( PilotLoadoutDef loadout )
	{
		if ( IsTokenLoadoutName( loadout.name ) )
			return Localize( loadout.name )

		return loadout.name
	}

	string function GetTitanLoadoutName( TitanLoadoutDef loadout )
	{
		if ( IsTokenLoadoutName( loadout.name ) )
			return Localize( loadout.name )

		return loadout.name
	}

	function SetTextFromItemName( element, string ref )
	{
		local text = ""

		if ( ref != "" )
			text = GetItemName( ref )

		Hud_SetText( element, text )
	}

	function SetTextFromItemDescription( element, string ref )
	{
		local text = ""

		if ( ref != "" )
			text = GetItemDescription( ref )

		Hud_SetText( element, text )
	}

	function SetTextFromItemLongDescription( element, string ref )
	{
		local text = ""

		if ( ref != "" )
			text = GetItemLongDescription( ref )

		if ( text == null )
			Hud_SetText( element, "ERROR: NO LONG DESC SPECIFIED" )
		else
			Hud_SetText( element, text )
	}

	function SetImageFromItemImage( element, string ref )
	{
		if ( ref != "" )
		{
			element.SetImage( GetItemImage( ref ) )
			Hud_Show( element )
		}
		else
		{
			Hud_Hide( element )
		}
	}

	function SetTextFromSubItemClipSize( element, string ref, string modRef )
	{
		Hud_SetText( element, "" )
		if ( ref != "" && modRef != "" )
		{
			local clipDiff = GetSubItemClipSizeStat( ref, modRef )
			if ( clipDiff == null || clipDiff == 0 )
				return

			if ( clipDiff > 0 )
			{
				element.SetColor( 141, 197, 84, 255 )
				Hud_SetText( element, "#MOD_CLIP_AMMO_INCREASE", string( clipDiff ) )
			}
			else
			{
				element.SetColor( 211, 77, 61, 255 )
				Hud_SetText( element, "#MOD_CLIP_AMMO_DECREASE", string( abs( clipDiff ) ) )
			}
		}
	}

	function SetTextFromSubitemName( var element, string parentRef, string childRef, string defaultText = "" )
	{
		string text = defaultText

		if ( parentRef != "" && childRef != "" && childRef != "none" )
			text = GetSubitemName( parentRef, childRef )

		Hud_SetText( element, text )
	}

	function SetTextFromSubitemDescription( element, string parentRef, string childRef, defaultText = "" )
	{
		local text = defaultText

		if ( parentRef != "" && childRef != "" && childRef != "none" )
			text = GetSubitemDescription( parentRef, childRef )

		Hud_SetText( element, text )
	}

	function SetTextFromSubitemLongDescription( element, string parentRef, string childRef, defaultText = "" )
	{
		local text = defaultText

		if ( parentRef != "" && childRef != "" && childRef != "none" )
			text = GetSubitemLongDescription( parentRef, childRef )

		if ( text == null )
			Hud_SetText( element, "ERROR: NO LONG DESC SPECIFIED" )
		else
			Hud_SetText( element, text )
	}

	function SetImageFromSubitemImage( element, string parentRef, string childRef, asset defaultIcon = $"" )
	{
		if ( parentRef != "" && childRef != "" && childRef != "none" )
		{
			element.SetImage( GetSubitemImage( parentRef, childRef ) )
			Hud_Show( element )
		}
		else
		{
			if ( defaultIcon != $"" )
			{
				element.SetImage( defaultIcon )
				Hud_Show( element )
			}
			else
			{
				Hud_Hide( element )
			}
		}
	}

	function SetTextFromSubitemUnlockReq( element, string parentRef, string childRef, defaultText = "" )
	{
		local text = defaultText

		if ( parentRef != "" && childRef != "" && childRef != "none" )
			text = GetItemUnlockReqText( childRef, parentRef )

		Hud_SetText( element, text )
	}
#endif //UI

#if UI || CLIENT
	void function UpdateAllCachedPilotLoadouts()
	{
		int numLoadouts = shGlobal.cachedPilotLoadouts.len()

		for ( int i = 0; i < numLoadouts; i++ )
			UpdateCachedPilotLoadout( i )
	}

	void function UpdateAllCachedTitanLoadouts()
	{
		int numLoadouts = shGlobal.cachedTitanLoadouts.len()

		for ( int i = 0; i < numLoadouts; i++ )
			UpdateCachedTitanLoadout( i )
	}

	void function UpdateCachedPilotLoadout( int loadoutIndex )
	{
		entity player
		#if UI
			player = GetUIPlayer()
		#elseif CLIENT
			player = GetLocalClientPlayer()
		#endif

		if ( player == null )
			return

		PopulatePilotLoadoutFromPersistentData( player, shGlobal.cachedPilotLoadouts[ loadoutIndex ], loadoutIndex )
	}

	void function UpdateCachedTitanLoadout( int loadoutIndex )
	{
		entity player
		#if UI
			player = GetUIPlayer()
		#elseif CLIENT
			player = GetLocalClientPlayer()
		#endif

		if ( player == null )
			return

		PopulateTitanLoadoutFromPersistentData( player, shGlobal.cachedTitanLoadouts[ loadoutIndex ], loadoutIndex )
	}

	PilotLoadoutDef function GetCachedPilotLoadout( int loadoutIndex )
	{
		Assert( loadoutIndex >= 0 && loadoutIndex < shGlobal.cachedPilotLoadouts.len() )

		return shGlobal.cachedPilotLoadouts[ loadoutIndex ]
	}

	TitanLoadoutDef function GetCachedTitanLoadout( int loadoutIndex )
	{
		Assert( loadoutIndex >= 0 && loadoutIndex < shGlobal.cachedTitanLoadouts.len() )

		return shGlobal.cachedTitanLoadouts[ loadoutIndex ]
	}

	PilotLoadoutDef[ NUM_PERSISTENT_PILOT_LOADOUTS ] function GetAllCachedPilotLoadouts()
	{
		return shGlobal.cachedPilotLoadouts
	}

	TitanLoadoutDef[ NUM_PERSISTENT_TITAN_LOADOUTS ] function GetAllCachedTitanLoadouts()
	{
		return shGlobal.cachedTitanLoadouts
	}
#endif // UI || CLIENT

#if UI
	bool function IsTokenLoadoutName( string name )
	{
		if ( name.find( "#DEFAULT_PILOT_" ) != null || name.find( "#DEFAULT_TITAN_" ) != null )
			return true

		return false
	}
#endif // UI

string function Loadouts_GetSetFileForRequestedClass( entity player )
{
	int loadoutIndex = GetPersistentSpawnLoadoutIndex( player, "pilot" )

	PilotLoadoutDef loadout
	PopulatePilotLoadoutFromPersistentData( player, loadout, loadoutIndex )

	return loadout.setFile
}

#if SERVER
	void function SetPersistentPilotLoadout( entity player, int loadoutIndex, PilotLoadoutDef loadout )
	{
		SetPersistentLoadoutValue( player, "pilot", loadoutIndex, "name", 				loadout.name )
		SetPersistentLoadoutValue( player, "pilot", loadoutIndex, "suit",				loadout.suit )
		SetPersistentLoadoutValue( player, "pilot", loadoutIndex, "race",				loadout.race )
		SetPersistentLoadoutValue( player, "pilot", loadoutIndex, "primary",			loadout.primary )
		SetPersistentLoadoutValue( player, "pilot", loadoutIndex, "primaryAttachment",	loadout.primaryAttachment )
		SetPersistentLoadoutValue( player, "pilot", loadoutIndex, "primaryMod1",		loadout.primaryMod1 )
		SetPersistentLoadoutValue( player, "pilot", loadoutIndex, "primaryMod2",		loadout.primaryMod2 )
		SetPersistentLoadoutValue( player, "pilot", loadoutIndex, "primaryMod3",		loadout.primaryMod3 )
		SetPersistentLoadoutValue( player, "pilot", loadoutIndex, "secondary",			loadout.secondary )
		SetPersistentLoadoutValue( player, "pilot", loadoutIndex, "secondaryMod1",		loadout.secondaryMod1 )
		SetPersistentLoadoutValue( player, "pilot", loadoutIndex, "secondaryMod2",		loadout.secondaryMod2 )
		SetPersistentLoadoutValue( player, "pilot", loadoutIndex, "secondaryMod3",		loadout.secondaryMod3 )
		SetPersistentLoadoutValue( player, "pilot", loadoutIndex, "ordnance",			loadout.ordnance )
		SetPersistentLoadoutValue( player, "pilot", loadoutIndex, "passive1",			loadout.passive1 )
		SetPersistentLoadoutValue( player, "pilot", loadoutIndex, "passive2",			loadout.passive2 )
	}

	void function SetPersistentTitanLoadout( entity player, int loadoutIndex, TitanLoadoutDef loadout )
	{
		SetPersistentLoadoutValue( player, "titan", loadoutIndex, "name",				loadout.name )
		SetPersistentLoadoutValue( player, "titan", loadoutIndex, "titanClass",			GetTitanCharacterNameFromSetFile( loadout.setFile ) )
		//SetPersistentLoadoutValue( player, "titan", loadoutIndex, "setFile",			loadout.setFile )
		//SetPersistentLoadoutValue( player, "titan", loadoutIndex, "primaryMod",		loadout.primaryMod )
		SetPersistentLoadoutValue( player, "titan", loadoutIndex, "special",			loadout.special )
		SetPersistentLoadoutValue( player, "titan", loadoutIndex, "antirodeo",			loadout.antirodeo )
		SetPersistentLoadoutValue( player, "titan", loadoutIndex, "passive1",			loadout.passive1 )
		SetPersistentLoadoutValue( player, "titan", loadoutIndex, "passive2",			loadout.passive2 )
		SetPersistentLoadoutValue( player, "titan", loadoutIndex, "passive3",			loadout.passive3 )
		SetPersistentLoadoutValue( player, "titan", loadoutIndex, "voice",				loadout.voice )
	}

	bool function Loadouts_CanGivePilotLoadout( entity player )
	{
		if ( !IsAlive( player ) )
			return false

		if ( !player.s.inGracePeriod )
			return false

		// hack for bug 114632, 167264. Real fix would be to make dropship spawn script not end on anim reset from model change.
		if ( player.GetParent() != null )
		{
			if ( HasCinematicFlag( player, CE_FLAG_INTRO ) )
		 		return false

			if ( HasCinematicFlag( player, CE_FLAG_CLASSIC_MP_SPAWNING ) )
		 		return false
		}

		if ( player.IsTitan() )
			return false

		return true
	}

	bool function Loadouts_CanGiveTitanLoadout( entity player )
	{
		// if ( GetPlayerBurnCardOnDeckIndex( player ) != null )
		// 	return false

		if ( HasCinematicFlag( player, CE_FLAG_INTRO ) )
			return false

		if ( HasCinematicFlag( player, CE_FLAG_CLASSIC_MP_SPAWNING ) )
			return false

		if ( !IsAlive( player ) )
			return false

		if ( !player.s.inGracePeriod )
			return false

		if ( player.isSpawningHotDroppingAsTitan )
			return false

		if ( !player.IsTitan() )
			return false

		return true
	}


	string function Loadouts_GetSetFileForActiveClass( entity player )
	{
		int loadoutIndex = GetActivePilotLoadoutIndex( player )

		PilotLoadoutDef loadout
		PopulatePilotLoadoutFromPersistentData( player, loadout, loadoutIndex )

		return loadout.setFile
	}


	string function Loadouts_GetPilotRaceForActiveClass( entity player )
	{
		int loadoutIndex = GetActivePilotLoadoutIndex( player )

		PilotLoadoutDef loadout
		PopulatePilotLoadoutFromPersistentData( player, loadout, loadoutIndex )

		return loadout.race
	}

	bool function Loadouts_TryGivePilotLoadout( entity player )
	{
		if ( !Loadouts_CanGivePilotLoadout( player ) )
			return false

		PilotLoadoutDef loadout

		int loadoutIndex = GetPersistentSpawnLoadoutIndex( player, "pilot" )

		#if DEV
		if ( player.IsBot() && !player.IsPlayback() && GetConVarString( "bot_pilot_settings" ) == "random" )
			loadout = GetRandomPilotLoadout()
		else
		#endif
			loadout = GetPilotLoadoutFromPersistentData( player, loadoutIndex )

		UpdateDerivedPilotLoadoutData( loadout )

		if ( player.IsBot() && !player.IsPlayback() )
			OverrideBotPilotLoadout( loadout )

		GivePilotLoadout( player, loadout )
		SetActivePilotLoadout( player, loadout )
		SetActivePilotLoadoutIndex( player, loadoutIndex )

		//PROTO_DisplayPilotLoadouts( player, loadout )

		return true
	}

	bool function Loadouts_TryGiveTitanLoadout( entity player )
	{
		if ( !Loadouts_CanGiveTitanLoadout( player ) )
			return false

		Assert( IsMultiplayer(), "Spawning as a Titan is not supported in SP currently" )

		entity soul = player.GetTitanSoul()

		TakeAllWeapons( player )
		TakeAllPassives( player )

		soul.passives = arrayofsize( GetNumPassives(), false ) //Clear out passives on soul

		TitanLoadoutDef loadout
		int loadoutIndex = GetPersistentSpawnLoadoutIndex( player, "titan" )

		#if DEV
		if ( player.IsBot() && !player.IsPlayback() )
			{
				string botTitanSettings = GetConVarString( "bot_titan_settings" )
				loadout = GetRandomTitanLoadout( botTitanSettings )

				array<string> legalLoadouts = GetAllowedTitanSetFiles()
				if ( legalLoadouts.contains( botTitanSettings ) )
					loadout.setFile = botTitanSettings //Overwrite just the setfile, mods etc will be random
			}
			else
		#endif
			loadout = GetTitanLoadoutFromPersistentData( player, loadoutIndex )

		OverwriteLoadoutWithDefaultsForSetFile_ExceptSpecialAndAntiRodeo( loadout )

		if ( player.IsBot() && !player.IsPlayback() )
			OverrideBotTitanLoadout( loadout )

		ApplyTitanLoadoutModifiers( player, loadout )

		player.SetPlayerSettingsFromDataTable( { playerSetFile = loadout.setFile, playerSetFileMods = loadout.setFileMods } )
		GiveTitanLoadout( player, loadout )
		SetActiveTitanLoadoutIndex( player, loadoutIndex )
		//PROTO_DisplayTitanLoadouts( player, player, loadout )
		SetTitanOSForPlayer( player, loadout.voice )

		string settings = GetSoulPlayerSettings( soul )
		var titanTint = Dev_GetPlayerSettingByKeyField_Global( settings, "titan_tint" )

		if ( titanTint != null )
		{
			expect string( titanTint )
			Highlight_SetEnemyHighlight( player, titanTint )
		}
		else
		{
			Highlight_ClearEnemyHighlight( player )
		}

		var title = GetPlayerSettingsFieldForClassName( settings, "printname" )
		if ( title != null )
		{
			player.SetTitle( expect string( title ) )
		}

		return true
	}

	void function OverrideBotPilotLoadout( PilotLoadoutDef loadout )
	{
		string bot_force_pilot_primary = GetConVarString( "bot_force_pilot_primary" )
		string bot_force_pilot_secondary = GetConVarString( "bot_force_pilot_secondary" )
		string bot_force_pilot_ordnance = GetConVarString( "bot_force_pilot_ordnance" )
		string bot_force_pilot_ability = GetConVarString( "bot_force_pilot_ability" )

		// Primary
		if ( DevFindItemByName( eItemTypes.PILOT_PRIMARY, bot_force_pilot_primary ) )
		{
			loadout.primary = bot_force_pilot_primary
			loadout.primaryAttachment = ""
			loadout.primaryAttachments = []
			loadout.primaryMod1 = ""
			loadout.primaryMod2 = ""
			loadout.primaryMod3 = ""
			loadout.primaryMods = []
		}

		// Secondary
		if ( DevFindItemByName( eItemTypes.PILOT_SECONDARY, bot_force_pilot_secondary ) )
		{
			loadout.secondary = bot_force_pilot_secondary
			loadout.secondaryMod1 = ""
			loadout.secondaryMod2 = ""
			loadout.secondaryMod3 = ""
			loadout.secondaryMods = []
		}

		// Ordnance/Offhand
		if ( DevFindItemByName( eItemTypes.PILOT_ORDNANCE, bot_force_pilot_ordnance ) )
		{
			loadout.ordnance = bot_force_pilot_ordnance
			loadout.ordnanceMods = []
		}

		// Ability/Special
		if ( DevFindItemByName( eItemTypes.PILOT_SPECIAL, bot_force_pilot_ability ) )
		{
			loadout.special = bot_force_pilot_ability
			loadout.specialMods = []
		}
	}

	void function OverrideBotTitanLoadout( TitanLoadoutDef loadout )
	{
		string bot_force_titan_primary = GetConVarString( "bot_force_titan_primary" )
		string bot_force_titan_ordnance = GetConVarString( "bot_force_titan_ordnance" )
		string bot_force_titan_ability = GetConVarString( "bot_force_titan_ability" )

		// Primary
		if ( DevFindItemByName( eItemTypes.TITAN_PRIMARY, bot_force_titan_primary ) )
		{
			loadout.primary = bot_force_titan_primary
			loadout.primaryMod = ""
			loadout.primaryMods = []
		}

		// Ordnance/Offhand
		if ( DevFindItemByName( eItemTypes.TITAN_ORDNANCE, bot_force_titan_ordnance ) )
		{
			loadout.ordnance = bot_force_titan_ordnance
			loadout.ordnanceMods = []
		}

		// Ability/Special
		if ( DevFindItemByName( eItemTypes.TITAN_SPECIAL, bot_force_titan_ability ) )
		{
			loadout.special = bot_force_titan_ability
			loadout.specialMods = []
		}
	}

	TitanLoadoutDef function GetTitanSpawnLoadout( entity player )
	{
		int loadoutIndex = GetPersistentSpawnLoadoutIndex( player, "titan" )
		TitanLoadoutDef loadout = GetTitanLoadoutFromPersistentData( player, loadoutIndex )
		OverwriteLoadoutWithDefaultsForSetFile_ExceptSpecialAndAntiRodeo( loadout )

		return loadout
	}

	// TODO: make loadout crate stuff not update your requested loadout
	void function Loadouts_OnUsedLoadoutCrate( entity player )
	{
		int loadoutIndex = GetPersistentSpawnLoadoutIndex( player, "pilot" )

		PilotLoadoutDef loadout = GetPilotLoadoutFromPersistentData( player, loadoutIndex )

		GivePilotLoadout( player, loadout )
	}

	void function SetActivePilotLoadout( entity player, PilotLoadoutDef loadout )
	{
		player.SetPersistentVar( "activePilotLoadout.name", 				loadout.name )
		player.SetPersistentVar( "activePilotLoadout.suit", 				loadout.suit )
		player.SetPersistentVar( "activePilotLoadout.race", 				loadout.race )
		player.SetPersistentVar( "activePilotLoadout.execution", 			loadout.execution )
		player.SetPersistentVar( "activePilotLoadout.primary", 				loadout.primary )
		player.SetPersistentVar( "activePilotLoadout.primaryAttachment", 	loadout.primaryAttachment )
		player.SetPersistentVar( "activePilotLoadout.primaryMod1", 			loadout.primaryMod1 )
		player.SetPersistentVar( "activePilotLoadout.primaryMod2", 			loadout.primaryMod2 )
		player.SetPersistentVar( "activePilotLoadout.primaryMod3", 			loadout.primaryMod3 )
		player.SetPersistentVar( "activePilotLoadout.secondary", 			loadout.secondary )
		player.SetPersistentVar( "activePilotLoadout.secondaryMod1",		loadout.secondaryMod1 )
		player.SetPersistentVar( "activePilotLoadout.secondaryMod2", 		loadout.secondaryMod2 )
		player.SetPersistentVar( "activePilotLoadout.secondaryMod3", 		loadout.secondaryMod3 )
		player.SetPersistentVar( "activePilotLoadout.ordnance",				loadout.ordnance )
		player.SetPersistentVar( "activePilotLoadout.passive1",				loadout.passive1 )
		player.SetPersistentVar( "activePilotLoadout.passive2",				loadout.passive2 )
		player.SetPersistentVar( "activePilotLoadout.skinIndex",			loadout.skinIndex )
		player.SetPersistentVar( "activePilotLoadout.camoIndex",			loadout.camoIndex )
		player.SetPersistentVar( "activePilotLoadout.primarySkinIndex",		loadout.primarySkinIndex )
		player.SetPersistentVar( "activePilotLoadout.primaryCamoIndex",		loadout.primaryCamoIndex )
		player.SetPersistentVar( "activePilotLoadout.secondarySkinIndex", 	loadout.secondarySkinIndex )
		player.SetPersistentVar( "activePilotLoadout.secondaryCamoIndex",	loadout.secondaryCamoIndex )
	}

	void function SetActivePilotLoadoutIndex( entity player, int loadoutIndex )
	{
		player.p.activePilotLoadoutIndex = loadoutIndex
		player.SetPlayerNetInt( "activePilotLoadoutIndex", loadoutIndex )
	}

	// TODO: Too risky to switch script to use this now. When not risky, anywhere SetActiveTitanLoadoutIndex() passes a non-negative loadout is where this should be called.
	//void function SetActiveTitanLoadout( entity player, TitanLoadoutDef loadout )
	//{
	//	player.SetPersistentVar( "activeTitanLoadout.name", 				loadout.name )
	//	player.SetPersistentVar( "activeTitanLoadout.titanClass", 			loadout.titanClass )
	//	player.SetPersistentVar( "activeTitanLoadout.primaryMod", 			loadout.primaryMod )
	//	player.SetPersistentVar( "activeTitanLoadout.special", 				loadout.special )
	//	player.SetPersistentVar( "activeTitanLoadout.antirodeo", 			loadout.antirodeo )
	//	player.SetPersistentVar( "activeTitanLoadout.passive1", 			loadout.passive1 )
	//	player.SetPersistentVar( "activeTitanLoadout.passive2", 			loadout.passive2 )
	//	player.SetPersistentVar( "activeTitanLoadout.passive3", 			loadout.passive3 )
	//	player.SetPersistentVar( "activeTitanLoadout.voice", 				loadout.voice )
	//	player.SetPersistentVar( "activeTitanLoadout.skinIndex", 			loadout.skinIndex )
	//	player.SetPersistentVar( "activeTitanLoadout.camoIndex", 			loadout.camoIndex )
	//	player.SetPersistentVar( "activeTitanLoadout.decalIndex", 			loadout.decalIndex )
	//	player.SetPersistentVar( "activeTitanLoadout.primarySkinIndex", 	loadout.primarySkinIndex )
	//	player.SetPersistentVar( "activeTitanLoadout.primaryCamoIndex", 	loadout.primaryCamoIndex )
	//}

	void function SetActiveTitanLoadoutIndex( entity player, int loadoutIndex )
	{
		//printt( ">>>>>>>>>>>>> SetActiveTitanLoadoutIndex() with index:", loadoutIndex )
		player.p.activeTitanLoadoutIndex = loadoutIndex
		player.SetPlayerNetInt( "activeTitanLoadoutIndex", loadoutIndex )
	}

	void function PROTO_DisplayTitanLoadouts( entity player, entity titan, TitanLoadoutDef loadout )
	{
		entity soul = titan.GetTitanSoul()
		if ( soul.e.embarkCount > 0 )
			return

		if ( loadout.primary != "" )
			PROTO_PlayLoadoutNotification( loadout.primary, player )
		if ( loadout.ordnance != "" )
			PROTO_PlayLoadoutNotification( loadout.ordnance, player )
		if ( loadout.special != "" )
			PROTO_PlayLoadoutNotification( loadout.special, player )
		if ( loadout.passive1 != "" )
			PROTO_PlayLoadoutNotification( loadout.passive1, player )
		if ( loadout.passive2 != "" )
			PROTO_PlayLoadoutNotification( loadout.passive2, player )
		if ( loadout.passive3 != "" )
			PROTO_PlayLoadoutNotification( loadout.passive3, player )
	}

	void function PROTO_DisplayPilotLoadouts( entity player, PilotLoadoutDef loadout )
	{
		if ( loadout.primary != "" )
			PROTO_PlayLoadoutNotification( loadout.primary, player )
		if ( loadout.secondary != "" )
			PROTO_PlayLoadoutNotification( loadout.secondary, player )
		if ( loadout.ordnance != "" )
			PROTO_PlayLoadoutNotification( loadout.ordnance, player )
		if ( loadout.special != "" )
			PROTO_PlayLoadoutNotification( loadout.special, player )
		if ( loadout.passive1 != "" )
			PROTO_PlayLoadoutNotification( loadout.passive1, player )
		if ( loadout.passive2 != "" )
			PROTO_PlayLoadoutNotification( loadout.passive2, player )
	}
#endif //SERVER

#if !UI
	PilotLoadoutDef function GetActivePilotLoadout( entity player )
	{
		PilotLoadoutDef loadout
		loadout.name 				= string( player.GetPersistentVar( "activePilotLoadout.name" ) )
		loadout.suit 				= string( player.GetPersistentVar( "activePilotLoadout.suit" ) )
		loadout.race 				= string( player.GetPersistentVar( "activePilotLoadout.race" ) )
		loadout.execution 			= string( player.GetPersistentVar( "activePilotLoadout.execution" ) )
		loadout.primary 			= string( player.GetPersistentVar( "activePilotLoadout.primary" ) )
		loadout.primaryAttachment	= string( player.GetPersistentVar( "activePilotLoadout.primaryAttachment" ) )
		loadout.primaryMod1			= string( player.GetPersistentVar( "activePilotLoadout.primaryMod1" ) )
		loadout.primaryMod2			= string( player.GetPersistentVar( "activePilotLoadout.primaryMod2" ) )
		loadout.primaryMod3			= string( player.GetPersistentVar( "activePilotLoadout.primaryMod3" ) )
		loadout.secondary 			= string( player.GetPersistentVar( "activePilotLoadout.secondary" ) )
		loadout.secondaryMod1		= string( player.GetPersistentVar( "activePilotLoadout.secondaryMod1" ) )
		loadout.secondaryMod2		= string( player.GetPersistentVar( "activePilotLoadout.secondaryMod2" ) )
		loadout.secondaryMod3		= string( player.GetPersistentVar( "activePilotLoadout.secondaryMod3" ) )
		loadout.ordnance 			= string( player.GetPersistentVar( "activePilotLoadout.ordnance" ) )
		loadout.passive1 			= string( player.GetPersistentVar( "activePilotLoadout.passive1" ) )
		loadout.passive2 			= string( player.GetPersistentVar( "activePilotLoadout.passive2" ) )
		loadout.skinIndex			= player.GetPersistentVarAsInt( "activePilotLoadout.skinIndex" )
		loadout.camoIndex			= player.GetPersistentVarAsInt( "activePilotLoadout.camoIndex" )
		loadout.primarySkinIndex	= player.GetPersistentVarAsInt( "activePilotLoadout.primarySkinIndex" )
		loadout.primaryCamoIndex	= player.GetPersistentVarAsInt( "activePilotLoadout.primaryCamoIndex" )
		loadout.secondarySkinIndex	= player.GetPersistentVarAsInt( "activePilotLoadout.secondarySkinIndex" )
		loadout.secondaryCamoIndex	= player.GetPersistentVarAsInt( "activePilotLoadout.secondaryCamoIndex" )

		UpdateDerivedPilotLoadoutData( loadout )

		return loadout
	}

	TitanLoadoutDef function GetActiveTitanLoadout( entity player )
	{
		// TODO: Too risky to switch script to use this now. When not risky, this should only be considered valid if SetActiveTitanLoadoutIndex() wouldn't return -1.
		//TitanLoadoutDef loadout
		//loadout.name 				= string( player.GetPersistentVar( "activeTitanLoadout.name" ) )
		//loadout.titanClass 			= string( player.GetPersistentVar( "activeTitanLoadout.titanClass" ) )
		//loadout.primaryMod 			= string( player.GetPersistentVar( "activeTitanLoadout.primaryMod" ) )
		//loadout.special 			= string( player.GetPersistentVar( "activeTitanLoadout.special" ) )
		//loadout.antirodeo 			= string( player.GetPersistentVar( "activeTitanLoadout.antirodeo" ) )
		//loadout.passive1 			= string( player.GetPersistentVar( "activeTitanLoadout.passive1" ) )
		//loadout.passive2 			= string( player.GetPersistentVar( "activeTitanLoadout.passive2" ) )
		//loadout.passive3 			= string( player.GetPersistentVar( "activeTitanLoadout.passive3" ) )
		//loadout.voice 				= string( player.GetPersistentVar( "activeTitanLoadout.voice" ) )
		//loadout.skinIndex			= player.GetPersistentVarAsInt( "activeTitanLoadout.skinIndex" )
		//loadout.camoIndex			= player.GetPersistentVarAsInt( "activeTitanLoadout.camoIndex" )
		//loadout.decalIndex			= player.GetPersistentVarAsInt( "activeTitanLoadout.decalIndex" )
		//loadout.primarySkinIndex	= player.GetPersistentVarAsInt( "activeTitanLoadout.primarySkinIndex" )
		//loadout.primaryCamoIndex	= player.GetPersistentVarAsInt( "activeTitanLoadout.primaryCamoIndex" )
		//
		//UpdateDerivedTitanLoadoutData( loadout )
		//OverwriteLoadoutWithDefaultsForSetFile( loadout )
		//OverwriteLoadoutWithDefaultsForSetFile_ExceptSpecialAndAntiRodeo( loadout )

		int loadoutIndex = GetActiveTitanLoadoutIndex( player )

		TitanLoadoutDef loadout = GetTitanLoadoutFromPersistentData( player, loadoutIndex )
		OverwriteLoadoutWithDefaultsForSetFile_ExceptSpecialAndAntiRodeo( loadout )

		return loadout
	}

	// When possible use GetActivePilotLoadout() instead
	int function GetActivePilotLoadoutIndex( entity player )
	{
		#if SERVER
			return player.p.activePilotLoadoutIndex
		#else
			return player.GetPlayerNetInt( "activePilotLoadoutIndex" )
		#endif
	}

	int function GetActiveTitanLoadoutIndex( entity player )
	{
		//printt( "<<<<<<<<<<<<< GetActiveTitanLoadoutIndex() with index:", player.p.activeTitanLoadoutIndex )
		#if SERVER
			return player.p.activeTitanLoadoutIndex
		#else
			return player.GetPlayerNetInt( "activeTitanLoadoutIndex" )
		#endif
	}
#endif

void function UpdateDerivedPilotLoadoutData( PilotLoadoutDef loadout )
{
	loadout.setFile 			= GetSuitAndGenderBasedSetFile( loadout.suit, loadout.race )
	loadout.special				= GetSuitBasedTactical( loadout.suit )
	loadout.primaryAttachments	= [ loadout.primaryAttachment ]
	loadout.primaryMods			= [ loadout.primaryMod1, loadout.primaryMod2, loadout.primaryMod3 ]
	loadout.secondaryMods		= [ loadout.secondaryMod1, loadout.secondaryMod2, loadout.secondaryMod3 ]
	loadout.setFileMods 		= GetSetFileModsForSettingType( "pilot", [ loadout.passive1, loadout.passive2 ] )

	#if SERVER
	foreach ( callbackFunc in svGlobal.onUpdateDerivedPilotLoadoutCallbacks )
	{
		callbackFunc( loadout )
	}
	#endif
}

void function UpdateDerivedTitanLoadoutData( TitanLoadoutDef loadout )
{
	loadout.setFile 			= GetSetFileForTitanClass( loadout.titanClass )
}

void function PrintPilotLoadouts( entity player )
{
	for ( int i = 0; i < NUM_PERSISTENT_PILOT_LOADOUTS; i++ )
		PrintPilotLoadout( GetPilotLoadoutFromPersistentData( player, i ) )
}

void function PrintTitanLoadouts( entity player )
{
	for ( int i = 0; i < NUM_PERSISTENT_TITAN_LOADOUTS; i++ )
		PrintTitanLoadout( GetTitanLoadoutFromPersistentData( player, i ) )
}

void function PrintPilotLoadout( PilotLoadoutDef loadout )
{
	printt( "PILOT LOADOUT:" )
	printt( "    PERSISTENT DATA:" )
	printt( "        name                 \"" + loadout.name + "\"" )
	printt( "        suit                 \"" + loadout.suit + "\"" )
	printt( "        race                 \"" + loadout.race + "\"" )
	printt( "        execution            \"" + loadout.execution + "\"" )
	printt( "        primary              \"" + loadout.primary + "\"" )
	printt( "        primaryAttachment    \"" + loadout.primaryAttachment + "\"" )
	printt( "        primaryMod1          \"" + loadout.primaryMod1 + "\"" )
	printt( "        primaryMod2          \"" + loadout.primaryMod2 + "\"" )
	printt( "        primaryMod3          \"" + loadout.primaryMod3 + "\"" )
	printt( "        secondary            \"" + loadout.secondary + "\"" )
	printt( "        secondaryMod1        \"" + loadout.secondaryMod1 + "\"" )
	printt( "        secondaryMod2        \"" + loadout.secondaryMod2 + "\"" )
	printt( "        secondaryMod3        \"" + loadout.secondaryMod3 + "\"" )
	printt( "        ordnance             \"" + loadout.ordnance + "\"" )
	printt( "        special              \"" + loadout.special + "\"" )
	printt( "        passive1             \"" + loadout.passive1 + "\"" )
	printt( "        passive2             \"" + loadout.passive2 + "\"" )
	printt( "        skinIndex            \"" + loadout.skinIndex + "\"" )
	printt( "        camoIndex            \"" + loadout.camoIndex + "\"" )
	printt( "        primarySkinIndex     \"" + loadout.primarySkinIndex + "\"" )
	printt( "        primaryCamoIndex     \"" + loadout.primaryCamoIndex + "\"" )
	printt( "        secondarySkinIndex   \"" + loadout.secondarySkinIndex + "\"" )
	printt( "        secondaryCamoIndex   \"" + loadout.secondaryCamoIndex + "\"" )
	printt( "    DERIVED DATA:" )
	printt( "        setFile              \"" + loadout.setFile + "\"" )
	print(  "        setFileMods          " )
	PrintStringArray( loadout.setFileMods )
	printt( "        melee                \"" + loadout.melee + "\"" )
	print(  "        meleeMods            " )
	PrintStringArray( loadout.meleeMods )
	print(  "        primaryAttachments   " )
	PrintStringArray( loadout.primaryAttachments )
	print(  "        primaryMods          " )
	PrintStringArray( loadout.primaryMods )
	print(  "        secondaryMods        " )
	PrintStringArray( loadout.secondaryMods )
	print(  "        specialMods          " )
	PrintStringArray( loadout.specialMods )
	print(  "        ordnanceMods         " )
	PrintStringArray( loadout.ordnanceMods )
}

void function PrintTitanLoadout( TitanLoadoutDef loadout )
{
	printt( "TITAN LOADOUT:" )
	printt( "    PERSISTENT DATA:" )
	printt( "        name                 \"" + loadout.name + "\"" )
	printt( "        titanClass           \"" + loadout.titanClass + "\"" )
	printt( "        setFile              \"" + loadout.setFile + "\"" )
	printt( "        primaryMod           \"" + loadout.primaryMod + "\"" )
	printt( "        special              \"" + loadout.special + "\"" )
	printt( "        antirodeo            \"" + loadout.antirodeo + "\"" )
	printt( "        passive1             \"" + loadout.passive1 + "\"" )
	printt( "        passive2             \"" + loadout.passive2 + "\"" )
	printt( "        passive3             \"" + loadout.passive3 + "\"" )
	printt( "        voice                \"" + loadout.voice + "\"" )
	printt( "        skinIndex            \"" + loadout.skinIndex + "\"" )
	printt( "        camoIndex            \"" + loadout.camoIndex + "\"" )
	printt( "        decalIndex           \"" + loadout.decalIndex + "\"" )
	printt( "        primarySkinIndex     \"" + loadout.primarySkinIndex + "\"" )
	printt( "        primaryCamoIndex     \"" + loadout.primaryCamoIndex + "\"" )
	printt( "    DERIVED DATA:" )
	print(  "        setFileMods          " )
	PrintStringArray( loadout.setFileMods )
	printt( "        melee                \"" + loadout.melee + "\"" )
	printt( "        coreAbility          \"" + loadout.coreAbility + "\"" )
	printt( "        primary              \"" + loadout.primary + "\"" )
	printt( "        primaryAttachment    \"" + loadout.primaryAttachment + "\"" )
	print(  "        primaryMods          " )
	PrintStringArray( loadout.primaryMods )
	printt( "        ordnance             \"" + loadout.ordnance + "\"" )
	print(  "        ordnanceMods         " )
	PrintStringArray( loadout.ordnanceMods )
	print(  "        specialMods          " )
	PrintStringArray( loadout.specialMods )
	print(  "        antirodeoMods        " )
	PrintStringArray( loadout.antirodeoMods )
}

void function PrintStringArray( array<string> stringArray )
{
	if ( stringArray.len() == 0 )
	{
		print( "[]" )
	}
	else
	{
		for ( int i = 0; i < stringArray.len(); i++ )
		{
			if ( i == 0 )
				print( "[ " )

			print( "\"" + stringArray[i] + "\"" )

			if ( i+1 < stringArray.len() )
				print( ", " )
			else
				print( " ]" )
		}
	}

	print( "\n" )
}

#if SERVER

TitanLoadoutDef function GetBurnCardTitanLoadout()
{
	TitanLoadoutDef titanLoadout

	titanLoadout.setFile					= "titan_atlas_burncard"
	titanLoadout.setFileMods				= []
	titanLoadout.primary					= "mp_titanweapon_xo16"
	titanLoadout.primaryMods				= []
	titanLoadout.special					= "mp_titanability_smoke"
	//titanLoadout.special					= "mp_titanweapon_vortex_shield"
	titanLoadout.specialMods				= []
	titanLoadout.ordnance					= "mp_titanweapon_salvo_rockets"
	titanLoadout.ordnanceMods				= []
	//titanLoadout.antirodeo					= "mp_titanability_smoke"
	titanLoadout.voice						= "titanos_maleintimidator"
	titanLoadout.melee 						= "melee_titan_punch"
	//titanLoadout.coreAbility 				= "mp_titancore_laser_cannon"

	return titanLoadout
}
#endif // SERVER

string function GetSkinPropertyName( string camoPropertyName )
{
	string skinPropertyName

	switch ( camoPropertyName )
	{
		case "camoIndex":
			skinPropertyName = "skinIndex"
			break

		case "primaryCamoIndex":
			skinPropertyName = "primarySkinIndex"
			break

		case "secondaryCamoIndex":
			skinPropertyName = "secondarySkinIndex"
			break

		default:
			Assert( false, "Unknown camoPropertyName: " + camoPropertyName )
			break
	}

	return skinPropertyName
}

int function GetSkinIndexForCamo( string modelType, string camoPropertyName, int camoIndex )
{
	Assert( modelType == "pilot" || modelType == "titan" )
	Assert( camoPropertyName == "camoIndex" || camoPropertyName == "primaryCamoIndex" || camoPropertyName == "secondaryCamoIndex" )

	int skinIndex = SKIN_INDEX_BASE

	if ( camoIndex > 0 )
	{
		if ( camoPropertyName == "camoIndex" )
		{
			if ( modelType == "pilot" )
				skinIndex = PILOT_SKIN_INDEX_CAMO
			else
				skinIndex = TITAN_SKIN_INDEX_CAMO
		}
		else if ( camoPropertyName == "primaryCamoIndex" || camoPropertyName == "secondaryCamoIndex" )
		{
			skinIndex = WEAPON_SKIN_INDEX_CAMO
		}
	}

	return skinIndex
}

#if SERVER
void function UpdateProScreen( entity player, entity weapon )
{
	int weaponXp = WeaponGetXP( player, weapon.GetWeaponClassName() )
	int previousWeaponXp = WeaponGetPreviousXP( player, weapon.GetWeaponClassName() )
	weapon.SetProScreenIntValForIndex( PRO_SCREEN_INT_LIFETIME_KILLS, weaponXp )
	weapon.SetProScreenIntValForIndex( PRO_SCREEN_INT_MATCH_KILLS, weaponXp - previousWeaponXp )
}
#endif