
untyped

global function InitStoreMenuBundles

struct
{
	var menu
} file

void function InitStoreMenuBundles()
{
	file.menu = GetMenu( "StoreMenu_Bundles" )

	Hud_SetText( Hud_GetChild( file.menu, "MenuTitle" ), "#STORE_BUNDLES" )

	var button = Hud_GetChild( file.menu, "Button0" )
	SetButtonRuiText( button, "#STORE_BUNDLE_DLC1" )
	button.s.entitlementId <- ET_DLC1_BUNDLE
	Hud_AddEventHandler( button, UIE_CLICK, OnBundleButton_Activate )

	button = Hud_GetChild( file.menu, "ButtonLast" )
	SetButtonRuiText( button, "#STORE_BUNDLE_DLC3" )
	button.s.entitlementId <- ET_DLC3_BUNDLE
	Hud_AddEventHandler( button, UIE_CLICK, OnBundleButton_Activate )

	AddMenuFooterOption( file.menu, BUTTON_A, "#A_BUTTON_VIEW_PACK" )
	AddMenuFooterOption( file.menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
}

void function OnBundleButton_Activate( var button )
{
	if ( !IsFullyConnected() )
		return

#if PC_PROG
	if ( !Origin_IsOverlayAvailable() )
	{
		PopUpOriginOverlayDisabledDialog()
		return
	}
#endif

	int entitlementToBuy = expect int ( button.s.entitlementId )

	if ( !LocalPlayerHasEntitlement( entitlementToBuy ) )
	{
		StorePurchase( entitlementToBuy )
	}
	else
	{
		EmitUISound( "blackmarket_purchase_fail" )
	}
}