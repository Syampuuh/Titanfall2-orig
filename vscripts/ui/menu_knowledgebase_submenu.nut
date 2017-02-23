global function InitKnowledgeBaseMenuSubMenu
global function AdvanceToKnowledgeBaseSubmenu

struct
{
	array<var> questionButtons
	var descriptionElement
	var descriptionRui

	var thisMenu
	var thisMenuHeader
	var thisMenuScreen
	int currentSubjectID
} file


////////////////////////////////////////////////////////////
// For the "KNB_SUBJECT_*" strings in r1_english.txt:
const array<int> KNB_SUBJECT_SUB_COUNTS =
[
	-1,		// playlist var: "faq_patchnotes_count"
	5,		// KNB_SUBJECT_SUB_COUNTS[1]
	7,		// KNB_SUBJECT_SUB_COUNTS[2]
	10,		// KNB_SUBJECT_SUB_COUNTS[3]
	3,		// KNB_SUBJECT_SUB_COUNTS[4]
	4,		// KNB_SUBJECT_SUB_COUNTS[5]
	6,		// KNB_SUBJECT_SUB_COUNTS[6]
	9,		// KNB_SUBJECT_SUB_COUNTS[7]
	16,		// KNB_SUBJECT_SUB_COUNTS[8]
	6,		// KNB_SUBJECT_SUB_COUNTS[9]
	14,		// KNB_SUBJECT_SUB_COUNTS[10]
]
global const int KNB_SUBJECT_COUNT = 11
global const int KNB_PATCHNOTES_INDEX = 0
////////////////////////////////////////////////////////////

global int KNB_COMMUNITY_INDEX = -1
void function AdvanceToKnowledgeBaseSubmenu( int subjectID )
{
	file.currentSubjectID = subjectID
	AdvanceMenu( file.thisMenu )
}

const int MAX_BUTTONS = 20
void function InitKnowledgeBaseMenuSubMenu()
{
	var menu = GetMenu( "KnowledgeBaseMenuSubMenu" )
	file.thisMenu = menu

	file.thisMenuHeader = Hud_GetChild( menu, "MenuTitle" )
	file.thisMenuScreen = Hud_GetChild( menu, "Screen" )

	for ( int idx = 0; idx < MAX_BUTTONS; ++idx )
	{
		string btnName = ("BtnKNBSubQuestion" + format( "%02d", idx ))
		var button = Hud_GetChild( menu, btnName )

		file.questionButtons.append( button )

		AddButtonEventHandler( button, UIE_CLICK, OnKBNSubjectButtonClick )
		AddButtonEventHandler( button, UIE_GET_FOCUS, OnKBNSubjectButtonFocus )
	}

	var ruiContainer = Hud_GetChild( menu, "LabelDetails" )
	file.descriptionRui = Hud_GetRui( ruiContainer )

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnOpenKnowledgeBaseSubMenu )
	AddMenuFooterOption( menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
}

string function GetCommunityURL( int index )
{
	return GetCurrentPlaylistVarString( format( "faq_community_url_%02d", index ), "" )
}

void function OnKBNSubjectButtonClick( var button )
{
	if ( file.currentSubjectID != KNB_COMMUNITY_INDEX )
		return

	int buttonID = int( Hud_GetScriptID( button ) )
	string urlText = GetCommunityURL( buttonID )
	if ( urlText.len() == 0 )
		return

	LaunchExternalWebBrowser( urlText )
}

void function OnKBNSubjectButtonFocus( var button )
{
	int buttonID = int( Hud_GetScriptID( button ) )

	string questionText
	string answerText
	if ( file.currentSubjectID == KNB_COMMUNITY_INDEX )
	{
		questionText = format( "#COMMUNITYUPDATE_%02d_Q", buttonID )
		answerText = format( "#COMMUNITYUPDATE_%02d_A", buttonID )
	}
	else
	{
		questionText = format( "#KNB_SUBJECT_%02d_SUB_%02d_Q", file.currentSubjectID, buttonID )
		answerText = format( "#KNB_SUBJECT_%02d_SUB_%02d_A", file.currentSubjectID, buttonID )
	}

	RuiSetString( file.descriptionRui, "headerText", Localize( questionText ) )
	RuiSetString( file.descriptionRui, "messageText", Localize( answerText ) )
	RuiSetGameTime( file.descriptionRui, "startTime", Time() )
}

int function GetCommunityQuestionCount()
{
	return GetCurrentPlaylistVarInt( "faq_community_count", 0 )
}

int function GetPatchNotesQuestionCount()
{
	return GetCurrentPlaylistVarInt( "faq_patchnotes_count", 0 )
}

void function OnOpenKnowledgeBaseSubMenu()
{
	//UI_SetPresentationType( ePresentationType.KNOWLEDGEBASE_SUB )
	UI_SetPresentationType( ePresentationType.NO_MODELS )

	int questionCount
	string headerRight
	if ( file.currentSubjectID == KNB_COMMUNITY_INDEX )
	{
		questionCount = GetCommunityQuestionCount()
		headerRight = Localize( format( "#COMMUNITYUPDATE_NAME" ) )
	}
	else if ( file.currentSubjectID == KNB_PATCHNOTES_INDEX )
	{
		questionCount = GetPatchNotesQuestionCount()
		headerRight = Localize( format( "#KNB_SUBJECT_%02d_NAME", file.currentSubjectID ) )
	}
	else
	{
		questionCount = KNB_SUBJECT_SUB_COUNTS[file.currentSubjectID]
		headerRight = Localize( format( "#KNB_SUBJECT_%02d_NAME", file.currentSubjectID ))
	}

	Hud_SetText( file.thisMenuHeader, (Localize( "#KNB_MENU_HEADER" ) + "  :  " + headerRight ) )

	for ( int idx = 0; idx < MAX_BUTTONS; ++idx )
	{
		var button = file.questionButtons[idx]

		if ( idx > (questionCount - 1) )
		{
			Hud_SetVisible( button, false )
			continue
		}

		Hud_SetVisible( button, true )

		string labelText
		bool showButtonPrompt
		if ( file.currentSubjectID == KNB_COMMUNITY_INDEX )
		{
			labelText = format( "#COMMUNITYUPDATE_%02d_Q", idx )
			showButtonPrompt = (GetCommunityURL( idx ).len() > 0)
		}
		else
		{
			labelText = format( "#KNB_SUBJECT_%02d_SUB_%02d_Q", file.currentSubjectID, idx )
			showButtonPrompt = false
		}

		var rui = Hud_GetRui( button )
		RuiSetBool( rui, "showButtonPrompt", showButtonPrompt )
		SetButtonRuiText( button, labelText )
	}

	RuiSetGameTime( file.descriptionRui, "initTime", Time() )
	RuiSetString( file.descriptionRui, "headerText", "" )
	RuiSetString( file.descriptionRui, "messageText", "" )
	thread DelayedSetFocusThread( file.questionButtons[0] )
}

void function DelayedSetFocusThread( var item )
{
	WaitEndFrame()
	Hud_SetFocused( item )
}

