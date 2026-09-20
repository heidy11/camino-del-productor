extends CanvasLayer

# Autoload único para transiciones consistentes entre escenas (fundido a
# negro breve). No participa en ninguna regla de juego: solo envuelve la
# misma llamada a change_scene_to_file que ya usaba cada pantalla.

var _rect: ColorRect
var _busy := false


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS

	_rect = ColorRect.new()
	_rect.color = Color(0.06, 0.05, 0.05, 0.0)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_rect)


func change_scene(path: String) -> void:
	if _busy:
		MusicManager.reproducir_para_escena(path)
		get_tree().change_scene_to_file(path)
		return

	_busy = true

	MusicManager.reproducir_para_escena(path)

	var tw_out = create_tween()
	tw_out.tween_property(_rect, "color:a", 1.0, 0.22).set_trans(Tween.TRANS_SINE)
	await tw_out.finished

	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	await get_tree().process_frame

	var tw_in = create_tween()
	tw_in.tween_property(_rect, "color:a", 0.0, 0.28).set_trans(Tween.TRANS_SINE)
	await tw_in.finished

	_busy = false
