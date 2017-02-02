
global function MpTitanAbilityBasicBlock_Init

global function OnWeaponActivate_titanability_basic_block
global function OnWeaponDeactivate_titanability_basic_block
global function OnWeaponAttemptOffhandSwitch_titanability_basic_block
global function OnWeaponPrimaryAttack_titanability_basic_block
global function OnWeaponChargeBegin_titanability_basic_block

const BLOCK_DAMAGE_REDUCTION = 0.25
const SWORD_CORE_BLOCK_DAMAGE_REDUCTION = 0.1
const BLOCK_DAMAGE_REDUCTION_ANGLE = 150

void function MpTitanAbilityBasicBlock_Init()
{
	#if SERVER
		AddDamageCallback( "player", TitanBasicBlock_OnDamage )
		AddDamageCallback( "npc_titan", TitanBasicBlock_OnDamage )
	#endif
	PrecacheParticleSystem( $"P_impact_xo_sword" )
}

bool function OnWeaponChargeBegin_titanability_basic_block( entity weapon )
{
	weapon.EmitWeaponSound_1p3p( "", "ronin_sword_draw_3p" )
	return true
}

void function OnWeaponActivate_titanability_basic_block( entity weapon )
{
	entity weaponOwner = weapon.GetWeaponOwner()
	if ( weaponOwner.IsPlayer() )
		PlayerUsedOffhand( weaponOwner, weapon )
	StartShield( weapon )
	entity offhandWeapon = weaponOwner.GetOffhandWeapon( OFFHAND_MELEE )
	if ( IsValid( offhandWeapon ) && offhandWeapon.HasMod( "super_charged" ) )
		thread BlockSwordCoreFXThink( weapon, weaponOwner )
}

void function BlockSwordCoreFXThink( entity weapon, entity weaponOwner )
{
	weapon.EndSignal( "WeaponDeactivateEvent" )
	weapon.EndSignal( "OnDestroy" )

	weapon.PlayWeaponEffectNoCull( SWORD_GLOW_FP, SWORD_GLOW, "sword_edge" )

	weaponOwner.WaitSignal( "CoreEnd" )

	weapon.StopWeaponEffect( SWORD_GLOW_FP, SWORD_GLOW )
}

void function OnWeaponDeactivate_titanability_basic_block( entity weapon )
{
	EndShield( weapon )
}

void function StartShield( entity weapon )
{
	#if SERVER
	entity weaponOwner = weapon.GetWeaponOwner()
	weaponOwner.e.blockActive = true
	#endif
}


void function EndShield( entity weapon )
{
	#if SERVER
	entity titan = weapon.GetWeaponOwner()
	titan.e.blockActive = false
	#endif
}

bool function OnWeaponAttemptOffhandSwitch_titanability_basic_block( entity weapon )
{
	bool allowSwitch = weapon.GetWeaponChargeFraction() < 0.9
	return allowSwitch
}

var function OnWeaponPrimaryAttack_titanability_basic_block( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return 0
}

#if SERVER

void function IncrementChargeBlockAnim( entity titan, var damageInfo )
{
	entity weapon = titan.GetActiveWeapon()
	if ( !IsValid( weapon ) )
		return
	if ( !weapon.IsChargeWeapon() )
		return

	int oldIdx = weapon.GetChargeAnimIndex()
	int newIdx = RandomInt( CHARGE_ACTIVITY_ANIM_COUNT )
	if ( oldIdx == newIdx )
		oldIdx = ((oldIdx + 1) % CHARGE_ACTIVITY_ANIM_COUNT)
	weapon.SetChargeAnimIndex( newIdx )
}
//ronin_sword_bullet_impacts
void function TitanBasicBlock_OnDamage( entity titan, var damageInfo )
{
	if ( !titan.e.blockActive )
		return

	bool modifyDamage = ( ( DamageInfo_GetCustomDamageType( damageInfo ) & DF_RODEO ) > 0 )
	modifyDamage = modifyDamage || ( ( DamageInfo_GetCustomDamageType( damageInfo ) & DF_MELEE ) > 0 )
	modifyDamage = modifyDamage || ( ( DamageInfo_GetCustomDamageType( damageInfo ) & DF_DOOMED_HEALTH_LOSS ) > 0 )

	if ( !modifyDamage )
	{
		entity attacker = DamageInfo_GetAttacker( damageInfo )

		int attachId = titan.LookupAttachment( "PROPGUN" )
		vector origin = GetDamageOrigin( damageInfo, titan )
		vector eyePos = titan.GetAttachmentOrigin( attachId )
		vector blockAngles = titan.GetAttachmentAngles( attachId )
		vector fwd = AnglesToForward( blockAngles )

		vector vec1 = Normalize( origin - eyePos )
		vector vec2 = fwd

		float dot = DotProduct( vec1, vec2 )

		if ( dot > AngleToDot( BLOCK_DAMAGE_REDUCTION_ANGLE ) )
		{
			IncrementChargeBlockAnim( titan, damageInfo )
			EmitSoundOnEntity( titan, "ronin_sword_bullet_impacts" )
			if ( titan.IsPlayer() )
				titan.RumbleEffect( 1, 0, 0 )
			StartParticleEffectInWorldWithControlPoint( GetParticleSystemIndex( $"P_impact_xo_sword" ), DamageInfo_GetDamagePosition( damageInfo ) + vec1*200, VectorToAngles( vec1 ) + <90,0,0>, <255,255,255> )
			//Update passive to soul for it to work with NPCs
			if( titan.IsPlayer() && PlayerHasPassive( titan, ePassives.PAS_SHIFT_CORE ) )
				DamageInfo_ScaleDamage( damageInfo, SWORD_CORE_BLOCK_DAMAGE_REDUCTION )
			else
				DamageInfo_ScaleDamage( damageInfo, BLOCK_DAMAGE_REDUCTION )
			// ideally this would be DF_INEFFECTIVE, but we are out of damage flags
			DamageInfo_AddCustomDamageType( damageInfo, DF_NO_INDICATOR )
			DamageInfo_RemoveCustomDamageType( damageInfo, DF_DOOM_FATALITY )
		}
	}
}
#endif