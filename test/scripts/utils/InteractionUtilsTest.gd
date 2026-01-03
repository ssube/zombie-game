# GdUnit generated TestSuite
class_name InteractionUtilsTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source: String = 'res://scripts/utils/InteractionUtils.gd'
const __script = preload(__source)


func test_valid_interactions() -> void:
	for interaction in __script.interactions:
		assert_str(interaction).is_not_empty()

		var pair = __script.interactions[interaction]
		assert_array(pair).is_not_null().has_size(2)

		var condition = pair[0]
		var handler = pair[1]
		assert_that(condition).is_not_null()
		assert_that(handler).is_not_null()


func test_has_ammo() -> void:
	var entity := ZE_Weapon.new()
	entity.add_component(ZC_Ammo.new())
	var has_ammo = __script.has_ammo(entity)
	entity.queue_free()
	assert_bool(has_ammo).is_true()
