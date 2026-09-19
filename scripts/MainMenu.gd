extends Control


func _on_new_game_button_pressed() -> void:
	GameState.nueva_partida()
	await SceneTransition.change_scene("res://scenes/Story.tscn")


func _on_album_button_pressed() -> void:
	await SceneTransition.change_scene("res://scenes/Album.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()
