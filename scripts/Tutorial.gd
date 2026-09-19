extends Control


func _on_start_button_pressed() -> void:
	await SceneTransition.change_scene("res://scenes/RegionSelection.tscn")
