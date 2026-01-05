class_name TimeUtils

class Debounce:
	var _callback: Callable
	var _timer: Timer

	func _init(tree: SceneTree, wait_time: float, callback: Callable):
		self._callback = callback
		self._timer = Timer.new()
		self._timer.wait_time = wait_time
		self._timer.one_shot = true
		self._timer.process_mode = Node.PROCESS_MODE_ALWAYS
		self._timer.timeout.connect(_on_timeout.bind(callback), CONNECT_REFERENCE_COUNTED)
		tree.root.add_child.call_deferred(self._timer)

	func _on_timeout(callback: Callable):
		callback.call()

	func start():
		if not self._timer.is_stopped():
			self._timer.stop()
		self._timer.start()

	func reset():
		self._timer.stop()


static func debounce(node: Node, wait_time: float, callback: Callable) -> Debounce:
	var tree := node.get_tree()
	var debounce_instance = Debounce.new(tree, wait_time, callback)
	return debounce_instance
