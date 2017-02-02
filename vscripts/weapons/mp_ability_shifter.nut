global function OnWeaponPrimaryAttack_shifter

const SHIFTER_WARMUP_TIME = 0.0
const SHIFTER_WARMUP_TIME_FAST = 0.0

var function OnWeaponPrimaryAttack_shifter( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	float warmupTime = SHIFTER_WARMUP_TIME
	if ( weapon.HasMod( "short_shift" ) )
	{
		warmupTime = SHIFTER_WARMUP_TIME_FAST
	}

	entity weaponOwner = weapon.GetWeaponOwner()

	int phaseResult = PhaseShift( weaponOwner, warmupTime, weapon.GetWeaponSettingFloat( eWeaponVar.fire_duration ) )

	if ( phaseResult )
	{
		PlayerUsedOffhand( weaponOwner, weapon )
		#if BATTLECHATTER_ENABLED && SERVER
			TryPlayWeaponBattleChatterLine( weaponOwner, weapon )
		#endif

		return weapon.GetWeaponSettingInt( eWeaponVar.ammo_min_to_fire )
	}

	return 0
}