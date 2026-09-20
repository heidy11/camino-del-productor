extends Control


func _ready() -> void:
	MusicManager.reproducir("menu")
	_animar_titulo()
	_animar_subtitulo()
	_animar_menu_art()
	_conectar_botones()


func _animar_titulo() -> void:
	var title = get_node("Title")
	title.pivot_offset = title.size / 2.0
	title.modulate.a = 0.0
	title.scale = Vector2(0.7, 0.7)

	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(title, "modulate:a", 1.0, 0.35)
	tw.tween_property(title, "scale", Vector2(1.0, 1.0), 0.55).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.chain().tween_callback(_iniciar_respiracion_titulo)


# Un leve "respiro" continuo para que el título no se sienta estático.
func _iniciar_respiracion_titulo() -> void:
	var title = get_node("Title")
	var tw = create_tween()
	tw.set_loops()
	tw.tween_property(title, "scale", Vector2(1.03, 1.03), 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(title, "scale", Vector2(1.0, 1.0), 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _animar_subtitulo() -> void:
	var subtitle = get_node("Subtitle")
	var offset_original = subtitle.position.y
	subtitle.modulate.a = 0.0
	subtitle.position.y = offset_original + 14.0

	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(subtitle, "modulate:a", 1.0, 0.4).set_delay(0.25)
	tw.tween_property(subtitle, "position:y", offset_original, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_delay(0.25)


# La imagen ya trae el logo del BDP y los tres botones dibujados, así que
# solo se anima como una sola pieza (los botones reales son hitboxes
# invisibles superpuestos, ver _conectar_botones).
func _animar_menu_art() -> void:
	var art = get_node("MenuArt")
	art.pivot_offset = art.size / 2.0
	art.modulate.a = 0.0
	art.scale = Vector2(0.9, 0.9)

	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(art, "modulate:a", 1.0, 0.4).set_delay(0.45)
	tw.tween_property(art, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.45)


func _conectar_botones() -> void:
	for boton in get_node("MenuButtons").get_children():
		boton.mouse_entered.connect(_on_boton_hover.bind(boton))
		boton.mouse_exited.connect(_on_boton_unhover.bind(boton))


func _on_boton_hover(boton: Button) -> void:
	boton.pivot_offset = boton.size / 2.0
	var tw = create_tween()
	tw.tween_property(boton, "scale", Vector2(1.05, 1.05), 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _on_boton_unhover(boton: Button) -> void:
	var tw = create_tween()
	tw.tween_property(boton, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _on_new_game_button_pressed() -> void:
	GameState.nueva_partida()
	await SceneTransition.change_scene("res://scenes/Story.tscn")


func _on_album_button_pressed() -> void:
	await SceneTransition.change_scene("res://scenes/Album.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()
