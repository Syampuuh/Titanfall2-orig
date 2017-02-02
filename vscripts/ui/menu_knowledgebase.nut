global function InitKnowledgeBaseMenu
global function HaveNewPatchNotes

//script_ui AdvanceMenu( GetMenu( "KnowledgeBaseMenu" ) )

struct
{
	array<var> subjectButtons
	int lastSelectedIndex
	var descriptionRui
} file

void function InitKnowledgeBaseMenu()
{
	var menu = GetMenu( "KnowledgeBaseMenu" )
	file.lastSelectedIndex = 0

	for ( int idx = 0; idx < 15; ++idx )
	{
		string btnName = ("BtnKNBSubject" + format( "%02d", idx ))
		var button = Hud_GetChild( menu, btnName )

		file.subjectButtons.append( button )

		if ( idx > (KNB_SUBJECT_COUNT - 1) )
		{
			Hud_SetVisible( button, false )
			continue
		}

		Hud_SetVisible( button, true )
		string labelText = format( "#KNB_SUBJECT_%02d_NAME", idx )
		SetButtonRuiText( button, labelText )
		AddButtonEventHandler( button, UIE_CLICK, OnKBNSubjectButtonClick )
		AddButtonEventHandler( button, UIE_GET_FOCUS, OnKBNSubjectButtonFocus )
	}

	var ruiContainer = Hud_GetChild( menu, "LabelDetails" )
	file.descriptionRui = Hud_GetRui( ruiContainer )

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnOpenKnowledgeBaseMenu )
	AddMenuFooterOption( menu, BUTTON_A, "#A_BUTTON_SELECT" )
	AddMenuFooterOption( menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
}

int function GetPatchNotesCurrentVersion()
{
	return GetCurrentPlaylistVarInt( "faq_patchnotes_version", -1 )
}

bool function HaveNewPatchNotes()
{
	int lastSeenVersion = GetConVarInt( "menu_faq_patchnotes_version" )
	int currentVersion = GetPatchNotesCurrentVersion()
	if ( lastSeenVersion < currentVersion )
		return true
	return false
}

void function MarkPatchNotesAsCurrent()
{
	int currentVersion = GetPatchNotesCurrentVersion()
	if ( currentVersion < 0 )
		return

	int lastSeenVersion = GetConVarInt( "menu_faq_patchnotes_version" )
	if ( lastSeenVersion == currentVersion )
		return

	SetConVarInt( "menu_faq_patchnotes_version", currentVersion )
}

void function OnOpenKnowledgeBaseMenu()
{
	//UI_SetPresentationType( ePresentationType.KNOWLEDGEBASE_MAIN )
	UI_SetPresentationType( ePresentationType.NO_MODELS )

	RuiSetGameTime( file.descriptionRui, "initTime", Time() )

	SetConVarBool( "menu_faq_viewed", true )

	SetNamedRuiBool( file.subjectButtons[KNB_PATCHNOTES_INDEX], "isNew", HaveNewPatchNotes() )

	thread DelayedSetFocusThread( file.subjectButtons[file.lastSelectedIndex] )
}

void function DelayedSetFocusThread( var item )
{
	WaitEndFrame()
	Hud_SetFocused( item )
}

void function OnKBNSubjectButtonClick( var button )
{
	int buttonID = int( Hud_GetScriptID( button ) )

	if ( buttonID == KNB_PATCHNOTES_INDEX )
		MarkPatchNotesAsCurrent()

	file.lastSelectedIndex = buttonID
	AdvanceToKnowledgeBaseSubmenu( buttonID )
}

void function OnKBNSubjectButtonFocus( var button )
{
	int buttonID = int( Hud_GetScriptID( button ) )

	string descText = format( "#KNB_SUBJECT_%02d_DESC", buttonID )

	RuiSetString( file.descriptionRui, "messageText", Localize( descText ) )
	RuiSetGameTime( file.descriptionRui, "startTime", Time() )
	RuiSetBool( file.descriptionRui, "isNew", (buttonID == KNB_PATCHNOTES_INDEX) && HaveNewPatchNotes() )
}

