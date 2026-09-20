extends Node

# Autoload que agrega una animación suave de hover/presión y un sonido de
# clic a TODOS los botones del juego, sin tener que tocar cada escena.
# No cambia señales existentes ni afecta la lógica de cada pantalla.

const SONIDO_CLIC := "res://assets/audio/ClickUI.wav"

var _click_player: AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	_click_player = AudioStreamPlayer.new()
	_click_player.stream = load(SONIDO_CLIC)
	_click_player.volume_db = -8.0
	add_child(_click_player)

	get_tree().node_added.connect(_on_node_added)


func _on_node_added(node: Node) -> void:
	if node is BaseButton:
		_wire_button(node)


func _wire_button(button: BaseButton) -> void:
	if button.has_meta("_button_polish_wired"):
		return
	button.set_meta("_button_polish_wired", true)

	button.mouse_entered.connect(_on_hover.bind(button))
	button.mouse_exited.connect(_on_unhover.bind(button))
	button.button_down.connect(_on_press.bind(button))
	button.button_up.connect(_on_release.bind(button))
	button.pressed.connect(_on_clicked)


func _on_clicked() -> void:
	_click_player.stop()
	_click_player.play()


func _target_scale(button: BaseButton, factor: float) -> void:
	if not is_instance_valid(button) or not button.is_inside_tree():
		return
	if button.disabled:
		return

	button.pivot_offset = button.size / 2.0

	var tw = button.create_tween()
	tw.tween_property(button, "scale", Vector2(factor, factor), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _target_glow(button: BaseButton, brighten: bool) -> void:
	if not is_instance_valid(button) or not button.is_inside_tree():
		return
	if button.disabled:
		return

	var target_color = Color(1.35, 1.32, 1.15, 1.0) if brighten else Color(1, 1, 1, 1)

	var tw = button.create_tween()
	tw.tween_property(button, "modulate", target_color, 0.1).set_trans(Tween.TRANS_SINE)


func _on_hover(button: BaseButton) -> void:
	_target_scale(button, 1.045)
	_target_glow(button, true)


func _on_unhover(button: BaseButton) -> void:
	_target_scale(button, 1.0)
	_target_glow(button, false)


func _on_press(button: BaseButton) -> void:
	_target_scale(button, 0.96)


func _on_release(button: BaseButton) -> void:
	if is_instance_valid(button) and button.is_inside_tree():
		var hovering = button.get_global_rect().has_point(button.get_global_mouse_position())
		_target_scale(button, 1.045 if hovering else 1.0)
		_target_glow(button, hovering)
