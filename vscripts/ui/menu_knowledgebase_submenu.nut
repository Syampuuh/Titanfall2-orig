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
	8,		// KNB_SUBJECT_SUB_COUNTS[7]
	16,		// KNB_SUBJECT_SUB_COUNTS[8]
	6,		// KNB_SUBJECT_SUB_COUNTS[9]
	14,		// KNB_SUBJECT_SUB_COUNTS[10]
]
global const int KNB_SUBJECT_COUNT = 11
global const int KNB_PATCHNOTES_INDEX = 0
////////////////////////////////////////////////////////////


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

		AddButtonEventHandler( button, UIE_GET_FOCUS, OnKBNSubjectButtonFocus )
	}

	var ruiContainer = Hud_GetChild( menu, "LabelDetails" )
	file.descriptionRui = Hud_GetRui( ruiContainer )

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnOpenKnowledgeBaseSubMenu )
	AddMenuFooterOption( menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
}

void function OnKBNSubjectButtonFocus( var button )
{
	int buttonID = int( Hud_GetScriptID( button ) )

	string questionText = format( "#KNB_SUBJECT_%02d_SUB_%02d_Q", file.currentSubjectID, buttonID )
	string answerText = format( "#KNB_SUBJECT_%02d_SUB_%02d_A", file.currentSubjectID, buttonID )

	RuiSetString( file.descriptionRui, "headerText", Localize( questionText ) )
	RuiSetString( file.descriptionRui, "messageText", Localize( answerText ) )
	RuiSetGameTime( file.descriptionRui, "startTime", Time() )
}

int function GetPatchNotesQuestionCount()
{
	return GetCurrentPlaylistVarInt( "faq_patchnotes_count", 0 )
}

void function OnOpenKnowledgeBaseSubMenu()
{
	//UI_SetPresentationType( ePresentationType.KNOWLEDGEBASE_SUB )
	UI_SetPresentationType( ePresentationType.NO_MODELS )

	int questionCount = ((file.currentSubjectID == KNB_PATCHNOTES_INDEX) ? GetPatchNotesQuestionCount() : KNB_SUBJECT_SUB_COUNTS[file.currentSubjectID])

	Hud_SetText( file.thisMenuHeader, (Localize( "#KNB_MENU_HEADER" ) + "  :  "+ Localize( format( "#KNB_SUBJECT_%02d_NAME", file.currentSubjectID )) ) )

	for ( int idx = 0; idx < MAX_BUTTONS; ++idx )
	{
		var button = file.questionButtons[idx]

		if ( idx > (questionCount - 1) )
		{
			Hud_SetVisible( button, false )
			continue
		}

		Hud_SetVisible( button, true )
		string labelText = format( "#KNB_SUBJECT_%02d_SUB_%02d_Q", file.currentSubjectID, idx )
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

void function OnInfo1Focus( var button )
{
	RuiSetString( file.descriptionRui, "messageText", "`1How does leveling up work?`0\n\nYour Pilot level is the main track of advancement, you'll find it in the upper right corner of this screen.\n\nPilot level increases by earning %$rui/merits/player_merit%merits.\n\nTitans, Factions, and Pilot weapons also have levels of advancement.  Leveling these not only unlocks new items but they also feed into increasing your Pilot Level.   \n\n`1What else has levels of advancement?`0\n\n%$rui/bullet_point%Pilot Weapons\n%$rui/bullet_point%Titans\n%$rui/bullet_point%Factions" )
}

void function OnInfo2Focus( var button )
{
	RuiSetString( file.descriptionRui, "messageText", "`1What are merits?`0\n\n%$rui/merits/player_merit% Merits are earned rewards that give you both 1 experience point and 1%$rui/merits/credit_sign% .\n\n`1How do I get them?`0\n\n%$rui/bullet_point%Match Win\n%$rui/bullet_point%Match Complete\n%$rui/bullet_point%Good Performance\n%$rui/bullet_point%Weapon Level Up\n%$rui/bullet_point%Titanfall\n%$rui/bullet_point%Titan Core Earned\n%$rui/bullet_point%Titan Kill by Titan\n%$rui/bullet_point%Faction Level Up\n%$rui/bullet_point%Happy Hour Network bonus" )
}
void function OnInfo3Focus( var button )
{
	RuiSetString( file.descriptionRui, "messageText", "`1What is regeneration?`0\n\n%$rui/gencard_icons/gc_icon_gen1% When you reach the maximum Pilot level you're given the option to regenerate.\n\nRegeneration relocks all of your Pilot loadout items that have not been purchased with %$rui/merits/credit_sign%credits and opens up the ability to unlock high level unlocks.\nYour first regen changes the way your rank is displayed, moving from Level 50 to G2.0.\n\n`1Automatic Regeneration`0\n\nPilot Weapons, Titans, and Factions regenerate automatically and feature no downsides.\n\n`1Permanent Unlocks`0\n\nItems purchased with %$rui/merits/credit_sign%credits never relock after a Pilot regeneration.  Weapons and Titans never reset their progress, when you unlock them again after regeneration they will be the level they were before you regenerated." )
}

void function OnEconInfo1Focus( var button )
{
	RuiSetString( file.descriptionRui, "messageText", "`1What are credits?`0\n\n%$rui/merits/credit_sign% Credits are an in-game currency that you can use to unlock items early and permanently.\n\n`1How do I get them?`0\n\nFor every merit you earn you also get 1 %$rui/merits/credit_sign% credit. You can also recieve credits through Advocate Gifts." )
}

void function OnEconInfo2Focus( var button )
{
	RuiSetString( file.descriptionRui, "messageText", "`1What are Advocate Gifts?`0\n\nAdvocate Gifts are random rewards that are given to you through the Inbox from the Advocate.\n\n`1How do I get them?`0\n\nLeveling up a Faction and fighting in the Coliseum playlist are the most direct ways to get Advocate Gifts.\n\nYou also get Advocate Gifts through the various level advancement tracks.\n\n`1What are the potential rewards?`0\n\n%$rui/bullet_point%Pilot, Titan, and Weapon Camos\n%$rui/bullet_point%Callsign Banners and Patches\n%$rui/bullet_point%Titan Nose Art\n%$rui/bullet_point%Pilot Executions\n%$rui/bullet_point%Coliseum Tickets\n%$rui/bullet_point%Credits`" )
}

void function OnModeInfo1Focus( var button )
{
	RuiSetString( file.descriptionRui, "messageText", "`1What's the objective'?`0\n\nHave your team earn more money than the enemy team.\n\n`1What are the rules'?`0\n\nBounty Hunt matches are divided into 3 different types of phases:\n\n%$rui/hud/gametype_icons/bounty_hunt/bh_grunt%Infantry Phase - kill Remnant Fleet AI\n\n%$rui/hud/gametype_icons/bounty_hunt/bh_bank_icon%Banking Phase - cash in your BONUS %$rui/hud/gametype_icons/bounty_hunt/bh_bonus_icon% at 1 of 2 hardpoints\n\n%$rui/hud/gametype_icons/bounty_hunt/bh_titan%Titan Phase - Remnant Fleet AI Titan(s) worth big points.\n\nYou earn %$rui/hud/gametype_icons/bounty_hunt/bh_bank_icon% by killing neutral AI enemies %$rui/hud/gametype_icons/bounty_hunt/bh_grunt% as well as the enemy team. For every %$rui/hud/gametype_icons/bounty_hunt/bh_bank_icon% you earn this way you also get an equal amount of %$rui/hud/gametype_icons/bounty_hunt/bh_bank_icon% added to your BONUS %$rui/hud/gametype_icons/bounty_hunt/bh_bonus_icon% wallet.\n\n" )
}
void function OnModeInfo2Focus( var button )
{
	RuiSetString( file.descriptionRui, "messageText", "`1What are credits?`0\n\n" )
}

