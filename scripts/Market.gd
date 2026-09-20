extends Control

var precio_por_unidad = 2
var ganancia = 0

var _bob_time := 0.0
var _bob_speed := 1.6
var _player_base_y := 0.0
var _tilcayo_base_y := 0.0


func _process(delta: float) -> void:
	_bob_time += delta
	var player_sprite = get_node("PlayerSprite")
	var tilcayo_sprite = get_node("TilcayoSprite")
	player_sprite.position.y = _player_base_y + sin(_bob_time * _bob_speed) * 3.0
	tilcayo_sprite.position.y = _tilcayo_base_y + sin(_bob_time * _bob_speed + PI) * 3.0


func _ready() -> void:
	var player_sprite = get_node("PlayerSprite")

	if GameState.personaje_sprite != "":
		player_sprite.texture = load(GameState.personaje_sprite)

	_player_base_y = player_sprite.position.y
	_tilcayo_base_y = get_node("TilcayoSprite").position.y

	var condor = get_node("CondorDialog")
	var resultado = _evaluar_resultado_produccion()
	condor.set_pose(resultado["pose"])
	condor.set_message(resultado["mensaje"])
	condor.animate_in()

	actualizar_feria()
	actualizar_saldo_superior()
	_animar_tarjeta_estadisticas()


# Compara la producción base (antes del imprevisto climático) con la final
# para que el cóndor explique qué pasó, en vez de un saludo genérico.
func _evaluar_resultado_produccion() -> Dictionary:
	var base = GameState.produccion_base
	var final = GameState.produccion
	var cultivo = GameState.cultivo.to_lower()

	if base <= 0 or final == base:
		return {
			"pose": "saludando",
			"mensaje": "¡Bienvenido a la Feria de las Alturas! Produjiste las " + str(final) + " unidades de " + cultivo + " que esperabas.",
		}

	var porcentaje = int(round(abs(final - base) / float(base) * 100.0))
	var frase_evento = _frase_evento(GameState.evento_actual)

	if final < base:
		return {
			"pose": "preocupado",
			"mensaje": "Podías producir " + str(base) + " unidades de " + cultivo + ", pero " + frase_evento + " te hizo perder un " + str(porcentaje) + "% y solo produjiste " + str(final) + " unidades.",
		}

	return {
		"pose": "celebrando",
		"mensaje": "¡Buena noticia! Gracias a " + frase_evento + ", produjiste un " + str(porcentaje) + "% más de lo previsto: " + str(final) + " unidades de " + cultivo + " en vez de " + str(base) + ".",
	}


func _frase_evento(evento: String) -> String:
	match evento:
		"Helada":
			return "una helada"
		"Lluvia":
			return "la lluvia"
		"Soleado":
			return "el buen clima"
		_:
			return "un imprevisto"


func actualizar_feria() -> void:
	var crop_label = get_node("CropLabel")
	var price_label = get_node("PriceLabel")
	var crop_icon = get_node("CropIcon")

	crop_label.text = GameState.cultivo
	price_label.text = "¡Cada unidad vale " + str(precio_por_unidad) + " monedas!"

	if GameState.cultivo == "Quinua":
		crop_icon.texture = load("res://assets/crops/quinua/QuinuaMadura.png")
	else:
		crop_icon.texture = load("res://assets/crops/papa/PapaMadura.png")

	ganancia = GameState.produccion * precio_por_unidad


# Anima toda la tarjeta de producción/venta/ganancia: los íconos aparecen
# con un rebote escalonado, los números cuentan desde 0, y los íconos quedan
# con un balanceo suave continuo para que la tarjeta se sienta viva.
func _animar_tarjeta_estadisticas() -> void:
	var iconos = [get_node("CropIcon"), get_node("PriceIcon"), get_node("TotalIcon")]
	var retraso = 0.0
	for icono in iconos:
		icono.pivot_offset = icono.size / 2.0
		icono.modulate.a = 0.0
		icono.scale = Vector2(0.3, 0.3)
		icono.rotation_degrees = -12.0

		var tw = create_tween()
		tw.tween_interval(retraso)
		tw.tween_property(icono, "modulate:a", 1.0, 0.25)
		tw.parallel().tween_property(icono, "scale", Vector2(1.0, 1.0), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(icono, "rotation_degrees", 0.0, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_callback(_iniciar_balanceo_icono.bind(icono))
		retraso += 0.15

	_animar_contador(get_node("ProductionLabel"), GameState.produccion, " unidades", 0.5)
	_animar_contador(get_node("TotalLabel"), ganancia, " monedas", 0.75)


func _iniciar_balanceo_icono(icono: TextureRect) -> void:
	if not is_instance_valid(icono):
		return
	var tw = create_tween()
	tw.set_loops()
	tw.tween_property(icono, "rotation_degrees", 6.0, 1.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(icono, "rotation_degrees", -6.0, 1.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _animar_contador(label: Label, valor_final: int, sufijo: String, retraso: float) -> void:
	label.text = "0" + sufijo
	label.pivot_offset = label.size / 2.0
	label.scale = Vector2(0.7, 0.7)

	var tw = create_tween()
	tw.tween_interval(retraso)
	tw.tween_property(label, "scale", Vector2(1.0, 1.0), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_method(
		func(v: float): label.text = str(int(round(v))) + sufijo,
		0.0, float(valor_final), 0.6
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func actualizar_saldo_superior() -> void:
	get_node("MoneyLabel").text = "Tienes: " + str(GameState.monedas) + " monedas"


func _on_sell_button_pressed() -> void:
	get_node("SellButton").disabled = true

	GameState.monedas += ganancia
	GameState.monedas_obtenidas += ganancia

	print("Producción vendida")
	print("Ganancia obtenida: ", ganancia)
	print("Monedas actuales: ", GameState.monedas)

	var condor = get_node("CondorDialog")
	condor.set_pose("celebrando")
	condor.set_message("¡Buen negocio! El tilcayo te paga por tu " + GameState.cultivo.to_lower() + ".")

	await _animar_venta()

	await SceneTransition.change_scene("res://scenes/Decision.tscn")


func _animar_venta() -> void:
	_crear_monedas_venta()

	var coin_icon = get_node("TotalIcon")
	coin_icon.pivot_offset = coin_icon.size / 2.0

	var tw_icon = create_tween()
	tw_icon.tween_property(coin_icon, "scale", Vector2(1.4, 1.4), 0.18).set_trans(Tween.TRANS_SINE)
	tw_icon.tween_property(coin_icon, "scale", Vector2(1.0, 1.0), 0.25).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

	var tw_count = create_tween()
	tw_count.tween_method(_actualizar_contador_ganancia, 0.0, float(ganancia), 0.55).set_trans(Tween.TRANS_SINE)

	await tw_count.finished
	await get_tree().create_timer(0.3).timeout

	actualizar_saldo_superior()
	_pulso_money_icon()

	await get_tree().create_timer(0.5).timeout


func _actualizar_contador_ganancia(valor: float) -> void:
	get_node("TotalLabel").text = "+" + str(int(valor)) + " monedas"


# ==========================================
# MONEDAS: DEL TILCAYO AL PERSONAJE
# ==========================================

func _crear_monedas_venta() -> void:
	var textura_moneda = load("res://assets/icons/coin.png")
	var tilcayo = get_node("TilcayoSprite")
	var jugador = get_node("PlayerSprite")

	var origen = tilcayo.global_position + Vector2(tilcayo.size.x * 0.25, tilcayo.size.y * 0.4)
	var destino = jugador.global_position + Vector2(jugador.size.x * 0.65, jugador.size.y * 0.4)

	for i in range(6):
		_lanzar_moneda_venta(textura_moneda, origen, destino, i)


func _lanzar_moneda_venta(textura: Texture2D, origen: Vector2, destino: Vector2, indice: int) -> void:
	var moneda = TextureRect.new()
	moneda.texture = textura
	moneda.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	moneda.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	moneda.size = Vector2(26, 26)
	moneda.position = origen - moneda.size / 2.0 + Vector2(randf_range(-14, 14), randf_range(-10, 10))
	moneda.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(moneda)

	var destino_final = destino - moneda.size / 2.0 + Vector2(randf_range(-18, 18), randf_range(-14, 14))

	var tw = create_tween()
	tw.tween_interval(indice * 0.07)
	tw.set_parallel(true)
	tw.tween_property(moneda, "position", destino_final, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(moneda, "rotation", randf_range(-1.8, 1.8), 0.6)
	tw.chain().tween_property(moneda, "modulate:a", 0.0, 0.15)
	if indice == 0:
		tw.tween_callback(_pulso_jugador)
	tw.tween_callback(moneda.queue_free)


func _pulso_jugador() -> void:
	var jugador = get_node("PlayerSprite")
	jugador.pivot_offset = jugador.size / 2.0
	var tw = create_tween()
	tw.tween_property(jugador, "scale", Vector2(1.08, 1.08), 0.12).set_trans(Tween.TRANS_SINE)
	tw.tween_property(jugador, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)


func _pulso_money_icon() -> void:
	var icono = get_node("MoneyIcon")
	icono.pivot_offset = icono.size / 2.0
	var tw = create_tween()
	tw.tween_property(icono, "scale", Vector2(1.35, 1.35), 0.12).set_trans(Tween.TRANS_SINE)
	tw.tween_property(icono, "scale", Vector2(1.0, 1.0), 0.18).set_trans(Tween.TRANS_SINE)
