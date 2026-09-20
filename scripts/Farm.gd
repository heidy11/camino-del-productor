extends Node2D

const CAMINAR_VELOCIDAD := 260.0

var terreno_preparado = false
var cultivo_seleccionado = false
var sembrado = false
var personaje_en_terreno = false
var caminando = false

var pulso_tween: Tween = null
var prepare_pulse_tween: Tween = null

var _bob_time := 0.0
var _bob_speed := 1.6
var _player_base_y := 0.0


func _process(delta: float) -> void:
	_bob_time += delta
	var player_sprite = get_node("PlayerSprite")
	player_sprite.position.y = _player_base_y + sin(_bob_time * _bob_speed) * 3.0


func _ready() -> void:
	GameState.ciclo_actual += 1
	GameState.actividad = "Agricultura"

	var cycle_label = get_node("CycleLabel")
	var money_label = get_node("MoneyLabel")
	var player_sprite = get_node("PlayerSprite")

	cycle_label.text = "Ciclo " + str(GameState.ciclo_actual) + " / " + str(GameState.MAX_CICLOS)
	money_label.text = "Monedas: " + str(GameState.monedas)

	if GameState.personaje_sprite != "":
		player_sprite.texture = load(GameState.personaje_sprite)

	_player_base_y = player_sprite.position.y

	var condor = get_node("CondorDialog")
	condor.set_pose("saludando")
	if GameState.ciclo_actual <= 1:
		condor.set_message("¡Bienvenido a la Finca de las Alturas! Camina hasta el terreno para empezar.")
	else:
		condor.set_message("¡Vamos con el ciclo " + str(GameState.ciclo_actual) + "! Camina hasta el terreno para seguir produciendo.")
	condor.animate_in()

	get_node("PrepareButton").visible = false
	get_node("PapaButton").visible = false
	get_node("QuinuaButton").visible = false

	var plot = get_node("PlotHighlight")
	plot.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	plot.gui_input.connect(_on_plot_highlight_gui_input)

	for boton in [get_node("PapaButton"), get_node("QuinuaButton")]:
		boton.mouse_entered.connect(_on_cultivo_button_mouse_entered.bind(boton))
		boton.mouse_exited.connect(_on_cultivo_button_mouse_exited.bind(boton))

	_iniciar_pulso_parcela()

	print("Entraste a la Finca de las Alturas")
	print("Ciclo actual: ", GameState.ciclo_actual)


func _iniciar_pulso_parcela() -> void:
	var highlight = get_node("PlotHighlight")
	pulso_tween = create_tween()
	pulso_tween.set_loops()
	pulso_tween.tween_property(highlight, "modulate:a", 0.4, 0.8).set_trans(Tween.TRANS_SINE)
	pulso_tween.tween_property(highlight, "modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_SINE)


func _on_plot_highlight_gui_input(event: InputEvent) -> void:
	if personaje_en_terreno or caminando:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_caminar_hacia_terreno()


func _caminar_hacia_terreno() -> void:
	caminando = true

	var player_sprite = get_node("PlayerSprite")
	var plot = get_node("PlotHighlight")

	var destino_x = plot.position.x - player_sprite.size.x - 20.0
	var distancia = abs(destino_x - player_sprite.position.x)
	var duracion = clamp(distancia / CAMINAR_VELOCIDAD, 0.3, 1.6)

	player_sprite.flip_h = destino_x > player_sprite.position.x
	_bob_speed = 5.0

	var tw = create_tween()
	tw.tween_property(player_sprite, "position:x", destino_x, duracion).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_callback(_on_llegada_al_terreno)


func _on_llegada_al_terreno() -> void:
	caminando = false
	personaje_en_terreno = true
	_bob_speed = 1.6
	_mostrar_boton_preparar()


func _mostrar_boton_preparar() -> void:
	var boton = get_node("PrepareButton")
	boton.pivot_offset = boton.size / 2.0
	boton.visible = true
	boton.modulate.a = 0.0
	boton.scale = Vector2(0.4, 0.4)

	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(boton, "modulate:a", 1.0, 0.25)
	tw.tween_property(boton, "scale", Vector2(1.08, 1.08), 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.chain().tween_property(boton, "scale", Vector2(1.0, 1.0), 0.15)
	tw.chain().tween_callback(_iniciar_pulso_boton_preparar)


func _iniciar_pulso_boton_preparar() -> void:
	var boton = get_node("PrepareButton")
	prepare_pulse_tween = create_tween()
	prepare_pulse_tween.set_loops()
	prepare_pulse_tween.tween_interval(0.5)
	prepare_pulse_tween.tween_property(boton, "scale", Vector2(1.06, 1.06), 0.35).set_trans(Tween.TRANS_SINE)
	prepare_pulse_tween.tween_property(boton, "scale", Vector2(1.0, 1.0), 0.35).set_trans(Tween.TRANS_SINE)


func _on_prepare_button_pressed() -> void:
	if terreno_preparado:
		return
	if not personaje_en_terreno:
		return

	terreno_preparado = true

	if prepare_pulse_tween:
		prepare_pulse_tween.kill()

	_mostrar_terreno_preparado()
	_ocultar_boton_preparar()
	_crear_polvo(Vector2(767, 412))

	print("Terreno preparado")


func _ocultar_boton_preparar() -> void:
	var boton = get_node("PrepareButton")
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(boton, "modulate:a", 0.0, 0.25)
	tw.tween_property(boton, "scale", Vector2(0.6, 0.6), 0.25)
	tw.chain().tween_callback(_on_boton_preparar_oculto)


func _on_boton_preparar_oculto() -> void:
	get_node("PrepareButton").visible = false
	_mostrar_opciones_cultivo()


func _crear_polvo(origen: Vector2) -> void:
	for i in range(7):
		var mota = ColorRect.new()
		mota.color = Color(0.62, 0.5, 0.35, 0.75)
		mota.size = Vector2(6, 6)
		mota.position = origen
		mota.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(mota)

		var angulo = randf_range(0.0, TAU)
		var distancia = randf_range(30.0, 70.0)
		var destino = origen + Vector2(cos(angulo), sin(angulo) * 0.6) * distancia

		var tw = create_tween()
		tw.set_parallel(true)
		tw.tween_property(mota, "position", destino, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tw.tween_property(mota, "modulate:a", 0.0, 0.5)
		tw.chain().tween_callback(mota.queue_free)


func _mostrar_terreno_preparado() -> void:
	if pulso_tween:
		pulso_tween.kill()

	var highlight = get_node("PlotHighlight")
	var badge = get_node("PlotReadyBadge")

	var tw = create_tween()
	tw.tween_property(highlight, "modulate:a", 0.0, 0.4)

	badge.visible = true
	badge.modulate.a = 0.0
	badge.scale = Vector2(0.3, 0.3)
	badge.pivot_offset = badge.size / 2.0

	var tw2 = create_tween()
	tw2.set_parallel(true)
	tw2.tween_property(badge, "modulate:a", 1.0, 0.2)
	tw2.tween_property(badge, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _mostrar_opciones_cultivo() -> void:
	var papa = get_node("PapaButton")
	var quinua = get_node("QuinuaButton")

	for boton in [papa, quinua]:
		boton.visible = true
		boton.modulate.a = 0.0
		boton.scale = Vector2(0.3, 0.3)
		boton.rotation_degrees = -10.0
		boton.pivot_offset = boton.size / 2.0

	_animar_entrada_cultivo(papa, 0.0)
	_animar_entrada_cultivo(quinua, 0.12)


func _animar_entrada_cultivo(boton: Button, retraso: float) -> void:
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(boton, "modulate:a", 1.0, 0.3).set_delay(retraso)
	tw.tween_property(boton, "scale", Vector2(1.12, 1.12), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(retraso)
	tw.tween_property(boton, "rotation_degrees", 0.0, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(retraso)
	tw.chain().tween_property(boton, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_SINE)


func _on_cultivo_button_mouse_entered(boton: Button) -> void:
	if not boton.visible:
		return
	boton.pivot_offset = boton.size / 2.0
	var tw = create_tween()
	tw.tween_property(boton, "scale", Vector2(1.08, 1.08), 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _on_cultivo_button_mouse_exited(boton: Button) -> void:
	if not boton.visible:
		return
	boton.pivot_offset = boton.size / 2.0
	var tw = create_tween()
	tw.tween_property(boton, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _on_papa_button_pressed() -> void:
	_sembrar("Papa", "res://assets/icons/papa.png", "res://assets/crops/papa/PapaSemilla.png")


func _on_quinua_button_pressed() -> void:
	_sembrar("Quinua", "res://assets/icons/quinua.png", "res://assets/crops/quinua/QuinuaBrote.png")


func _sembrar(nombre_cultivo: String, icon_path: String, semilla_path: String) -> void:
	if terreno_preparado == false:
		print("Primero debes preparar el terreno")
		return

	if sembrado:
		print("El cultivo ya fue sembrado")
		return

	GameState.cultivo = nombre_cultivo
	cultivo_seleccionado = true
	sembrado = true

	_ocultar_opciones_cultivo()
	_mostrar_cultivo_elegido(icon_path)

	print("Cultivo seleccionado: ", nombre_cultivo)

	await get_tree().create_timer(0.35).timeout
	_mostrar_planta_inicial(semilla_path)

	print("Has sembrado: ", nombre_cultivo)

	await get_tree().create_timer(0.45).timeout
	await SceneTransition.change_scene("res://scenes/Growth.tscn")


func _ocultar_opciones_cultivo() -> void:
	var papa = get_node("PapaButton")
	var quinua = get_node("QuinuaButton")

	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(papa, "modulate:a", 0.0, 0.2)
	tw.tween_property(quinua, "modulate:a", 0.0, 0.2)
	tw.chain().tween_callback(_on_opciones_cultivo_ocultas)


func _on_opciones_cultivo_ocultas() -> void:
	get_node("PapaButton").visible = false
	get_node("QuinuaButton").visible = false


func _mostrar_cultivo_elegido(icon_path: String) -> void:
	var badge = get_node("CropChoiceBadge")
	badge.texture = load(icon_path)
	badge.visible = true
	badge.modulate.a = 0.0
	badge.scale = Vector2(0.5, 0.5)
	badge.pivot_offset = badge.size / 2.0

	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(badge, "modulate:a", 1.0, 0.2)
	tw.tween_property(badge, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _mostrar_planta_inicial(semilla_path: String) -> void:
	var badge = get_node("CropChoiceBadge")
	var sprite = get_node("CropSprite")

	badge.visible = false

	sprite.texture = load(semilla_path)
	sprite.visible = true
	sprite.modulate.a = 0.0
	sprite.scale = Vector2(0.3, 0.3)
	sprite.pivot_offset = sprite.size / 2.0

	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(sprite, "modulate:a", 1.0, 0.25)
	tw.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
