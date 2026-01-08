# GdUnit generated TestSuite
class_name EntityUtilsTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source: String = 'res://scripts/utils/EntityUtils.gd'
const __script = preload(__source)


#region Boolean Check Functions (is_X)
func test_is_broken_true() -> void:
	var entity := Entity.new()
	var durability := ZC_Durability.new()
	durability.current_durability = 0
	entity.add_component(durability)

	var result = __script.is_broken(entity)
	entity.queue_free()
	assert_bool(result).is_true()


func test_is_broken_false() -> void:
	var entity := Entity.new()
	var durability := ZC_Durability.new()
	durability.current_durability = 10
	entity.add_component(durability)

	var result = __script.is_broken(entity)
	entity.queue_free()
	assert_bool(result).is_false()


func test_is_broken_no_component() -> void:
	var entity := Entity.new()
	var result = __script.is_broken(entity)
	entity.queue_free()
	assert_bool(result).is_false()


func test_is_broken_not_entity() -> void:
	var node := Node.new()
	var result = __script.is_broken(node)
	node.queue_free()
	assert_bool(result).is_false()


func test_is_ammo_empty_true() -> void:
	var ammo := ZC_Ammo.new()
	ammo.ammo_count = {"bullets": 0, "shells": 0}

	var result = __script.is_ammo_empty(ammo)
	assert_bool(result).is_true()


func test_is_ammo_empty_false() -> void:
	var ammo := ZC_Ammo.new()
	ammo.ammo_count = {"bullets": 5, "shells": 0}

	var result = __script.is_ammo_empty(ammo)
	assert_bool(result).is_false()


func test_is_enemy_true() -> void:
	var entity := Entity.new()
	var faction := ZC_Faction.new()
	faction.faction_name = "enemy_zombie"
	entity.add_component(faction)

	var result = __script.is_enemy(entity)
	entity.queue_free()
	assert_bool(result).is_true()


func test_is_enemy_false() -> void:
	var entity := Entity.new()
	var faction := ZC_Faction.new()
	faction.faction_name = "friendly_npc"
	entity.add_component(faction)

	var result = __script.is_enemy(entity)
	entity.queue_free()
	assert_bool(result).is_false()


func test_is_enemy_not_entity() -> void:
	var node := Node.new()
	var result = __script.is_enemy(node)
	node.queue_free()
	assert_bool(result).is_false()


func test_is_player_true() -> void:
	var entity := Entity.new()
	entity.add_component(ZC_Player.new())

	var result = __script.is_player(entity)
	entity.queue_free()
	assert_bool(result).is_true()


func test_is_player_false() -> void:
	var entity := Entity.new()
	var result = __script.is_player(entity)
	entity.queue_free()
	assert_bool(result).is_false()


func test_is_player_not_entity() -> void:
	var node := Node.new()
	var result = __script.is_player(node)
	node.queue_free()
	assert_bool(result).is_false()


func test_is_explosive_true() -> void:
	var entity := Entity.new()
	entity.add_component(ZC_Explosive.new())

	var result = __script.is_explosive(entity)
	entity.queue_free()
	assert_bool(result).is_true()


func test_is_explosive_false() -> void:
	var entity := Entity.new()
	var result = __script.is_explosive(entity)
	entity.queue_free()
	assert_bool(result).is_false()


func test_is_flammable_true() -> void:
	var entity := Entity.new()
	entity.add_component(ZC_Flammable.new())

	var result = __script.is_flammable(entity)
	entity.queue_free()
	assert_bool(result).is_true()


func test_is_flammable_false() -> void:
	var entity := Entity.new()
	var result = __script.is_flammable(entity)
	entity.queue_free()
	assert_bool(result).is_false()


func test_is_interactive_true() -> void:
	var entity := Entity.new()
	entity.add_component(ZC_Interactive.new())

	var result = __script.is_interactive(entity)
	entity.queue_free()
	assert_bool(result).is_true()


func test_is_interactive_false() -> void:
	var entity := Entity.new()
	var result = __script.is_interactive(entity)
	entity.queue_free()
	assert_bool(result).is_false()


func test_is_locked_true() -> void:
	var entity := Entity.new()
	var locked := ZC_Locked.new()
	locked.is_locked = true
	entity.add_component(locked)

	var result = __script.is_locked(entity)
	entity.queue_free()
	assert_bool(result).is_true()


func test_is_locked_false_unlocked() -> void:
	var entity := Entity.new()
	var locked := ZC_Locked.new()
	locked.is_locked = false
	entity.add_component(locked)

	var result = __script.is_locked(entity)
	entity.queue_free()
	assert_bool(result).is_false()


func test_is_locked_false_no_component() -> void:
	var entity := Entity.new()
	var result = __script.is_locked(entity)
	entity.queue_free()
	assert_bool(result).is_false()


func test_is_objective_true() -> void:
	var entity := Entity.new()
	entity.add_component(ZC_Objective.new())

	var result = __script.is_objective(entity)
	entity.queue_free()
	assert_bool(result).is_true()


func test_is_objective_false() -> void:
	var entity := Entity.new()
	var result = __script.is_objective(entity)
	entity.queue_free()
	assert_bool(result).is_false()


func test_is_weapon_melee() -> void:
	var entity := Entity.new()
	entity.add_component(ZC_Weapon_Melee.new())

	var result = __script.is_weapon(entity)
	entity.queue_free()
	assert_bool(result).is_true()


func test_is_weapon_ranged() -> void:
	var entity := Entity.new()
	entity.add_component(ZC_Weapon_Ranged.new())

	var result = __script.is_weapon(entity)
	entity.queue_free()
	assert_bool(result).is_true()


func test_is_weapon_thrown() -> void:
	var entity := Entity.new()
	entity.add_component(ZC_Weapon_Thrown.new())

	var result = __script.is_weapon(entity)
	entity.queue_free()
	assert_bool(result).is_true()


func test_is_weapon_false() -> void:
	var entity := Entity.new()
	var result = __script.is_weapon(entity)
	entity.queue_free()
	assert_bool(result).is_false()


func test_is_melee_weapon_true() -> void:
	var entity := Entity.new()
	entity.add_component(ZC_Weapon_Melee.new())

	var result = __script.is_melee_weapon(entity)
	entity.queue_free()
	assert_bool(result).is_true()


func test_is_melee_weapon_false() -> void:
	var entity := Entity.new()
	entity.add_component(ZC_Weapon_Ranged.new())

	var result = __script.is_melee_weapon(entity)
	entity.queue_free()
	assert_bool(result).is_false()


func test_is_ranged_weapon_ranged() -> void:
	var entity := Entity.new()
	entity.add_component(ZC_Weapon_Ranged.new())

	var result = __script.is_ranged_weapon(entity)
	entity.queue_free()
	assert_bool(result).is_true()


func test_is_ranged_weapon_thrown() -> void:
	var entity := Entity.new()
	entity.add_component(ZC_Weapon_Thrown.new())

	var result = __script.is_ranged_weapon(entity)
	entity.queue_free()
	assert_bool(result).is_true()


func test_is_ranged_weapon_false() -> void:
	var entity := Entity.new()
	entity.add_component(ZC_Weapon_Melee.new())

	var result = __script.is_ranged_weapon(entity)
	entity.queue_free()
	assert_bool(result).is_false()


func test_is_thrown_weapon_true() -> void:
	var entity := Entity.new()
	entity.add_component(ZC_Weapon_Thrown.new())

	var result = __script.is_thrown_weapon(entity)
	entity.queue_free()
	assert_bool(result).is_true()


func test_is_thrown_weapon_false() -> void:
	var entity := Entity.new()
	entity.add_component(ZC_Weapon_Melee.new())

	var result = __script.is_thrown_weapon(entity)
	entity.queue_free()
	assert_bool(result).is_false()


func test_has_shimmer_true() -> void:
	var entity := Entity.new()
	entity.add_component(ZC_Shimmer.new())

	var result = __script.has_shimmer(entity)
	entity.queue_free()
	assert_bool(result).is_true()


func test_has_shimmer_false() -> void:
	var entity := Entity.new()
	var result = __script.has_shimmer(entity)
	entity.queue_free()
	assert_bool(result).is_false()


func test_has_health_true() -> void:
	var entity := Entity.new()
	entity.add_component(ZC_Health.new())

	var result = __script.has_health(entity)
	entity.queue_free()
	assert_bool(result).is_true()


func test_has_health_false() -> void:
	var entity := Entity.new()
	var result = __script.has_health(entity)
	entity.queue_free()
	assert_bool(result).is_false()
#endregion


#region Getter Functions
func test_get_damage_multiplier_default() -> void:
	var entity := Entity.new()
	var result = __script.get_damage_multiplier(entity)
	entity.queue_free()
	assert_float(result).is_equal(1.0)


func test_get_damage_multiplier_with_armor() -> void:
	var entity := Entity.new()
	var armor := ZC_Effect_Armor.new()
	armor.multiplier = 0.5
	var modifier := RelationshipUtils.make_modifier(armor)
	entity.add_relationship(modifier)

	var result = __script.get_damage_multiplier(entity)
	entity.queue_free()
	assert_float(result).is_equal(0.5)


func test_get_damage_multiplier_not_entity() -> void:
	var node := Node.new()
	var result = __script.get_damage_multiplier(node)
	node.queue_free()
	assert_float(result).is_equal(1.0)


func test_get_speed_multiplier_default() -> void:
	var entity := Entity.new()
	var result = __script.get_speed_multiplier(entity)
	entity.queue_free()
	assert_float(result).is_equal(1.0)


func test_get_speed_multiplier_with_effect() -> void:
	var entity := Entity.new()
	var speed := ZC_Effect_Speed.new()
	speed.multiplier = 1.5
	var modifier := RelationshipUtils.make_modifier(speed)
	entity.add_relationship(modifier)

	var result = __script.get_speed_multiplier(entity)
	entity.queue_free()
	assert_float(result).is_equal(1.5)


func test_get_speed_multiplier_not_entity() -> void:
	var node := Node.new()
	var result = __script.get_speed_multiplier(node)
	node.queue_free()
	assert_float(result).is_equal(1.0)


func test_get_ranged_component_ranged() -> void:
	var weapon := ZE_Weapon.new()
	var ranged := ZC_Weapon_Ranged.new()
	weapon.add_component(ranged)

	var result = __script.get_ranged_component(weapon)
	weapon.queue_free()
	assert_object(result).is_equal(ranged)


func test_get_ranged_component_thrown() -> void:
	var weapon := ZE_Weapon.new()
	var thrown := ZC_Weapon_Thrown.new()
	weapon.add_component(thrown)

	var result = __script.get_ranged_component(weapon)
	weapon.queue_free()
	assert_object(result).is_equal(thrown)


func test_get_ranged_component_null() -> void:
	var weapon := ZE_Weapon.new()
	var result = __script.get_ranged_component(weapon)
	weapon.queue_free()
	assert_object(result).is_null()
#endregion


#region Action Functions
func test_apply_damage_success() -> void:
	var actor := Entity.new()
	var target := Entity.new()
	target.add_component(ZC_Health.new())

	var damage = __script.apply_damage(actor, target, 10, 1.0)

	assert_int(damage).is_equal(10)

	# Verify damage relationship was added
	var damages := RelationshipUtils.get_damage(target)
	assert_array(damages).is_not_empty()

	actor.queue_free()
	target.queue_free()


func test_apply_damage_with_multiplier() -> void:
	var actor := Entity.new()
	var target := Entity.new()
	target.add_component(ZC_Health.new())

	var damage = __script.apply_damage(actor, target, 10, 2.0)

	assert_int(damage).is_equal(20)

	actor.queue_free()
	target.queue_free()


func test_apply_damage_no_health() -> void:
	var actor := Entity.new()
	var target := Entity.new()

	var damage = __script.apply_damage(actor, target, 10, 1.0)

	assert_int(damage).is_equal(0)

	actor.queue_free()
	target.queue_free()


func test_apply_damage_not_entity() -> void:
	var actor := Entity.new()
	var target := Node.new()

	var damage = __script.apply_damage(actor, target, 10, 1.0)

	assert_int(damage).is_equal(0)

	actor.queue_free()
	target.queue_free()
#endregion


#region Edge Cases
func test_multiple_weapon_checks() -> void:
	# Ensure weapon type checks are exclusive
	var melee := Entity.new()
	melee.add_component(ZC_Weapon_Melee.new())

	assert_bool(__script.is_weapon(melee)).is_true()
	assert_bool(__script.is_melee_weapon(melee)).is_true()
	assert_bool(__script.is_ranged_weapon(melee)).is_false()
	assert_bool(__script.is_thrown_weapon(melee)).is_false()

	melee.queue_free()


func test_locked_vs_unlocked() -> void:
	# Test the distinction between having the component and being locked
	var entity := Entity.new()
	var locked := ZC_Locked.new()
	locked.is_locked = false
	entity.add_component(locked)

	# Has the component but is not locked
	assert_bool(entity.has_component(ZC_Locked)).is_true()
	assert_bool(__script.is_locked(entity)).is_false()

	# Now lock it
	locked.is_locked = true
	assert_bool(__script.is_locked(entity)).is_true()

	entity.queue_free()


func test_ammo_empty_with_multiple_types() -> void:
	var ammo := ZC_Ammo.new()
	ammo.ammo_count = {"bullets": 0, "shells": 3, "rockets": 0}

	# Should be false because shells > 0
	var result = __script.is_ammo_empty(ammo)
	assert_bool(result).is_false()


func test_damage_multiplier_stacking() -> void:
	var entity := Entity.new()

	# Add multiple armor effects
	var armor1 := ZC_Effect_Armor.new()
	armor1.multiplier = 0.8
	entity.add_relationship(RelationshipUtils.make_modifier(armor1))

	var armor2 := ZC_Effect_Armor.new()
	armor2.multiplier = 0.5
	entity.add_relationship(RelationshipUtils.make_modifier(armor2))

	var result = __script.get_damage_multiplier(entity)
	# 0.8 * 0.5 = 0.4
	assert_float(result).is_equal(0.4)

	entity.queue_free()


func test_speed_multiplier_stacking() -> void:
	var entity := Entity.new()

	# Add multiple speed effects
	var speed1 := ZC_Effect_Speed.new()
	speed1.multiplier = 1.2
	entity.add_relationship(RelationshipUtils.make_modifier(speed1))

	var speed2 := ZC_Effect_Speed.new()
	speed2.multiplier = 1.5
	entity.add_relationship(RelationshipUtils.make_modifier(speed2))

	var result = __script.get_speed_multiplier(entity)
	# 1.2 * 1.5 = 1.8
	assert_float(result).is_equal_approx(1.8, 1e-8)

	entity.queue_free()
#endregion
