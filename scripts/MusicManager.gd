extends Node

# Autoload único de música de fondo. Hace crossfade entre dos pistas:
# "menu" (menú, historia, selección de región/personaje y álbum) y
# "farm" (desde que empieza la Finca y durante el resto de la partida).
# reproducir() es idempotente: si ya suena la pista pedida, no hace nada,
# para no reiniciar el audio cada vez que se cambia de escena.

const PISTAS := {
	"menu": "res://assets/audio/MusicaMenu.mp3",
	"farm": "res://assets/audio/MusicaFarm.mp3",
}

const VOLUMEN_DB := -8.0
const VOLUMEN_SILENCIO_DB := -80.0
const DURACION_FADE := 0.6

const ESCENAS_FARM := [
	"res://scenes/Farm.tscn",
	"res://scenes/Growth.tscn",
	"res://scenes/Market.tscn",
	"res://scenes/Decision.tscn",
	"res://scenes/Results.tscn",
]

var _player_a: AudioStreamPlayer
var _player_b: AudioStreamPlayer
var _activo: AudioStreamPlayer
var _pista_actual := ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	_player_a = AudioStreamPlayer.new()
	_player_b = AudioStreamPlayer.new()
	for jugador in [_player_a, _player_b]:
		jugador.volume_db = VOLUMEN_SILENCIO_DB
		add_child(jugador)

	_activo = _player_a


func reproducir(nombre_pista: String) -> void:
	if nombre_pista == _pista_actual or not PISTAS.has(nombre_pista):
		return

	_pista_actual = nombre_pista

	var saliente = _activo
	var entrante = _player_b if _activo == _player_a else _player_a

	var stream = load(PISTAS[nombre_pista])
	if stream is AudioStreamMP3:
		stream.loop = true
	entrante.stream = stream
	entrante.volume_db = VOLUMEN_SILENCIO_DB
	entrante.play()

	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(entrante, "volume_db", VOLUMEN_DB, DURACION_FADE)
	if saliente.playing:
		tw.tween_property(saliente, "volume_db", VOLUMEN_SILENCIO_DB, DURACION_FADE)
		tw.chain().tween_callback(saliente.stop)

	_activo = entrante


# Mapea cada escena a la pista que le corresponde. Úsalo desde
# SceneTransition (y desde MainMenu al arrancar el juego) en vez de decidir
# la pista escena por escena.
func reproducir_para_escena(path: String) -> void:
	if path in ESCENAS_FARM:
		reproducir("farm")
	else:
		reproducir("menu")
