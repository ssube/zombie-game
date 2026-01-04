class_name CommandLineArgs

## Parses user command line arguments into a dictionary.
## Supports both --key=value and --key value formats.
## Repeated keys produce an array of values.
## Flags without values (--flag) are stored with value `true`.
static func parse_user_args() -> Dictionary:
	var args := OS.get_cmdline_user_args()
	return parse_args(args)


## Parses an array of argument strings into a dictionary.
static func parse_args(args: PackedStringArray) -> Dictionary:
	var result := {}
	var i := 0

	while i < args.size():
		var arg := args[i]

		if not arg.begins_with("--"):
			# Skip non-flag arguments
			i += 1
			continue

		# Remove the leading --
		arg = arg.substr(2)

		var key: String
		var value: Variant

		if arg.contains("="):
			# Format: --key=value
			var parts := arg.split("=", true, 1)
			key = parts[0]
			value = parts[1] if parts.size() > 1 else ""
		else:
			# Format: --key value or --flag
			key = arg

			# Check if there's a next argument that isn't a flag
			if i + 1 < args.size() and not args[i + 1].begins_with("--"):
				value = args[i + 1]
				i += 1  # Skip the value in next iteration
			else:
				# It's a boolean flag
				value = true

		# Add to result, creating array for repeated keys
		_add_to_dict(result, key, value)
		i += 1

	return result


## Adds a value to the dictionary, converting to array if key already exists.
static func _add_to_dict(dict: Dictionary, key: String, value: Variant) -> void:
	if not dict.has(key):
		dict[key] = value
	elif dict[key] is Array:
		dict[key].append(value)
	else:
		# Convert existing single value to array
		dict[key] = [dict[key], value]


## Loads PCK files from the --mod arguments.
## Returns a dictionary with mod paths as keys and success status as values.
static func load_mods_from_args(parsed_args: Dictionary) -> Dictionary:
	var results := {}

	if not parsed_args.has("mod"):
		return results

	var mods: Variant = parsed_args["mod"]
	var mod_list: Array

	if mods is Array:
		mod_list = mods
	else:
		mod_list = [mods]

	for mod_path: Variant in mod_list:
		if mod_path is String:
			var success := load_pck(mod_path)
			results[mod_path] = success

	return results


## Loads a single PCK file. Returns true on success.
static func load_pck(path: String) -> bool:
	if not FileAccess.file_exists(path):
		ZombieLogger.error("Mod PCK not found: {0}", [path])
		return false

	var success := ProjectSettings.load_resource_pack(path)

	if success:
		ZombieLogger.info("Loaded mod: {0}", [path])
	else:
		ZombieLogger.error("Failed to load mod: {0}", [path])

	return success


## Gets the debug level and marker from parsed arguments.
## Falls back to provided defaults if not specified or invalid.
## The campaign must have a has_level(name: String) -> bool method.
## Returns [level, marker] array.
static func get_debug_level(parsed_args: Dictionary, campaign: Variant, default_level: String, default_marker: String = "") -> Array[String]:
	var level := default_level
	var marker := default_marker

	# Check for --level argument
	if parsed_args.has("level"):
		var arg_level: Variant = parsed_args["level"]
		# If multiple were provided, use the last one
		if arg_level is Array:
			arg_level = arg_level[-1]

		if arg_level is String and arg_level != "":
			if campaign.has_level(arg_level):
				level = arg_level
			else:
				ZombieLogger.error("Requested level {0} is not in the levels table!" , [arg_level])

	# Check for --marker argument (no way to validate until level is loaded)
	if parsed_args.has("marker"):
		var arg_marker: Variant = parsed_args["marker"]
		# If multiple were provided, use the last one
		if arg_marker is Array:
			arg_marker = arg_marker[-1]

		if arg_marker is String and arg_marker != "":
			marker = arg_marker

	ZombieLogger.info("Loading debug level {0} at marker {1}", [level, marker])

	return [level, marker]


## Loads a campaign resource from the --campaign argument.
## Falls back to default_campaign if not specified or load fails.
## Returns the loaded ZR_Campaign resource.
static func get_campaign(parsed_args: Dictionary, default_campaign: ZR_Campaign) -> ZR_Campaign:
	if not parsed_args.has("campaign"):
		return default_campaign

	var campaign_path: Variant = parsed_args["campaign"]
	# If multiple were provided, use the last one
	if campaign_path is Array:
		campaign_path = campaign_path[-1]

	if not campaign_path is String or campaign_path == "":
		return default_campaign

	# Ensure the path has the correct extension
	if not campaign_path.ends_with(".tres") and not campaign_path.ends_with(".res"):
		campaign_path = campaign_path + ".tres"

	# Try loading as a resource path first (res://)
	if not campaign_path.begins_with("res://"):
		# Assume it's relative to a campaigns folder
		campaign_path = "res://campaigns/%s" % campaign_path

	if not ResourceLoader.exists(campaign_path):
		ZombieLogger.error("Campaign resource not found: {0}", [campaign_path])
		return default_campaign

	var loaded: Resource = load(campaign_path)

	if loaded == null:
		ZombieLogger.error("Failed to load campaign: {0}", [campaign_path])
		return default_campaign

	if not loaded is ZR_Campaign:
		ZombieLogger.error("Resource is not a ZR_Campaign: {0}", [campaign_path])
		return default_campaign

	ZombieLogger.info("Loaded campaign: {0}", [campaign_path])
	return loaded as ZR_Campaign

## Checks for --help flag and prints usage if present.
## Returns true if help was shown (caller should quit), false otherwise.
static func check_help(parsed_args: Dictionary) -> bool:
	if not parsed_args.has("help"):
		return false

	print_help()
	return true


## Prints help text describing available command line arguments.
static func print_help() -> void:
	var help_text := """
Zombie Game - Command Line Arguments
=====================================

Usage: game [-- OPTIONS]

Note: Arguments after -- are passed to the game, not the engine.

OPTIONS:
  --help                    Show this help message and quit

  --campaign=PATH           Load a campaign resource
                            Can be a short name (e.g., main) or full path
                            Short names look in res://campaigns/

  --level=NAME              Start at a specific level (must exist in campaign)

  --marker=PATH             Spawn at a specific marker node path
                            (e.g., Markers/FrontDoor)

  --merge-campaigns         Merge the base campaign and the campaign loaded
                            with the --campaign option

  --mod=PATH                Load a PCK mod file (can be repeated)
                            (e.g., --mod=weapons.pck --mod=maps.pck)

EXAMPLES:
  game -- --help
  game -- --level=1_hotel --marker=Markers/Pool
  game -- --campaign=debug --level=test_town
  game -- --mod=mymods/extra_weapons.pck --mod=mymods/new_maps.pck
  game -- --campaign=main --level=1_hotel --marker=Markers/Start --mod=dlc.pck
"""
	print(help_text)
