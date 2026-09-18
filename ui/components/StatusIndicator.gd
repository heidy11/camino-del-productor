extends HBoxContainer


func set_status(success: bool, message: String) -> void:
	var icon = get_node("Icon")
	var label = get_node("MessageLabel")

	label.text = message

	if success:
		icon.texture = load("res://assets/icons/status_success.png")
		label.add_theme_color_override("font_color", Color(0.306, 0.576, 0.314))
	else:
		icon.texture = load("res://assets/icons/status_error.png")
		label.add_theme_color_override("font_color", Color(0.749, 0.200, 0.169))
