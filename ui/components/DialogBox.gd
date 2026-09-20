extends HBoxContainer

# Mapeo de poses a los retratos finales entregados.
# Explicando, Señalando y Celebrando no tienen transparencia real (fondo de
# cuadros horneado en el PNG - ver informe de auditoría de assets), así que
# usan un retrato limpio equivalente mientras el arte no se regenera.
const POSES = {
	"saludando": "res://assets/condor/CondorSaludando.png",
	"explicando": "res://assets/condor/CondorNeutral.png",
	"pensativo": "res://assets/condor/CondorPensativo.png",
	"senalando": "res://assets/condor/CondorNeutral.png",
	"celebrando": "res://assets/condor/CondorSaludando.png",
	"preocupado": "res://assets/condor/CondorPreocupado.png",
	"neutral": "res://assets/condor/CondorNeutral.png",
	"feliz": "res://assets/condor/CondorFeliz.png",
	"dudoso": "res://assets/condor/Condordudoso.png",
	"triste": "res://assets/condor/condorTriste.png",
}

var _bob_time := randf() * TAU
var _base_portrait_y := 0.0


func _ready() -> void:
	_base_portrait_y = get_node("Portrait").position.y


func _process(delta: float) -> void:
	_bob_time += delta
	var portrait = get_node("Portrait")
	portrait.position.y = _base_portrait_y + sin(_bob_time * 1.6) * 4.0


func set_message(message: String) -> void:
	get_node("Bubble/MessageLabel").text = message
	_speak_pulse()


func set_portrait(texture: Texture2D) -> void:
	get_node("Portrait").texture = texture


func set_pose(pose_name: String) -> void:
	if POSES.has(pose_name):
		get_node("Portrait").texture = load(POSES[pose_name])


func _speak_pulse() -> void:
	var bubble = get_node("Bubble")
	bubble.pivot_offset = bubble.size / 2.0

	var tw = create_tween()
	tw.tween_property(bubble, "scale", Vector2(1.04, 1.04), 0.1).set_trans(Tween.TRANS_SINE)
	tw.tween_property(bubble, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_SINE)


func animate_in() -> void:
	visible = true
	modulate.a = 0.0
	scale = Vector2(0.7, 0.7)
	pivot_offset = size / 2.0

	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "modulate:a", 1.0, 0.3)
	tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func animate_out() -> void:
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "modulate:a", 0.0, 0.2)
	tw.tween_property(self, "scale", Vector2(0.7, 0.7), 0.2)
	tw.chain().tween_callback(func(): visible = false)
