untyped

global function ClControlPanel_Init

global function ServerCallback_ControlPanelRefresh
global function CreateCallback_Panel
global function DestroyCallback_PanelTarget
global function RegisterWithPanel
global function VGUIUpdateGeneric
global function VGUISetupGeneric
global function Create_Display
global function AddPanelUpdateCallback


const HEAVY_TURRET_HEALTH_STR = "Health: %d%%"
const HEAVY_TURRET_REPAIR_STR = "Progress: %d%%"
const HEAVY_TURRET_REBOOT_STR = "Some indicator"

function ClControlPanel_Init()
{
	PrecacheParticleSystem( $"panel_light_blue" )
	PrecacheParticleSystem( $"panel_light_red" )
	PrecacheParticleSystem( $"runway_light_orange" )

	AddCreateCallback( "prop_control_panel", CreateCallback_Panel )
	AddDestroyCallback( "prop_control_panel", DestroyCallback_Panel )
}

function AddPanelUpdateCallback( panel, func )
{
	if ( !( "updateCallbacks" in panel.s ) )
		panel.s.updateCallbacks <- []
	panel.s.updateCallbacks.append( func )
}

function ServerCallback_ControlPanelRefresh( panelEHandle )
{
	entity panel = GetEntityFromEncodedEHandle( panelEHandle )
	if ( !IsValid( panel ) )
		return

	ControlPanelRefresh( panel )
}

void function CreateCallback_Panel( entity panel )
{
	if ( panel.GetModelName() != $"models/communication/terminal_usable_imc_01.mdl" )
		return

	ControlPanelInit( panel )
	Create_Display( panel )

	ControlPanelRefresh( panel )
}

void function DestroyCallback_Panel( entity panel )
{
	if ( panel.GetModelName() != $"models/communication/terminal_usable_imc_01.mdl" )
		return

	if ( "HudVGUI" in panel.s && panel.s.HudVGUI )
	{
		panel.s.HudVGUI.Destroy()
		panel.s.HudVGUI = null
	}

    if ( "particleEffect" in panel.s && panel.s.particleEffect != null && EffectDoesExist( panel.s.particleEffect ) )
    	EffectStop( panel.s.particleEffect, true, false )
}

function ControlPanelInit( entity panel )
{
	panel.s.initiated <- true
	panel.s.HudVGUI <- null
	panel.s.VGUIFunc <- VGUIUpdateGeneric
	panel.s.VGUISetupFunc <- VGUISetupGeneric
	panel.s.targetArray <- []
	panel.s.resfile <- "control_panel_generic_screen"
	panel.s.particleEffect <- null
	panel.s.particleFlashingBlueToPlayer <- false

	if ( !( "updateCallbacks" in panel.s ) )
		panel.s.updateCallbacks <- []

	AddAnimEvent( panel, "create_dataknife", CreateFirstPersonDataKnife )
	AddAnimEvent( panel, "knife_popout", DataKnifePopsOpen )

	panel.useFunction = ControlPanel_CanUseFunction

	int flags = panel.GetScriptPropFlags()
	if ( flags & 0x01 )
	{
		panel.s.VGUIFunc = VGUIUpdateForRemoteTurret
		panel.s.VGUISetupFunc <- VGUISetupForRemoteTurret
	}
}

function RegisterWithPanel( ent )
{
	//printt( "RegisterWithPanel", ent.GetTargetName() )
	ent.EndSignal( "OnDestroy" )
	local panel = ent.GetControlPanel()

	Assert( IsValid( panel ) )
	Assert( "initiated" in panel.s )
	/*while ( !IsValid( panel ) || !( "initiated" in panel.s ) ) //Need to wait till panel has finished initializing
	{
		panel = turret.GetControlPanel() //Don't think is actually necessary, but better safe than sorry...
		WaitFrame()
	}*/

	if ( !panel.s.targetArray.contains( ent ) )
		panel.s.targetArray.append( ent )

	Create_Display( panel )

	ControlPanelRefresh( panel )
}

void function DestroyCallback_PanelTarget( entity ent )
{
	if ( ent.GetControlPanel() == null )
		return

	local panel = ent.GetControlPanel()
	if ( !IsValid( panel ) )
		return

	foreach ( index, targetEnt in clone panel.s.targetArray )
	{
		if ( ent == targetEnt )
		{
			panel.s.targetArray.remove( index )
			break
		}
	}
}

function ControlPanelRefresh( panel )
{
	if ( !IsValid( panel ) )
		return

	foreach ( func in panel.s.updateCallbacks )
	{
		func( panel )
	}

	if ( CanUpdateVGUI( panel ) )
	{
		panel.s.VGUIFunc( panel )	// Update the panel vgui screen to match the state of the target(s)
		UpdateParticleSystem( panel )
	}
}

function CanUpdateVGUI( panel )
{
	if ( panel.s.VGUIFunc == null )
		return false

	if ( panel.s.HudVGUI == null )
		return false

	// if ( panel.s.targetArray.len() == 0 )
	// 	return false

	return true
}

function Create_Display( panel )
{
	if ( panel.s.HudVGUI )
	{
		panel.s.HudVGUI.Destroy()
		panel.s.HudVGUI = null
	}

	entity player = GetLocalViewPlayer()

	local bottomLeftID = panel.LookupAttachment( "PANEL_SCREEN_BL" )
	local topRightID = panel.LookupAttachment( "PANEL_SCREEN_TR" )

	local size = ComputeSizeForAttachments( panel, bottomLeftID, topRightID, false )

	local origin = panel.GetAttachmentOrigin( bottomLeftID )
	local angles = panel.GetAttachmentAngles( bottomLeftID )

	// push the origin "out" slightly, since the tags are coplanar with the geo
	origin += AnglesToUp( angles ) * 0.05

	//panel.s.HudVGUI = CreateClientsideVGuiScreen( panel.s.resfile, VGUI_SCREEN_PASS_WORLD, origin, angles, size[0], size[1] );
	//panel.s.HudVGUI.s.panel <- panel.s.HudVGUI.GetPanel() // This is a different panel than the Control Panel
	//panel.s.HudVGUI.SetParent( panel, "PANEL_SCREEN_BL" )

	//panel.s.VGUISetupFunc( panel )
}

function VGUIUpdateSpectre( panel )
{
	local stateElement = panel.s.HudVGUI.s.state
	local controlledItem = panel.s.HudVGUI.s.controlledItem
	controlledItem.SetText( "Spectre Drop" )
	stateElement.SetText( "[READY]" )

	// alternate on and off
	local show = ( ( Time() * 4 ).tointeger() % 2 )
	if ( show )
		stateElement.Show()
	else
		stateElement.Hide()
}

function VGUISetupGeneric( panel )
{
	expect entity( panel )
	panel.s.HudVGUI.s.state <- HudElement( "State", panel.s.HudVGUI.s.panel )
	panel.s.HudVGUI.s.controlledItem <- HudElement( "ControlledItem", panel.s.HudVGUI.s.panel )
}

function VGUIUpdateGeneric( panel )
{
	expect entity( panel )
	local state = panel.s.HudVGUI.s.state

	// alternate on and off
	local show = ( Time().tointeger() % 2 )
	if ( show )
		state.Show()
	else
		state.Hide()

	local stateElement = panel.s.HudVGUI.s.state
	stateElement.SetText( "#CONTROL_PANEL_ENABLED" )
}

function VGUISetupForRemoteTurret( panel )
{
	expect entity( panel )

	VGUISetupGeneric( panel )
	VGUIUpdateForRemoteTurret( panel )
}

function VGUIUpdateForRemoteTurret( panel )
{
	expect entity( panel )

	var topLine = panel.s.HudVGUI.s.controlledItem
	var bottomLine = panel.s.HudVGUI.s.state

	int flags = panel.GetScriptPropFlags()
	if ( flags & 0x10 )
	{
		topLine.SetText( "Rebooting..." )
		bottomLine.SetText( "[ TURRET DAMAGED ]" )
		bottomLine.SetColor( 255, 100, 100, 255 )
	}
	else
	{
		topLine.SetText( "Link ready..." )
		topLine.SetColor( 130, 130, 155, 255 )
		bottomLine.SetText( "[ REMOTE TURRET ]" )
		bottomLine.SetColor( 255, 255, 128, 255 )
	}

}

function UpdateParticleSystem( panel )
{
	expect entity( panel )

	bool playerSameTeamAsPanel = ( GetLocalViewPlayer().GetTeam() == panel.GetTeam() )

	if ( panel.s.particleEffect != null )
	{
		// Return if don't need to update panel particle effect
		if ( playerSameTeamAsPanel && panel.s.particleFlashingBlueToPlayer )
			return

		if ( !playerSameTeamAsPanel && !panel.s.particleFlashingBlueToPlayer )
			return

		// We need to change the effect of the panel now, so stop existing one
		if ( EffectDoesExist( panel.s.particleEffect ) )
			EffectStop( panel.s.particleEffect, true, false )
	}

	int tagID = panel.LookupAttachment( "glow1" )

	int fxID
	if ( playerSameTeamAsPanel )
		fxID = GetParticleSystemIndex( $"panel_light_blue" )
	else
		fxID = GetParticleSystemIndex( $"panel_light_red" )

	panel.s.particleEffect = PlayFXOnTag( panel, fxID, tagID )

	panel.s.particleFlashingBlueToPlayer = playerSameTeamAsPanel
}