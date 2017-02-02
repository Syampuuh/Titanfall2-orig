untyped

global function MenuGamepadLayout_Init

global function ExecCurrentGamepadButtonConfig
global function ExecCurrentGamepadStickConfig
global function InitGamepadLayoutMenu
global function ButtonLayoutButton_Focused
global function SouthpawButton_Focused
global function StickLayoutButton_Focused

struct ButtonVars
{
	string common
	string pilot
	string titan
}

struct
{
	var menu
	asset gamepadButtonLayoutImage
	asset gamepadStickLayoutImage
	var description
	var gamepadButtonLayout

	table< string, asset > horizontalImages =
	{
		move = $"ui/menu/controls_menu/horizontal_move",
		turn = $"ui/menu/controls_menu/horizontal_turn"
	}

	table< string, asset > verticalImages =
	{
		move = $"ui/menu/controls_menu/vertical_move",
		turn = $"ui/menu/controls_menu/vertical_turn"
	}
} file

function MenuGamepadLayout_Init()
{
	PrecacheHUDMaterial( $"ui/menu/controls_menu/horizontal_move" )
	PrecacheHUDMaterial( $"ui/menu/controls_menu/horizontal_turn" )
	PrecacheHUDMaterial( $"ui/menu/controls_menu/vertical_move" )
	PrecacheHUDMaterial( $"ui/menu/controls_menu/vertical_turn" )

	#if PS4_PROG
		file.gamepadButtonLayoutImage = $"ui/menu/controls_menu/ps4_gamepad_button_layout"
		file.gamepadStickLayoutImage = $"ui/menu/controls_menu/ps4_gamepad_stick_layout"
	#else
		file.gamepadButtonLayoutImage = $"ui/menu/controls_menu/xboxone_gamepad_button_layout"
		file.gamepadStickLayoutImage = $"ui/menu/controls_menu/xboxone_gamepad_stick_layout"
	#endif
}

int function GetGamepadButtonLayout()
{
	int gamepadButtonLayout = GetConVarInt( "gamepad_button_layout" )
	Assert( gamepadButtonLayout >= 0 && gamepadButtonLayout < uiGlobal.buttonConfigs.len() )

	if ( gamepadButtonLayout < 0 || gamepadButtonLayout >= uiGlobal.buttonConfigs.len() )
		gamepadButtonLayout = 0

	return gamepadButtonLayout
}

int function GetGamepadStickLayout()
{
	int gamepadStickLayout = GetConVarInt( "gamepad_stick_layout" )
	Assert( gamepadStickLayout >= 0 && gamepadStickLayout < uiGlobal.stickConfigs.len() )

	if ( gamepadStickLayout < 0 || gamepadStickLayout >= uiGlobal.stickConfigs.len() )
		gamepadStickLayout = 0

	return gamepadStickLayout
}

string function GetButtonStance()
{
	string stance = "orthodox"
	if ( GetConVarInt( "gamepad_buttons_are_southpaw" ) != 0 )
		stance = "southpaw"

	return stance
}

function ExecCurrentGamepadButtonConfig()
{
	ExecConfig( uiGlobal.buttonConfigs[ GetGamepadButtonLayout() ][ GetButtonStance() ] )
}

function ExecCurrentGamepadStickConfig()
{
	ExecConfig( uiGlobal.stickConfigs[ GetGamepadStickLayout() ] )
}

void function InitGamepadLayoutMenu()
{
	var menu = GetMenu( "GamepadLayoutMenu" )
	file.menu = menu

	var button = Hud_GetChild( menu, "SwchButtonLayout" )
	SetButtonRuiText( button, "#BUTTON_LAYOUT" )
	AddButtonEventHandler( button, UIE_GET_FOCUS, ThreadButtonLayoutButton_Focused )

	button = Hud_GetChild( menu, "SwchSouthpaw" )
	SetButtonRuiText( button, "#LEFTY" )
	AddButtonEventHandler( button, UIE_GET_FOCUS, ThreadSouthpawButton_Focused )

	button = Hud_GetChild( menu, "SwchStickLayout" )
	SetButtonRuiText( button, "#STICK_LAYOUT" )
	AddButtonEventHandler( button, UIE_GET_FOCUS, ThreadStickLayoutButton_Focused )

	file.description = Hud_GetChild( menu, "lblControllerDescription" )
	file.gamepadButtonLayout = Hud_GetChild( menu, "ImgGamepadButtonLayoutRui" )
#if PS4_PROG
	RuiSetBool( Hud_GetRui( file.gamepadButtonLayout ), "isPS4", true )
#endif

	AddMenuFooterOption( menu, BUTTON_A, "#A_BUTTON_SELECT" )
	AddMenuFooterOption( menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
#if DURANGO_PROG
	AddMenuFooterOption( menu, BUTTON_Y, "#Y_BUTTON_XBOX_HELP", "", OpenXboxHelp )
#endif // DURANGO_PROG
}

void function ThreadButtonLayoutButton_Focused( var button )
{
	thread ButtonLayoutButton_Focused( button )
}

void function ThreadSouthpawButton_Focused( var button )
{
	thread SouthpawButton_Focused( button )
}

void function ThreadStickLayoutButton_Focused( var button )
{
	thread StickLayoutButton_Focused( button )
}

void function ButtonLayoutButton_Focused( var button )
{
	WaitFrame() // Needed for focus to actually take effect

	SetImagesByClassname( file.menu, "GamepadImageClass", file.gamepadButtonLayoutImage )

	int currentButtonConfig = -1
	int lastButtonConfig = -1

	while ( Hud_IsFocused( button ) )
	{
		currentButtonConfig = GetGamepadButtonLayout()

		if ( currentButtonConfig != lastButtonConfig )
		{
			ExecCurrentGamepadButtonConfig()
			WaitFrame() // ExecConfig does not execute immediately, need to wait a frame
			UpdateButtonDisplay()
			UpdateButtonLayoutDescription()
			lastButtonConfig = currentButtonConfig
		}

		WaitFrame()
	}
}

void function SouthpawButton_Focused( var button )
{
	WaitFrame() // Needed for focus to actually take effect

	string currentButtonStance
	string lastButtonStance

	while ( Hud_IsFocused( button ) )
	{
		currentButtonStance = GetButtonStance()

		if ( currentButtonStance != lastButtonStance )
		{
			ExecCurrentGamepadButtonConfig()
			WaitFrame() // ExecConfig does not execute immediately, need to wait a frame
			UpdateButtonDisplay()
			UpdateButtonSouthpawDescription()
			lastButtonStance = currentButtonStance
		}

		WaitFrame()
	}
}

void function StickLayoutButton_Focused( var button )
{
	WaitFrame() // Needed for focus to actually take effect

	int currentStickConfig = -1
	int lastStickConfig = -1

	while ( Hud_IsFocused( button ) )
	{
		currentStickConfig = GetGamepadStickLayout()

		if ( currentStickConfig != lastStickConfig )
		{
			ExecCurrentGamepadStickConfig()
			WaitFrame() // ExecConfig does not execute immediately, need to wait a frame
			UpdateStickDisplay()
			UpdateStickLayoutDescription()
			lastStickConfig = currentStickConfig
		}

		WaitFrame()
	}
}

function UpdateButtonDisplay()
{
	RuiSetInt( Hud_GetRui( file.gamepadButtonLayout ), "stickLayout", -1 )

	array<int> buttonLayoutBinds
	buttonLayoutBinds.append( BUTTON_A )
	buttonLayoutBinds.append( BUTTON_B )
	buttonLayoutBinds.append( BUTTON_X )
	buttonLayoutBinds.append( BUTTON_Y )
	buttonLayoutBinds.append( BUTTON_TRIGGER_LEFT )
	buttonLayoutBinds.append( BUTTON_TRIGGER_RIGHT )
	buttonLayoutBinds.append( BUTTON_SHOULDER_LEFT )
	buttonLayoutBinds.append( BUTTON_SHOULDER_RIGHT )
	buttonLayoutBinds.append( BUTTON_DPAD_UP )
	buttonLayoutBinds.append( BUTTON_DPAD_DOWN )
	buttonLayoutBinds.append( BUTTON_DPAD_LEFT )
	buttonLayoutBinds.append( BUTTON_DPAD_RIGHT )
	buttonLayoutBinds.append( BUTTON_STICK_LEFT )
	buttonLayoutBinds.append( BUTTON_STICK_RIGHT )
	buttonLayoutBinds.append( BUTTON_BACK )
	buttonLayoutBinds.append( BUTTON_START )

	table<int, string> binds
	foreach ( bindName in buttonLayoutBinds )
		binds[ bindName ] <- GetKeyBinding( bindName ).tolower()

	foreach ( key, val in binds )
	{
		ButtonVars ruiVars = GetButtonRuiVars( key )
		ButtonVars bindDisplayName = GetBindDisplayName( val )
		var rui = Hud_GetRui( file.gamepadButtonLayout )

		if ( ruiVars.common != "" )
		{
			RuiSetString( rui, ruiVars.common, bindDisplayName.common )
		}
		if ( ruiVars.pilot != "" )
		{
			RuiSetString( rui, ruiVars.pilot, bindDisplayName.pilot )
		}
		if ( ruiVars.titan != "" )
		{
			RuiSetString( rui, ruiVars.titan, bindDisplayName.titan )
		}

		// This would ideally be read from the default config file so this doesn't have to stay in sync here
		table<int, string> bindsDefault = {
			[ BUTTON_A ] = "+ability 3",
			[ BUTTON_B ] = "+toggle_duck",
			[ BUTTON_X ] = "+useandreload",
			[ BUTTON_Y ] = "+ability 7",
			[ BUTTON_TRIGGER_LEFT ] = "+zoom",
			[ BUTTON_TRIGGER_RIGHT ] = "+attack",
			[ BUTTON_SHOULDER_LEFT ] = "+offhand1",
			[ BUTTON_SHOULDER_RIGHT ] = "+offhand0",
			[ BUTTON_DPAD_UP ] = "+scriptcommand1",
			[ BUTTON_DPAD_DOWN ] = "+ability 1",
			[ BUTTON_DPAD_LEFT ] = "+ability 6",
			[ BUTTON_DPAD_RIGHT ] = "scoreboard_focus",
			[ BUTTON_STICK_LEFT ] = "+speed",
			[ BUTTON_STICK_RIGHT ] = "+melee",
			[ BUTTON_BACK ] = "+showscores",
			[ BUTTON_START ] = "ingamemenu_activate"
		}

		if ( GetButtonStance() == "southpaw" )
		{
			bindsDefault[ BUTTON_TRIGGER_LEFT ] = "+attack"
			bindsDefault[ BUTTON_TRIGGER_RIGHT ] = "+zoom"
			bindsDefault[ BUTTON_SHOULDER_LEFT ] = "+offhand0"
			bindsDefault[ BUTTON_SHOULDER_RIGHT ] = "+offhand1"
			bindsDefault[ BUTTON_STICK_LEFT ] = "+melee"
			bindsDefault[ BUTTON_STICK_RIGHT ] = "+speed"
		}

		foreach ( keyDefault, valDefault in bindsDefault )
		{
			if ( key == keyDefault )
			{
				if ( val != valDefault )
					SetDiffArrowVisible( key, true )
				else
					SetDiffArrowVisible( key, false )
			}
		}
	}
}

function SetDiffArrowVisible( int key, bool visible )
{
	string ruiVar = ""

	switch ( key )
	{
		case BUTTON_A:
			ruiVar = "aButtonShowDiff"
			break

		case BUTTON_B:
			ruiVar = "bButtonShowDiff"
			break

		case BUTTON_X:
			ruiVar = ""
			break

		case BUTTON_Y:
			ruiVar = ""
			break

		case BUTTON_TRIGGER_LEFT:
			ruiVar = "leftTriggerShowDiff"
			break

		case BUTTON_TRIGGER_RIGHT:
			ruiVar = "rightTriggerShowDiff"
			break

		case BUTTON_SHOULDER_LEFT:
			ruiVar = "leftBumperShowDiff"
			break

		case BUTTON_SHOULDER_RIGHT:
			ruiVar = "rightBumperShowDiff"
			break

		case BUTTON_DPAD_UP:
			ruiVar = ""
			break

		case BUTTON_DPAD_DOWN:
			ruiVar = ""
			break

		case BUTTON_DPAD_LEFT:
			ruiVar = ""
			break

		case BUTTON_DPAD_RIGHT:
			ruiVar = ""
			break

		case BUTTON_STICK_LEFT:
			ruiVar = "leftStickShowDiff"
			break

		case BUTTON_STICK_RIGHT:
			ruiVar = "rightStickShowDiff"
			break

		case BUTTON_BACK:
			ruiVar = ""
			break

		case BUTTON_START:
			ruiVar = ""
			break

		default:
			Assert( 0 )
			break
	}

	if ( ruiVar != "" )
		RuiSetBool( Hud_GetRui( file.gamepadButtonLayout ), ruiVar, visible )
}

function UpdateButtonLayoutDescription()
{
	string cfg = expect string( uiGlobal.buttonConfigs[ GetGamepadButtonLayout() ][ GetButtonStance() ] )
	string description = ""

	switch ( cfg )
	{
		case "gamepad_button_layout_default.cfg":
		case "gamepad_button_layout_default_southpaw.cfg":
			description = "#BUTTON_LAYOUT_DEFAULT_DESC"
			break

		case "gamepad_button_layout_bumper_jumper.cfg":
			description = "#BUTTON_LAYOUT_BUMPER_JUMPER_DESC"
			break

		case "gamepad_button_layout_bumper_jumper_southpaw.cfg":
			description = "#BUTTON_LAYOUT_BUMPER_JUMPER_SOUTHPAW_DESC"
			break

		case "gamepad_button_layout_bumper_jumper_alt.cfg":
			description = "#BUTTON_LAYOUT_BUMPER_JUMPER_ALT_DESC"
			break

		case "gamepad_button_layout_bumper_jumper_alt_southpaw.cfg":
			description = "#BUTTON_LAYOUT_BUMPER_JUMPER_ALT_SOUTHPAW_DESC"
			break

		case "gamepad_button_layout_pogo_stick.cfg":
			description = "#BUTTON_LAYOUT_POGO_STICK_DESC"
			break

		case "gamepad_button_layout_pogo_stick_southpaw.cfg":
			description = "#BUTTON_LAYOUT_POGO_STICK_SOUTHPAW_DESC"
			break

		case "gamepad_button_layout_button_kicker.cfg":
			description = "#BUTTON_LAYOUT_BUTTON_KICKER_DESC"
			break

		case "gamepad_button_layout_button_kicker_southpaw.cfg":
			description = "#BUTTON_LAYOUT_BUTTON_KICKER_SOUTHPAW_DESC"
			break

		case "gamepad_button_layout_circle.cfg":
			description = "#BUTTON_LAYOUT_CIRCLE_DESC"
			break

		case "gamepad_button_layout_circle_southpaw.cfg":
			description = "#BUTTON_LAYOUT_CIRCLE_SOUTHPAW_DESC"
			break

		default:
			Assert( 0, "Add a hint for the config" )
			break
	}

	RuiSetString( Hud_GetRui( file.description ), "description", description )
}

function UpdateButtonSouthpawDescription()
{
	string description = "#BUTTON_SOUTHPAW_DISABLED_DESC"
	if ( GetConVarInt( "gamepad_buttons_are_southpaw" ) != 0 )
		description = "#BUTTON_SOUTHPAW_ENABLED_DESC"

	RuiSetString( Hud_GetRui( file.description ), "description", description )
}

function UpdateStickLayoutDescription()
{
	string description = ""

	int movementStick = GetConVarInt( "joy_movement_stick" )
	int legacy = GetConVarInt( "joy_legacy" )

	if ( movementStick == 0 )
	{
		if ( legacy == 0 )
			description = "#STICK_LAYOUT_DEFAULT_DESC"
		else
			description = "#STICK_LAYOUT_LEGACY_DESC"
	}
	else
	{
		if ( legacy == 0 )
			description = "#STICK_LAYOUT_SOUTHPAW_DESC"
		else
			description = "#STICK_LAYOUT_LEGACY_SOUTHPAW_DESC"
	}

	RuiSetString( Hud_GetRui( file.description ), "description", description )
}

function UpdateStickDisplay()
{
	table<string, string> stickInfo = GetStickInfo()

	string lx = stickInfo.ANALOG_LEFT_X
	string ly = stickInfo.ANALOG_LEFT_Y
	string rx = stickInfo.ANALOG_RIGHT_X
	string ry = stickInfo.ANALOG_RIGHT_Y

	int stickLayout = 0

	if ( lx == "turn" && ly == "turn" )
		stickLayout = 1
	else if ( lx == "turn" && ly == "move" )
		stickLayout = 2
	else if ( lx == "move" && ly == "turn" )
		stickLayout = 3

	RuiSetInt( Hud_GetRui( file.gamepadButtonLayout ), "stickLayout", stickLayout )
}

ButtonVars function GetBindDisplayName( string bind )
{
	ButtonVars displayName

	switch ( bind )
	{
		case "+zoom":
		case "+toggle_zoom":
			displayName.common = "#AIM_MODIFIER"
			displayName.pilot = ""
			displayName.titan = ""
			break

		case "+attack":
			displayName.common = "#FIRE"
			displayName.pilot = ""
			displayName.titan = ""
			break

		case "+ability 3":
			displayName.common = ""
			displayName.pilot = "#JUMP"
			displayName.titan = "#DASH"
			break

		case "+ability 4":
			displayName.common = ""
			displayName.pilot = "#JUMP"
			displayName.titan = "#TACTICAL_ABILITY"
			break

		case "+ability 5":
			displayName.common = ""
			displayName.pilot = "#TACTICAL_ABILITY"
			displayName.titan = "#DASH"
			break

		case "+ability 6":
			displayName.common = ""
			displayName.pilot = "#ACTIVATE_BOOST"
			displayName.titan = "#ANTI_RODEO_COUNTERMEASURE"
			break

		case "scoreboard_focus":
			displayName.common = ""
			displayName.pilot = ""
			displayName.titan = "#SWITCH_TITAN_LOADOUT"
			break

		case "+toggle_duck":
			displayName.common = "#CROUCH"
			displayName.pilot = ""
			displayName.titan = ""
			break

		case "+useandreload":
			displayName.common = "#USE_RELOAD"
			displayName.pilot = ""
			displayName.titan = "#DISEMBARK_TITAN"
			break

		case "+ability 7":
		case "+weaponcycle":
			displayName.common = ""
			displayName.pilot = "#SWITCH_WEAPONS"
			displayName.titan = "#TITAN_UTILITY"
			break

		case "+offhand0":
			displayName.common = "#ORDNANCE"
			displayName.pilot = ""
			displayName.titan = ""
			break

		case "+offhand1":
			displayName.common = "#TACTICAL_ABILITY"
			displayName.pilot = ""
			displayName.titan = ""
			break

		case "+showscores":
			displayName.common = "#SCOREBOARD"
			displayName.pilot = ""
			displayName.titan = ""
			break

		case "+displayfullscreenmap":
			displayName.common = "#DISPLAY_FULLSCREEN_MINIMAP"
			displayName.pilot = ""
			displayName.titan = ""
			break

		case "ingamemenu_activate":
			displayName.common = "#LOADOUTS_SETTINGS"
			displayName.pilot = ""
			displayName.titan = ""
			break

		case "+speed":
			displayName.common = "#SPRINT"
			displayName.pilot = ""
			displayName.titan = ""
			break

		case "+melee":
			displayName.common = "#MELEE"
			displayName.pilot = ""
			displayName.titan = ""
			break

		case "+scriptcommand1":
			displayName.common = ""
			displayName.pilot = ""
			displayName.titan = "#DISABLE_EJECT_SAFETY_TITAN"
			break

		case "+ability 1":
			displayName.common = ""
			displayName.pilot = "#TITANFALL_TITAN_AI_MODE"
			displayName.titan = "#TITAN_CORE_CONTROLS"
			break

		case "weaponselectordnance":
			displayName.common = "#EQUIP_ANTITITAN_WEAPON_PILOT"
			displayName.pilot = ""
			displayName.titan = ""
			break

		default:
			displayName.common = bind
			displayName.pilot = ""
			displayName.titan = ""
			break
	}

	return displayName
}

ButtonVars function GetButtonRuiVars( int index )
{
	ButtonVars ruiVars

	switch ( index )
	{
		case BUTTON_A:
			ruiVars.common = "aButtonText"
			ruiVars.pilot = "aButtonPilotText"
			ruiVars.titan = "aButtonTitanText"
			break

		case BUTTON_B:
			ruiVars.common = "bButtonText"
			ruiVars.pilot = ""
			ruiVars.titan = ""
			break

		case BUTTON_X:
			ruiVars.common = "xButtonText"
			ruiVars.pilot = ""
			ruiVars.titan = "xButtonTitanText"
			break

		case BUTTON_Y:
			ruiVars.common = "yButtonText"
			ruiVars.pilot = "yButtonPilotText"
			ruiVars.titan = "yButtonTitanText"
			break

		case BUTTON_TRIGGER_LEFT:
			ruiVars.common = "leftTriggerText"
			ruiVars.pilot = ""
			ruiVars.titan = ""
			break

		case BUTTON_TRIGGER_RIGHT:
			ruiVars.common = "rightTriggerText"
			ruiVars.pilot = ""
			ruiVars.titan = ""
			break

		case BUTTON_SHOULDER_LEFT:
			ruiVars.common = "leftBumperText"
			ruiVars.pilot = "leftBumperPilotText"
			ruiVars.titan = "leftBumperTitanText"
			break

		case BUTTON_SHOULDER_RIGHT:
			ruiVars.common = "rightBumperText"
			ruiVars.pilot = "rightBumperPilotText"
			ruiVars.titan = "rightBumperTitanText"
			break

		case BUTTON_DPAD_UP:
			ruiVars.common = ""
			ruiVars.pilot = ""
			ruiVars.titan = "dpadUpTitanText"
			break

		case BUTTON_DPAD_DOWN:
			ruiVars.common = ""
			ruiVars.pilot = "dpadDownPilotText"
			ruiVars.titan = "dpadDownTitanText"
			break

		case BUTTON_DPAD_LEFT:
			ruiVars.common = ""
			ruiVars.pilot = "dpadLeftPilotText"
			ruiVars.titan = "dpadLeftTitanText"
			break

		case BUTTON_DPAD_RIGHT:
			ruiVars.common = ""
			ruiVars.pilot = ""
			ruiVars.titan = "dpadRightTitanText"
			break

		case BUTTON_STICK_LEFT:
			ruiVars.common = "leftStickText"
			ruiVars.pilot = ""
			ruiVars.titan = ""
			break

		case BUTTON_STICK_RIGHT:
			ruiVars.common = "rightStickText"
			ruiVars.pilot = ""
			ruiVars.titan = ""
			break

		case BUTTON_BACK:
			ruiVars.common = ""
			ruiVars.pilot = ""
			ruiVars.titan = ""
			break

		case BUTTON_START:
			ruiVars.common = ""
			ruiVars.pilot = ""
			ruiVars.titan = ""
			break
	}

	return ruiVars
}

table<string, string> function GetStickInfo()
{
	table<string, string> stickInfo
	stickInfo.ANALOG_LEFT_X <- ""
	stickInfo.ANALOG_LEFT_Y <- ""
	stickInfo.ANALOG_RIGHT_X <- ""
	stickInfo.ANALOG_RIGHT_Y <- ""

	int movementStick = GetConVarInt( "joy_movement_stick" )
	int legacy = GetConVarInt( "joy_legacy" )

	if ( movementStick == 0 )
	{
		if ( legacy == 0 )
		{
			stickInfo.ANALOG_LEFT_X = "move"
			stickInfo.ANALOG_LEFT_Y = "move"

			stickInfo.ANALOG_RIGHT_X = "turn"
			stickInfo.ANALOG_RIGHT_Y = "turn"
		}
		else
		{
			stickInfo.ANALOG_LEFT_X = "turn"
			stickInfo.ANALOG_LEFT_Y = "move"

			stickInfo.ANALOG_RIGHT_X = "move"
			stickInfo.ANALOG_RIGHT_Y = "turn"
		}
	}
	else
	{
		if ( legacy == 0 )
		{
			stickInfo.ANALOG_LEFT_X = "turn"
			stickInfo.ANALOG_LEFT_Y = "turn"

			stickInfo.ANALOG_RIGHT_X = "move"
			stickInfo.ANALOG_RIGHT_Y = "move"
		}
		else
		{
			stickInfo.ANALOG_LEFT_X = "move"
			stickInfo.ANALOG_LEFT_Y = "turn"

			stickInfo.ANALOG_RIGHT_X = "turn"
			stickInfo.ANALOG_RIGHT_Y = "move"
		}
	}

	return stickInfo
}
