extends PanelContainer


func set_event(icon: Texture2D, event_title: String, description: String) -> void:
	get_node("Content/Header/Icon").texture = icon
	get_node("Content/Header/TitleLabel").text = event_title
	get_node("Content/DescriptionLabel").text = description
