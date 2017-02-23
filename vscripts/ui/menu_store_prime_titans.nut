untyped

global function InitStoreMenuPrimeTitans
global function EntitlementsChanged_PrimeTitans

struct
{
	var[NUM_PERSISTENT_TITAN_LOADOUTS] primeTitanButtons
	var titanPreview
	int entitlementToBuy
} file

void function InitStoreMenuPrimeTitans()
{
	var menu = GetMenu( "StoreMenu_PrimeTitans" )

	Hud_SetText( Hud_GetChild( menu, "MenuTitle" ), "#STORE_PRIME_TITANS" )

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnOpenStoreMenuPrimeTitans )

	for ( int i = 0; i < NUM_PERSISTENT_TITAN_LOADOUTS; i++ )
	{
		var activateButton = Hud_GetChild( menu, "Button" + i )
		activateButton.s.rowIndex <- i
		Hud_SetVisible( activateButton, true )
		if ( i < 2 )
			Hud_AddEventHandler( activateButton, UIE_CLICK, OnPrimeButton_Activate )
		Hud_AddEventHandler( activateButton, UIE_GET_FOCUS, OnPrimeButton_Focused )
		file.primeTitanButtons[i] = activateButton
	}

	var button = Hud_GetChild( menu, "Button2" )
	var rui = Hud_GetRui( button )
	RuiSetBool( rui, "isComingSoon", true )

	button = Hud_GetChild( menu, "Button3" )
	rui = Hud_GetRui( button )
	RuiSetBool( rui, "isComingSoon", true )

	button = Hud_GetChild( menu, "Button4" )
	rui = Hud_GetRui( button )
	RuiSetBool( rui, "isComingSoon", true )

	button = Hud_GetChild( menu, "Button5" )
	rui = Hud_GetRui( button )
	RuiSetBool( rui, "isComingSoon", true )

	file.titanPreview = Hud_GetChild( menu, "TitanPreview" )

	AddMenuFooterOption( menu, BUTTON_A, "#A_BUTTON_SELECT" )
	AddMenuFooterOption( menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
}

void function OnOpenStoreMenuPrimeTitans()
{
	UI_SetPresentationType( ePresentationType.TITAN )
	RunMenuClientFunction( "UpdateTitanModel", 0, TITANMENU_NO_CUSTOMIZATION  | TITANMENU_FORCE_PRIME )
	var rui = Hud_GetRui( file.titanPreview )
	RuiSetImage( rui, "titanPreview", $"" )
	UpdateStoreMenuPrimeTitanButtons()
}

void function UpdateStoreMenuPrimeTitanButtons()
{
	entity player = GetUIPlayer()
	if ( player == null )
		return

	foreach ( index, button in file.primeTitanButtons )
	{
		TitanLoadoutDef loadout = GetCachedTitanLoadout( index )
		var rui = Hud_GetRui( button )

		if ( index >= 2 )
			RuiSetString( rui, "buttonText", GetTitanLoadoutName( loadout ) + " %$rui/menu/common/item_locked%" )
		else
			RuiSetString( rui, "buttonText", GetTitanLoadoutName( loadout ) )

		switch ( loadout.primeTitanRef )
		{
			case "ion_prime":
				RuiSetImage( rui, "primeImage", $"rui/menu/store/ion_icon" )
				break

			case "scorch_prime":
				RuiSetImage( rui, "primeImage", $"rui/menu/store/scorch_icon" )
				break

			case "northstar_prime":
				RuiSetImage( rui, "primeImage", $"rui/menu/store/northstar_icon" )
				break

			case "ronin_prime":
				RuiSetImage( rui, "primeImage", $"rui/menu/store/ronin_icon" )
				break

			case "tone_prime":
				RuiSetImage( rui, "primeImage", $"rui/menu/store/tone_icon" )
				break

			case "legion_prime":
				RuiSetImage( rui, "primeImage", $"rui/menu/store/legion_icon" )
				break
		}

		Hud_SetEnabled( button, true )
		Hud_SetVisible( button, true )

		array<int> entitlementIds = GetEntitlementIds( loadout.primeTitanRef )
		Assert( entitlementIds.len() <= 2 )
		entitlementIds.removebyvalue( ET_DELUXE_EDITION )
		button.s.hasEntitlement <- LocalPlayerHasEntitlement( entitlementIds[ 0 ] ) || LocalPlayerHasEntitlement( ET_DELUXE_EDITION )
	}

	RefreshEntitlements()
}

void function OnPrimeButton_Focused( var button )
{
	int index = expect int( button.s.rowIndex )
	var rui = Hud_GetRui( file.titanPreview )

	if ( index < 2 )
	{
		RunMenuClientFunction( "UpdateTitanModel", index, TITANMENU_NO_CUSTOMIZATION | TITANMENU_FORCE_PRIME )
		RuiSetImage( rui, "titanPreview", $"" )
	}
	else
	{
		RunMenuClientFunction( "UpdateTitanModel", -1, TITANMENU_NO_CUSTOMIZATION | TITANMENU_FORCE_PRIME )

		TitanLoadoutDef loadout = GetCachedTitanLoadout( index )

		switch ( loadout.titanClass )
		{
			case "ronin":
				RuiSetImage( rui, "titanPreview", $"rui/menu/store/ronin_prime" )
				break

			case "tone":
				RuiSetImage( rui, "titanPreview", $"rui/menu/store/tone_prime" )
				break

			case "northstar":
				RuiSetImage( rui, "titanPreview", $"rui/menu/store/northstar_prime" )
				break

			case "legion":
				RuiSetImage( rui, "titanPreview", $"rui/menu/store/legion_prime" )
				break
		}
	}
}

void function OnPrimeButton_Activate( var button )
{
	if ( !IsFullyConnected() )
		return

#if PC_PROG
	if ( !Origin_IsOverlayAvailable() )
	{
		DialogData dialogData
		dialogData.header = "#ORIGIN_OVERLAY_DISABLED"
		AddDialogButton( dialogData, "#OK" )

		OpenDialog( dialogData )
		return
	}
#endif

	file.entitlementToBuy = expect int ( button.s.entitlementId )

	if ( !LocalPlayerHasEntitlement( file.entitlementToBuy ) && !LocalPlayerHasEntitlement( ET_DELUXE_EDITION ) )
	{
		DialogData dialogData

		switch ( file.entitlementToBuy )
		{
			case ET_DLC1_PRIME_ION:
				dialogData.header = "#STORE_BUY_ION_PRIME"
				break

			case ET_DLC1_PRIME_SCORCH:
				dialogData.header = "#STORE_BUY_SCORCH_PRIME"
				break

			default:
				Assert( false, "entitlement id not found " + file.entitlementToBuy )
		}

		dialogData.message = "#STORE_PRIME_TITAN_WARNING_DLC2"
		AddDialogButton( dialogData, "#BUY", Store_BuyPrimeTitan )
		AddDialogButton( dialogData, "#CANCEL" )

		OpenDialog( dialogData )
	}
	else
	{
		EmitUISound( "blackmarket_purchase_fail" )
	}
}

void function Store_BuyPrimeTitan()
{
	StorePurchase( file.entitlementToBuy )
}

void function EntitlementsChanged_PrimeTitans()
{
	RefreshEntitlements()
}

void function RefreshEntitlements()
{
	foreach ( index, button in file.primeTitanButtons )
	{
		TitanLoadoutDef loadout = GetCachedTitanLoadout( index )

		array<int> entitlementIds = GetEntitlementIds( loadout.primeTitanRef )
		Assert( entitlementIds.len() <= 2 )
		entitlementIds.removebyvalue( ET_DELUXE_EDITION )
		array<string> prices = GetEntitlementPrices( entitlementIds )
		Assert( prices.len() == 1 )

		var rui = Hud_GetRui( button )
		RuiSetString( rui, "price", prices[ 0 ] )
		bool hasEntitlement = LocalPlayerHasEntitlement( entitlementIds[ 0 ] ) || LocalPlayerHasEntitlement( ET_DELUXE_EDITION )
		RuiSetBool( rui, "isOwned", hasEntitlement )

		if ( !button.s.hasEntitlement && hasEntitlement )
		{
			ClientCommand( "StoreSetNewItemStatus StoreMenu_PrimeTitans " + loadout.primeTitanRef )
		}

		button.s.entitlementId <- entitlementIds[ 0 ]
	}
}