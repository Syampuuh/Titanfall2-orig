untyped


global function MenuLobby_Init

global function InitLobbyMenu
//global function PrivateMatchSwitchTeams
global function UICodeCallback_SetupPlayerListGenElements
global function UpdateAnnouncementDialog
global function DisableButton

global function LeaveParty
global function LeaveMatchAndParty

global function SCB_RefreshLobby

global function CoopMatchButton_Activate

global function UICodeCallback_CommunityUpdated
global function UICodeCallback_FactionUpdated
global function Lobby_UpdateInboxButtons

global function UpdateNetworksMoreButton
global function GetTimeToRestartMatchMaking
global function UpdateTimeToRestartMatchmaking

global function RefreshCreditsAvailable
global function SetUIPlayerCreditsInfo

global function InviteFriendsIfAllowed
global function StartPrivateMatch
global function SetPutPlayerInMatchmakingAfterDelay

struct
{
	struct {
		string playlistName = ""
		int mapIdx = -1
		int modeIdx = -1
	} preCacheInfo

	array searchIconElems
	array searchTextElems
	array matchStartCountdownElems
	array matchStatusRuis

	array MMDevStringElems

	array myTeamLogoElems
	array myTeamNameElems
	array enemyTeamLogoElems
	array enemyTeamNameElems
	array creditsAvailableElems
	array teamSlotBackgrounds
	array teamSlotBackgroundsNeutral

	var enemyTeamBackgroundPanel
	var friendlyTeamBackgroundPanel
	var enemyTeamBackground
	var friendlyTeamBackground
	var enemyPlayers
	var friendlyPlayers
	var chatroomMenu
	var chatroomMenu_chatroomWidget
	var firstNetworkSubButton

	var nextMapNameLabel
	var nextGameModeLabel

	var findGameButton
	var inviteRoomButton
	var inviteFriendsButton

	var networksMoreButton

	int inboxHeaderIndex
	var inboxButton

	int customizeHeaderIndex
	var pilotButton
	var titanButton
	var boostsButton
	var factionButton
	var bannerButton
	var patchButton
	var networksHeader

	var genUpButton

//	var armoryButton

	array<var> lobbyButtons
	var playHeader
	var customizeHeader
	var callsignHeader

	float timeToRestartMatchMaking = 0

	var callsignCard

	bool putPlayerInMatchmakingAfterDelay = false

} file

struct
{
	var startButton
	var mapButton
	var modeButton

	var enemiesPanel
	var friendliesPanel
} privateMatch

void function MenuLobby_Init()
{
	PrecacheHUDMaterial( $"ui/menu/common/menu_background_neutral" )
	PrecacheHUDMaterial( $"ui/menu/common/menu_background_imc" )
	PrecacheHUDMaterial( $"ui/menu/common/menu_background_militia" )
	PrecacheHUDMaterial( $"ui/menu/common/menu_background_imc_blur" )
	PrecacheHUDMaterial( $"ui/menu/common/menu_background_militia_blur" )
	PrecacheHUDMaterial( $"ui/menu/common/menu_background_neutral_blur" )
	PrecacheHUDMaterial( $"ui/menu/common/menu_background_blackMarket" )
	PrecacheHUDMaterial( $"ui/menu/rank_menus/ranked_FE_background" )

	PrecacheHUDMaterial( $"ui/menu/lobby/friendly_slot" )
	PrecacheHUDMaterial( $"ui/menu/lobby/friendly_player" )
	PrecacheHUDMaterial( $"ui/menu/lobby/enemy_slot" )
	PrecacheHUDMaterial( $"ui/menu/lobby/enemy_player" )
	PrecacheHUDMaterial( $"ui/menu/lobby/neutral_slot" )
	PrecacheHUDMaterial( $"ui/menu/lobby/neutral_player" )
	PrecacheHUDMaterial( $"ui/menu/lobby/player_hover" )
	PrecacheHUDMaterial( $"ui/menu/lobby/chatroom_player" )
	PrecacheHUDMaterial( $"ui/menu/lobby/chatroom_hover" )
	PrecacheHUDMaterial( $"ui/menu/main_menu/motd_background" )
	PrecacheHUDMaterial( $"ui/menu/main_menu/motd_background_happyhour" )

	AddUICallback_OnLevelInit( OnLobbyLevelInit )
}


bool function ChatroomIsVisibleAndFocused()
{
	return Hud_IsVisible( file.chatroomMenu ) && Hud_IsFocused( file.chatroomMenu_chatroomWidget );
}

bool function ChatroomIsVisibleAndNotFocused()
{
	return Hud_IsVisible( file.chatroomMenu ) && !Hud_IsFocused( file.chatroomMenu_chatroomWidget );
}

void function Lobby_UpdateInboxButtons()
{
	var menu = GetMenu( "LobbyMenu" )
	if ( GetUIPlayer() == null || !IsPersistenceAvailable() )
		return

	//if ( Inbox_GetTotalMessageCount() == 0 )
	//{
	//	SetComboButtonHeaderTitle( menu, file.inboxHeaderIndex, Localize( "#MENU_HEADER_NETWORKS" )  )
	//	ComboButton_SetText( file.inboxButton, Localize( "#MENU_TITLE_READ" ) )
	//	Hud_SetLocked( file.inboxButton, true )
	//}
	//else if ( Inbox_HasUnreadMessages() )
	//{
	//	int messageCount = Inbox_GetTotalMessageCount()
	//	SetComboButtonHeaderTitle( menu, file.inboxHeaderIndex, Localize( "#MENU_HEADER_NETWORKS_NEW_MSGS", messageCount )  )
	//	ComboButton_SetText( file.inboxButton, Localize( "#MENU_TITLE_INBOX_NEW_MSGS", messageCount ) )
	//	Hud_SetLocked( file.inboxButton, false )
	//}
	//else
	//{
	//	SetComboButtonHeaderTitle( menu, file.inboxHeaderIndex, Localize( "#MENU_HEADER_NETWORKS" )  )
	//	ComboButton_SetText( file.inboxButton, Localize( "#MENU_TITLE_READ" ) )
	//	Hud_SetLocked( file.inboxButton, true )
	//}

	bool hasNewMail = (Inbox_HasUnreadMessages() && Inbox_GetTotalMessageCount() > 0) || PlayerRandomUnlock_GetTotal( GetUIPlayer() ) > 0
	if ( hasNewMail )
	{
		int messageCount = Inbox_GetTotalMessageCount()
		int lootCount = PlayerRandomUnlock_GetTotal( GetUIPlayer() )
		int totalCount = messageCount + lootCount

		string countString
		if ( totalCount >= MAX_MAIL_COUNT )
			countString = MAX_MAIL_COUNT + "+"
		else
			countString = string( totalCount )

		SetComboButtonHeaderTitle( menu, file.inboxHeaderIndex, Localize( "#MENU_HEADER_NETWORKS_NEW_MSGS", countString )  )
		ComboButton_SetText( file.inboxButton, Localize( "#MENU_TITLE_INBOX_NEW_MSGS", countString ) )
	}
	else
	{
		SetComboButtonHeaderTitle( menu, file.inboxHeaderIndex, Localize( "#MENU_HEADER_COMMS" )  )
		ComboButton_SetText( file.inboxButton, Localize( "#MENU_TITLE_READ" ) )
	}

	ComboButton_SetNewMail( file.inboxButton, hasNewMail )
}

void function InitLobbyMenu()
{
	var menu = GetMenu( "LobbyMenu" )

	InitOpenInvitesMenu()

	//AddMenuFooterOption( menu, BUTTON_A, profileText, "#MOUSE1_VIEW_PROFILE", null, IsPlayerListFocused ) // Mismatched input for mouse, but ok with null activateFunc.
	AddMenuFooterOption( menu, BUTTON_A, "#A_BUTTON_SELECT", "", null, ChatroomIsVisibleAndNotFocused )
	AddMenuFooterOption( menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
	//AddMenuFooterOption( menu, BUTTON_X, "#X_BUTTON_MUTE", "#MOUSE2_MUTE", null, IsPlayerListFocused ) // Mismatched input for mouse, but ok with null activateFunc.
	AddMenuFooterOption( menu, BUTTON_BACK, "#BACK_BUTTON_POSTGAME_REPORT", "#POSTGAME_REPORT", OpenPostGameMenu, IsPostGameMenuValid )
	AddMenuFooterOption( menu, BUTTON_TRIGGER_RIGHT, "#R_TRIGGER_CHAT", "", null, IsVoiceChatPushToTalk )

	InitChatroom( menu )

	file.chatroomMenu = Hud_GetChild( menu, "ChatRoomPanel" )
	file.chatroomMenu_chatroomWidget = Hud_GetChild( file.chatroomMenu, "ChatRoom" )
	file.genUpButton = Hud_GetChild( menu, "GenUpButton" )

	SetupComboButtonTest( menu )

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnLobbyMenu_Open )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, OnLobbyMenu_Close )
	AddMenuEventHandler( menu, eUIEvent.MENU_NAVIGATE_BACK, OnLobbyMenu_NavigateBack )

	//AddEventHandlerToButton( menu, "PilotLoadoutsButton", UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "PilotLoadoutsMenu" ) ) )
	//AddEventHandlerToButton( menu, "TitanLoadoutsButton", UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "TitanLoadoutsMenu" ) ) )

	AddEventHandlerToButton( menu, "StartMatchButton", UIE_CLICK, OnStartMatchButton_Activate )
	AddEventHandlerToButton( menu, "StartMatchButton", UIE_GET_FOCUS, OnStartMatchButton_GetFocus )
	AddEventHandlerToButton( menu, "StartMatchButton", UIE_LOSE_FOCUS, OnStartMatchButton_LoseFocus )

	AddEventHandlerToButton( menu, "MapsButton", UIE_CLICK, OnMapsButton_Activate )
	AddEventHandlerToButton( menu, "ModesButton", UIE_CLICK, OnModesButton_Activate )
	AddEventHandlerToButton( menu, "OldSettingsButton", UIE_CLICK, OnSettingsButton_Activate )

	//AddEventHandlerToButton( menu, "CommunityButton", UIE_CLICK, OnCommunityButton_Activate )

	RegisterUIVarChangeCallback( "badRepPresent", UpdateLobbyBadRepPresentMessage )

	RegisterUIVarChangeCallback( "nextMapModeSet", NextMapModeSet_Changed )
	RegisterUIVarChangeCallback( "gameStartTime", GameStartTime_Changed )

	RegisterUIVarChangeCallback( "showGameSummary", ShowGameSummary_Changed )

	RegisterUIVarChangeCallback( "putPlayerInMatchmakingAfterDelay", PutPlayerInMatchmakingAfterDelay_Changed )

	file.searchIconElems = GetElementsByClassnameForMenus( "SearchIconClass", uiGlobal.allMenus )
	file.searchTextElems = GetElementsByClassnameForMenus( "SearchTextClass", uiGlobal.allMenus )
	file.matchStartCountdownElems = GetElementsByClassnameForMenus( "MatchStartCountdownClass", uiGlobal.allMenus )
	file.matchStatusRuis = GetElementsByClassnameForMenus( "MatchmakingStatusRui", uiGlobal.allMenus )
	file.MMDevStringElems = GetElementsByClassnameForMenus( "MMDevStringClass", uiGlobal.allMenus )
	file.myTeamLogoElems = GetElementsByClassnameForMenus( "MyTeamLogoClass", uiGlobal.allMenus )
	file.myTeamNameElems = GetElementsByClassnameForMenus( "MyTeamNameClass", uiGlobal.allMenus )
	file.enemyTeamLogoElems = GetElementsByClassnameForMenus( "EnemyTeamLogoClass", uiGlobal.allMenus )
	file.enemyTeamNameElems = GetElementsByClassnameForMenus( "EnemyTeamNameClass", uiGlobal.allMenus )
	file.creditsAvailableElems = GetElementsByClassnameForMenus( "CreditsAvailableClass", uiGlobal.allMenus )

	file.enemyPlayers = Hud_GetChild( menu, "MatchEnemiesPanel" )
	file.friendlyPlayers = Hud_GetChild( menu, "MatchFriendliesPanel" )

	file.enemyTeamBackgroundPanel = Hud_GetChild( file.enemyPlayers, "LobbyEnemyTeamBackground" )
	file.friendlyTeamBackgroundPanel = Hud_GetChild( file.friendlyPlayers, "LobbyFriendlyTeamBackground" )

	file.enemyTeamBackground = Hud_GetChild( file.enemyTeamBackgroundPanel, "TeamBackground" )
	file.friendlyTeamBackground = Hud_GetChild( file.friendlyTeamBackgroundPanel, "TeamBackground" )

	file.teamSlotBackgrounds = GetElementsByClassnameForMenus( "LobbyTeamSlotBackgroundClass", uiGlobal.allMenus )
	file.teamSlotBackgroundsNeutral = GetElementsByClassnameForMenus( "LobbyTeamSlotBackgroundNeutralClass", uiGlobal.allMenus )

	file.nextMapNameLabel = Hud_GetChild( menu, "NextMapName" )
	file.nextGameModeLabel = Hud_GetChild( menu, "NextGameModeName" )

	file.firstNetworkSubButton = Hud_GetChild( GetMenu( "CommunitiesMenu" ), "BtnBrowse" )

	file.callsignCard = Hud_GetChild( menu, "CallsignCard" )

	AddEventHandlerToButton( menu, "GenUpButton", UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "Generation_Respawn" ) ) )

	/*#if DURANGO_PROG
		string profileText = "#A_BUTTON_VIEW_GAMERCARD"
	#else
		string profileText = "#A_BUTTON_VIEW_PROFILE"
	#endif*/


	AddMenuVarChangeHandler( "focus", UpdateFooterOptions )
	AddMenuVarChangeHandler( "isFullyConnected", UpdateFooterOptions )
	AddMenuVarChangeHandler( "isPartyLeader", UpdateFooterOptions )
	AddMenuVarChangeHandler( "isPrivateMatch", UpdateFooterOptions )
	#if DURANGO_PROG
		AddMenuVarChangeHandler( "DURANGO_canInviteFriends", UpdateFooterOptions )
		AddMenuVarChangeHandler( "DURANGO_isJoinable", UpdateFooterOptions )
		AddMenuVarChangeHandler( "DURANGO_isGameFullyInstalled", UpdateFooterOptions )
	#elseif PS4_PROG
		AddMenuVarChangeHandler( "PS4_canInviteFriends", UpdateFooterOptions )
	#elseif PC_PROG
		AddMenuVarChangeHandler( "ORIGIN_isEnabled", UpdateFooterOptions )
		AddMenuVarChangeHandler( "ORIGIN_isJoinable", UpdateFooterOptions )
	#endif

	RegisterSignal( "BypassWaitBeforeRestartingMatchmaking" )
	RegisterSignal( "PutPlayerInMatchmakingAfterDelay" )
	RegisterSignal( "CancelRestartingMatchmaking" )
}


void function SetupComboButtonTest( var menu )
{
	ComboStruct comboStruct = ComboButtons_Create( menu )

	int headerIndex = 0
	int buttonIndex = 0
	file.playHeader = AddComboButtonHeader( comboStruct, headerIndex, "#MENU_HEADER_PLAY" )
	var findGameButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_FIND_GAME" )
	file.findGameButton = findGameButton
	file.lobbyButtons.append( findGameButton )
	Hud_AddEventHandler( findGameButton, UIE_CLICK, BigPlayButton1_Activate )

	if ( DoesCurrentCommunitySupportInvites() )
	{
		var roomButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_INVITE_ROOM" )
		file.inviteRoomButton = roomButton
		Hud_AddEventHandler( roomButton, UIE_CLICK, DoRoomInvite )
	}
	else
	{
		var roomButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_JOIN_NETWORK" )
		file.inviteRoomButton = roomButton
		Hud_AddEventHandler( roomButton, UIE_CLICK, DoRoomInvite )
	}
	var friendsButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_INVITE_FRIENDS" )
	file.inviteFriendsButton = friendsButton
	Hud_AddEventHandler( friendsButton, UIE_CLICK, InviteFriendsIfAllowed )

	headerIndex++
	buttonIndex = 0
	file.customizeHeader = AddComboButtonHeader( comboStruct, headerIndex, "#MENU_HEADER_LOADOUTS" )
	file.customizeHeaderIndex = headerIndex
	var pilotButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_PILOT" )
	file.pilotButton = pilotButton
	file.lobbyButtons.append( pilotButton )
	Hud_AddEventHandler( pilotButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "EditPilotLoadoutsMenu" ) ) )
	var titanButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_TITAN" )
	file.titanButton = titanButton
	Hud_AddEventHandler( titanButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "EditTitanLoadoutsMenu" ) ) )
	file.boostsButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_BOOSTS" )
	Hud_AddEventHandler( file.boostsButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "BurnCardMenu" ) ) )
//	var armoryButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_ARMORY" )
//	file.armoryButton = armoryButton
//	Hud_AddEventHandler( armoryButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "ArmoryMenu" ) ) )

	headerIndex++
	buttonIndex = 0
	file.networksHeader = AddComboButtonHeader( comboStruct, headerIndex, "#MENU_HEADER_COMMS" )
	file.inboxHeaderIndex = headerIndex
	var networksInbox = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_INBOX" )
	file.inboxButton = networksInbox
	file.lobbyButtons.append( networksInbox )
	Hud_AddEventHandler( networksInbox, UIE_CLICK, OnInboxButton_Activate )
	var switchButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#COMMUNITY_SWITCHCOMMUNITY" )
	Hud_AddEventHandler( switchButton, UIE_CLICK, OnSwitchButton_Activate )
	file.factionButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_FACTION" )
	Hud_AddEventHandler( file.factionButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "FactionChoiceMenu" ) ) )

	// var networksMoreButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#COMMUNITY_MORE" )
	// Hud_AddEventHandler( networksMoreButton, UIE_CLICK, OnCommunityButton_Activate )
	// file.networksMoreButton = networksMoreButton

	headerIndex++
	buttonIndex = 0
	file.callsignHeader = AddComboButtonHeader( comboStruct, headerIndex, "#MENU_HEADER_CALLSIGN" )
	file.bannerButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_BANNER" )
	file.lobbyButtons.append( file.bannerButton )
	Hud_AddEventHandler( file.bannerButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "CallsignCardSelectMenu" ) ) )
	file.patchButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_PATCH" )
	Hud_AddEventHandler( file.patchButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "CallsignIconSelectMenu" ) ) )

	file.callsignCard = Hud_GetChild( menu, "CallsignCard" )

	headerIndex++
	buttonIndex = 0
	var settingsHeader = AddComboButtonHeader( comboStruct, headerIndex, "#MENU_HEADER_SETTINGS" )
	var controlsButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_CONTROLS" )
	Hud_AddEventHandler( controlsButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "ControlsMenu" ) ) )
	file.lobbyButtons.append( controlsButton )
	#if CONSOLE_PROG
		var avButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#AUDIO_VIDEO" )
		Hud_AddEventHandler( avButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "AudioVideoMenu" ) ) )
	#elseif PC_PROG
		var videoButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#AUDIO" )
		Hud_AddEventHandler( videoButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "AudioMenu" ) ) )
		var soundButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#VIDEO" )
		Hud_AddEventHandler( soundButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "VideoMenu" ) ) )
	#endif
	//var dataCenterButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#DATA_CENTER" )
	//Hud_AddEventHandler( dataCenterButton, UIE_CLICK, OpenDataCenterDialog )

	comboStruct.navUpButton = file.chatroomMenu_chatroomWidget
	comboStruct.navDownButton = file.genUpButton

	ComboButtons_Finalize( comboStruct )
}


/*bool function IsGamepadSelectValid()
{
	return ( IsPlayerListFocused() && ( GetMenuVarBool( "isPrivateMatch" ) || GetMenuVarBool( "isPartyLeader" ) ) )
}

bool function IsPlayerListFocused()
{
	var focusedItem = GetFocus()

	// The check for GetScriptID existing isn't ideal, but if the text chat text output element has focus it will script error otherwise
	return ( (focusedItem != null) && ("GetScriptID" in focusedItem) && (Hud_GetScriptID( focusedItem ) == "PlayerListButton") )
}*/

bool function MatchResultsExist()
{
	return true // TODO
}

bool function CanSwitchTeams()
{
	return ( GetMenuVarBool( "isPrivateMatch" ) && ( level.ui.privatematch_starting != ePrivateMatchStartState.STARTING ) )
}

void function LeaveParty()
{
	ClientCommand( "party_leave" )
}

void function LeaveMatchAndParty()
{
	LeaveParty()
	LeaveMatch()
}

void function DoRoomInvite( var button )
{
	if ( !DoesCurrentCommunitySupportInvites() )
	{
		OnBrowseNetworksButton_Activate( button )
		return
	}

	if ( GetPartySize() <= 1 )
	{
		SendOpenInvite( true )
		void functionref( var ) handlerFunc = AdvanceMenuEventHandler( GetMenu( "PlaylistMenu" ) )
		handlerFunc( button )
	}
	else
	{
		printt( "You can't invite room if you're in a party" )
	}
}

void function CreatePartyAndInviteFriends()
{
	if ( CanInvite() )
	{
		while ( !PartyHasMembers() && !AmIPartyLeader() )
		{
			ClientCommand( "createparty" )
			WaitFrameOrUntilLevelLoaded()
		}
		InviteFriends( file.inviteFriendsButton )
	}
	else
	{
		printt( "Not inviting friends - CanInvite() returned false" );
	}
}

void function InviteFriendsIfAllowed( var button )
{
	if ( InPendingOpenInvite() )
	{
		printt( "not inviting friends - we are in an openInvite" )
		return
	}
	thread CreatePartyAndInviteFriends()
}

bool function CanInvite()
{
	#if DURANGO_PROG
		return ( GetMenuVarBool( "isFullyConnected" ) && GetMenuVarBool( "DURANGO_canInviteFriends" ) && GetMenuVarBool( "DURANGO_isJoinable" ) && GetMenuVarBool( "DURANGO_isGameFullyInstalled" ) )
	#elseif PS4_PROG
		return GetMenuVarBool( "PS4_canInviteFriends" )
	#elseif PC_PROG
		return ( GetMenuVarBool( "isFullyConnected" ) && GetMenuVarBool( "ORIGIN_isEnabled" ) && GetMenuVarBool( "ORIGIN_isJoinable" ) && Origin_IsOverlayAvailable() )
	#endif
}

void function CreatePartyAndStartPrivateMatch()
{
	while ( !PartyHasMembers() && !AmIPartyLeader() )
	{
		ClientCommand( "createparty" )
		WaitFrameOrUntilLevelLoaded()
	}
	ClientCommand( "StartPrivateMatchSearch" )
	OpenConnectingDialog()
}

void function StartPrivateMatch()
{
	thread CreatePartyAndStartPrivateMatch()
}

void function OnLobbyMenu_Open()
{
	Assert( IsConnected() )

	thread UpdateCachedNewItems()
	if ( file.putPlayerInMatchmakingAfterDelay ) //Start this off every time we come into the lobby. Will be cancelled by PostGameScreen if it runs
	{
		AdvanceMenu( GetMenu( "SearchMenu" ) )
		thread PutPlayerInMatchmakingAfterDelay()
		file.putPlayerInMatchmakingAfterDelay = false
	}

	thread UpdateLobbyUI()
	thread LobbyMenuUpdate( GetMenu( "LobbyMenu" ) )

	if ( uiGlobal.activeMenu == GetMenu( "LobbyMenu" ) )
		UI_SetPresentationType( ePresentationType.DEFAULT )

/*
	if ( GetLobbyTypeScript() == eLobbyType.MATCH )
		Hud_Hide( file.chatroomMenu )
	else
*/
		Hud_Show( file.chatroomMenu )

	if ( IsFullyConnected() )
	{
		UpdateCallsignElement( file.callsignCard )
		RefreshCreditsAvailable()

		entity player = GetUIPlayer()
		if ( !IsValid( player ) )
			return

		RuiSetBool( Hud_GetRui( file.customizeHeader ), "isNew", HasAnyNewPilotItems( player ) || HasAnyNewTitanItems( player ) || HasAnyNewBoosts( player))
		ComboButton_SetNew( file.pilotButton, HasAnyNewPilotItems( player ) )
		ComboButton_SetNew( file.titanButton, HasAnyNewTitanItems( player ) )
		ComboButton_SetNew( file.boostsButton, HasAnyNewBoosts( player ) )

		RuiSetBool( Hud_GetRui( file.networksHeader ), "isNew", HasAnyNewFactions( player ))
		ComboButton_SetNew( file.factionButton, HasAnyNewFactions( player ) )

		RuiSetBool( Hud_GetRui( file.callsignHeader ), "isNew", HasAnyNewCallsignBanners( player )|| HasAnyNewCallsignPatches( player ))
		ComboButton_SetNew( file.bannerButton, HasAnyNewCallsignBanners( player ) )
		ComboButton_SetNew( file.patchButton, HasAnyNewCallsignPatches( player ) )


		TryUnlockSRSCallsign()

		Lobby_UpdateInboxButtons()
	}
}

void function LobbyMenuUpdate( var menu )
{
	EndSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )

	while ( GetTopNonDialogMenu() == menu )
	{
		bool canInviteFriends = CanInvite()
		Hud_SetLocked( file.findGameButton, !IsPartyLeader() || InPendingOpenInvite() )
		Hud_SetLocked( file.inviteFriendsButton, !canInviteFriends || InPendingOpenInvite() )
		Hud_SetLocked( file.inviteRoomButton, IsOpenInviteVisible() || GetPartySize() > 1 || InPendingOpenInvite() )

		bool canGenUp = false
		if ( GetUIPlayer() )
			canGenUp = GetPersistentVarAsInt( "xp" ) == GetMaxPlayerXP() && GetGen() < MAX_GEN

		Hud_SetVisible( file.genUpButton, canGenUp )
		Hud_SetEnabled( file.genUpButton, canGenUp )

		WaitFrame()
	}
}


void function PutPlayerInMatchmakingAfterDelay()
{
	Signal( uiGlobal.signalDummy, "PutPlayerInMatchmakingAfterDelay" )
	EndSignal( uiGlobal.signalDummy, "PutPlayerInMatchmakingAfterDelay" )
	EndSignal( uiGlobal.signalDummy, "CancelRestartingMatchmaking" )
	EndSignal( uiGlobal.signalDummy, "OnCloseLobbyMenu" )
	EndSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )

	Assert( !AreWeMatchmaking() )

	entity player = GetUIPlayer()
	//Bump player out of match making if they were playing coliseum and are out of tickets.
	if ( "coliseum" == expect string( player.GetPersistentVar( "lastPlaylist" ) ) && Player_GetColiseumTicketCount( GetLocalClientPlayer() ) <= 0 )
	{
		return
	}

	waitthread WaitBeforeRestartingMatchmaking()

	if ( !Console_HasPermissionToPlayMultiplayer() )
	{
		ClientCommand( "disconnect" )
		return
	}

	string  lastPlaylistAbrv = expect string( player.GetPersistentVar( "lastPlaylist" ) )
	StartMatchmaking( lastPlaylistAbrv )
}

void function WaitBeforeRestartingMatchmaking()
{
	Signal( uiGlobal.signalDummy, "BypassWaitBeforeRestartingMatchmaking" )
	EndSignal( uiGlobal.signalDummy, "BypassWaitBeforeRestartingMatchmaking" ) //TODO: We want a button to bypass the wait. Once we create the button it should just signal this

	float timeToWait = GetCurrentPlaylistVarFloat( "wait_before_restarting_matchmaking_time", 30.0 )

	UpdateTimeToRestartMatchmaking( Time() + timeToWait )

	OnThreadEnd(
	function() : (  )
		{
			UpdateTimeToRestartMatchmaking( 0.0 )
			UpdateFooterOptions()
		}
	)
	wait timeToWait
}


function SCB_RefreshLobby()
{
	if ( uiGlobal.activeMenu != GetMenu( "LobbyMenu" ) )
		return

	OnLobbyMenu_Open()
}

void function OnLobbyMenu_Close()
{
	Signal( uiGlobal.signalDummy, "OnCloseLobbyMenu" )

	//RegisterButtonPressedCallback( BUTTON_SHOULDER_LEFT, ButtonCallback_RotateNodeCounterClockwise )

	// Hud_Hide( file.chatroomMenu )
}

void function OnLobbyMenu_NavigateBack()
{
	if ( ChatroomIsVisibleAndFocused() )
	{
		foreach ( button in file.lobbyButtons )
		{
			if ( Hud_IsVisible( button ) && Hud_IsEnabled( button ) && !Hud_IsLocked( button ) )
			{
				Hud_SetFocused( button )
				return
			}
		}
	}

	if ( InPendingOpenInvite() )
		LeaveOpenInvite()
	else
		LeaveDialog()
}

function GameStartTime_Changed()
{
	UpdateGameStartTimeCounter()
}

function ShowGameSummary_Changed()
{
	if ( level.ui.showGameSummary )
		uiGlobal.EOGOpenInLobby = true
}

function PutPlayerInMatchmakingAfterDelay_Changed() //Seems hacky: I can't change the value of  level.ui.putPlayerInMatchmakingAfterDelay from ui script, so use a file variable to proxy the value of level.ui.putPlayerInMatchmakingAfterDelay insted. Needs to use the UI var so server can set it
{
	if ( level.ui.putPlayerInMatchmakingAfterDelay )
		file.putPlayerInMatchmakingAfterDelay = true
	else
		file.putPlayerInMatchmakingAfterDelay = false
}

function UpdateGameStartTimeCounter()
{
	if ( level.ui.gameStartTime == null )
		return

	MatchmakingSetSearchText( "#STARTING_IN_LOBBY" )
	MatchmakingSetCountdownTimer( expect float( level.ui.gameStartTime + 0.0 ), true )

	HideMatchmakingStatusIcons()
}

function UpdateDebugStatus()
{
	EndSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )

	OnThreadEnd(
		function() : ()
		{
			foreach ( elem in file.MMDevStringElems )
				Hud_Hide( elem )
		}
	)

	foreach ( elem in file.MMDevStringElems )
		Hud_Show( elem )

	while ( true )
	{
		local strstr = GetLobbyDevString()
		foreach ( elem in file.MMDevStringElems )
			Hud_SetText( elem, strstr )

		WaitFrameOrUntilLevelLoaded()
	}
}

void function UpdateMatchmakingStatus()
{
	EndSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )

	OnThreadEnd(
		function() : ()
		{
			printt( "Hiding all matchmaking elems due to UpdateMatchmakingStatus thread ending" )

			HideMatchmakingStatusIcons()

			MatchmakingSetSearchText( "" )
			MatchmakingSetCountdownTimer( 0.0, true )


			MatchmakingSetSearchVisible( false )
			MatchmakingSetCountdownVisible( false )
		}
	)

	MatchmakingSetSearchVisible( true )
	MatchmakingSetCountdownVisible( true )

	var searchMenu = GetMenu( "SearchMenu" )
	var postGameMenu = GetMenu( "PostGameMenu" )

	while ( true )
	{
		int lobbyType = GetLobbyTypeScript()
		string matchmakingStatus = GetMyMatchmakingStatus()

		if ( level.ui.gameStartTime != null || lobbyType == eLobbyType.PRIVATE_MATCH )
		{
			if ( level.ui.gameStartTimerComplete )
			{
				MatchmakingSetSearchText( matchmakingStatus, GetMyMatchmakingStatusParam( 1 ), GetMyMatchmakingStatusParam( 2 ), GetMyMatchmakingStatusParam( 3 ), GetMyMatchmakingStatusParam( 4 ) )
			}

			if ( uiGlobal.activeMenu == searchMenu )
				CloseActiveMenu()
		}
		else if ( GetTimeToRestartMatchMaking() > 0  )
		{
			MatchmakingSetSearchText( "#MATCHMAKING_WAIT_BEFORE_RESTARTING_MATCHMAKING" )
		}
		else if ( level.ui.gameStartTime == null )
		{
			MatchmakingSetCountdownTimer( 0.0, true )
			MatchmakingSetSearchText( "" )
			HideMatchmakingStatusIcons()

			if ( !IsConnected() || !AreWeMatchmaking() )
			{
				ClearDisplayedMapAndMode()

				if ( uiGlobal.activeMenu == searchMenu )
					CloseActiveMenu()

				if( lobbyType == eLobbyType.MATCH )
				{
					//MatchmakingSetSearchText( "#MATCHMAKING_PLAYERS_CONNECTING" )
					MatchmakingSetSearchText( "" )
				}
			}
			else
			{
				ShowMatchmakingStatusIcons()

				if ( !IsMenuInMenuStack( searchMenu ) && !IsMenuInMenuStack( postGameMenu ) )
					AdvanceMenu( searchMenu )

				var statusEl = Hud_GetChild( searchMenu, "MatchmakingStatusBig" )
				var titleEl = searchMenu.GetChild( "MenuTitle" )
				string param1 = GetMyMatchmakingStatusParam( 1 )
				string param2 = GetMyMatchmakingStatusParam( 2 )
				string param3 = GetMyMatchmakingStatusParam( 3 )
				string param4 = GetMyMatchmakingStatusParam( 4 )
				string param5 = GetMyMatchmakingStatusParam( 5 )
				string param6 = GetMyMatchmakingStatusParam( 6 )
				if ( matchmakingStatus == "#MATCH_NOTHING" )
				{
					Hud_SetText( titleEl, "" )
					Hud_Hide( statusEl )
				}
				else if ( matchmakingStatus == "#MATCHMAKING_QUEUED" ||
						matchmakingStatus == "#MATCHMAKING_ALLOCATING_SERVER" ||
						matchmakingStatus == "#MATCHMAKING_MATCH_CONNECTING" )
				{
					string playlistName = param1
					Hud_SetText( titleEl, "#MATCHMAKING_PLAYLIST", GetPlaylistVarOrUseValue( playlistName, "name", "#UNKNOWN_PLAYLIST_NAME" ) )
					RuiSetString( Hud_GetRui( statusEl ), "statusText", Localize( "#MATCHMAKING_PLAYLIST", Localize( GetPlaylistVarOrUseValue( playlistName, "name", "#UNKNOWN_PLAYLIST_NAME" ) ) ) )

					RuiSetString( Hud_GetRui( statusEl ), "bulletPointText1", Localize( GetPlaylistVarOrUseValue( playlistName, "gamemode_bullet_001", "" ) ) )
					RuiSetString( Hud_GetRui( statusEl ), "bulletPointText2", Localize( GetPlaylistVarOrUseValue( playlistName, "gamemode_bullet_002", "" ) ) )
					RuiSetString( Hud_GetRui( statusEl ), "bulletPointText3", Localize( GetPlaylistVarOrUseValue( playlistName, "gamemode_bullet_003", "" ) ) )
					RuiSetString( Hud_GetRui( statusEl ), "bulletPointText4", Localize( GetPlaylistVarOrUseValue( playlistName, "gamemode_bullet_004", "" ) ) )
					RuiSetString( Hud_GetRui( statusEl ), "bulletPointText5", Localize( GetPlaylistVarOrUseValue( playlistName, "gamemode_bullet_005", "" ) ) )

					Hud_Show( statusEl )
					string maxPlayers = ""
					int mapIdx = int( param3 )
					int modeIdx = int( param4 )
					if ( mapIdx > -1 && modeIdx > -1 )
					{
						if ( file.preCacheInfo.playlistName != playlistName || file.preCacheInfo.mapIdx != mapIdx || file.preCacheInfo.modeIdx != modeIdx )
						{
							file.preCacheInfo.playlistName = playlistName
							file.preCacheInfo.mapIdx = mapIdx
							file.preCacheInfo.modeIdx = modeIdx
							// SetPlaylistDisplayedMapAndModeByIndex( playlistName, mapIdx, modeIdx )
						}

						maxPlayers = GetPlaylistGamemodeByIndexVar( playlistName, modeIdx, "max_players" )
					}

					if ( maxPlayers == "" )
					{
						matchmakingStatus = "#MATCHMAKING_QUEUE"
					}
					else
					{
						param1 = param2
						param2 = maxPlayers
						param3 = GetPlaylistCountDescForRegion( playlistName )
						if ( param3 == "" )
							param3 = "0"
					}
				}
				else
				{
					Hud_SetText( titleEl, "#MATCHMAKING" )
					Hud_Show( statusEl )
				}

				MatchmakingSetSearchText( matchmakingStatus, param1, param2, param3, param3 )
			}
		}

		WaitFrameOrUntilLevelLoaded()
	}
}

function NextMapModeSet_Changed()
{
	if ( IsPrivateMatch() )
		return

	if ( IsCoopMatch() )
		return

	if ( !level.ui.nextMapModeSet )
	{
		ClearDisplayedMapAndMode()
		return
	}

	SetCurrentPlaylistDisplayedMapAndModeByIndex( expect int( level.ui.nextMapIdx ), expect int( level.ui.nextModeIdx ) )
}

void function SetMapInfo( string mapName )
{
}

void function SetModeInfo( string modeName )
{
}

void function ClearDisplayedMapAndMode()
{
}

void function SetDisplayedMapAndMode( string mapName, string modeName )
{
}

void function SetCurrentPlaylistDisplayedMapAndModeByIndex( int mapIdx, int modeIdx )
{
	string mapName = GetCurrentPlaylistGamemodeByIndexMapByIndex( modeIdx, mapIdx )
	Assert( mapName.len() )
	string modeName = GetCurrentPlaylistGamemodeByIndex( modeIdx )
	Assert( modeName.len() )
	SetDisplayedMapAndMode( mapName, modeName )
}

void function SetPlaylistDisplayedMapAndModeByIndex( string playlistName, int mapIdx, int modeIdx )
{
	string mapName = GetPlaylistGamemodeByIndexMapByIndex( playlistName, modeIdx, mapIdx )
	Assert( mapName.len() )
	string modeName = GetPlaylistGamemodeByIndex( playlistName, modeIdx )
	Assert( modeName.len() )
	SetDisplayedMapAndMode( mapName, modeName )
}



function UpdateAnnouncementDialog()
{
	while ( IsLobby() && IsFullyConnected() )
	{
		if ( uiGlobal.activeMenu == null || IsDialog( uiGlobal.activeMenu ) )
		{
			WaitFrame()
			continue
		}

		entity player = GetUIPlayer()

		// Only initialize here, CloseAnnouncementDialog() handles setting it when closing
		if ( uiGlobal.announcementVersionSeen == -1 )
			uiGlobal.announcementVersionSeen = player.GetPersistentVarAsInt( "announcementVersionSeen" )

		int announcementVersion = GetConVarInt( "announcementVersion" )
		if ( announcementVersion > uiGlobal.announcementVersionSeen )
			OpenAnnouncementDialog()

		WaitFrame()
	}
}

function UpdateLobbyTitle()
{
	EndSignal( uiGlobal.signalDummy, "OnCloseLobbyMenu" )
	EndSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )

	local lobbyMenuTitleEl = GetMenu( "LobbyMenu" ).GetChild( "MenuTitle" )
	string title
	string lastTitle

	while ( true )
	{
		/*if ( GetLobbyTypeScript() == eLobbyType.MATCH )
			title = expect string( GetCurrentPlaylistVar( "lobbytitle" ) )
		else*/ if ( GetLobbyTypeScript() == eLobbyType.PRIVATE_MATCH )
			title = "#PRIVATE_MATCH"
		else
			title = "#MULTIPLAYER"

		if ( title != lastTitle )
		{
			lobbyMenuTitleEl.SetText( title )
			lastTitle = title
		}

		WaitFrameOrUntilLevelLoaded()
	}
}

void function RefreshCreditsAvailable( int creditsOverride = -1 )
{
	int credits = creditsOverride >= 0 ? creditsOverride : GetAvailableCredits( GetLocalClientPlayer() )

	foreach ( elem in file.creditsAvailableElems )
	{
		SetUIPlayerCreditsInfo( elem, credits, GetLocalClientPlayer().GetXP(), GetGen(), GetLevel(), GetNextLevel( GetLocalClientPlayer() ) )
	}
}

void function SetUIPlayerCreditsInfo( var infoElement, int credits, int xp, int gen, int level, int nextLevel )
{
	var rui = Hud_GetRui( infoElement )
	RuiSetInt( rui, "credits", credits )
	RuiSetString( rui, "nameText", GetPlayerName() )

	if ( xp == GetMaxPlayerXP() && gen < MAX_GEN )
	{
		RuiSetString( rui, "levelText", PlayerXPDisplayGenAndLevel( gen, level ) )
		RuiSetString( rui, "nextLevelText", Localize( "#REGEN_AVAILABLE" ) )
		RuiSetInt( rui, "numLevelPips", GetXPPipsForLevel( level - 1 ) )
		RuiSetInt( rui, "filledLevelPips", GetXPPipsForLevel( level - 1 ) )
	}
	else
	{
		RuiSetString( rui, "levelText", PlayerXPDisplayGenAndLevel( gen, level ) )
		RuiSetString( rui, "nextLevelText", PlayerXPDisplayGenAndLevel( gen, nextLevel ) )
		RuiSetInt( rui, "numLevelPips", GetXPPipsForLevel( level ) )
		RuiSetInt( rui, "filledLevelPips", GetXPFilledPipsForXP( xp ) )
	}

	CallsignIcon callsignIcon = PlayerCallsignIcon_GetActive( GetLocalClientPlayer() )

	RuiSetImage( rui, "callsignIcon", callsignIcon.image )
}


void function BigPlayButton1_Activate( var button )
{
	SendOpenInvite( false )
	void functionref( var ) handlerFunc = AdvanceMenuEventHandler( GetMenu( "PlaylistMenu" ) )
	handlerFunc( button )
	// Hud_Hide( file.chatroomMenu )
}

void function CoopMatchButton_Activate( var button )
{
}

// Handles turning on/off buttons when we switch lobby types
// Also, Any button we disable needs to set a new focus if they are focused when we disable them
void function UpdateLobbyTypeButtons( var menu, int lobbyType )
{
/*
	var bigPlayButton1 = Hud_GetChild( menu, "BigPlayButton1" )
	var coopMatchButton = Hud_GetChild( menu, "CoopMatchButton" )
	var privateMatchButton = Hud_GetChild( menu, "PrivateMatchButton" )
	var startMatchButton = Hud_GetChild( menu, "StartMatchButton" )
	var mapsButton = Hud_GetChild( menu, "MapsButton" )
	var modesButton = Hud_GetChild( menu, "ModesButton" )
	var settingsButton = Hud_GetChild( menu, "OldSettingsButton" )

	array< var > lobbyTypeButtons = [ bigPlayButton1, privateMatchButton, startMatchButton, mapsButton, modesButton, settingsButton ]

	table< int, array< var > > enableList = {}
	enableList[eLobbyType.SOLO] <- [ bigPlayButton1, privateMatchButton ]
	enableList[eLobbyType.PARTY_LEADER] <- [ bigPlayButton1, privateMatchButton ]
	enableList[eLobbyType.MATCH] <- []
	enableList[eLobbyType.PARTY_MEMBER] <- []
	enableList[eLobbyType.PRIVATE_MATCH] <- [ startMatchButton, mapsButton, modesButton, settingsButton ]

	array< var > disableList = []

	int partySize = GetPartySize()
	foreach ( button in lobbyTypeButtons )
	{
		if ( enableList[lobbyType].contains( button ) )
		{
			EnableButton( button )

			if ( partySize > 4 && button == coopMatchButton )
				Hud_SetEnabled( button, false )
		}
		else
		{
			disableList.append( button )
		}
	}

	foreach ( button in disableList )
	{
		if ( enableList[lobbyType].len() && Hud_IsFocused( button ) )
			Hud_SetFocused( enableList[lobbyType][0] )

		DisableButton( button )
	}
*/
}

function EnableButton( button )
{
	Hud_SetEnabled( button, true )
	Hud_Show( button )
}

function DisableButton( button )
{
	Hud_SetEnabled( button, false )
	Hud_Hide( button )
}

function UpdateLobbyUI()
{
	if ( uiGlobal.updatingLobbyUI )
		return
	uiGlobal.updatingLobbyUI = true

	thread UpdateLobbyType()
	thread UpdateMatchmakingStatus()
	thread UpdateDebugStatus()
	thread UpdateLobbyTitle()
	//thread MonitorTeamChange()
	thread MonitorPlaylistChange()
	thread UpdateChatroomThread()
	thread UpdateInviteJoinButton()
	thread UpdatePlayerInfo()

	if ( uiGlobal.EOGOpenInLobby )
		EOGOpen()

	WaitSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )
	uiGlobal.updatingLobbyUI = false
}

function UpdateNetworksMoreButton( bool newStuff )
{
	// if ( newStuff )
	// 	ComboButton_SetText( file.networksMoreButton, "#COMMUNITY_MORE_NEW" )
	// else
	// 	ComboButton_SetText( file.networksMoreButton, "#COMMUNITY_MORE" )

	// Search_UpdateNetworksMoreButton( newStuff )
}

void function UpdateInviteJoinButton()
{
	EndSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )
	var menu = GetMenu( "LobbyMenu" )

	while ( true )
	{
		if ( DoesCurrentCommunitySupportInvites() )
			ComboButton_SetText( file.inviteRoomButton, Localize( "#MENU_TITLE_INVITE_ROOM" ) )
		else
			ComboButton_SetText( file.inviteRoomButton, Localize( "#MENU_TITLE_JOIN_NETWORK" ) )

		WaitFrame()
	}
}

function UpdateLobbyType()
{
	EndSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )

	var menu = GetMenu( "LobbyMenu" )
	int lobbyType
	local lastType
	local partySize
	local lastPartySize
	local debugArray = [ "SOLO", "PARTY_LEADER", "PARTY_MEMBER", "MATCH", "PRIVATE_MATCH" ] // Must match enum

	WaitFrameOrUntilLevelLoaded()

	while ( true )
	{
		lobbyType = GetLobbyTypeScript()
		partySize = GetPartySize()

		if ( IsConnected() && ((lobbyType != lastType) || (partySize != lastPartySize))  )
		{
			if ( lastType == null )
				printt( "Lobby lobbyType changing from:", lastType, "to:", debugArray[lobbyType] )
			else
				printt( "Lobby lobbyType changing from:", debugArray[lastType], "to:", debugArray[lobbyType] )

			if ( lobbyType != lastType )
				ClearDisplayedMapAndMode()

			UpdateLobbyTypeButtons( menu, lobbyType )

			local animation = null

			switch ( lobbyType )
			{
				case eLobbyType.SOLO:
					animation = "SoloLobby"
					break

				case eLobbyType.PARTY_LEADER:
					animation = "PartyLeaderLobby"
					break

				case eLobbyType.PARTY_MEMBER:
					animation = "PartyMemberLobby"
					break

				case eLobbyType.MATCH:
					animation = "MatchLobby"
					break

				case eLobbyType.PRIVATE_MATCH:
					animation = "PrivateMatchLobby"
					break
			}

			if ( animation != null )
			{
				menu.RunAnimationScript( animation )
			}

			// Force the animation scripts (which have zero duration) to complete before anything can cancel them.
			ForceUpdateHUDAnimations()

			lastType = lobbyType
			lastPartySize = partySize
		}

		WaitFrameOrUntilLevelLoaded()
	}
}

function MonitorTeamChange()
{
	EndSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )

	local myTeam
	local lastMyTeam = 0
	local showBalanced
	local lastShowBalanced

	while ( true )
	{
		myTeam = GetTeam()
		showBalanced = GetLobbyTeamsShowAsBalanced()

		if ( (myTeam != lastMyTeam) || (showBalanced != lastShowBalanced) || IsPrivateMatch() )
		{
			lastMyTeam = myTeam
			lastShowBalanced = showBalanced
		}

		WaitFrameOrUntilLevelLoaded()
	}
}

void function UICodeCallback_CommunityUpdated()
{
	Community_CommunityUpdated()
	UpdateChatroomUI()
}

void function UICodeCallback_FactionUpdated()
{
	printt( "Faction changed! to " + GetCurrentFaction() );
}


function UpdateLobbyBadRepPresentMessage()
{
	var menu = GetMenu( "LobbyMenu" )
	var message = Hud_GetChild( menu, "LobbyBadRepPresentMessage" )

	if ( level.ui.badRepPresent )
	{
		#if PC_PROG
			Hud_SetText( message, "#ASTERISK_FAIRFIGHT_CHEATER" )
		#elseif DURANGO_PROG // #if PC_PROG
			Hud_SetText( message, "#ASTERISK_BAD_REPUTATION" )
		#elseif PS4_PROG // #elseif DURANGO_PROG // #if PC_PROG
			// TODO: cheat protection on PS4?
		#endif // #elseif PS4_PROG // #elseif DURANGO_PROG // #if PC_PROG
		Hud_Show( message )
	}
	else
	{
		Hud_Hide( message )
	}
}

void function OnMapsButton_Activate( var button )
{
	if ( level.ui.privatematch_starting == ePrivateMatchStartState.STARTING )
		return

	AdvanceMenu( GetMenu( "MapsMenu" ) )
}

void function OnModesButton_Activate( var button )
{
	if ( level.ui.privatematch_starting == ePrivateMatchStartState.STARTING )
		return

	AdvanceMenu( GetMenu( "ModesMenu" ) )
}

void function OnSettingsButton_Activate( var button )
{
	if ( level.ui.privatematch_starting == ePrivateMatchStartState.STARTING )
		return

	AdvanceMenu( GetMenu( "MatchSettingsMenu" ) )
}


void function OnPrivateMatchButton_Activate( var button )
{
	ShowPrivateMatchConnectDialog()
	ClientCommand( "match_playlist private_match" )
	StartPrivateMatch()
}

void function OnCommunityButton_Activate( var button )
{
	void functionref( var ) handlerFunc = AdvanceMenuEventHandler( GetMenu( "CommunitiesMenu" ) )
	handlerFunc( button )
	Hud_SetFocused( file.firstNetworkSubButton )
}

void function OnStartMatchButton_Activate( var button )
{
	ClientCommand( "PrivateMatchLaunch" )
}

void function OnStartMatchButton_GetFocus( var button )
{
	var menu = GetMenu( "LobbyMenu" )
	Hud_Show( file.chatroomMenu )

	//HandleLockedCustomMenuItem( menu, button, ["#FOO"] )
}

void function OnPrivateMatchButton_GetFocus( var button )
{
	Hud_Show( file.chatroomMenu )
}

void function OnStartMatchButton_LoseFocus( var button )
{
	var menu = GetMenu( "LobbyMenu" )
	//HandleLockedCustomMenuItem( menu, button, [], true )
}

function MonitorPlaylistChange()
{
	EndSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )

	string playlist
	string lastPlaylist

	while ( true )
	{
		playlist = GetCurrentPlaylistName()

		if ( playlist != lastPlaylist )
		{
			lastPlaylist = playlist
		}

		WaitFrameOrUntilLevelLoaded()
	}
}

void function UICodeCallback_SetupPlayerListGenElements( table params, int gen, int rank, bool isPlayingRanked, int pilotClassIndex )
{
	params.image = ""
	params.label = ""
	params.imageOverlay = ""
}

float function GetTimeToRestartMatchMaking()
{
	return file.timeToRestartMatchMaking
}

void function UpdateTimeToRestartMatchmaking( float time )//JFS: This uses UI time instead of server time, which leads to awkwardness in MatchmakingSetCountdownTimer() and the rui involved
{
	file.timeToRestartMatchMaking  = time

	if ( time > 0  )
	{
		MatchmakingSetSearchText( "#MATCHMAKING_WAIT_BEFORE_RESTARTING_MATCHMAKING" )
		MatchmakingSetCountdownTimer( time, false )
		ShowMatchmakingStatusIcons()
	}
	else
	{
		MatchmakingSetSearchText( "" )
		MatchmakingSetCountdownTimer( 0.0, true )
		HideMatchmakingStatusIcons()
	}
}

void function HideMatchmakingStatusIcons()
{
	foreach ( element in file.searchIconElems )
		Hud_Hide( element )

	foreach ( element in file.matchStatusRuis )
		RuiSetBool( Hud_GetRui( element ), "iconVisible", false )
}

void function ShowMatchmakingStatusIcons()
{
	//foreach ( element in file.searchIconElems )
	//	Hud_Show( element )

	foreach ( element in file.matchStatusRuis )
		RuiSetBool( Hud_GetRui( element ), "iconVisible", true )
}

void function MatchmakingSetSearchVisible( bool state )
{
	foreach ( el in file.searchTextElems )
	{
		//if ( state )
		//	Hud_Show( el )
		//else
			Hud_Hide( el )
	}

	foreach ( element in file.matchStatusRuis )
		RuiSetBool( Hud_GetRui( element ), "statusVisible", state )
}

void function MatchmakingSetSearchText( string searchText, var param1 = "", var param2 = "", var param3 = "", var param4 = "" )
{
	foreach ( el in file.searchTextElems )
	{
		Hud_SetText( el, searchText, param1, param2, param3, param4 )
	}

	foreach ( element in file.matchStatusRuis )
	{
		RuiSetBool( Hud_GetRui( element ), "statusHasText", searchText != "" )

		RuiSetString( Hud_GetRui( element ), "statusText", Localize( searchText, param1, param2, param3, param4 ) )
	}
}


void function MatchmakingSetCountdownVisible( bool state )
{
	foreach ( el in file.matchStartCountdownElems )
	{
		//if ( state )
		//	Hud_Show( el )
		//else
			Hud_Hide( el )
	}

	foreach ( element in file.matchStatusRuis )
		RuiSetBool( Hud_GetRui( element ), "timerVisible", state )
}

void function MatchmakingSetCountdownTimer( float time, bool useServerTime = true ) //JFS: useServerTime bool is awkward, comes from level.ui.gameStartTime using server time and UpdateTimeToRestartMatchmaking() uses UI time.
{
	foreach ( element in file.matchStatusRuis )
	{
		RuiSetBool( Hud_GetRui( element ), "timerHasText", time != 0.0 )
		RuiSetGameTime( Hud_GetRui( element ), "startTime", Time() )
		RuiSetBool( Hud_GetRui( element ), "useServerTime", useServerTime )
		RuiSetGameTime( Hud_GetRui( element ), "timerEndTime", time )
	}
}

void function OnLobbyLevelInit()
{
	UpdateCallsignElement( file.callsignCard )
	RefreshCreditsAvailable()
}


function UpdatePlayerInfo()
{
	EndSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )

	var menu = GetMenu( "LobbyMenu" )

	WaitFrameOrUntilLevelLoaded()

	while ( true )
	{
		RefreshCreditsAvailable()
		WaitFrame()
	}
}

void function TryUnlockSRSCallsign()
{
	int numCallsignsToUnlock = 0

	if ( GetTotalLionsCollected() >= GetTotalLionsInGame() )
		numCallsignsToUnlock = 3
	else if ( GetTotalLionsCollected() >= ACHIEVEMENT_COLLECTIBLES_2_COUNT )
		numCallsignsToUnlock = 2
	else if ( GetTotalLionsCollected() >= ACHIEVEMENT_COLLECTIBLES_1_COUNT )
		numCallsignsToUnlock = 1
	else
		numCallsignsToUnlock = 0

	if ( numCallsignsToUnlock > 0 )
		ClientCommand( "UnlockSRSCallsign " + numCallsignsToUnlock )
}

void function SetPutPlayerInMatchmakingAfterDelay( bool value )
{
	file.putPlayerInMatchmakingAfterDelay = value
}
