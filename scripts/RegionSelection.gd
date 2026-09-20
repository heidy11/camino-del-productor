extends Control

const GLOW_COLORS: Array[Color] = [
	Color(0, 1, 0.9, 1),
	Color(0.3, 0.6, 1, 1),
	Color(1, 0.3, 0.85, 1),
	Color(1, 0.85, 0.2, 1),
	Color(0.4, 1, 0.3, 1),
]
const AMBIENT_ALPHA := 0.55
const HOVER_ALPHA := 1.0

var _color_cycle_tween: Tween = null
var _glow_alpha_tween: Tween = null


func _ready() -> void:
	var boton = get_node("AndesButton")
	boton.mouse_entered.connect(_on_andes_hover)
	boton.mouse_exited.connect(_on_andes_unhover)
	_start_color_cycle()


func _start_color_cycle() -> void:
	var glow_style: StyleBoxFlat = get_node("AndesButton/AndesGlow").get_theme_stylebox("panel")
	if _color_cycle_tween:
		_color_cycle_tween.kill()

	_color_cycle_tween = create_tween()
	_color_cycle_tween.set_loops()
	for color in GLOW_COLORS:
		_color_cycle_tween.tween_property(glow_style, "border_color", color, 0.9).set_trans(Tween.TRANS_SINE)
		_color_cycle_tween.parallel().tween_property(glow_style, "shadow_color", Color(color.r, color.g, color.b, 0.55), 0.9)


func _on_andes_hover() -> void:
	_set_glow_alpha(HOVER_ALPHA, 0.15)


func _on_andes_unhover() -> void:
	_set_glow_alpha(AMBIENT_ALPHA, 0.25)


func _set_glow_alpha(target: float, duration: float) -> void:
	var glow = get_node("AndesButton/AndesGlow")
	if _glow_alpha_tween:
		_glow_alpha_tween.kill()

	_glow_alpha_tween = create_tween()
	_glow_alpha_tween.tween_property(glow, "modulate:a", target, duration).set_trans(Tween.TRANS_SINE)


func _on_andes_button_pressed() -> void:
	GameState.region = "Andes"
	await _destacar_seleccion()
	await SceneTransition.change_scene("res://scenes/CharacterSelection.tscn")


func _destacar_seleccion() -> void:
	var glow = get_node("AndesButton/AndesGlow")
	if _glow_alpha_tween:
		_glow_alpha_tween.kill()
		_glow_alpha_tween = null

	var tw = create_tween()
	tw.tween_property(glow, "modulate:a", 1.0, 0.08)
	await tw.finished

	var tw2 = create_tween()
	tw2.tween_property(glow, "modulate:a", AMBIENT_ALPHA, 0.2)
	await tw2.finished


func _on_back_button_pressed() -> void:
	await SceneTransition.change_scene("res://scenes/Story.tscn")
