untyped

global function ClGamemodeMfd_Init

global function SCB_MarkedChanged

global function MFDChanged

global function MarkedForDeathHudThink


void function ClGamemodeMfd_Init()
{
	RegisterSignal( "UpdateMFDVGUI" )

	level.teamFlags <- {}
	level.teamFlags[TEAM_IMC] <- null
	level.teamFlags[TEAM_MILITIA] <- null

	level.overheadIconShouldPing <- false
	RegisterServerVarChangeCallback( "mfdOverheadPingDelay", mfdOverheadPingDelay_Changed )

	RegisterSignal( "MFDChanged" )
	RegisterSignal( "TargetUnmarked"  )
	RegisterSignal( "PingEnemyFlag" )

	AddPlayerFunc( MarkedForDeath_AddPlayer )

	AddCreateCallback( MARKER_ENT_CLASSNAME, OnMarkedCreated )
	AddPermanentEventNotification( ePermanentEventNotifications.MFD_YouAreTheMark, "#MARKED_FOR_DEATH_YOU_ARE_MARKED_REMINDER" )
}


void function mfdOverheadPingDelay_Changed()
{
	level.overheadIconShouldPing = level.nv.mfdOverheadPingDelay != 0 ? true : false
}


function SCB_MarkedChanged()
{
	//printt( "SCB_MarkedChanged" )
	thread MFDChanged()
}

void function OnMarkedCreated( entity ent )
{
	FillMFDMarkers( ent )
}

function MFDChanged()
{
	//PrintFunc()
	clGlobal.levelEnt.Signal( "MFDChanged" ) //Only want this called once per frame
	clGlobal.levelEnt.EndSignal( "MFDChanged" )
	FlagWait( "ClientInitComplete" )
	WaitEndFrame() //Necessary to get MFD effect to play upon spawning
	//printt( "Done waiting for MFD Changed" )
	entity player = GetLocalViewPlayer()

	int team = player.GetTeam()
	int enemyTeam = GetOtherTeam( team )

	entity friendlyMarked = GetMarked( team )
	entity enemyMarked = GetMarked( enemyTeam )

	entity pendingFriendlyMarked = GetPendingMarked( team )
	entity pendingEnemyMarked = GetPendingMarked( enemyTeam )

	if ( player == friendlyMarked )
	{
		//printt( "Player is friendly marked" )
		if ( !IsWatchingReplay() )
		{
			entity cockpit = player.GetCockpit()

			if ( !cockpit )
				return

		 	StartParticleEffectOnEntity( cockpit, GetParticleSystemIndex( $"P_MFD" ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
		 	EmitSoundOnEntity( player, "UI_InGame_MarkedForDeath_PlayerMarked"  )
		 	thread PlayMarkedForDeathMusic( player )
		 	thread DelayPlayingUnmarkedEffect( player )

		 	HideEventNotification()
			AnnouncementData announcement = Announcement_Create( "#MARKED_FOR_DEATH_YOU_ARE_MARKED_ANNOUNCEMENT" )
			Announcement_SetSubText( announcement, "#MARKED_FOR_DEATH_STAY_ALIVE" )
			Announcement_SetPurge( announcement, true )
			Announcement_SetDuration( announcement, 4.5 )
			AnnouncementFromClass( player, announcement )
		}
	}
	else
	{
		if ( !IsWatchingReplay() )
		{
			if ( IsAlive( friendlyMarked ) && IsAlive( enemyMarked ) )
				SetTimedEventNotification( 6.0, "#MARKED_FOR_DEATH_ARE_MARKED", GetMarkedName( friendlyMarked), GetMarkedName( enemyMarked ) )
		}
	}

	if ( IsAlive( friendlyMarked ) )
	{
		if ( friendlyMarked != player )
		{
			player.hudElems.FriendlyFlagIcon.Show()
			player.hudElems.FriendlyFlagLabel.Show()
			player.hudElems.FriendlyFlagLabel.SetText( "#MARKED_FOR_DEATH_GUARD_PLAYER", GetMarkedName( friendlyMarked ) )
			player.hudElems.FriendlyFlagIcon.SetImage( $"vgui/HUD/mfd_friendly" )
			player.hudElems.FriendlyFlagIcon.SetEntityOverhead( friendlyMarked, Vector( 0, 0, 0 ), 0.5, 1.25 )
		}
		else
		{
			player.hudElems.FriendlyFlagIcon.Hide()
			player.hudElems.FriendlyFlagLabel.Hide()
		}
	}
	else if ( IsAlive( pendingFriendlyMarked ) )
	{
		if ( pendingFriendlyMarked != player )
		{
			player.hudElems.FriendlyFlagIcon.Show()
			player.hudElems.FriendlyFlagLabel.Show()
			player.hudElems.FriendlyFlagLabel.SetText( "#MARKED_FOR_DEATH_GUARD_PLAYER", GetMarkedName( pendingFriendlyMarked ) )
			player.hudElems.FriendlyFlagIcon.SetImage( $"vgui/HUD/mfd_pre_friendly" )
			player.hudElems.FriendlyFlagIcon.SetEntityOverhead( pendingFriendlyMarked, Vector( 0, 0, 0 ), 0.5, 1.25 )
		}
		else
		{
			player.hudElems.FriendlyFlagIcon.Hide()
			player.hudElems.FriendlyFlagLabel.Hide()
		}
	}
	else
	{
		player.Signal( "TargetUnmarked" )
		player.hudElems.FriendlyFlagIcon.Hide()
		player.hudElems.FriendlyFlagLabel.Hide()
	}

	if ( IsAlive( enemyMarked ) )
	{
		player.hudElems.EnemyFlagIcon.Show()
		if ( level.overheadIconShouldPing )
		{
			player.hudElems.EnemyFlagPingIcon.Show()
			player.hudElems.EnemyFlagPing2Icon.Show()
		}
		player.hudElems.EnemyFlagLabel.Show()
		player.hudElems.EnemyFlagLabel.SetText( "#MARKED_FOR_DEATH_KILL_PLAYER", GetMarkedName( enemyMarked ) )
		player.hudElems.EnemyFlagIcon.SetImage( $"vgui/HUD/mfd_enemy" )

		player.hudElems.EnemyFlagIcon.SetEntityOverhead( enemyMarked, Vector( 0, 0, 0 ), 0.5, 1.25 )
		if ( level.overheadIconShouldPing )
			thread PingEnemyFlag( player, enemyMarked )
	}
	else
	{
		player.Signal( "TargetUnmarked" )
		player.hudElems.EnemyFlagIcon.Hide()
		if ( level.overheadIconShouldPing )
		{
			player.hudElems.EnemyFlagPingIcon.Hide()
			player.hudElems.EnemyFlagPing2Icon.Hide()
		}
		player.hudElems.EnemyFlagLabel.Hide()
	}

	if ( !GamePlaying() )
		HideEventNotification()

	//UpdateMFDVGUI regardless
	UpdateMFDVGUI()
}

function PingEnemyFlag( player, enemyMarked )
{
	expect entity( player )
	expect entity( enemyMarked )

	enemyMarked.EndSignal( "OnDeath" )
	enemyMarked.EndSignal( "OnDestroy" )
	player.EndSignal( "TargetUnmarked" )

	player.Signal( "PingEnemyFlag" )
	player.EndSignal( "PingEnemyFlag" )

	const MFD_DISPLAY_FRACS = 5.0
	local delayFrac = level.nv.mfdOverheadPingDelay / MFD_DISPLAY_FRACS

	while ( IsAlive( enemyMarked ) )
	{
		local centerPoint = enemyMarked.GetWorldSpaceCenter()
		local origin = enemyMarked.GetOrigin()

		player.hudElems.EnemyFlagIcon.SetAlpha( 255 )
		if ( level.overheadIconShouldPing )
		{
			player.hudElems.EnemyFlagPingIcon.SetAlpha( 255 )
			player.hudElems.EnemyFlagPingIcon.SetScale( 0.5, 0.5 )
			player.hudElems.EnemyFlagPingIcon.ScaleOverTime( 1.45, 1.45, delayFrac, INTERPOLATOR_DEACCEL )
			player.hudElems.EnemyFlagPingIcon.SetColor( 255, 229, 215, 190 )
			player.hudElems.EnemyFlagPingIcon.ColorOverTime( 255, 177, 134, 0, delayFrac, INTERPOLATOR_ACCEL )
		}
		player.hudElems.EnemyFlagLabel.SetAlpha( 255 )

		wait delayFrac * 0.25

		if ( level.overheadIconShouldPing )
		{
			player.hudElems.EnemyFlagPing2Icon.SetAlpha( 175 )
			player.hudElems.EnemyFlagPing2Icon.SetScale( 0.5, 0.5 )
			player.hudElems.EnemyFlagPing2Icon.ScaleOverTime( 1.15, 1.15, delayFrac, INTERPOLATOR_DEACCEL )
			player.hudElems.EnemyFlagPing2Icon.SetColor( 255, 229, 215, 190 )
			player.hudElems.EnemyFlagPing2Icon.ColorOverTime( 255, 177, 134, 0, delayFrac, INTERPOLATOR_ACCEL )
		}

		wait delayFrac * 0.75

		player.hudElems.EnemyFlagIcon.FadeOverTime( 0, delayFrac, INTERPOLATOR_DEACCEL )
		player.hudElems.EnemyFlagLabel.FadeOverTime( 0, delayFrac, INTERPOLATOR_DEACCEL )
		wait delayFrac * (MFD_DISPLAY_FRACS - delayFrac)
	}
}


function UpdateMFDVGUI()
{
	clGlobal.levelEnt.Signal( "UpdateMFDVGUI" )
}

void function MarkedForDeath_AddPlayer( entity player )
{
	if ( IsMenuLevel() )
		return

	player.InitHudElem( "FriendlyFlagIcon" )
	player.InitHudElem( "EnemyFlagIcon" )
	player.InitHudElem( "EnemyFlagPingIcon" )
	player.InitHudElem( "EnemyFlagPing2Icon" )

	player.InitHudElem( "FriendlyFlagLabel" )
	player.InitHudElem( "EnemyFlagLabel" )

	player.hudElems.FriendlyFlagIcon.SetClampToScreen( CLAMP_RECT )
	player.hudElems.FriendlyFlagIcon.SetClampBounds( CL_HIGHLIGHT_ICON_X, CL_HIGHLIGHT_ICON_Y )

	player.hudElems.EnemyFlagIcon.SetClampToScreen( CLAMP_RECT )
	player.hudElems.EnemyFlagIcon.SetClampBounds( CL_HIGHLIGHT_ICON_X, CL_HIGHLIGHT_ICON_Y )

	if ( level.overheadIconShouldPing )
	{
		player.hudElems.EnemyFlagPingIcon.SetClampToScreen( CLAMP_RECT )
		player.hudElems.EnemyFlagPingIcon.SetClampBounds( CL_HIGHLIGHT_ICON_X, CL_HIGHLIGHT_ICON_Y )
	}

	player.hudElems.EnemyFlagPing2Icon.SetClampToScreen( CLAMP_RECT )
	player.hudElems.EnemyFlagPing2Icon.SetClampBounds( CL_HIGHLIGHT_ICON_X, CL_HIGHLIGHT_ICON_Y )

	player.hudElems.FriendlyFlagLabel.SetClampToScreen( CLAMP_RECT )
	player.hudElems.FriendlyFlagLabel.SetClampBounds( CL_HIGHLIGHT_LABEL_X, CL_HIGHLIGHT_LABEL_Y )

	player.hudElems.EnemyFlagLabel.SetClampToScreen( CLAMP_RECT )
	player.hudElems.EnemyFlagLabel.SetClampBounds( CL_HIGHLIGHT_LABEL_X, CL_HIGHLIGHT_LABEL_Y )

	player.hudElems.FriendlyFlagLabel.SetText( "#GAMEMODE_FLAG_GUARD" )
	player.hudElems.EnemyFlagLabel.SetText( "#GAMEMODE_FLAG_ATTACK" )

	thread MFDChanged()
}

function MarkedForDeathHudThink( vgui, entity player, scoreGroup )
{
	vgui.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDestroy" )

	local panel = vgui.GetPanel()
	local flags = {}
	local flagLabels = {}

	int team = player.GetTeam()
	if ( team == TEAM_UNASSIGNED )
		return

	int otherTeam = GetOtherTeam( team )
	flags[ team ] <- scoreGroup.CreateElement( "MFDFriendlyMark", panel )
	flagLabels[ team ] <- scoreGroup.CreateElement( "FriendlyFlagLabel", panel )
	flags[ otherTeam ] <- scoreGroup.CreateElement( "MFDEnemyMark", panel )
	flagLabels[ otherTeam ] <- scoreGroup.CreateElement( "EnemyFlagLabel", panel )

	array<int> teams
	teams.append( TEAM_IMC )
	teams.append( TEAM_MILITIA )

	for ( ;; )
	{
		foreach ( team in teams )
		{
			entity marked = GetMarked( team )
			local label = flagLabels[team]
			local flag = flags[team]

			if ( !IsAlive( marked ) )
			{
				label.Hide()
				flag.Hide()
				continue
			}

			label.SetText( "#GAMEMODE_JUST_THE_SCORE", GetMarkedName( marked ) )

			label.Show()
			flag.Show()
		}

		clGlobal.levelEnt.WaitSignal( "UpdateMFDVGUI" )

		WaitEndFrame() // not sure if this is nec
	}
}

function PlayMarkedForDeathMusic( player ) //Long term should look into API-ing some of this so it isn't hard for game modes to play their own music
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "TargetUnmarked" )

	if ( GetMusicReducedSetting() )
		return

	OnThreadEnd(
		function() : (  )
		{
			StopLoopMusic()
			PlayActionMusic()
		}
	)

	waitthread ForceLoopMusic( eMusicPieceID.GAMEMODE_1 ) 	//Is looping music, so doesn't return from this until the end signals kick in
}

function DelayPlayingUnmarkedEffect( entity player )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )

	player.WaitSignal( "TargetUnmarked" )

	if ( !IsAlive( player ) )
		return

	entity cockpit = player.GetCockpit()

	if ( !cockpit )
		return

 	StartParticleEffectOnEntity( cockpit, GetParticleSystemIndex( $"P_MFD_unmark" ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
}

string function GetMarkedName( entity marked )
{
	return marked.IsNPC() ? "Titan(" + marked.GetBossPlayerName() + ")" : marked.GetPlayerName()
}