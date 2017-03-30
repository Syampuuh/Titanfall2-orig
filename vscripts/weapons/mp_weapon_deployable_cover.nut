untyped

global function MpWeaponDeployableCover_Init

global function OnWeaponTossReleaseAnimEvent_weapon_deployable_cover
global function OnWeaponAttemptOffhandSwitch_weapon_deployable_cover
global function OnWeaponTossPrep_weapon_deployable_cover


const DEPLOYABLE_ONE_PER_PLAYER = false
const DEPLOYABLE_SHIELD_DURATION = 15.0

const DEPLOYABLE_SHIELD_FX = $"P_pilot_cover_shield"
const DEPLOYABLE_SHIELD_FX_AMPED = $"P_pilot_amped_shield"
const DEPLOYABLE_SHIELD_HEALTH = 850

const DEPLOYABLE_SHIELD_RADIUS = 84
const DEPLOYABLE_SHIELD_HEIGHT = 89
const DEPLOYABLE_SHIELD_FOV = 150

const DEPLOYABLE_SHIELD_ANGLE_LIMIT = 0.55

struct
{
	int index
}file;

function MpWeaponDeployableCover_Init()
{
	PrecacheParticleSystem( DEPLOYABLE_SHIELD_FX )
	file.index = PrecacheParticleSystem( DEPLOYABLE_SHIELD_FX_AMPED )
	PrecacheModel( $"models/fx/pilot_shield_wall_amped.mdl" )
}

bool function OnWeaponAttemptOffhandSwitch_weapon_deployable_cover( entity weapon )
{
	int ammoReq = weapon.GetAmmoPerShot()
	int currAmmo = weapon.GetWeaponPrimaryClipCount()
	if ( currAmmo < ammoReq )
		return false

	entity player = weapon.GetWeaponOwner()
	if ( player.IsPhaseShifted() )
		return false

	return true
}

var function OnWeaponTossReleaseAnimEvent_weapon_deployable_cover( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	int ammoReq = weapon.GetAmmoPerShot()
	weapon.EmitWeaponSound_1p3p( GetGrenadeThrowSound_1p( weapon ), GetGrenadeThrowSound_3p( weapon ) )

	#if SERVER
	if ( DEPLOYABLE_ONE_PER_PLAYER && IsValid( weapon.w.lastProjectileFired ) )
		weapon.w.lastProjectileFired.Destroy()
	#endif

	entity deployable = ThrowDeployable( weapon, attackParams, DEPLOYABLE_THROW_POWER, OnDeployableCoverPlanted )
	if ( deployable )
	{
		entity player = weapon.GetWeaponOwner()
		PlayerUsedOffhand( player, weapon )

		#if SERVER
		string projectileSound = GetGrenadeProjectileSound( weapon )
		if ( projectileSound != "" )
			EmitSoundOnEntity( deployable, projectileSound )

		weapon.w.lastProjectileFired = deployable
		#endif

		#if BATTLECHATTER_ENABLED && SERVER
			TryPlayWeaponBattleChatterLine( player, weapon )
		#endif
	}

	#if SERVER && MP
		if ( weapon.HasMod( "burn_card_weapon_mod" ) )
		{
			TryUsingBurnCardWeapon( weapon, weapon.GetWeaponOwner() )
		}
	#endif
	return ammoReq
}

void function OnWeaponTossPrep_weapon_deployable_cover( entity weapon, WeaponTossPrepParams prepParams )
{
	weapon.EmitWeaponSound_1p3p( GetGrenadeDeploySound_1p( weapon ), GetGrenadeDeploySound_3p( weapon ) )
}

void function OnDeployableCoverPlanted( entity projectile )
{
	#if SERVER
		vector origin = projectile.GetOrigin()

		vector endOrigin = origin - Vector( 0.0, 0.0, 32.0 )
		vector surfaceAngles = projectile.proj.savedAngles
		vector oldUpDir = AnglesToUp( surfaceAngles )

		TraceResults traceResult = TraceLine( origin, endOrigin, [], TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE )
		if ( traceResult.fraction < 1.0 )
		{
			vector forward = AnglesToForward( projectile.proj.savedAngles )
			surfaceAngles = AnglesOnSurface( traceResult.surfaceNormal, forward )

			vector newUpDir = AnglesToUp( surfaceAngles )
			if ( DotProduct( newUpDir, oldUpDir ) < DEPLOYABLE_SHIELD_ANGLE_LIMIT )
				surfaceAngles = projectile.proj.savedAngles
		}

		projectile.SetAngles( surfaceAngles )

		bool isAmpedWall = !( projectile.ProjectileGetMods().contains( "burn_card_weapon_mod" ) ) //Unusual, but deliberate: the boost version of the weapon does not have amped functionality

		if ( isAmpedWall )
			DeployAmpedWall( projectile, origin, surfaceAngles )
		else
			DeployCover( projectile, origin, surfaceAngles )
	#endif
}

#if SERVER
function DeployCover( entity projectile, vector origin, vector angles )
{
	EmitSoundOnEntity( projectile, "Hardcover_Shield_Start_3P" )

	vector fwd = AnglesToForward( angles )
	vector up = AnglesToUp( angles )
	origin = origin - (fwd * (DEPLOYABLE_SHIELD_RADIUS - 1.0))
	origin = origin - (up * 1.0)

	entity vortexSphere = CreateShieldWithSettings( origin, angles, DEPLOYABLE_SHIELD_RADIUS, DEPLOYABLE_SHIELD_HEIGHT, DEPLOYABLE_SHIELD_FOV, DEPLOYABLE_SHIELD_DURATION, DEPLOYABLE_SHIELD_HEALTH, DEPLOYABLE_SHIELD_FX )
	vortexSphere.SetParent( projectile )
	vortexSphere.EndSignal( "OnDestroy" )
	vortexSphere.SetBlocksRadiusDamage( true )

	UpdateShieldWallColorForFrac( vortexSphere.e.shieldWallFX, GetHealthFrac( vortexSphere ) )

	OnThreadEnd(
		function() : ( vortexSphere, projectile )
		{
			StopSoundOnEntity( projectile, "Hardcover_Shield_Start_3P" )
			EmitSoundOnEntity( projectile, "Hardcover_Shield_End_3P" )

			if ( IsValid( projectile ) )
				projectile.GrenadeExplode( Vector(0,0,0) )

			if ( IsValid( vortexSphere ) )
				vortexSphere.Destroy()
		}
	)

	wait DEPLOYABLE_SHIELD_DURATION
}

function DeployAmpedWall( entity grenade, vector origin, vector angles )
{
	EmitSoundOnEntity( grenade, "Hardcover_Shield_Start_3P" )
	grenade.SetBlocksRadiusDamage( true )

	vector fwd = AnglesToForward( angles )
	vector up = AnglesToUp( angles )
	origin = origin - (fwd * (DEPLOYABLE_SHIELD_RADIUS - 1.0))
	origin = origin - (up * 1.0)

	entity shieldFX = StartParticleEffectInWorld_ReturnEntity( file.index, origin, angles )

	angles = AnglesCompose( angles, <0,180,0> )
	entity ampedWall = CreatePropDynamic( $"models/fx/pilot_shield_wall_amped.mdl", origin, angles, SOLID_VPHYSICS )
	ampedWall.kv.contents = (CONTENTS_WINDOW)
	ampedWall.kv.CollisionGroup = TRACE_COLLISION_GROUP_BLOCK_WEAPONS_AND_PHYSICS
	ampedWall.SetPassThroughFlags( PTF_ADDS_MODS | PTF_NO_DMG_ON_PASS_THROUGH )
	ampedWall.SetBlocksRadiusDamage( true )
	ampedWall.Hide()
	ampedWall.SetTakeDamageType( DAMAGE_YES)
	ampedWall.SetMaxHealth( 1000 )
	ampedWall.SetHealth( 1000 )
	ampedWall.EndSignal( "OnDestroy" )

	SetTeam( ampedWall, TEAM_BOTH )

	ampedWall.SetPassThroughThickness( 0 )
	ampedWall.SetPassThroughDirection( -0.55 )
	StatusEffect_AddTimed( ampedWall, eStatusEffect.pass_through_amps_weapon, 1.0, DEPLOYABLE_SHIELD_DURATION, 0.0 )

	CreateAirShakeRumbleOnly( origin, 16, 150, 0.6, 150 )

	entity owner = grenade.GetThrower()
	if ( IsValid( owner ) && owner.IsPlayer() )
	{
		array<entity> offhandWeapons = owner.GetOffhandWeapons()
		foreach ( weapon in offhandWeapons )
		{
			//if ( weapon.GetWeaponClassName() == grenade.GetWeaponClassName() ) // function doesn't exist for grenade entities
			if ( weapon.GetWeaponClassName() == "mp_weapon_deployable_cover" )
			{
				StatusEffect_AddTimed( weapon, eStatusEffect.simple_timer, 1.0, DEPLOYABLE_SHIELD_DURATION, DEPLOYABLE_SHIELD_DURATION )
				break
			}
		}
	}

	OnThreadEnd(
		function() : ( ampedWall, grenade, shieldFX )
		{
			StopSoundOnEntity( grenade, "Hardcover_Shield_Start_3P" )
			EmitSoundOnEntity( grenade, "Hardcover_Shield_End_3P" )

			if ( IsValid( grenade ) )
				grenade.GrenadeExplode( Vector( 0, 0, 0 ) )

			if ( IsValid( ampedWall ) )
				ampedWall.Destroy()

			if ( IsValid( shieldFX ) )
				shieldFX.Destroy()
		}
	)

	wait DEPLOYABLE_SHIELD_DURATION
}
#endif