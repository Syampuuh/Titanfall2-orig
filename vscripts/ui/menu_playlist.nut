untyped

global function GetVisiblePlaylists

global function InitPlaylistMenu
global function SendOpenInvite
global function GetPlaylistImage
global function BuyIntoColiseumTicket

struct
{
	bool initialized = false
	GridMenuData gridData
	array<string> playlistNames
	var menu
	var unlockReq

	bool sendOpenInvite = false
} file

void function InitPlaylistMenu()
{
	var menu = GetMenu( "PlaylistMenu" )

	file.unlockReq = Hud_GetChild( menu, "UnlockReq" )

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnPlaylistMenu_Open )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, OnPlaylistMenu_Close )

	AddMenuFooterOption( menu, BUTTON_A, "#A_BUTTON_SELECT" )
	AddMenuFooterOption( menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
}

bool function PlaylistButtonInit( var button, int elemNum )
{
	var rui = Hud_GetRui( button )
	GridMenuData data = Grid_GetGridDataForButton( button )

	string playlistName = file.playlistNames[ elemNum ]

	string levelName = GetPlaylistVarOrUseValue( playlistName, "name", "#UNKNOWN_PLAYLIST_NAME" )
	string imageName = GetPlaylistVarOrUseValue( playlistName, "image", "default" )
	var dataTable = GetDataTable( $"datatable/playlist_items.rpak" )

	int row = GetDataTableRowMatchingStringValue( dataTable, GetDataTableColumnByName( dataTable, "playlist" ), imageName )
	asset levelImage = GetDataTableAsset( dataTable, row, GetDataTableColumnByName( dataTable, "image" ) )

	RuiSetImage( rui, "itemImage", levelImage )
	RuiSetString( rui, "title", levelName )

	return true
}

asset function GetPlaylistImage( string playlistName )
{
	string imageName = GetPlaylistVarOrUseValue( playlistName, "image", "default" )
	var dataTable = GetDataTable( $"datatable/playlist_items.rpak" )
	int row = GetDataTableRowMatchingStringValue( dataTable, GetDataTableColumnByName( dataTable, "playlist" ), imageName )
	asset levelImage = GetDataTableAsset( dataTable, row, GetDataTableColumnByName( dataTable, "image" ) )

	return levelImage
}


void function SendOpenInvite( bool state )
{
	file.sendOpenInvite = state
}

void function PlaylistButton_GetFocus( var button, int elemNum )
{
	string playlistName = file.playlistNames[ elemNum ]

	string unlockReq
	if ( IsUnlockValid( playlistName ) )
		unlockReq = GetItemUnlockReqText( playlistName )
	RHud_SetText( file.unlockReq, unlockReq )

	string levelName = GetPlaylistVarOrUseValue( playlistName, "name", "#UNKNOWN_PLAYLIST_NAME" )
	string desc = GetPlaylistVarOrUseValue( playlistName, "description", "#UNKNOWN_PLAYLIST_NAME" )

	file.menu = GetMenu( "PlaylistMenu" )
	file.menu.GetChild( "ContentDescriptionTitle" ).SetText( levelName )
	file.menu.GetChild( "ContentDescription" ).SetText( desc )
	file.menu.GetChild( "PlayerCount" ).SetText( "#PLAYLIST_PLAYERCOUNT_COMBINED", GetPlaylistCountDescForRegion( playlistName ), GetPlaylistCountDescForWorld( playlistName ) )
}

void function OnPlaylistMenu_Open()
{
	StopMatchmaking()

	var menu = GetMenu( "PlaylistMenu" )

	file.playlistNames = GetVisiblePlaylists()
	int numRows = file.playlistNames.len()
	file.gridData.numElements = numRows
	file.gridData.rows = 2
	file.gridData.columns = 4
	file.gridData.paddingVert = 10
	file.gridData.paddingHorz = 10
	file.gridData.pageType = eGridPageType.HORIZONTAL
	file.gridData.tileWidth = Grid_GetMaxWidthForSettings( menu, file.gridData )

	float tileHeight = ( file.gridData.tileWidth * 9.0 ) / 21.0

	file.gridData.tileHeight = int( tileHeight )

	file.gridData.initCallback = PlaylistButtonInit
	file.gridData.getFocusCallback = PlaylistButton_GetFocus
	file.gridData.clickCallback = PlaylistButton_Click
//	file.gridData.buttonFadeCallback = FadePlaylistButton

	file.gridData.currentPage = 0

	if ( file.initialized )
		Grid_InitPage( menu, file.gridData, true )
	else
		GridMenuInit( menu, file.gridData )

	file.initialized = true

	Hud_SetFocused( Grid_GetButtonAtRowColumn( menu, 0, 0 ) )

	UI_SetPresentationType( ePresentationType.NO_MODELS )

	Grid_MenuOpened( menu )

	thread UpdatePlaylistButtons()
}


void function OnPlaylistMenu_Close()
{
	var menu = GetMenu( "PlaylistMenu" )
	Grid_MenuClosed( menu )

}

bool function CanPlaylistFitMyParty( string playlistName )
{
	int maxPlayers = GetMaxPlayersForPlaylistName( playlistName )
	int maxTeams = GetMaxTeamsForPlaylistName( playlistName )
	int maxPlayersPerTeam = int( max( maxPlayers / maxTeams, 1 ) )

	if ( GetPartySize() > maxPlayersPerTeam )
		return false

	if ( file.sendOpenInvite && maxPlayersPerTeam == 1 )
		return false

	return true
}

void function UpdatePlaylistButtons()
{
	while ( GetTopNonDialogMenu() == GetMenu( "PlaylistMenu" ) )
	{
		table< int, var > activePageButtons = Grid_GetActivePageButtons( GetMenu( "PlaylistMenu" ) )

		if ( GetUIPlayer() )
		{
			foreach ( buttonIndex, button in activePageButtons )
			{
				string playlistName = file.playlistNames[ buttonIndex ]

				bool isLocked = false

				if ( playlistName == "coliseum" )
				{
					var rui = Hud_GetRui( button )
					RuiSetInt( rui, "specialObjectCount", Player_GetColiseumTicketCount( GetUIPlayer() ) )
					RuiSetImage( rui, "specialObjectIcon", $"rui/menu/common/ticket_icon" )
					RuiSetFloat( rui, "specialAlpha", 1.0 )
				}
				else
				{
					var rui = Hud_GetRui( button )
					RuiSetInt( rui, "specialObjectCount", 0 )
					RuiSetImage( rui, "specialObjectIcon", $"" )
					RuiSetFloat( rui, "specialAlpha", 0.0 )
				}

				int costOverride = -1
				if ( playlistName == "private_match" )
				{
					isLocked = false
					costOverride = 0
				}
				else if ( !CanPlaylistFitMyParty( playlistName ) )
				{
					isLocked = true
					costOverride = 0
				}
				else if ( IsUnlockValid( playlistName ) && IsItemLocked( GetUIPlayer(), playlistName ) )
				{
					isLocked = true
				}

				Hud_SetLocked( button, isLocked )

				if ( IsRefValid( playlistName ) )
					RefreshButtonCost( button, playlistName, "", -1, costOverride )
			}
		}
		WaitFrame()
	}
}

void function PlaylistButton_Click( var button, int elemNum )
{
	string playlistName = file.playlistNames[ elemNum ]
	if ( playlistName == "private_match" )
	{
		if ( Hud_IsLocked( button ) )
			return

		if ( !file.sendOpenInvite )
		{
			StartPrivateMatch()
			return
		}
	}

	if ( Hud_IsLocked( button ) )
	{
		if ( !CanPlaylistFitMyParty( playlistName ) )
			return

		array<var> buttons = GetElementsByClassname( file.menu, "GridButtonClass" )
		OpenBuyItemDialog( buttons, button, GetItemName( playlistName ), playlistName )
		return
	}

	//DO CHECK HERE TO SEE IF WE ARE TYING TO ENTER COLISEUM
	if ( playlistName == "coliseum" )
	{
		// Does player have a ticket?
		if ( Player_GetColiseumTicketCount( GetLocalClientPlayer() ) > 0 )
		{
			ColiseumPlaylist_SpendTicketDialogue( button )
			return
		}
		else
		{
			//OFFER PLAYER BUY TICKET
			array<var> buttons = GetElementsByClassname( file.menu, "GridButtonClass" )
			OpenBuyTicketDialog( buttons, button )
			return
		}
	}

	CloseActiveMenu() // playlist selection menu

	printt( "Setting match_playlist to '" + playlistName + "' from playlist menu" )
	if ( file.sendOpenInvite )
		ClientCommand( "openinvite playlist " + playlistName )
	else
		StartMatchmaking( playlistName )
}

array<string> function GetVisiblePlaylists()
{
	int numPlaylists = GetPlaylistCount()

	array<string> list = []

	bool rearrangeForAngelCity = false

	for ( int i=0; i<numPlaylists; i++ )
	{
		string name = string( GetPlaylistName(i) )
		bool visible = GetPlaylistVarOrUseValue( name, "visible", "0" ) == "1"

		if ( visible )
		{
			// printt( name )
			if ( IsItemInEntitlementUnlock( name ) && IsValid( GetUIPlayer() ) )
	 		{
	 			if ( IsItemLocked( GetUIPlayer(), name ) )
	 			{
	 				continue
	 			}
	 			else if ( name == "angel_city_247" )
	 			{
	 				rearrangeForAngelCity = true
	 			}
	 		}

			list.append( name )
		}
	}

	if ( rearrangeForAngelCity )
	{
		string playlistReplacement = GetCurrentPlaylistVarString( "angel_city_replacement", "" )
		int playlistReplacementIdx = GetCurrentPlaylistVarInt( "angel_city_replacement_index", 3 )
		if ( playlistReplacement != "" && list.contains( playlistReplacement ) )
		{
			int idx = list.find( playlistReplacement )
			list.remove( idx )
			list.insert( playlistReplacementIdx, playlistReplacement )
		}
	}

	return list
}

void function FadePlaylistButton( var elem, int fadeTarget, float fadeTime )
{
	var rui = Hud_GetRui( elem )
	RuiSetFloat( rui, "mAlpha", ( fadeTarget / 255.0 ) )
	RuiSetGameTime( rui, "fadeStartTime", Time() )
	RuiSetGameTime( rui, "fadeEndTime", Time() + fadeTime )
}

void function ColiseumPlaylist_SpendTicketDialogue( var button )
{
	DialogData dialogData
	dialogData.header = "#COLISEUM_PAY_HEADER"
	dialogData.message = "#COLISEUM_PAY_MESSAGE"

	AddDialogButton( dialogData, "#YES", BuyIntoColiseumTicket )
	AddDialogButton( dialogData, "#NO" )

	AddDialogFooter( dialogData, "#A_BUTTON_SELECT" )
	AddDialogFooter( dialogData, "#B_BUTTON_BACK" )

	OpenDialog( dialogData )
}

void function BuyIntoColiseumTicket()
{
	string playlistName = "coliseum"
	CloseActiveMenu() // playlist selection menu
	AdvanceMenu( GetMenu( "SearchMenu" ) )

	StartMatchmaking( playlistName )
}
