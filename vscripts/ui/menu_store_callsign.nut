untyped

global function InitStoreMenuCallsign
global function EntitlementsChanged_Callsign

struct
{
	bool initialized = false
	var menu
	var callsignCard
	var buyButton
	array<string> iconRefs
	array<string> bannerRefs
	GridMenuData gridData
	bool hasEntitlement
	var callsignFocusElem = null
	var iconFocusElem = null
} file

void function InitStoreMenuCallsign()
{
	file.menu = GetMenu( "StoreMenu_Callsign" )
	Hud_SetText( Hud_GetChild( file.menu, "MenuTitle" ), "#STORE_CALLSIGN_PACKS" )

	file.callsignCard = Hud_GetChild( file.menu, "CallsignCard" )

	file.buyButton = Hud_GetChild( file.menu, "BuyButton" )
	Hud_AddEventHandler( file.buyButton, UIE_CLICK, OnBuyButton_Activate )

	AddMenuEventHandler( file.menu, eUIEvent.MENU_OPEN, OnOpenStoreMenuCallsign )
	AddMenuEventHandler( file.menu, eUIEvent.MENU_NAVIGATE_BACK, OnStoreMenuCallsign_NavigateBack )

	file.iconRefs.extend( Store_GetPatchRefs() )
	file.bannerRefs.extend( Store_GetBannerRefs() )

	AddMenuFooterOption( file.menu, BUTTON_X, "#SWITCH_FOCUS", "", StoreSwitchFocus, null )

	AddMenuFooterOption( file.menu, BUTTON_A, "#A_BUTTON_SELECT" )
	AddMenuFooterOption( file.menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
}

void function StoreSwitchFocus( var list )
{
	EmitUISound( "menu_focus" )
	if ( Hud_GetHudName( GetFocus() ).find( "CallsignIcon" ) != null )
	{
		if ( file.callsignFocusElem == null )
			Hud_SetFocused( Hud_GetChild( file.menu, "GridButton0x0" ) )
		else
			Hud_SetFocused( file.callsignFocusElem )
	}
	else
	{
		if ( file.iconFocusElem == null )
			Hud_SetFocused( Hud_GetChild( file.menu, "CallsignIcon0x0" ) )
		else
			Hud_SetFocused( file.iconFocusElem )
	}
}

void function SetupCallsignIcon( string elem, asset icon, int rowIndex )
{
	var button = Hud_GetChild( file.menu, elem )
	button.s.rowIndex <- rowIndex
	Hud_AddEventHandler( button, UIE_CLICK, StoreIconButton_Activate )
	Hud_AddEventHandler( button, UIE_GET_FOCUS, StoreIconButton_GetFocus )
	var rui = Hud_GetRui( button )
	RuiSetImage( rui, "iconImage", icon )
}

void function OnStoreMenuCallsign_NavigateBack()
{
	CloseActiveMenu()
}

void function OnOpenStoreMenuCallsign()
{
	UI_SetPresentationType( ePresentationType.NO_MODELS )

	file.hasEntitlement = LocalPlayerHasEntitlement( ET_DLC1_CALLSIGN )

	file.gridData.rows = 5
	file.gridData.columns = 4
	file.gridData.numElements = 20
	file.gridData.pageType = eGridPageType.HORIZONTAL
	file.gridData.tileWidth = 225
	file.gridData.tileHeight = 100
	file.gridData.paddingVert = 4
	file.gridData.paddingHorz = 6
	file.gridData.panelTopPadding = 16
	file.gridData.panelLeftPadding = 64
	file.gridData.panelRightPadding = 64
	file.gridData.panelBottomPadding = 16

	Grid_AutoAspectSettings( file.menu, file.gridData )

	file.gridData.initCallback = StoreCallsignButton_Init
	file.gridData.getFocusCallback = StoreCallsignButton_GetFocus
	file.gridData.clickCallback = StoreCallsignButton_Activate

	GridMenuInit( file.menu, file.gridData )

	var panel = GetMenuChild( file.menu, "GridPanel" )
	var rui = Hud_GetRui( Hud_GetChild( panel, "PanelFrame" ) )
	RuiSetColorAlpha( rui, "backgroundColor", <0.0, 0.0, 0.0>, 0.5 )
	Hud_GetChild( panel, "GridButton4x0" ).SetNavDown( Hud_GetChild( file.menu, "CallsignIcon0x0" ) )
	Hud_GetChild( panel, "GridButton4x1" ).SetNavDown( Hud_GetChild( file.menu, "CallsignIcon0x3" ) )
	Hud_GetChild( panel, "GridButton4x2" ).SetNavDown( Hud_GetChild( file.menu, "CallsignIcon0x6" ) )
	Hud_GetChild( panel, "GridButton4x3" ).SetNavDown( Hud_GetChild( file.menu, "CallsignIcon0x9" ) )

	Update2DCallsignElement( file.callsignCard )
	Update2DCallsignIconElement( file.callsignCard, CallsignIcon_GetByRef( file.iconRefs[ 0 ] ) )

	RefreshEntitlements()

	if ( !file.initialized )
	{
		file.initialized = true

		for ( int i = 0; i < 2; i++ )
		{
			for ( int j = 0; j < 10; j++ )
			{
				int index = i * 10 + j
				asset iconImage = GetItemDisplayData( file.iconRefs[ index ] ).image
				SetupCallsignIcon( "CallsignIcon" + i + "x" + j, iconImage, index )
			}
		}
	}
}

bool function StoreCallsignButton_Init( var button, int elemNum )
{
	var rui = Hud_GetRui( button )

	asset image = GetItemDisplayData( file.bannerRefs[ elemNum ] ).image
	RuiSetImage( rui, "cardImage", image )

	return true
}

void function StoreCallsignButton_Activate( var button, int elemNum )
{
	Hud_SetFocused( file.buyButton )
}

void function StoreCallsignButton_GetFocus( var button, int elemNum )
{
	file.callsignFocusElem = button

	CallingCard callsignCard = CallingCard_GetByRef( file.bannerRefs[ elemNum ] )

	Update2DCallsignCardElement( file.callsignCard, callsignCard )
}

void function StoreIconButton_Activate( var button )
{
	Hud_SetFocused( file.buyButton )
}

void function StoreIconButton_GetFocus( var button )
{
	file.iconFocusElem = button

	int index = expect int( button.s.rowIndex )
	CallsignIcon callsignIcon = CallsignIcon_GetByRef( file.iconRefs[ index ] )

	Update2DCallsignIconElement( file.callsignCard, callsignIcon )
}

void function OnBuyButton_Activate( var button )
{
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

	if ( !LocalPlayerHasEntitlement( ET_DLC1_CALLSIGN ) )
	{
		StorePurchase( ET_DLC1_CALLSIGN )
	}
	else
	{
		EmitUISound( "blackmarket_purchase_fail" )
	}
}

void function EntitlementsChanged_Callsign()
{
	RefreshEntitlements()
}

void function RefreshEntitlements()
{
	bool hasEntitlement = LocalPlayerHasEntitlement( ET_DLC1_CALLSIGN )

	var rui = Hud_GetRui( file.buyButton )
	RuiSetString( rui, "price", GetEntitlementPrices( [ ET_DLC1_CALLSIGN ] )[ 0 ] )
	RuiSetBool( rui, "isOwned", hasEntitlement )

	if ( !file.hasEntitlement && hasEntitlement )
	{
		ClientCommand( "StoreSetNewItemStatus StoreMenu_Callsign" )
	}
}