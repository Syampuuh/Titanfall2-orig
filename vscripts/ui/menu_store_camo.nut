untyped

global function InitStoreMenuCamo
global function EntitlementsChanged_Camo

struct
{
	var menu
	var buyButton
	GridMenuData gridData
	bool hasEntitlement
	array<CamoRef> camoRefs
} file

void function InitStoreMenuCamo()
{
	file.menu = GetMenu( "StoreMenu_Camo" )
	Hud_SetText( Hud_GetChild( file.menu, "MenuTitle" ), "#STORE_CAMO_PACKS" )

	file.buyButton = Hud_GetChild( file.menu, "BuyButton" )
	Hud_AddEventHandler( file.buyButton, UIE_CLICK, OnBuyButton_Activate )

	AddMenuEventHandler( file.menu, eUIEvent.MENU_OPEN, OnOpenStoreMenuCamo )
	AddMenuEventHandler( file.menu, eUIEvent.MENU_NAVIGATE_BACK, OnStoreMenuCamo_NavigateBack )

	file.camoRefs = Store_GetCamoRefs()

	AddMenuFooterOption( file.menu, BUTTON_A, "#A_BUTTON_SELECT" )
	AddMenuFooterOption( file.menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
}

void function OnStoreMenuCamo_NavigateBack()
{
	RunMenuClientFunction( "ClearTitanCamoPreview" )
	RunMenuClientFunction( "ClearAllTitanPreview" )
	RunMenuClientFunction( "ClearAllPilotPreview" )
	CloseActiveMenu()
}

void function OnOpenStoreMenuCamo()
{
	UI_SetPresentationType( ePresentationType.STORE_CAMO_PACKS )

	file.hasEntitlement = LocalPlayerHasEntitlement( ET_DLC1_CAMO )

	file.gridData.rows = 4
	file.gridData.columns = 5
	file.gridData.numElements = 20
	file.gridData.paddingVert = 6
	file.gridData.paddingHorz = 6
	file.gridData.panelTopPadding = 12
	file.gridData.panelLeftPadding = 12
	file.gridData.panelRightPadding = 12
	file.gridData.panelBottomPadding = 12
	file.gridData.pageType = eGridPageType.HORIZONTAL

	Grid_AutoTileSettings( file.menu, file.gridData )

	file.gridData.initCallback = StoreCamoButton_Init
	file.gridData.getFocusCallback = StoreCamoButton_GetFocus
	file.gridData.clickCallback = StoreCamoButton_Activate

	GridMenuInit( file.menu, file.gridData )

	var panel = GetMenuChild( file.menu, "GridPanel" )
	var rui = Hud_GetRui( Hud_GetChild( panel, "PanelFrame" ) )
	RuiSetColorAlpha( rui, "backgroundColor", <0.0, 0.0, 0.0>, 0.4 )
	Hud_GetChild( panel, "GridButton3x0" ).SetNavDown( file.buyButton )
	Hud_GetChild( panel, "GridButton3x1" ).SetNavDown( file.buyButton )
	Hud_GetChild( panel, "GridButton3x2" ).SetNavDown( file.buyButton )
	Hud_GetChild( panel, "GridButton3x3" ).SetNavDown( file.buyButton )
	Hud_GetChild( panel, "GridButton3x4" ).SetNavDown( file.buyButton )
	file.buyButton.SetNavUp( Hud_GetChild( panel, "GridButton3x2" ) )

	RefreshEntitlements()
}

bool function StoreCamoButton_Init( var button, int elemNum )
{
	var rui = Hud_GetRui( button )

	asset image = GetItemDisplayData( file.camoRefs[ elemNum ].pilotRef ).image
	RuiSetImage( rui, "buttonImage", image )

	return true
}

void function StoreCamoButton_Activate( var button, int elemNum )
{
	Hud_SetFocused( file.buyButton )
}

void function StoreCamoButton_GetFocus( var button, int elemNum )
{
	// titan camo
	RunMenuClientFunction( "PreviewTitanCamoChange", GetItemPersistenceId( file.camoRefs[ elemNum ].titanRef ) )

	// titan weapon
	RunMenuClientFunction( "PreviewTitanWeaponCamoChange", eItemTypes.TITAN_PRIMARY, GetItemPersistenceId( file.camoRefs[ elemNum ].ref ) )

	// pilot camo
	RunMenuClientFunction( "PreviewPilotCamoChange", GetItemPersistenceId( file.camoRefs[ elemNum ].pilotRef ) )

	// pilot weapon camo
	RunMenuClientFunction( "PreviewPilotWeaponCamoChange", eItemTypes.PILOT_PRIMARY, GetItemPersistenceId( file.camoRefs[ elemNum ].ref ) )
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

	if ( !LocalPlayerHasEntitlement( ET_DLC1_CAMO ) )
	{
		StorePurchase( ET_DLC1_CAMO )
	}
	else
	{
		EmitUISound( "blackmarket_purchase_fail" )
	}
}

void function EntitlementsChanged_Camo()
{
	RefreshEntitlements()
}

void function RefreshEntitlements()
{
	bool hasEntitlement = LocalPlayerHasEntitlement( ET_DLC1_CAMO )

	var rui = Hud_GetRui( file.buyButton )
	RuiSetString( rui, "price", GetEntitlementPrices( [ ET_DLC1_CAMO ] )[ 0 ] )
	RuiSetBool( rui, "isOwned", hasEntitlement )

	if ( !file.hasEntitlement && hasEntitlement )
	{
		ClientCommand( "StoreSetNewItemStatus StoreMenu_Camo" )
	}
}