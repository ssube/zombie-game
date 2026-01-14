extends Component
class_name ZC_Message

enum MessageGroup {
	## Messages from the system, such as notifications or alerts.
	SYSTEM,
	## Subtitles for audio in the game.
	SUBTITLE,
	## Messages related to player interactions.
	INTERACTION,
	## Chat messages between characters.
	CHAT,
}

enum MessageFormat {
	## Display the message as plain text using a label control.
	PLAIN,
	## Display the message using BBCode formatting in a rich text label control.
	BBCODE,
	# TODO: Add support for markdown formatting.
	# MARKDOWN,
}

@export var message_format: MessageFormat = MessageFormat.PLAIN
@export var message_group: MessageGroup = MessageGroup.CHAT

@export var message: String = ""
@export var icon: Texture2D = null
@export var author: String = ""
@export var sound: AudioStream = null
@export var style: StringName = &"default"
@export var duration: float = 3.0

@export_group("Timestamps")
@export var sent_at: float = 0.0
@export var read_at: float = 0.0


#region Utility Methods
@warning_ignore("shadowed_variable")
static func make_interaction(message: String, icon: Texture2D = null) -> ZC_Message:
	var result := ZC_Message.new()
	result.message_format = MessageFormat.PLAIN
	result.message_group = MessageGroup.INTERACTION
	result.message = message
	result.icon = icon
	result.sent_at = Time.get_ticks_msec() / 1000.0
	return result

@warning_ignore("shadowed_variable")
static func make_subtitle(text: String, duration: float = 3.0) -> ZC_Message:
	var result := ZC_Message.new()
	result.message_format = MessageFormat.BBCODE
	result.message_group = MessageGroup.SUBTITLE
	# TODO: move this formatting to the subtitle template
	result.message = "[color=gray][i]%s[/i][/color]" % text
	result.duration = duration
	result.sent_at = Time.get_ticks_msec() / 1000.0
	return result

@warning_ignore("shadowed_variable")
static func make_system(message: String, icon: Texture2D = null) -> ZC_Message:
	var result := ZC_Message.new()
	result.message_format = MessageFormat.PLAIN
	result.message_group = MessageGroup.SYSTEM
	result.message = message
	result.icon = icon
	result.sent_at = Time.get_ticks_msec() / 1000.0
	return result

#endregion
