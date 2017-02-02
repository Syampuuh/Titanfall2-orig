
global function ActivateQuickMatch

void function ActivateQuickMatch( var button )
{
	entity player = GetUIPlayer()
	Assert( player != null )

	string lastPlaylist = expect string( player.GetPersistentVar( "lastPlaylist" ) )
	AdvanceMenu( GetMenu( "SearchMenu" ) )
	printt( "Setting match_playlist to '" + lastPlaylist + "' due to ActivateQuickMatch call" )
	StartMatchmaking( lastPlaylist )
}
