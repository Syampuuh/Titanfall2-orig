global function OnWeaponPrimaryAttack_ability_grapple
global function OnWeaponAttemptOffhandSwitch_ability_grapple

#if SERVER
global function OnWeaponNpcPrimaryAttack_ability_grapple
#endif

var function OnWeaponPrimaryAttack_ability_grapple( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity owner = weapon.GetWeaponOwner()

#if SERVER
	if ( owner.MayGrapple() )
	{
		#if BATTLECHATTER_ENABLED
			TryPlayWeaponBattleChatterLine( owner, weapon ) //Note that this is fired whenever you fire the grapple, not when you've successfully grappled something. No callback for that unfortunately...
		#endif
	}
#endif

	PlayerUsedOffhand( owner, weapon )

	owner.Grapple( attackParams.dir )

	return 1
}

#if SERVER
var function OnWeaponNpcPrimaryAttack_ability_grapple( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity owner = weapon.GetWeaponOwner()

	owner.GrappleNPC( attackParams.dir )

	return 1
}
#endif

bool function OnWeaponAttemptOffhandSwitch_ability_grapple( entity weapon )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	bool allowSwitch = (ownerPlayer.GetSuitGrapplePower() >= 100.0)

	if ( !allowSwitch )
	{
		entity ownerPlayer = weapon.GetWeaponOwner()
		ownerPlayer.Grapple( <0,0,1> )
	}

	return allowSwitch
}
