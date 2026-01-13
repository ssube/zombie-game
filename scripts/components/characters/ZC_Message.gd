extends Component
class_name ZC_Message

enum MessageType {
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

@export var message_type: MessageType = MessageType.CHAT
@export var message: String = ""
@export var icon: Texture2D = null
@export var author: String = ""
@export var sound: AudioStream = null
@export var style: StringName = &"default"
@export var duration: float = 3.0

@export_group("Timestamps")
@export var sent_at: float = 0.0
@export var read_at: float = 0.0
