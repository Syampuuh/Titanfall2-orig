global function InitStoreMenu
global function OpenStoreMenu
global function StoreMenuClosedThread

void function InitStoreMenu()
{
	var menu = GetMenu( "StoreMenu" )

	Hud_SetText( Hud_GetChild( menu, "MenuTitle" ), "#STORE_MENU" )

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnOpenStoreMenu )

	var button = Hud_GetChild( menu, "Button0" )
	SetButtonRuiText( button, "#STORE_PRIME_TITANS" )
	AddButtonEventHandler( button, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "StoreMenu_PrimeTitans" ) ) )

	button = Hud_GetChild( menu, "Button1" )
	SetButtonRuiText( button, "#STORE_CUSTOMIZATION_PACKS" )
	AddButtonEventHandler( button, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "StoreMenu_Customization" ) ) )
	var rui = Hud_GetRui( button )
	RuiSetImage( rui, "bgImage", $"rui/menu/store/store_button_art" )

	button = Hud_GetChild( menu, "Button2" )
	SetButtonRuiText( button, "#STORE_CAMO_PACKS" )
	AddButtonEventHandler( button, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "StoreMenu_Camo" ) ) )
	rui = Hud_GetRui( button )
	RuiSetImage( rui, "bgImage", $"rui/menu/store/store_button_camo" )

	button = Hud_GetChild( menu, "ButtonLast" )
	SetButtonRuiText( button, "#STORE_CALLSIGN_PACKS" )
	AddButtonEventHandler( button, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "StoreMenu_Callsign" ) ) )
	rui = Hud_GetRui( button )
	RuiSetImage( rui, "bgImage", $"rui/menu/store/store_button_callsigns" )

	AddMenuFooterOption( menu, BUTTON_A, "#A_BUTTON_SELECT" )
	AddMenuFooterOption( menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
}

void function OpenStoreMenu( string menuName )
{
	if ( IsDLCStoreUnavailable() )
	{
		ShowDLCStoreUnavailableNotice()
		return;
	}

	if ( IsDLCStoreInitialized() )
	{
		OnOpenDLCStore()
	 	AdvanceMenu( GetMenu( menuName ) )
		thread StoreMenuClosedThread()
	 	return
	}

	thread WaitForDLCStoreInitialization()
}

void function StoreMenuClosedThread()
{
	array<var> storeMenus

	storeMenus.append( GetMenu( "StoreMenu" ) )
	storeMenus.append( GetMenu( "StoreMenu_PrimeTitans" ) )
	storeMenus.append( GetMenu( "StoreMenu_Customization" ) )
	storeMenus.append( GetMenu( "StoreMenu_CustomizationPreview" ) )
	storeMenus.append( GetMenu( "StoreMenu_Camo" ) )
	storeMenus.append( GetMenu( "StoreMenu_Callsign" ) )
	storeMenus.append( GetMenu( "Dialog" ) )

	while ( true )
	{
		var activeMenu = GetActiveMenu()
		if ( !storeMenus.contains( activeMenu ) )
			break
		WaitSignal( uiGlobal.signalDummy, "ActiveMenuChanged" )
	}

	OnCloseDLCStore()
}

void function OnOpenStoreMenu()
{
	UI_SetPresentationType( ePresentationType.TITAN )
	RunMenuClientFunction( "UpdateTitanModel", 0 )

	if ( !GetPersistentVar( "hasSeenStore" ) )
		ClientCommand( "SetHasSeenStore" )
}

void function WaitForDLCStoreInitialization()
{
	EndSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )

	DialogData dialogData
	dialogData.header = "#PENDING_PLAYER_STATUS_LOADING"
	dialogData.showSpinner = true

	AddDialogButton( dialogData, "#CANCEL" )

	OpenDialog( dialogData )

	while ( !IsDLCStoreInitialized() )
	{
		WaitFrame()
	}

	if ( IsDialogActive( dialogData ) )
	{
		CloseActiveMenu( true )
		if ( IsDLCStoreInitialized() )
		{
			OnOpenDLCStore()
			AdvanceMenu( GetMenu( "StoreMenu" ) )
			thread StoreMenuClosedThread()
		}
	}
}
