extends ZM_BaseMenu

@export var book_title: Label
@export var book_text: RichTextLabel
@export var page_label: Label
@export var page_template: String = "Page %d of %d"

var current_page: int = 0
var current_book: ZC_Book = null


func _on_close_button_pressed() -> void:
	back_pressed.emit()


func on_update() -> void:
	var pages := current_book.pages
	book_text.text = pages[current_page]
	page_label.text = page_template % [current_page + 1, pages.size()]


func set_data(data: Dictionary) -> void:
	var source := data.get("source", null) as Entity
	var c_book := source.get_component(ZC_Book) as ZC_Book
	if c_book == null:
		return

	current_book = c_book
	current_page = 0
	on_update()


func _on_previous_button_pressed() -> void:
	current_page = maxi(current_page - 1, 0)
	on_update()


func _on_next_button_pressed() -> void:
	current_page = mini(current_page + 1, current_book.pages.size() - 1)
	on_update()


func _on_first_button_pressed() -> void:
	current_page = 0
	on_update()


func _on_last_button_pressed() -> void:
	current_page = current_book.pages.size() - 1
	on_update()
