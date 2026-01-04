extends Node

enum LogLevel {
	TRACE,
	DEBUG,
	INFO,
	WARNING,
	ERROR,
	CRITICAL,
}

@export var level: LogLevel = LogLevel.INFO
@export var stack_on_error: bool = true
@export var stack_on_warning: bool = false


func log_level(message_level: LogLevel, message: String, args: Array = []):
	if message_level < level:
		return

	var level_str: String
	match message_level:
		LogLevel.TRACE:
			level_str = "TRACE"
		LogLevel.DEBUG:
			level_str = "DEBUG"
		LogLevel.INFO:
			level_str = "INFO"
		LogLevel.WARNING:
			level_str = "WARNING"
		LogLevel.ERROR:
			level_str = "ERROR"
		LogLevel.CRITICAL:
			level_str = "CRITICAL"
		_:
			level_str = "UNKNOWN"

	var formatted_message = message.format(args)
	var timestamp := Time.get_date_string_from_system()
	var output := "%s - %s - %s" % [timestamp, level_str, formatted_message]

	if message_level >= LogLevel.ERROR:
		printerr(output)
		push_error(output)
	else:
		print(output)
		if message_level == LogLevel.WARNING:
			push_warning(output)


func trace(message: String, args: Array = []):
	log_level(LogLevel.TRACE, message, args)


func debug(message: String, args: Array = []):
	log_level(LogLevel.DEBUG, message, args)


func info(message: String, args: Array = []):
	log_level(LogLevel.INFO, message, args)


func warning(message: String, args: Array = []):
	log_level(LogLevel.WARNING, message, args)
	if stack_on_warning:
		print_stack()


func error(message: String, args: Array = []):
	log_level(LogLevel.ERROR, message, args)
	if stack_on_error:
		print_stack()


func critical(message: String, args: Array = []):
	log_level(LogLevel.CRITICAL, message, args)
	print_stack()


# TODO: add child() logger support
