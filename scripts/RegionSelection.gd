extends Control


func _on_andes_button_pressed() -> void:
	GameState.region = "Andes"
	await SceneTransition.change_scene("res://scenes/CharacterSelection.tscn")


func _on_back_button_pressed() -> void:
	await SceneTransition.change_scene("res://scenes/Story.tscn")
