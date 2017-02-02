global function InitSearchMenu
global function Search_UpdateNetworksMoreButton
global function Search_UpdateInboxButtons

struct {
	var chatroomMenu
	var chatroomMenu_chatroomWidget

	var firstNetworkSubButton

	int customizeHeaderIndex
	var networksMoreButton

	var pilotButton
	var titanButton
	var boostsButton
	var factionButton
	var bannerButton
	var patchButton
	var networksHeader

	var inboxButton
	int inboxHeaderIndex

	var customizeHeader
	var callsignHeader

	var callsignCard
	bool chatroomWidgetState
} file


void function InitSearchMenu()
{
	var menu = GetMenu( "SearchMenu" )

	AddMenuFooterOption( menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
	AddMenuFooterOption( menu, BUTTON_BACK, "#BACK_BUTTON_POSTGAME_REPORT", "#POSTGAME_REPORT", OpenPostGameMenu, IsPostGameMenuValid )
	AddMenuFooterOption( menu, BUTTON_Y, "#Y_BUTTON_SKIP_WAIT_BEFORE_MATCHMAKING", "#SKIP_WAIT_BEFORE_MATCHMAKING", SkipMatchMakingWait, IsWaitingBeforeMatchMaking )
	AddMenuFooterOption( menu, BUTTON_TRIGGER_RIGHT, "#R_TRIGGER_CHAT", "", null, IsVoiceChatPushToTalk )

	InitChatroom( menu )

	file.chatroomMenu = Hud_GetChild( menu, "ChatRoomPanel" )
	file.chatroomMenu_chatroomWidget = Hud_GetChild( file.chatroomMenu, "ChatRoom" )

	CreateButtons( menu )

	file.firstNetworkSubButton = Hud_GetChild( GetMenu( "CommunitiesMenu" ), "BtnBrowse" )

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnSearchMenu_Open )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, OnSearchMenu_Close )
	AddMenuEventHandler( menu, eUIEvent.MENU_NAVIGATE_BACK, OnSearchMenu_NavigateBack )

}


void function OnSearchMenu_Open()
{
	UI_SetPresentationType( ePresentationType.SEARCH )

	thread UpdateCachedNewItems()

	if ( !Console_HasPermissionToPlayMultiplayer() )
	{
		ClientCommand( "disconnect" )
		return
	}

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

		Search_UpdateInboxButtons()
	}
}

void function OnSearchMenu_Close()
{
	var menu = GetMenu( "SearchMenu" )
	var titleEl = Hud_GetChild( menu, "MenuTitle" )
	Hud_SetText( titleEl, "" )

	if ( GetUIPlayer() )
		StopMatchmaking()
}

void function OnSearchMenu_NavigateBack()
{
	LeaveDialog()
}

void function OnCommunityButton_Activate( var button )
{
	void functionref( var ) handlerFunc = AdvanceMenuEventHandler( GetMenu( "CommunitiesMenu" ) )
	handlerFunc( button )
	Hud_SetFocused( file.firstNetworkSubButton )
}

void function Search_UpdateNetworksMoreButton( bool newStuff )
{
	if ( newStuff )
		ComboButton_SetText( file.networksMoreButton, "#COMMUNITY_MORE_NEW" )
	else
		ComboButton_SetText( file.networksMoreButton, "#COMMUNITY_MORE" )
}


void function Search_UpdateInboxButtons()
{
	var menu = GetMenu( "SearchMenu" )
	if ( GetUIPlayer() == null )
		return

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

void function CreateButtons( var menu )
{
	ComboStruct comboStruct = ComboButtons_Create( menu )

	int headerIndex = 0
	int buttonIndex = 0
	file.customizeHeader = AddComboButtonHeader( comboStruct, headerIndex, "#MENU_HEADER_LOADOUTS" )
	file.customizeHeaderIndex = headerIndex
	var pilotButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_PILOT" )
	file.pilotButton = pilotButton

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
	Hud_AddEventHandler( file.bannerButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "CallsignCardSelectMenu" ) ) )
	file.patchButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_PATCH" )
	Hud_AddEventHandler( file.patchButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "CallsignIconSelectMenu" ) ) )

	file.callsignCard = Hud_GetChild( menu, "CallsignCard" )

	headerIndex++
	buttonIndex = 0
	var settingsHeader = AddComboButtonHeader( comboStruct, headerIndex, "#MENU_HEADER_SETTINGS" )
	var controlsButton = AddComboButton( comboStruct, headerIndex, buttonIndex++, "#MENU_TITLE_CONTROLS" )
	Hud_AddEventHandler( controlsButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "ControlsMenu" ) ) )
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

	comboStruct.navDownButton = file.chatroomMenu_chatroomWidget

	ComboButtons_Finalize( comboStruct )
}

void function SkipMatchMakingWait( var button )
{
	Signal( uiGlobal.signalDummy, "BypassWaitBeforeRestartingMatchmaking" )
	UpdateFooterOptions()

}

bool function IsWaitingBeforeMatchMaking()
{
	return GetTimeToRestartMatchMaking() > 0.0
}
