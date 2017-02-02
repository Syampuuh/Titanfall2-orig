untyped

global function InitStoreMenuCustomization

struct
{
	var menu
} file

void function InitStoreMenuCustomization()
{
	file.menu = GetMenu( "StoreMenu_Customization" )

	Hud_SetText( Hud_GetChild( file.menu, "MenuTitle" ), "#STORE_CUSTOMIZATION_PACKS" )

	AddMenuEventHandler( file.menu, eUIEvent.MENU_OPEN, OnOpenStoreMenuCustomization )

	for ( int i = 0; i < NUM_PERSISTENT_TITAN_LOADOUTS; i++ )
	{
		var activateButton = Hud_GetChild( file.menu, "Titan" + i + "DLC1" )
		activateButton.s.rowIndex <- i
		Hud_AddEventHandler( activateButton, UIE_GET_FOCUS, OnCustomizationButton_Focused )
		Hud_AddEventHandler( activateButton, UIE_CLICK, OnCustomizationButton_Activate )
	}

	AddMenuFooterOption( file.menu, BUTTON_A, "#A_BUTTON_VIEW_PACK" )
	AddMenuFooterOption( file.menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
}

void function OnOpenStoreMenuCustomization()
{
	UI_SetPresentationType( ePresentationType.TITAN_LOADOUT_EDIT )

	for ( int i = 0; i < NUM_PERSISTENT_TITAN_LOADOUTS; i++ )
	{
		var label = Hud_GetChild( file.menu, "Titan" + i + "Label" )
		TitanLoadoutDef loadout = GetCachedTitanLoadout( i )
		RHud_SetText( label, GetTitanLoadoutName( loadout ) )

		int entitlementId = -1
		asset packIcon = $""
		switch ( loadout.titanClass )
		{
			case "ion":
				entitlementId = ET_DLC1_ION
				packIcon = $"rui/menu/store/ion_art_pack"
				break

			case "scorch":
				entitlementId = ET_DLC1_SCORCH
				packIcon = $"rui/menu/store/scorch_art_pack"
				break

			case "northstar":
				entitlementId = ET_DLC1_NORTHSTAR
				packIcon = $"rui/menu/store/northstar_art_pack"
				break

			case "ronin":
				entitlementId = ET_DLC1_RONIN
				packIcon = $"rui/menu/store/ronin_art_pack"
				break

			case "tone":
				entitlementId = ET_DLC1_TONE
				packIcon = $"rui/menu/store/tone_art_pack"
				break

			case "legion":
				entitlementId = ET_DLC1_LEGION
				packIcon = $"rui/menu/store/legion_art_pack"
				break
		}

		var button = Hud_GetChild( file.menu, "Titan" + i + "DLC1" )
		button.s.entitlementId <- entitlementId

		var rui = Hud_GetRui( button )
		RuiSetImage( rui, "buttonImage", packIcon )
	}
}

void function OnCustomizationButton_Focused( var button )
{
	int index = expect int( button.s.rowIndex )
	RunMenuClientFunction( "UpdateTitanModel", index, TITANMENU_NO_CUSTOMIZATION | TITANMENU_FORCE_NON_PRIME )
}

void function OnCustomizationButton_Activate( var button )
{
	uiGlobal.entitlementId = expect int( button.s.entitlementId )
	AdvanceMenu( GetMenu( "StoreMenu_CustomizationPreview" ) )
}