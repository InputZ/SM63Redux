extends LineEdit


## Clears the entered text.
func clear() -> void:
	grab_focus()
	text = ""
	update_text()


## Trigger text change event.
func update_text() -> void:
	emit_signal("text_changed", text)