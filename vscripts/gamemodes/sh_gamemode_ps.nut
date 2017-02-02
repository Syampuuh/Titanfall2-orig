
global function GamemodePsShared_Init

void function GamemodePsShared_Init()
{
	SetWaveSpawnInterval( 8.0 )
	SetScoreEventOverrideFunc( PS_SetScoreEventOverride )
}

void function PS_SetScoreEventOverride()
{
	ScoreEvent_SetGameModeRelevant( GetScoreEvent( "KillPilot" ) )
}