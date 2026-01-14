extends Control


@export var max_messages: int = 100
@export var duplicate_duration: float = 10.0 # seconds
@export var message_container: Container
@export var message_formats: Dictionary[ZC_Message.MessageFormat, PackedScene] = {
	ZC_Message.MessageFormat.PLAIN: preload("res://menus/message_history_item_plain.tscn"),
	ZC_Message.MessageFormat.BBCODE: preload("res://menus/message_history_item_bbcode.tscn"),
}
@export var scroll_container: ScrollContainer
@export var scroll_duration: float = 0.2

var _last_message: ZC_Message = null
var _message_cache: Dictionary[ZC_Message, Control] = {}
var _message_order: Array[ZC_Message] = []
var _scroll_tween: Tween = null


func _ready() -> void:
	clear_messages()


func append_message(message: ZC_Message) -> void:
	# Skip if already cached
	if _message_cache.has(message):
		return

	# Avoid duplicate consecutive messages within the configured time window
	# This only applies to subtitles
	if message.message_group == ZC_Message.MessageGroup.SUBTITLE:
		if _last_message != null:
			if message.message == _last_message.message and message.author == _last_message.author:
				if message.sent_at - _last_message.sent_at < duplicate_duration:
					return

	var format := message.message_format
	var message_scene := message_formats.get(format, null) as PackedScene
	if message_scene == null:
		ZombieLogger.error("No message scene found for format: %s" % str(format))
		return

	var message_item := message_scene.instantiate()
	if message_item is Control:
		message_item.set_message(message)
		message_container.add_child(message_item)
		_message_cache[message] = message_item
		_message_order.append(message)
		_last_message = message

	# Remove oldest messages if limit exceeded
	while _message_order.size() > max_messages:
		var oldest_message := _message_order.pop_front() as ZC_Message
		var oldest_item := _message_cache.get(oldest_message, null) as Control
		if oldest_item:
			oldest_item.queue_free.call_deferred()
			_message_cache.erase(oldest_message)

	# Stop any existing scroll tween
	if _scroll_tween and _scroll_tween.is_running():
		_scroll_tween.kill()

	# Scroll to the bottom
	var bottom := scroll_container.get_v_scroll_bar().max_value
	_scroll_tween = scroll_container.create_tween()
	_scroll_tween.tween_property(scroll_container, "scroll_vertical", bottom, scroll_duration)


func clear_messages() -> void:
	for item in _message_cache.values():
		if item and is_instance_valid(item):
			item.queue_free.call_deferred()
	for child in message_container.get_children():
		child.queue_free.call_deferred()
	_message_cache.clear()
	_message_order.clear()


func show_messages(messages: Array[ZC_Message]) -> void:
	clear_messages()

	var displayed_count := 0
	for message in messages:
		if displayed_count >= max_messages:
			break

		append_message(message)
		displayed_count += 1
