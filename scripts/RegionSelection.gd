extends Control

var _glow_pulse: Tween = null


func _ready() -> void:
	var boton = get_node("RegionRow/AndesButton")
	boton.mouse_entered.connect(_on_andes_hover)
	boton.mouse_exited.connect(_on_andes_unhover)


func _on_andes_hover() -> void:
	var glow = get_node("AndesGlow")
	if _glow_pulse:
		_glow_pulse.kill()

	var tw_in = create_tween()
	tw_in.tween_property(glow, "modulate:a", 0.85, 0.15).set_trans(Tween.TRANS_SINE)
	await tw_in.finished

	_glow_pulse = create_tween()
	_glow_pulse.set_loops()
	_glow_pulse.tween_property(glow, "modulate:a", 0.55, 0.55).set_trans(Tween.TRANS_SINE)
	_glow_pulse.tween_property(glow, "modulate:a", 0.85, 0.55).set_trans(Tween.TRANS_SINE)


func _on_andes_unhover() -> void:
	if _glow_pulse:
		_glow_pulse.kill()
		_glow_pulse = null

	var glow = get_node("AndesGlow")
	var tw = create_tween()
	tw.tween_property(glow, "modulate:a", 0.0, 0.25).set_trans(Tween.TRANS_SINE)


func _on_andes_button_pressed() -> void:
	GameState.region = "Andes"
	await _destacar_seleccion()
	await SceneTransition.change_scene("res://scenes/CharacterSelection.tscn")


func _destacar_seleccion() -> void:
	if _glow_pulse:
		_glow_pulse.kill()
		_glow_pulse = null

	var glow = get_node("AndesGlow")
	var tw = create_tween()
	tw.tween_property(glow, "modulate:a", 1.0, 0.08)
	await tw.finished

	var tw2 = create_tween()
	tw2.tween_property(glow, "modulate:a", 0.0, 0.2)
	await tw2.finished


func _on_back_button_pressed() -> void:
	await SceneTransition.change_scene("res://scenes/Story.tscn")
