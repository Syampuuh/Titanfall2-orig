
global function InitEditTitanLoadoutMenu

struct {
	var menu
	var menuTitle
	var loadoutPanel
	var xpPanel
	var appearanceLabel
	var descriptionBox
	var hintIcon
	var hintBox
	var weaponCamoButton
	var camoSkinButton
	var noseArtButton
	bool menuClosing = false
} file

void function InitEditTitanLoadoutMenu()
{
	file.menu = GetMenu( "EditTitanLoadoutMenu" )
	var menu = file.menu

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnOpenEditTitanLoadoutMenu )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, OnCloseEditTitanLoadoutMenu )

	file.loadoutPanel = Hud_GetChild( menu, "TitanLoadoutButtons" )
	file.xpPanel = Hud_GetChild( file.loadoutPanel, "TitanXP" )
	array<var> loadoutPanelButtons = GetElementsByClassname( menu, "TitanLoadoutPanelButtonClass" )
	foreach ( button in loadoutPanelButtons )
	{
		Hud_AddEventHandler( button, UIE_CLICK, OnEditTitanSlotButton_Activate )
		AddButtonEventHandler( button, UIE_GET_FOCUS, OnTitanLoadoutButton_Focus )
		AddButtonEventHandler( button, UIE_LOSE_FOCUS, OnTitanLoadoutButton_LoseFocus )
	}

	file.menuTitle = Hud_GetChild( menu, "MenuTitle" )

	array<var> hintButtons = GetElementsByClassname( menu, "LoadoutHintLabel" )
	foreach ( button in hintButtons )
		Hud_EnableKeyBindingIcons( button )

	file.weaponCamoButton = Hud_GetChild( file.loadoutPanel, "ButtonWeaponCamo" )
	RuiSetImage( Hud_GetRui( file.weaponCamoButton ), "buttonImage", $"rui/menu/common/weapon_appearance_button" )
	RuiSetImage( Hud_GetRui( file.weaponCamoButton ), "camoImage", $"rui/menu/common/appearance_button_swatch" )
	AddButtonEventHandler( file.weaponCamoButton, UIE_GET_FOCUS, OnEditTitanCamoSkinButton_Focus )
	AddButtonEventHandler( file.weaponCamoButton, UIE_LOSE_FOCUS, OnEditTitanCamoSkinButton_LoseFocus )
	AddButtonEventHandler( file.weaponCamoButton, UIE_CLICK, OnEditTitanWeaponSkinButton_Activate )

	file.camoSkinButton = Hud_GetChild( file.loadoutPanel, "ButtonCamoSkin" )
	RuiSetImage( Hud_GetRui( file.camoSkinButton ), "buttonImage", $"rui/menu/common/warpaint_appearance_button" )
	RuiSetImage( Hud_GetRui( file.camoSkinButton ), "camoImage", $"rui/menu/common/appearance_button_swatch" )
	AddButtonEventHandler( file.camoSkinButton, UIE_GET_FOCUS, OnEditTitanCamoSkinButton_Focus )
	AddButtonEventHandler( file.camoSkinButton, UIE_LOSE_FOCUS, OnEditTitanCamoSkinButton_LoseFocus )
	AddButtonEventHandler( file.camoSkinButton, UIE_CLICK, OnEditTitanCamoSkinButton_Activate )

	file.noseArtButton = Hud_GetChild( file.loadoutPanel, "ButtonNoseArt" )
	RuiSetImage( Hud_GetRui( file.noseArtButton ), "buttonImage", $"rui/menu/common/noseart_appearance_button" )
	AddButtonEventHandler( file.noseArtButton, UIE_GET_FOCUS, OnEditTitanCamoSkinButton_Focus )
	AddButtonEventHandler( file.noseArtButton, UIE_LOSE_FOCUS, OnEditTitanCamoSkinButton_LoseFocus )
	AddButtonEventHandler( file.noseArtButton, UIE_CLICK, OnEditTitanNoseArtButton_Activate )

	AddMenuFooterOption( menu, BUTTON_A, "#A_BUTTON_SELECT" )
	AddMenuFooterOption( menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
	AddMenuFooterOption( menu, BUTTON_X, "#X_BUTTON_VIEW_TITAN_BRIEFING", "#VIEW_TITAN_BRIEFING", PlayMeetTitanVideo, IsLobby )

	file.appearanceLabel = Hud_GetChild( file.loadoutPanel, "LabelAppearance" )
	file.descriptionBox = Hud_GetChild( file.loadoutPanel, "LabelDetails" )
	file.hintIcon = Hud_GetChild( file.loadoutPanel, "HintIcon" )

	var rui = Hud_GetRui( file.hintIcon )
	RuiSetImage( rui, "basicImage", $"rui/menu/common/bulb_hint_icon" )

	file.hintBox = Hud_GetChild( file.loadoutPanel, "HintBackground" )
	rui = Hud_GetRui( file.hintBox )
	RuiSetImage( rui, "basicImage", $"rui/borders/menu_border_button" )
	RuiSetFloat3( rui, "basicImageColor", <0,0,0> )
	RuiSetFloat( rui, "basicImageAlpha", 0.5 )
}

void function OnOpenEditTitanLoadoutMenu()
{
	var menu = file.menu

	AddDefaultTitanElementsToTitanLoadoutMenu( menu )

	TitanLoadoutDef loadout = GetCachedTitanLoadout( uiGlobal.editingLoadoutIndex )

	Hud_SetUTF8Text( file.menuTitle, GetTitanLoadoutName( loadout ) )
	file.menuClosing = false

	UpdateTitanLoadoutPanel( file.loadoutPanel, loadout )
	UpdateTitanXP( file.xpPanel, uiGlobal.editingLoadoutIndex )
	Hud_SetNew( file.camoSkinButton, ButtonShouldShowNew( eItemTypes.CAMO_SKIN_TITAN, "", loadout.titanClass ) || ButtonShouldShowNew( eItemTypes.TITAN_WARPAINT, "", loadout.titanClass ) )
	Hud_SetNew( file.weaponCamoButton, ButtonShouldShowNew( eItemTypes.CAMO_SKIN, "", loadout.titanClass ) )
	Hud_SetNew( file.noseArtButton, ButtonShouldShowNew( eItemTypes.TITAN_NOSE_ART, "", loadout.titanClass ) )

	asset titanCamoImage
	if ( loadout.camoIndex == 0 && loadout.skinIndex == 0 )
	{
		titanCamoImage = $"rui/menu/common/appearance_button_swatch"
	}
	else if ( loadout.camoIndex > 0 )
	{
		titanCamoImage = CamoSkin_GetImage( CamoSkins_GetByIndex( loadout.camoIndex ) )
	}
	else
	{
		array<ItemDisplayData> titanSkinRefs = GetVisibleItemsOfType( eItemTypes.TITAN_WARPAINT, loadout.titanClass )
		string skinRef = ""
		foreach ( data in titanSkinRefs )
		{
			ItemData skin = GetItemData( data.ref )
			if ( skin.i.skinIndex != loadout.skinIndex )
				continue

			skinRef = data.ref
			break
		}
		Assert( skinRef != "" )
		titanCamoImage = GetItemImage( skinRef )
	}

	RuiSetImage( Hud_GetRui( file.camoSkinButton ), "camoImage", titanCamoImage )

	asset primaryCamoImage = loadout.primaryCamoIndex > 0 ? CamoSkin_GetImage( CamoSkins_GetByIndex( loadout.primaryCamoIndex ) ) : $"rui/menu/common/appearance_button_swatch"
	RuiSetImage( Hud_GetRui( file.weaponCamoButton ), "camoImage", primaryCamoImage )

	UI_SetPresentationType( ePresentationType.TITAN_LOADOUT_EDIT )

	Hud_SetText( file.appearanceLabel, "" )

	RefreshCreditsAvailable()
}

void function OnEditTitanCamoSkinButton_LoseFocus( var button )
{
	var rui = Hud_GetRui( file.descriptionBox )
	RuiSetString( rui, "messageText", "" )

	Hud_Hide( file.hintIcon )
	Hud_Hide( file.hintBox )
}

void function OnEditTitanCamoSkinButton_Focus( var button )
{
	string desc
	switch ( Hud_GetHudName( button ) )
	{
		case "ButtonCamoSkin":
			desc = "#ITEM_TYPE_CAMO_SKIN_TITAN_CHOICE"
		break
		case "ButtonNoseArt":
			desc = "#ITEM_TYPE_TITAN_NOSE_ART_CHOICE"
		break
		case "ButtonWeaponCamo":
			desc = "#ITEM_TYPE_CAMO_SKIN_CHOICE"
		break
	}
	var rui = Hud_GetRui( file.descriptionBox )
	RuiSetString( rui, "messageText", desc )
	Hud_Show( file.hintIcon )
	Hud_Show( file.hintBox )
}

void function OnEditTitanWeaponSkinButton_Activate( var button )
{
	uiGlobal.editingLoadoutProperty = "primaryCamoIndex"
	AdvanceMenu( GetMenu( "CamoSelectMenu" ) )
}

void function OnEditTitanCamoSkinButton_Activate( var button )
{
	uiGlobal.editingLoadoutProperty = "camoIndex"
	AdvanceMenu( GetMenu( "CamoSelectMenu" ) )
}

void function OnEditTitanNoseArtButton_Activate( var button )
{
	uiGlobal.editingLoadoutProperty = "decalIndex"
	AdvanceMenu( GetMenu( "NoseArtSelectMenu" ) )
}

void function OnCloseEditTitanLoadoutMenu()
{
	file.menuClosing = true
}

void function OnTitanLoadoutButton_Focus( var button )
{
	TitanLoadoutDef loadout = GetCachedTitanLoadout( uiGlobal.editingLoadoutIndex )
	string propertyName = Hud_GetScriptID( button )
	string itemRef = GetTitanLoadoutValue( loadout, propertyName )
	int itemType = GetItemTypeFromTitanLoadoutProperty( propertyName, loadout.setFile )
	string desc = GetItemDescription( itemRef )
	var rui = Hud_GetRui( file.descriptionBox )
	RuiSetString( rui, "messageText", desc )
	Hud_Show( file.hintIcon )
	Hud_Show( file.hintBox )
}

void function OnTitanLoadoutButton_LoseFocus( var button )
{
	var rui = Hud_GetRui( file.descriptionBox )
	RuiSetString( rui, "messageText", "" )
	Hud_Hide( file.hintIcon )
	Hud_Hide( file.hintBox )
}

void function OnEditTitanSlotButton_Activate( var button )
{
	string loadoutProperty = Hud_GetScriptID( button )
	uiGlobal.editingLoadoutProperty = loadoutProperty

	switch ( loadoutProperty )
	{
		case "passive1":
		case "passive2":
		case "passive3":
			AdvanceMenu( GetMenu( "PassiveSelectMenu" ) )
			break

		case "decal":
			AdvanceMenu( GetMenu( "DecalSelectMenu" ) )
			break

		default:
			break
	}
}

void function PlayMeetTitanVideo( var button )
{
	TitanLoadoutDef loadout = GetCachedTitanLoadout( uiGlobal.editingLoadoutIndex )

	PlayVideoMenu( "meet_" + loadout.titanClass, true )
}
