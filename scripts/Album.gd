extends Control

# Insignias cosméticas del Camino del Guardián.
# Son puramente visuales: no modifican economía, producción ni reglas.
# La condición de cada una solo LEE datos que ya existen en GameState.
const LOGROS_DEFINIDOS = [
	{"nodo": "Badge1", "condicion": "ahorro"},
	{"nodo": "Badge2", "condicion": "productor"},
	{"nodo": "Badge3", "condicion": "futuro"},
	{"nodo": "Badge4", "condicion": "inversor"},
	{"nodo": "Badge5", "condicion": "aprendiz"},
]


func _cumple_condicion(clave: String) -> bool:
	match clave:
		"ahorro":
			return GameState.monedas_ahorradas > 0
		"productor":
			return GameState.minidesafios_completados > 0
		"futuro":
			return GameState.fondo_emergencia > 0
		"inversor":
			return GameState.monedas_invertidas > 0
		"aprendiz":
			return GameState.sellos > 0
	return false


func _ready() -> void:
	get_node("SealsLabel").text = "Sellos: " + str(GameState.sellos)

	var index = 0
	for logro in LOGROS_DEFINIDOS:
		var icon = get_node(logro["nodo"] + "Icon")
		var label = get_node(logro["nodo"] + "Label")
		var glow = get_node(logro["nodo"] + "Glow")
		var desbloqueado = _cumple_condicion(logro["condicion"])

		if desbloqueado:
			icon.modulate = Color(1, 1, 1, 1)
			label.add_theme_color_override("font_color", Color(0.11, 0.14, 0.2, 1))
			_animar_insignia(icon, index)
			_iniciar_glow_insignia(glow, index)
		else:
			icon.modulate = Color(0.65, 0.62, 0.56, 0.7)
			label.add_theme_color_override("font_color", Color(0.45, 0.42, 0.38, 1))
			glow.visible = false

		index += 1


func _animar_insignia(icon: TextureRect, index: int) -> void:
	icon.pivot_offset = icon.size / 2.0
	icon.scale = Vector2(0.4, 0.4)
	icon.rotation = -0.25

	var tw = create_tween()
	tw.tween_interval(index * 0.1)
	tw.tween_property(icon, "scale", Vector2(1.0, 1.0), 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(icon, "rotation", 0.0, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_callback(_iniciar_brillo.bind(icon))


func _iniciar_brillo(icon: TextureRect) -> void:
	if not is_instance_valid(icon):
		return
	var tw = create_tween()
	tw.set_loops()
	tw.tween_property(icon, "modulate", Color(1.18, 1.16, 1.05, 1.0), 1.1).set_trans(Tween.TRANS_SINE)
	tw.tween_property(icon, "modulate", Color(1.0, 1.0, 1.0, 1.0), 1.1).set_trans(Tween.TRANS_SINE)


# Borde delgado dorado/blanco que se desvanece detrás del escudo desbloqueado,
# como un halo respirando (no un contorno fijo).
func _iniciar_glow_insignia(glow: Panel, index: int) -> void:
	glow.visible = true
	glow.modulate.a = 0.0

	var tw_entrada = create_tween()
	tw_entrada.tween_interval(index * 0.1 + 0.25)
	tw_entrada.tween_property(glow, "modulate:a", 1.0, 0.4)
	tw_entrada.tween_callback(_iniciar_respiracion_glow.bind(glow))


func _iniciar_respiracion_glow(glow: Panel) -> void:
	if not is_instance_valid(glow):
		return
	var tw = create_tween()
	tw.set_loops()
	tw.tween_property(glow, "modulate:a", 0.35, 1.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(glow, "modulate:a", 1.0, 1.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _on_back_button_pressed() -> void:
	await SceneTransition.change_scene("res://scenes/MainMenu.tscn")
