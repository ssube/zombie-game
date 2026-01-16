## Creates decorative hanging chains, ropes, power lines, flag strings, and similar
## repeated-pattern lines between anchor points defined by an external Path3D.
##
## Pattern children are duplicated along a catenary curve between each pair of
## anchor points. Each pattern child must have RopeStart and RopeEnd Marker3D
## children to define connection points.
@tool
extends Node3D
class_name ZN_ChainPath3D

#region Signals
signal bake_completed
signal bake_failed(reason: String)
#endregion

#region Exports
@export_group("Path")
## Reference to external Path3D defining anchor points
@export var path: Path3D:
	set(value):
		if path != value:
			_disconnect_path_signals()
			path = value
			_connect_path_signals()
			_request_rebake()

@export_group("Catenary")
## 0.0 = full catenary sag, 1.0 = straight line
@export_range(0.0, 1.0) var tension: float = 0.5:
	set(value):
		tension = value
		_request_rebake()

@export_group("Scaling")
## Minimum allowed scale for pattern children
@export_range(0.1, 2.0) var min_scale: float = 0.8:
	set(value):
		min_scale = value
		if min_scale > max_scale:
			push_warning("ZN_ChainPath3D: min_scale > max_scale, swapping values")
			var temp := min_scale
			min_scale = max_scale
			max_scale = temp
		_request_rebake()

## Maximum allowed scale for pattern children
@export_range(0.1, 2.0) var max_scale: float = 1.2:
	set(value):
		max_scale = value
		if max_scale < min_scale:
			push_warning("ZN_ChainPath3D: max_scale < min_scale, swapping values")
			var temp := max_scale
			max_scale = min_scale
			min_scale = temp
		_request_rebake()

## Minimum repetitions per span (prevents degenerate cases)
@export_range(1, 100) var min_segments: int = 3:
	set(value):
		min_segments = max(1, value)
		_request_rebake()

## If true, allows incomplete pattern sequences at span end
@export var allow_partial: bool = false:
	set(value):
		allow_partial = value
		_request_rebake()

@export_group("Wind")
## Enables wind animation shader
@export var wind_enabled: bool = false:
	set(value):
		wind_enabled = value
		_apply_wind_shader()

## Multiplier for wind displacement
@export_range(0.0, 5.0) var wind_strength: float = 1.0:
	set(value):
		wind_strength = value
		_update_wind_strength()

@export_group("Debug")
## Force rebake in editor
@export_tool_button("Rebake") var rebake_action := _force_rebake
#endregion

#region Constants
const ROPE_START_NAME := "RopeStart"
const ROPE_END_NAME := "RopeEnd"
const PATTERN_NODE_NAME := "Pattern"
const BAKED_NODE_NAME := "Baked"
const DEBOUNCE_TIME := 0.3
const CATENARY_SAMPLES := 64
const MAX_SCALE_ITERATIONS := 100
#endregion

#region Private Variables
var _pattern_node: Node3D
var _baked_node: Node3D
var _rebake_timer: Timer
var _rebake_requested: bool = false
var _wind_shader: Shader
var _is_ready: bool = false
#endregion

#region Lifecycle
func _ready() -> void:
	_setup_child_nodes()
	_setup_rebake_timer()
	_connect_path_signals()
	_load_wind_shader()
	_is_ready = true
	_request_rebake()


func _exit_tree() -> void:
	_disconnect_path_signals()
	if _rebake_timer:
		_rebake_timer.queue_free()
#endregion

#region Setup
func _setup_child_nodes() -> void:
	# Find or create Pattern node
	_pattern_node = get_node_or_null(PATTERN_NODE_NAME) as Node3D
	if not _pattern_node:
		_pattern_node = Node3D.new()
		_pattern_node.name = PATTERN_NODE_NAME
		add_child(_pattern_node)
		if Engine.is_editor_hint():
			_pattern_node.owner = get_tree().edited_scene_root

	# Find or create Baked node
	_baked_node = get_node_or_null(BAKED_NODE_NAME) as Node3D
	if not _baked_node:
		_baked_node = Node3D.new()
		_baked_node.name = BAKED_NODE_NAME
		add_child(_baked_node)
		if Engine.is_editor_hint():
			_baked_node.owner = get_tree().edited_scene_root


func _setup_rebake_timer() -> void:
	_rebake_timer = Timer.new()
	_rebake_timer.one_shot = true
	_rebake_timer.wait_time = DEBOUNCE_TIME
	_rebake_timer.timeout.connect(_on_rebake_timer_timeout)
	add_child(_rebake_timer)


func _load_wind_shader() -> void:
	_wind_shader = load("res://shaders/chain_wind.gdshader") as Shader
#endregion

#region Path3D Signals
func _connect_path_signals() -> void:
	if not path:
		return
	if path.curve and not path.curve.changed.is_connected(_on_curve_changed):
		path.curve.changed.connect(_on_curve_changed)


func _disconnect_path_signals() -> void:
	if not path:
		return
	if path.curve and path.curve.changed.is_connected(_on_curve_changed):
		path.curve.changed.disconnect(_on_curve_changed)


func _on_curve_changed() -> void:
	_request_rebake()
#endregion

#region Rebake Trigger
func _request_rebake() -> void:
	if not _is_ready:
		return
	_rebake_requested = true
	if _rebake_timer:
		_rebake_timer.start()


func _force_rebake() -> void:
	_rebake()


func _on_rebake_timer_timeout() -> void:
	if _rebake_requested:
		_rebake_requested = false
		_rebake()
#endregion

#region Main Bake Process
func _rebake() -> void:
	_clear_baked()

	# Validation
	if not _validate_setup():
		return

	# Get pattern children info
	var pattern_info := _get_pattern_info()
	if pattern_info.is_empty():
		return

	# Process each span
	var curve := path.curve
	var point_count := curve.point_count

	if point_count < 2:
		push_warning("ZN_ChainPath3D: Path3D needs at least 2 points")
		bake_failed.emit("Path3D needs at least 2 points")
		return

	for i in range(point_count - 1):
		var start_pos := path.global_transform * curve.get_point_position(i)
		var end_pos := path.global_transform * curve.get_point_position(i + 1)
		var start_tilt := curve.get_point_tilt(i)
		var end_tilt := curve.get_point_tilt(i + 1)

		_process_span(start_pos, end_pos, start_tilt, end_tilt, pattern_info, i)

	# Hide pattern node after bake
	_pattern_node.visible = false

	bake_completed.emit()


func _clear_baked() -> void:
	if not _baked_node:
		return
	for child in _baked_node.get_children():
		child.free()

	# Wait for the next frame to ensure nodes are freed
	await get_tree().process_frame


func _validate_setup() -> bool:
	if not path:
		push_warning("ZN_ChainPath3D: No path assigned")
		bake_failed.emit("No path assigned")
		return false

	if not path.curve:
		push_warning("ZN_ChainPath3D: Path3D has no curve")
		bake_failed.emit("Path3D has no curve")
		return false

	if not _pattern_node or _pattern_node.get_child_count() == 0:
		push_warning("ZN_ChainPath3D: Pattern node is empty")
		bake_failed.emit("Pattern node is empty")
		return false

	return true
#endregion

#region Pattern Info
## Returns array of dictionaries with pattern child info
func _get_pattern_info() -> Array[Dictionary]:
	var info: Array[Dictionary] = []

	for child in _pattern_node.get_children():
		if not child is Node3D:
			continue

		var rope_start := child.get_node_or_null(ROPE_START_NAME) as Marker3D
		var rope_end := child.get_node_or_null(ROPE_END_NAME) as Marker3D

		if not rope_start:
			push_error("ZN_ChainPath3D: Pattern child '%s' missing RopeStart marker" % child.name)
			continue
		if not rope_end:
			push_error("ZN_ChainPath3D: Pattern child '%s' missing RopeEnd marker" % child.name)
			continue

		var length := rope_start.position.distance_to(rope_end.position)
		if length < 0.001:
			push_error("ZN_ChainPath3D: Pattern child '%s' has zero-length (RopeStart == RopeEnd)" % child.name)
			continue

		info.append({
			"node": child,
			"rope_start": rope_start,
			"rope_end": rope_end,
			"length": length,
			"rope_start_local": rope_start.position,
			"rope_end_local": rope_end.position,
		})

	return info
#endregion

#region Span Processing
func _process_span(start_pos: Vector3, end_pos: Vector3, start_tilt: float, end_tilt: float, pattern_info: Array[Dictionary], span_index: int) -> void:
	# Calculate catenary curve
	var catenary := _calculate_catenary(start_pos, end_pos)
	var arc_length := _calculate_arc_length(catenary)

	# Calculate total pattern length
	var pattern_length := 0.0
	for info in pattern_info:
		pattern_length += info.length

	if pattern_length < 0.001:
		push_error("ZN_ChainPath3D: Pattern has zero total length")
		return

	# Solve for scale and count
	var solution := _solve_scale(arc_length, pattern_length, pattern_info.size())
	if solution.is_empty():
		push_error("ZN_ChainPath3D: Cannot fit pattern in span %d (arc_length=%.2f, pattern_length=%.2f)" % [span_index, arc_length, pattern_length])
		return

	var scale_factor: float = solution.scale
	var repetitions: int = solution.repetitions
	var partial_count: int = solution.partial_count

	# Create span group node for visibility distance and other options
	var span_group := Node3D.new()
	span_group.name = "Span_%03d" % span_index
	_baked_node.add_child(span_group)
	if Engine.is_editor_hint():
		span_group.owner = get_tree().edited_scene_root

	# Place segments
	var current_arc_dist := 0.0
	var segment_index := 0
	var pattern_index := 0

	var total_segments := repetitions * pattern_info.size() + partial_count

	for i in range(total_segments):
		pattern_index = i % pattern_info.size()
		var info: Dictionary = pattern_info[pattern_index]
		var scaled_length: float = info.length * scale_factor

		# Sample start position (where RopeStart will be placed)
		var t_start := current_arc_dist / arc_length
		var seg_start := _sample_catenary(catenary, t_start)

		# Sample end position (where RopeEnd will be placed)
		var t_end := minf((current_arc_dist + scaled_length) / arc_length, 1.0)
		var seg_end := _sample_catenary(catenary, t_end)

		# Calculate up vector at midpoint of segment
		var t_mid := (t_start + t_end) / 2.0
		var up := _get_up_vector_at(catenary, t_mid, start_tilt, end_tilt)

		# Create segment - rotation calculated to place RopeStart at seg_start and RopeEnd at seg_end
		_create_segment(info, seg_start, seg_end, up, span_group, segment_index)

		current_arc_dist += scaled_length
		segment_index += 1
#endregion

#region Catenary Math
## Calculates catenary curve data between two points
func _calculate_catenary(start: Vector3, end: Vector3) -> Dictionary:
	var horizontal := Vector3(end.x - start.x, 0, end.z - start.z)
	var horizontal_dist := horizontal.length()
	var vertical_diff := end.y - start.y
	var mid_point := (start + end) / 2.0

	# Calculate sag based on tension
	# At tension=0, full sag; at tension=1, straight line
	var max_sag := horizontal_dist * 0.25  # Maximum sag is 25% of horizontal distance
	var sag := max_sag * (1.0 - tension)

	# Catenary lowest point (below midpoint)
	var catenary_low := mid_point - Vector3(0, sag, 0)

	# Calculate catenary parameter 'a' that fits through start, catenary_low, and end
	# Using simplified catenary: y = a * cosh(x/a) - a + y_offset
	# We'll use a quadratic approximation for simplicity and numerical stability
	var a := _fit_catenary_parameter(horizontal_dist, sag)

	return {
		"start": start,
		"end": end,
		"mid": catenary_low,
		"horizontal_dist": horizontal_dist,
		"vertical_diff": vertical_diff,
		"sag": sag,
		"a": a,
		"direction": horizontal.normalized() if horizontal_dist > 0.001 else Vector3.FORWARD,
	}


## Fits catenary parameter 'a' given horizontal distance and sag
func _fit_catenary_parameter(L: float, sag: float) -> float:
	if sag < 0.001:
		return 1000000.0  # Very large 'a' = nearly straight line

	# For catenary y = a * cosh(x/a), sag at midpoint is: a * (cosh(L/2a) - 1)
	# We solve iteratively for 'a'
	var a := L / 2.0  # Initial guess

	for i in range(20):
		var target_sag := a * (cosh(L / (2.0 * a)) - 1.0)
		if abs(target_sag - sag) < 0.001:
			break
		# Newton-Raphson step (simplified)
		a = a * sag / target_sag if target_sag > 0.001 else a * 0.5
		a = clampf(a, 0.01, 1000000.0)

	return a


## Calculates approximate arc length of catenary
func _calculate_arc_length(catenary: Dictionary) -> float:
	var length := 0.0
	var prev_pos := catenary.start as Vector3

	for i in range(1, CATENARY_SAMPLES + 1):
		var t := float(i) / float(CATENARY_SAMPLES)
		var pos := _sample_catenary(catenary, t)
		length += prev_pos.distance_to(pos)
		prev_pos = pos

	return length


## Samples a point on the catenary at parameter t (0 to 1)
func _sample_catenary(catenary: Dictionary, t: float) -> Vector3:
	var start: Vector3 = catenary.start
	var end: Vector3 = catenary.end
	var sag: float = catenary.sag

	# Linear interpolation for x and z
	var pos := start.lerp(end, t)

	# Catenary curve for y (parabolic approximation)
	# At t=0 and t=1, we're at endpoints; at t=0.5, maximum sag
	var sag_factor := 4.0 * t * (1.0 - t)  # Parabola peaking at t=0.5
	pos.y -= sag * sag_factor

	return pos


## Samples the tangent (derivative) at parameter t
func _sample_catenary_tangent(catenary: Dictionary, t: float) -> Vector3:
	var delta := 0.01
	var t0 := clampf(t - delta, 0.0, 1.0)
	var t1 := clampf(t + delta, 0.0, 1.0)

	var p0 := _sample_catenary(catenary, t0)
	var p1 := _sample_catenary(catenary, t1)

	return (p1 - p0).normalized()
#endregion

#region Scale Solver
## Solves for the best scale and repetition count
func _solve_scale(arc_length: float, pattern_length: float, pattern_count: int) -> Dictionary:
	var ideal_repetitions := arc_length / pattern_length

	# Try integer counts starting from floor(ideal) going down
	for count in range(int(floor(ideal_repetitions)), min_segments - 1, -1):
		if count < min_segments:
			break
		var required_scale := arc_length / (count * pattern_length)
		if required_scale >= min_scale and required_scale <= max_scale:
			return {"scale": required_scale, "repetitions": count, "partial_count": 0}

	# Try integer counts from ceil(ideal) going up
	for count in range(int(ceil(ideal_repetitions)), int(ideal_repetitions) + MAX_SCALE_ITERATIONS):
		if count < min_segments:
			continue
		var required_scale := arc_length / (count * pattern_length)
		if required_scale >= min_scale and required_scale <= max_scale:
			return {"scale": required_scale, "repetitions": count, "partial_count": 0}

	# Try partial sequences if allowed
	if allow_partial:
		var base_count := int(floor(ideal_repetitions))
		if base_count >= min_segments:
			# Calculate how many partial pattern items we can fit
			var used_length := base_count * pattern_length * max_scale
			var remaining := arc_length - used_length

			if remaining > 0:
				# Fit as many partial items as possible at max_scale
				var partial := 0
				for i in range(pattern_count):
					# This would need more sophisticated handling for real partial sequences
					partial = i
					break

				return {"scale": max_scale, "repetitions": base_count, "partial_count": partial}

	# No valid configuration found
	return {}
#endregion

#region Segment Creation
func _create_segment(info: Dictionary, rope_start_world: Vector3, rope_end_world: Vector3, up_hint: Vector3, span_group: Node3D, segment_index: int) -> void:
	var original: Node3D = info.node
	var rope_start_local: Vector3 = info.rope_start_local
	var rope_end_local: Vector3 = info.rope_end_local

	# Duplicate the pattern node
	var segment := original.duplicate() as Node3D
	segment.name = "%s_%03d" % [original.name, segment_index]

	# Calculate the local rope direction and length
	var local_rope_dir := (rope_end_local - rope_start_local).normalized()
	var local_rope_length := rope_start_local.distance_to(rope_end_local)

	# Calculate the world rope direction and length
	var world_rope_dir := (rope_end_world - rope_start_world).normalized()
	var world_rope_length := rope_start_world.distance_to(rope_end_world)

	# Calculate scale factor to match the world distance
	var scale_factor := world_rope_length / local_rope_length if local_rope_length > 0.001 else 1.0

	# Build a rotation that transforms local_rope_dir to world_rope_dir
	# First, create a basis for the local rope direction
	var local_up := Vector3.UP
	var local_right := local_rope_dir.cross(local_up).normalized()
	if local_right.length_squared() < 0.001:
		local_right = Vector3.RIGHT
	local_up = local_right.cross(local_rope_dir).normalized()
	var local_basis := Basis(local_right, local_up, local_rope_dir)

	# Create a basis for the world rope direction
	var world_up := up_hint
	var world_right := world_rope_dir.cross(world_up).normalized()
	if world_right.length_squared() < 0.001:
		world_right = Vector3.RIGHT
	world_up = world_right.cross(world_rope_dir).normalized()
	var world_basis := Basis(world_right, world_up, world_rope_dir)

	# The final basis transforms from local to world orientation
	var basis := world_basis * local_basis.inverse()

	# Position the segment so RopeStart lands at rope_start_world
	var offset := basis * (rope_start_local * scale_factor)
	segment.global_transform = Transform3D(basis, rope_start_world - offset)
	segment.scale = Vector3.ONE * scale_factor

	# Add to span group
	span_group.add_child(segment)

	# Set owner for editor visibility
	if Engine.is_editor_hint():
		_set_owner_recursive(segment, get_tree().edited_scene_root)

	# Apply wind shader if enabled
	if wind_enabled:
		_apply_wind_shader_to_segment(segment)


func _set_owner_recursive(node: Node, owner: Node) -> void:
	node.owner = owner
	for child in node.get_children():
		_set_owner_recursive(child, owner)
#endregion

#region Up Vector
## Calculates the up vector at a point along the curve, accounting for tilt
func _get_up_vector_at(catenary: Dictionary, t: float, start_tilt: float, end_tilt: float) -> Vector3:
	var tilt := lerpf(start_tilt, end_tilt, t)
	var tangent := _sample_catenary_tangent(catenary, t)

	# Start with world up
	var up := Vector3.UP

	# Make up perpendicular to tangent (Gram-Schmidt)
	up = (up - tangent * tangent.dot(up)).normalized()

	# Apply tilt rotation around the tangent axis
	if abs(tilt) > 0.001:
		up = up.rotated(tangent, tilt)

	return up
#endregion

#region Wind Shader
func _apply_wind_shader() -> void:
	if not _baked_node:
		return

	for child in _baked_node.get_children():
		if wind_enabled:
			_apply_wind_shader_to_segment(child)
		else:
			_remove_wind_shader_from_segment(child)


func _apply_wind_shader_to_segment(segment: Node3D) -> void:
	if not _wind_shader:
		return

	var meshes := _find_mesh_instances(segment)
	for mesh in meshes:
		_apply_wind_material(mesh)


func _remove_wind_shader_from_segment(segment: Node3D) -> void:
	var meshes := _find_mesh_instances(segment)
	for mesh in meshes:
		_remove_wind_material(mesh)


func _find_mesh_instances(node: Node) -> Array[MeshInstance3D]:
	var result: Array[MeshInstance3D] = []
	if node is MeshInstance3D:
		result.append(node)
	for child in node.get_children():
		result.append_array(_find_mesh_instances(child))
	return result


func _apply_wind_material(mesh: MeshInstance3D) -> void:
	if not _wind_shader:
		return

	# Get or create material override
	var mat := mesh.get_surface_override_material(0)
	if mat is ShaderMaterial and mat.shader == _wind_shader:
		mat.set_shader_parameter("wind_strength", wind_strength)
		return

	# Store original material and create shader material
	var original_mat := mesh.get_active_material(0)
	var shader_mat := ShaderMaterial.new()
	shader_mat.shader = _wind_shader
	shader_mat.set_shader_parameter("wind_strength", wind_strength)

	# Copy albedo from original if it exists
	if original_mat is StandardMaterial3D:
		shader_mat.set_shader_parameter("albedo", original_mat.albedo_color)
		if original_mat.albedo_texture:
			shader_mat.set_shader_parameter("texture_albedo", original_mat.albedo_texture)

	mesh.set_surface_override_material(0, shader_mat)


func _remove_wind_material(mesh: MeshInstance3D) -> void:
	var mat := mesh.get_surface_override_material(0)
	if mat is ShaderMaterial and mat.shader == _wind_shader:
		mesh.set_surface_override_material(0, null)


func _update_wind_strength() -> void:
	if not _baked_node or not wind_enabled:
		return

	for child in _baked_node.get_children():
		var meshes := _find_mesh_instances(child)
		for mesh in meshes:
			var mat := mesh.get_surface_override_material(0)
			if mat is ShaderMaterial:
				mat.set_shader_parameter("wind_strength", wind_strength)
#endregion
