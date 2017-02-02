
global function InitControlsMenu

struct
{
	var menu
	table<var,string> buttonDescriptions
	var autoSprintSetting
	array<var> advanceControlsDisableItems
	array<var> advanceControlsVisibleItems
} file

void function InitControlsMenu()
{
	var menu = GetMenu( "ControlsMenu" )
	file.menu = menu

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnOpenControlsMenu )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, OnCloseControlsMenu )

	var button

	Hud_EnableKeyBindingIcons( Hud_GetChild( menu, "LblMenuItemDescription" ) )

#if PC_PROG
	button = Hud_GetChild( menu, "BtnMouseKeyboardBindings" )
	SetupButton( button, "#KEY_BINDINGS", "#MOUSE_KEYBOARD_MENU_CONTROLS_DESC" )
	AddButtonEventHandler( button, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "MouseKeyboardBindingsMenu" ) ) )

	SetupButton( Hud_GetChild( Hud_GetChild( menu, "SldMouseSensitivity" ), "BtnDropButton" ), "#MOUSE_SENSITIVITY", "#MOUSE_KEYBOARD_MENU_SENSITIVITY_DESC" )
	SetupButton( Hud_GetChild( Hud_GetChild( menu, "SldMouseSensitivityZoomed" ), "BtnDropButton" ), "#MOUSE_SENSITIVITY_ZOOM", "#MOUSE_KEYBOARD_MENU_SENSITIVITY_ZOOM_DESC" )
	SetupButton( Hud_GetChild( menu, "SwchMouseAcceleration" ), "#MOUSE_ACCELERATION", "#MOUSE_KEYBOARD_MENU_ACCELERATION_DESC" )
	SetupButton( Hud_GetChild( menu, "SwchMouseInvertY" ), "#MOUSE_INVERT", "#MOUSE_KEYBOARD_MENU_INVERT_DESC" )
#endif //PC_PROG

	button = Hud_GetChild( menu, "BtnGamepadLayout" )
	SetupButton( button, "#BUTTON_STICK_LAYOUT", "#GAMEPAD_MENU_CONTROLS_DESC" )
	AddButtonEventHandler( button, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "GamepadLayoutMenu" ) ) )

	button = Hud_GetChild( menu, "BtnControllerResetToDefaults" )
	SetupButton( button, "#RESET_CONTROLLER_TO_DEFAULT", "#RESET_CONTROLLER_TO_DEFAULT_DESC" )
	AddButtonEventHandler( button, UIE_CLICK, Controller_ResetToDefaultsDialog )

	//BtnControllerOpenAdvancedMenu
	button = Hud_GetChild( menu, "BtnControllerOpenAdvancedMenu" )
	SetupButton( button, "#OPEN_ADVANCED_LOOK_CONTROLS", "#OPEN_ADVANCED_LOOK_CONTROLS_DESC" )
	AddButtonEventHandler( button, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "ControlsAdvancedLookMenu" ) ) )

	button = SetupButton( Hud_GetChild( menu, "SwchLookSensitivity" ), "#LOOK_SENSITIVITY", "#GAMEPAD_MENU_SENSITIVITY_DESC" )
	file.advanceControlsDisableItems.append( button )

	button = SetupButton( Hud_GetChild( menu, "SwchLookSensitivityADS" ), "#LOOK_SENSITIVITY_ADS", "#GAMEPAD_MENU_SENSITIVITY_ADS_DESC" )
	file.advanceControlsDisableItems.append( button )

	SetupButton( Hud_GetChild( menu, "SwchLookInvert" ), "#LOOK_INVERT", "#GAMEPAD_MENU_INVERT_DESC" )

	button = SetupButton( Hud_GetChild( menu, "SwchLookDeadzone" ), "#LOOK_DRIFT_GUARD", "#GAMEPAD_MENU_DRIFT_GUARD_DESC" )
	file.advanceControlsDisableItems.append( button )

	SetupButton( Hud_GetChild( menu, "SwchMoveDeadzone" ), "#MOVE_DRIFT_GUARD", "#GAMEPAD_MENU_MOVE_DRIFT_GUARD_DESC" )

#if DURANGO_PROG
	button = SetupButton( Hud_GetChild( menu, "SwchLookAiming" ), "#LOOKSTICK_AIMING", "#GAMEPAD_MENU_LOOK_AIMING_DESC_DURANGO" )
#else // #if DURANGO_PROG
	button = SetupButton( Hud_GetChild( menu, "SwchLookAiming" ), "#LOOKSTICK_AIMING", "#GAMEPAD_MENU_LOOK_AIMING_DESC" )
#endif // #if DURANGO_PROG
	file.advanceControlsDisableItems.append( button )

	SetupButton( Hud_GetChild( menu, "SwchVibration" ), "#VIBRATION", "#GAMEPAD_MENU_VIBRATION_DESC" )
	file.autoSprintSetting = Hud_GetChild( menu, "SwchAutoSprint" )
	SetupButton( file.autoSprintSetting, "#MENU_AUTOMATIC_SPRINT", "#OPTIONS_MENU_AUTOSPRINT_DESC" )

	file.advanceControlsVisibleItems.append( Hud_GetChild( menu, "SwchLookSensitivity_AdvLabel" ) )
	file.advanceControlsVisibleItems.append( Hud_GetChild( menu, "SwchLookSensitivityADS_AdvLabel" ) )
	file.advanceControlsVisibleItems.append( Hud_GetChild( menu, "SwchLookAiming_AdvLabel" ) )
	file.advanceControlsVisibleItems.append( Hud_GetChild( menu, "SwchLookDeadzone_AdvLabel" ) )
	file.advanceControlsVisibleItems.append( Hud_GetChild( menu, "LblAdvController" ) )

#if PC_PROG
	AddEventHandlerToButtonClass( menu, "RuiFooterButtonClass", UIE_GET_FOCUS, FooterButton_Focused )
#endif //PC_PROG

	AddMenuFooterOption( menu, BUTTON_A, "#A_BUTTON_SELECT" )
	AddMenuFooterOption( menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
#if CONSOLE_PROG
	AddMenuFooterOption( menu, BUTTON_X, "#X_BUTTON_REVIEW_TERMS", "#REVIEW_TERMS", OpenReviewTermsDialog, AreTermsAccepted ) // Console only, waiting on PC text
#endif // CONSOLE_PROG
#if DURANGO_PROG
	AddMenuFooterOption( menu, BUTTON_Y, "#Y_BUTTON_XBOX_HELP", "", OpenXboxHelp )
#endif // DURANGO_PROG
}

bool function IsAffectedByAdvancedControls( var button )
{
	foreach( var item in file.advanceControlsDisableItems )
	{
		if ( item == button )
			return true
	}
	return false
}

void function SetStatesForCustomEnable()
{
	bool customGamepadIsEnabled = GetConVarBool( "gamepad_custom_enabled" )

	foreach( var item in file.advanceControlsDisableItems )
		Hud_SetEnabled( item, !customGamepadIsEnabled )

	foreach( var item in file.advanceControlsVisibleItems )
		Hud_SetVisible( item, customGamepadIsEnabled )
}

void function OnOpenControlsMenu()
{
	UI_SetPresentationType( ePresentationType.NO_MODELS )

	Hud_SetEnabled( file.autoSprintSetting, !IsAutoSprintForced() )

	SetStatesForCustomEnable()
}

void function OnCloseControlsMenu()
{
	SavePlayerSettings()
}

var function SetupButton( var button, string buttonText, string description )
{
	SetButtonRuiText( button, buttonText )
	file.buttonDescriptions[ button ] <- description
	AddButtonEventHandler( button, UIE_GET_FOCUS, Button_Focused )
	return button
}

void function Button_Focused( var button )
{
	string description = file.buttonDescriptions[ button ]
	SetElementsTextByClassname( file.menu, "MenuItemDescriptionClass", description )
}

void function Controller_ResetToDefaultsDialog( var button )
{
	DialogData dialogData
	dialogData.header = "#RESET_CONTROLLER_TO_DEFAULT_DIALOG"
	dialogData.message = "#RESET_CONTROLLER_TO_DEFAULT_DIALOG_DESC"
	AddDialogButton( dialogData, "#RESTORE", Controller_ResetToDefaults )
	AddDialogButton( dialogData, "#CANCEL" )
	OpenDialog( dialogData )
}

void function Controller_ResetToDefaults()
{
	SetConVarInt( "gamepad_aim_speed", 2 )
	SetConVarInt( "gamepad_aim_speed_ads", -1 )
	SetConVarInt( "joy_inverty", 0 )
	SetConVarInt( "gamepad_look_curve", 0 )
	SetConVarInt( "gamepad_deadzone_index_look", 1 )
	SetConVarInt( "gamepad_deadzone_index_move", 1 )
	SetConVarInt( "joy_rumble", 1 )

	SetConVarInt( "gamepad_button_layout", 0 )
	SetConVarInt( "gamepad_buttons_are_southpaw", 0 )
	SetConVarInt( "gamepad_stick_layout", 0 )

	SetConVarInt( "gamepad_custom_enabled", 0 )
	SetStatesForCustomEnable()

	ExecConfig( "gamepad_stick_layout_default.cfg" )
	ExecConfig( "gamepad_button_layout_default.cfg" )
}

#if PC_PROG
void function FooterButton_Focused( var button )
{
	SetElementsTextByClassname( file.menu, "MenuItemDescriptionClass", "" )
}
#endif //PC_PROG
