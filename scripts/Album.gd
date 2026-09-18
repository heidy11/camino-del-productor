extends Control


func _ready() -> void:
	get_node("SealsLabel").text = "Sellos acumulados: " + str(GameState.sellos)

	var list = get_node("AchievementsList")

	for child in list.get_children():
		child.queue_free()

	if GameState.logros.is_empty():
		var empty_label = Label.new()
		empty_label.text = "Aún no tienes logros. ¡Juega una partida para conseguir Sellos del Guardián!"
		empty_label.add_theme_color_override("font_color", Color(0.11, 0.14, 0.2))
		list.add_child(empty_label)
	else:
		for logro in GameState.logros:
			var label = Label.new()
			label.text = "✔ " + logro
			label.add_theme_color_override("font_color", Color(0.11, 0.14, 0.2))
			list.add_child(label)


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
