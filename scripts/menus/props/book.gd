extends ZM_BaseMenu


class TestBook:
	var title: String = "The Great Book"
	var pages: Array[String] = [
		"Page 1: Once upon a time...",
		"Page 2: In a land far, far away...",
		"Page 3: There lived a brave hero.",
	]


@export var book_title: Label
@export var book_text: RichTextLabel
@export var page_label: Label

@onready var page_template: String = page_label.text

var current_page: int = 0
var book: TestBook = TestBook.new()


func _on_close_button_pressed() -> void:
	back_pressed.emit()


func on_update() -> void:
	book_text.text = book.pages[current_page]
	page_label.text = page_template % [current_page + 1, book.pages.size()]


func _on_previous_button_pressed() -> void:
	current_page = maxi(current_page - 1, 0)
	on_update()


func _on_next_button_pressed() -> void:
	current_page = mini(current_page + 1, book.pages.size() - 1)
	on_update()
