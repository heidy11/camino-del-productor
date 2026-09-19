extends Control

# Efecto visual ligero por evento climático. No participa en el cálculo de
# producción ni en ninguna regla de juego - es puramente decorativo.

const PARTICLE_COUNT = 26

var particles: Array = []
var weather_type := "none"


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	get_node("Tint").mouse_filter = Control.MOUSE_FILTER_IGNORE
	get_node("Tint").color = Color(0, 0, 0, 0)

	for i in range(PARTICLE_COUNT):
		var p = ColorRect.new()
		p.mouse_filter = Control.MOUSE_FILTER_IGNORE
		p.visible = false
		add_child(p)
		particles.append(p)
		_reset_particle(p)


func _reset_particle(p: ColorRect) -> void:
	p.position = Vector2(randf_range(0.0, 1280.0), randf_range(-400.0, 0.0))


func set_weather(type: String) -> void:
	weather_type = type
	var tint = get_node("Tint")

	match type:
		"soleado":
			_tween_tint(Color(1.0, 0.85, 0.5, 0.16))
			_configurar_particulas(false, Color(0, 0, 0, 0))
		"lluvia":
			_tween_tint(Color(0.55, 0.7, 0.95, 0.16))
			_configurar_particulas(true, Color(0.65, 0.8, 1.0, 0.65), Vector2(3, 16))
		"helada":
			_tween_tint(Color(0.75, 0.9, 1.0, 0.22))
			_configurar_particulas(true, Color(1.0, 1.0, 1.0, 0.8), Vector2(4, 4))
		_:
			_tween_tint(Color(0, 0, 0, 0))
			_configurar_particulas(false, Color(0, 0, 0, 0))


func _tween_tint(color: Color) -> void:
	var tint = get_node("Tint")
	var tw = create_tween()
	tw.tween_property(tint, "color", color, 0.6)


func _configurar_particulas(activas: bool, color: Color, tamano: Vector2 = Vector2(4, 4)) -> void:
	for p in particles:
		p.visible = activas
		p.color = color
		p.size = tamano
		if activas:
			_reset_particle(p)


func _process(delta: float) -> void:
	if weather_type == "lluvia":
		for p in particles:
			p.position.y += 780.0 * delta
			if p.position.y > 720.0:
				_reset_particle(p)
	elif weather_type == "helada":
		for p in particles:
			p.position.y += 55.0 * delta
			p.position.x += sin(p.position.y * 0.02) * 18.0 * delta
			if p.position.y > 720.0:
				_reset_particle(p)
