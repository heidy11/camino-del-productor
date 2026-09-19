extends Control


func _on_pressed() -> void:
	await SceneTransition.change_scene("res://scenes/RegionSelection.tscn")
