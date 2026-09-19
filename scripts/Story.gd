extends Control


var _button_glow_pulse: Tween = null


func _ready() -> void:
	var condor = get_node("CondorDialog")
	condor.set_pose("saludando")
	condor.animate_in()

	_animar_encabezado()
	_animar_resplandor(get_node("CondorGlow"), 0.65, 1.0, 0.1)
	_animar_resplandor(get_node("ButtonGlow"), 0.45, 0.75, 0.3)

	var boton = get_node("ContinueButton")
	boton.mouse_entered.connect(_on_button_hover)
	boton.mouse_exited.connect(_on_button_unhover)


func _animar_resplandor(glow: TextureRect, low: float, high: float, delay: float) -> Tween:
	glow.modulate.a = 0.0

	var tw_in = create_tween()
	tw_in.tween_property(glow, "modulate:a", high, 0.5).set_delay(delay)
	await tw_in.finished

	var tw_pulse = create_tween()
	tw_pulse.set_loops()
	tw_pulse.tween_property(glow, "modulate:a", low, 1.6).set_trans(Tween.TRANS_SINE)
	tw_pulse.tween_property(glow, "modulate:a", high, 1.6).set_trans(Tween.TRANS_SINE)
	return tw_pulse


func _on_button_hover() -> void:
	var glow = get_node("ButtonGlow")
	if _button_glow_pulse:
		_button_glow_pulse.kill()
	glow.pivot_offset = glow.size / 2.0
	var tw = create_tween()
	tw.tween_property(glow, "modulate:a", 1.0, 0.15).set_trans(Tween.TRANS_SINE)
	tw.tween_property(glow, "scale", Vector2(1.15, 1.15), 0.15).set_trans(Tween.TRANS_SINE)


func _on_button_unhover() -> void:
	var glow = get_node("ButtonGlow")
	var tw = create_tween()
	tw.tween_property(glow, "modulate:a", 0.75, 0.2).set_trans(Tween.TRANS_SINE)
	tw.tween_property(glow, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_SINE)
	_button_glow_pulse = await _animar_resplandor(glow, 0.45, 0.75, 0.0)


func _animar_encabezado() -> void:
	var title = get_node("Title")
	var subtitle = get_node("Subtitle")

	title.modulate.a = 0.0
	title.position.y -= 10.0
	subtitle.modulate.a = 0.0

	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(title, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_SINE)
	tw.tween_property(title, "position:y", title.position.y + 10.0, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(subtitle, "modulate:a", 1.0, 0.5).set_delay(0.15)


func _on_continue_button_pressed() -> void:
	await SceneTransition.change_scene("res://scenes/RegionSelection.tscn")
