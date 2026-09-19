extends Node2D


var terreno_preparado = false
var cultivo_seleccionado = false
var sembrado = false
var pulso_tween: Tween = null

var _bob_time := 0.0
var _player_base_y := 0.0


func _process(delta: float) -> void:
	_bob_time += delta
	var player_sprite = get_node("PlayerSprite")
	player_sprite.position.y = _player_base_y + sin(_bob_time * 1.6) * 3.0


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
		condor.set_message("¡Bienvenido a la Finca de las Alturas! Prepara tu terreno y elige qué sembrar.")
	else:
		condor.set_message("¡Vamos con el ciclo " + str(GameState.ciclo_actual) + "! Sigamos produciendo.")
	condor.animate_in()

	_iniciar_pulso_parcela()

	print("Entraste a la Finca de las Alturas")
	print("Ciclo actual: ", GameState.ciclo_actual)


func _iniciar_pulso_parcela() -> void:
	var highlight = get_node("PlotHighlight")
	pulso_tween = create_tween()
	pulso_tween.set_loops()
	pulso_tween.tween_property(highlight, "modulate:a", 0.4, 0.8).set_trans(Tween.TRANS_SINE)
	pulso_tween.tween_property(highlight, "modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_SINE)


func _on_prepare_button_pressed() -> void:
	if terreno_preparado:
		print("El terreno ya está preparado")
		return

	terreno_preparado = true
	_mostrar_terreno_preparado()
	_crear_polvo(Vector2(767, 412))

	print("Terreno preparado")


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


func _on_papa_button_pressed() -> void:
	if terreno_preparado == false:
		print("Primero debes preparar el terreno")
		return

	if cultivo_seleccionado:
		print("Ya elegiste un cultivo")
		return

	GameState.cultivo = "Papa"
	cultivo_seleccionado = true
	_mostrar_cultivo_elegido("res://assets/icons/papa.png")

	print("Cultivo seleccionado: Papa")


func _on_quinua_button_pressed() -> void:
	if terreno_preparado == false:
		print("Primero debes preparar el terreno")
		return

	if cultivo_seleccionado:
		print("Ya elegiste un cultivo")
		return

	GameState.cultivo = "Quinua"
	cultivo_seleccionado = true
	_mostrar_cultivo_elegido("res://assets/icons/quinua.png")

	print("Cultivo seleccionado: Quinua")


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


func _on_plant_button_pressed() -> void:
	if terreno_preparado == false:
		print("Primero debes preparar el terreno")
		return

	if cultivo_seleccionado == false:
		print("Primero debes elegir un cultivo")
		return

	if sembrado:
		print("El cultivo ya fue sembrado")
		return

	sembrado = true
	_mostrar_planta_inicial()

	print("Has sembrado: ", GameState.cultivo)

	await get_tree().create_timer(0.45).timeout
	await SceneTransition.change_scene("res://scenes/Growth.tscn")


func _mostrar_planta_inicial() -> void:
	var badge = get_node("CropChoiceBadge")
	var sprite = get_node("CropSprite")

	badge.visible = false

	var textura: Texture2D
	if GameState.cultivo == "Papa":
		textura = load("res://assets/crops/papa/PapaSemilla.png")
	else:
		textura = load("res://assets/crops/quinua/QuinuaBrote.png")

	sprite.texture = textura
	sprite.visible = true
	sprite.modulate.a = 0.0
	sprite.scale = Vector2(0.3, 0.3)
	sprite.pivot_offset = sprite.size / 2.0

	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(sprite, "modulate:a", 1.0, 0.25)
	tw.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
