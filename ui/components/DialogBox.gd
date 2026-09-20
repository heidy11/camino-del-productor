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

const VELOCIDAD_TIPEO := 0.028  # segundos por letra
const DURACION_TIPEO_MIN := 0.15
const DURACION_TIPEO_MAX := 1.8

var _bob_time := randf() * TAU
var _base_portrait_y := 0.0
var _tipeo_tween: Tween = null
var _url_regex := RegEx.new()


func _ready() -> void:
	_base_portrait_y = get_node("Portrait").position.y
	_url_regex.compile("(https?://[^\\s]+)")
	get_node("Bubble/MessageLabel").meta_clicked.connect(_on_link_clicked)


func _process(delta: float) -> void:
	_bob_time += delta
	var portrait = get_node("Portrait")
	portrait.position.y = _base_portrait_y + sin(_bob_time * 1.6) * 4.0


func set_message(message: String) -> void:
	var label = get_node("Bubble/MessageLabel")
	label.text = _resaltar_enlaces(message)
	_iniciar_tipeo(label)
	_speak_pulse()


# Si el mensaje trae un link (como el del funcionario del BDP invitando a
# las agencias), lo subraya, lo colorea y lo hace clickeable. El resto del
# texto queda igual.
func _resaltar_enlaces(texto: String) -> String:
	return _url_regex.sub(texto, "[u][color=#0e655d][url=$1]$1[/url][/color][/u]", true)


func _on_link_clicked(meta) -> void:
	OS.shell_open(str(meta))


# Revela el mensaje letra por letra en vez de mostrarlo de golpe, para darle
# más presencia al diálogo del cóndor.
func _iniciar_tipeo(label: RichTextLabel) -> void:
	if _tipeo_tween:
		_tipeo_tween.kill()

	label.visible_ratio = 0.0
	var duracion = clamp(label.get_parsed_text().length() * VELOCIDAD_TIPEO, DURACION_TIPEO_MIN, DURACION_TIPEO_MAX)

	_tipeo_tween = create_tween()
	_tipeo_tween.tween_property(label, "visible_ratio", 1.0, duracion).set_trans(Tween.TRANS_LINEAR)


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
