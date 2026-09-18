extends HBoxContainer


func set_text(text: String) -> void:
	get_node("TextLabel").text = text


func set_icon(texture: Texture2D) -> void:
	get_node("Icon").texture = texture
