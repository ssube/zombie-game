# GdUnit generated TestSuite
class_name InteractionUtilsTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source: String = 'res://scripts/utils/InteractionUtils.gd'
const __script = preload(__source)


func test_has_ammo() -> void:
	var entity := ZE_Weapon.new()
	entity.add_component(ZC_Ammo.new())
	var has_ammo = __script.has_ammo(entity)
	assert_bool(has_ammo).is_true()
