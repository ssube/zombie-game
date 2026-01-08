@tool
extends Node

enum Level {
	TRACE,
	DEBUG,
	INFO,
	WARNING,
	ERROR,
	CRITICAL,
}

@export var level: Level = Level.INFO
@export var stack_on_error: bool = true
@export var stack_on_warning: bool = false


func log_level(message_level: Level, message: String, args: Array = []):
	if message_level < level:
		return

	var level_str: String
	match message_level:
		Level.TRACE:
			level_str = "TRACE"
		Level.DEBUG:
			level_str = "DEBUG"
		Level.INFO:
			level_str = "INFO"
		Level.WARNING:
			level_str = "WARNING"
		Level.ERROR:
			level_str = "ERROR"
		Level.CRITICAL:
			level_str = "CRITICAL"
		_:
			level_str = "UNKNOWN"

	var formatted_message = message.format(args)
	var timestamp := Time.get_date_string_from_system()
	var output := "%s - %s - %s" % [timestamp, level_str, formatted_message]

	if message_level >= Level.ERROR:
		printerr(output)
		push_error(output)
	else:
		print(output)
		if message_level == Level.WARNING:
			push_warning(output)


func trace(message: String, args: Array = []):
	log_level(Level.TRACE, message, args)


func debug(message: String, args: Array = []):
	log_level(Level.DEBUG, message, args)


func info(message: String, args: Array = []):
	log_level(Level.INFO, message, args)


func warning(message: String, args: Array = []):
	log_level(Level.WARNING, message, args)
	if stack_on_warning:
		print_stack()


func error(message: String, args: Array = []):
	log_level(Level.ERROR, message, args)
	if stack_on_error:
		print_stack()


func critical(message: String, args: Array = []):
	log_level(Level.CRITICAL, message, args)
	print_stack()


# TODO: add child() logger support
