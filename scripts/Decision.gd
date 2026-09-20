extends Control

const COSTO_AHORRAR := 50
const COSTO_INVERTIR := 100
const COSTO_GASTAR := 100


func _ready() -> void:
	actualizar_dinero()

	# Si el jugador llegó sin monedas (por ejemplo, tras arriesgarse en varias
	# heladas seguidas sin comprar protección), no hay ninguna decisión real
	# que tomar: antes esto dejaba las 3 tarjetas deshabilitadas sin ninguna
	# forma de continuar. Ahora se corta la partida con una explicación.
	if GameState.monedas <= 0:
		_mostrar_sin_monedas()
		return

	_actualizar_costos()
	_conectar_hover(["SaveButton", "InvestButton", "SpendButton", "InvestToolsButton", "InvestSeedsButton", "SpendCandyButton", "SpendGamesButton"])
	_animar_entrada_principal()

	var condor = get_node("CondorDialog")
	condor.set_pose("pensativo")
	condor.set_message("Piensa bien: la decisión que elijas tendrá una consecuencia. ¡Podrás ganar puntos extra o perderlos!")
	condor.animate_in()


# Corta la partida cuando no queda ni una moneda para decidir. En vez de
# dejar las tarjetas bloqueadas sin salida, se explica qué pasó y se ofrece
# ir directo al resumen final (Results ya recalcula el perfil financiero
# con los datos que dejó la partida, así que no hace falta una pantalla nueva).
func _mostrar_sin_monedas() -> void:
	get_node("QuestionLabel").text = "No te queda ninguna moneda para decidir"

	for nombre in ["SaveButton", "InvestButton", "SpendButton", "SaveCost", "SaveEffect", "InvestCost", "InvestEffect", "SpendCost", "SpendEffect"]:
		get_node(nombre).visible = false

	var boton = get_node("NoFundsButton")
	boton.visible = true
	boton.modulate.a = 0.0
	boton.pivot_offset = boton.size / 2.0
	boton.scale = Vector2(0.7, 0.7)
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(boton, "modulate:a", 1.0, 0.3).set_delay(0.3)
	tw.tween_property(boton, "scale", Vector2(1.0, 1.0), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.3)

	var condor = get_node("CondorDialog")
	condor.set_pose("preocupado")
	condor.set_message("Te quedaste sin monedas por algunas decisiones difíciles. No pasa nada, así se aprende: ¡vuelve a intentarlo la próxima vez!")
	condor.animate_in()


func _on_no_funds_button_pressed() -> void:
	await SceneTransition.change_scene("res://scenes/Results.tscn")


# Entrada escalonada de las 3 tarjetas principales (Ahorrar / Invertir /
# Date un gusto) para que la pantalla se sienta viva desde el primer momento.
func _animar_entrada_principal() -> void:
	var retraso = 0.0
	for nombre in ["SaveButton", "InvestButton", "SpendButton"]:
		var boton = get_node(nombre)
		boton.pivot_offset = boton.size / 2.0
		boton.modulate.a = 0.0
		boton.scale = Vector2(0.6, 0.6)
		boton.rotation_degrees = -8.0

		var tw = create_tween()
		tw.tween_interval(retraso)
		tw.tween_property(boton, "modulate:a", 1.0, 0.25)
		tw.parallel().tween_property(boton, "scale", Vector2(1.0, 1.0), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(boton, "rotation_degrees", 0.0, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		retraso += 0.12


# Mismo pop dinámico (escala + leve giro + brillo) en las 7 tarjetas de
# decisión, tanto las principales como las que se despliegan al elegir.
func _conectar_hover(nombres: Array) -> void:
	for nombre in nombres:
		var boton = get_node(nombre)
		boton.mouse_entered.connect(_on_opcion_hover.bind(boton))
		boton.mouse_exited.connect(_on_opcion_unhover.bind(boton))


func _on_opcion_hover(boton: Button) -> void:
	if boton.disabled or not boton.visible:
		return
	boton.pivot_offset = boton.size / 2.0
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(boton, "scale", Vector2(1.06, 1.06), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(boton, "rotation_degrees", 2.0, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_opcion_unhover(boton: Button) -> void:
	boton.pivot_offset = boton.size / 2.0
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(boton, "scale", Vector2(1.0, 1.0), 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(boton, "rotation_degrees", 0.0, 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func actualizar_dinero() -> void:
	var money_label = get_node("MoneyLabel")
	var goal_label = get_node("GoalLabel")

	money_label.text = "Tienes: " + str(GameState.monedas) + " monedas"
	goal_label.text = "Meta de ahorro: " + str(GameState.monedas_ahorradas) + " / " + str(GameState.meta_ahorro)


# Nunca se puede pedir más de lo que el jugador realmente tiene: si tiene
# menos que el objetivo, la decisión usa todas sus monedas disponibles.
func _costo_real(objetivo: int) -> int:
	return min(objetivo, GameState.monedas)


func _actualizar_costos() -> void:
	get_node("SaveCost").text = "AHORRA " + str(_costo_real(COSTO_AHORRAR)) + " MONEDAS"
	get_node("InvestCost").text = "INVIERTE " + str(_costo_real(COSTO_INVERTIR)) + " MONEDAS"
	get_node("SpendCost").text = "UTILIZA " + str(_costo_real(COSTO_GASTAR)) + " MONEDAS"
	get_node("InvestToolsCost").text = "INVIERTE " + str(_costo_real(COSTO_INVERTIR)) + " MONEDAS"
	get_node("InvestSeedsCost").text = "INVIERTE " + str(_costo_real(COSTO_INVERTIR)) + " MONEDAS"
	get_node("SpendCandyCost").text = "UTILIZA " + str(_costo_real(COSTO_GASTAR)) + " MONEDAS"
	get_node("SpendGamesCost").text = "UTILIZA " + str(_costo_real(COSTO_GASTAR)) + " MONEDAS"


func _bloquear_botones() -> void:
	for nombre in ["SaveButton", "InvestButton", "SpendButton", "InvestToolsButton", "InvestSeedsButton", "SpendCandyButton", "SpendGamesButton"]:
		get_node(nombre).disabled = true


# ==========================================
# DESPLIEGUE DE SUB-OPCIONES (INVERTIR / GASTAR)
# ==========================================

func _on_invest_button_pressed() -> void:
	_desplegar_subopciones("invertir")


func _on_spend_button_pressed() -> void:
	_desplegar_subopciones("gastar")


func _desplegar_subopciones(categoria: String) -> void:
	get_node("SaveButton").disabled = true
	get_node("InvestButton").disabled = true
	get_node("SpendButton").disabled = true

	var fila_principal = ["SaveButton", "SaveCost", "SaveEffect", "InvestButton", "InvestCost", "InvestEffect", "SpendButton", "SpendCost", "SpendEffect"]

	var tw_salida = create_tween()
	tw_salida.set_parallel(true)
	for nombre in fila_principal:
		tw_salida.tween_property(get_node(nombre), "modulate:a", 0.0, 0.2)
	await tw_salida.finished

	for nombre in fila_principal:
		get_node(nombre).visible = false

	var condor = get_node("CondorDialog")

	if categoria == "invertir":
		get_node("QuestionLabel").text = "¿En qué quieres invertir tus " + str(_costo_real(COSTO_INVERTIR)) + " monedas?"
		condor.set_pose("explicando")
		condor.set_message("Las herramientas mejoran tu trabajo y las semillas hacen crecer tu próxima cosecha. ¡Tú decides!")
		_mostrar_subopciones(["InvestToolsButton", "InvestToolsCost", "InvestToolsEffect", "InvestSeedsButton", "InvestSeedsCost", "InvestSeedsEffect"])
	else:
		get_node("QuestionLabel").text = "¿Con qué te vas a dar un gusto con tus " + str(_costo_real(COSTO_GASTAR)) + " monedas?"
		condor.set_pose("preocupado")
		condor.set_message("Cuidado: darte un gusto sin pensar puede costarte puntos extra.")
		_mostrar_subopciones(["SpendCandyButton", "SpendCandyCost", "SpendCandyEffect", "SpendGamesButton", "SpendGamesCost", "SpendGamesEffect"])


func _mostrar_subopciones(nombres: Array) -> void:
	var botones = [nombres[0], nombres[3]]

	for nombre in nombres:
		var nodo = get_node(nombre)
		nodo.visible = true
		nodo.modulate.a = 0.0

	var retraso = 0.0
	for nombre_boton in botones:
		_animar_entrada_opcion(get_node(nombre_boton), retraso)
		retraso += 0.12

	for nombre in nombres:
		if not (nombre in botones):
			var nodo = get_node(nombre)
			var tw = create_tween()
			tw.tween_interval(0.2)
			tw.tween_property(nodo, "modulate:a", 1.0, 0.25)


func _animar_entrada_opcion(boton: Button, retraso: float) -> void:
	boton.pivot_offset = boton.size / 2.0
	boton.rotation = deg_to_rad(-10.0)
	boton.scale = Vector2(0.6, 0.6)
	boton.modulate.a = 0.0

	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(boton, "modulate:a", 1.0, 0.25).set_delay(retraso)
	tw.tween_property(boton, "rotation", 0.0, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(retraso)
	tw.tween_property(boton, "scale", Vector2(1.0, 1.0), 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(retraso)


# ==========================================
# ANIMACIÓN DE CONFIRMACIÓN Y MONEDAS
# ==========================================

func _animar_confirmacion(boton: Button) -> void:
	boton.pivot_offset = boton.size / 2.0
	var tw = create_tween()
	tw.tween_property(boton, "scale", Vector2(1.08, 1.08), 0.12).set_trans(Tween.TRANS_SINE)
	tw.tween_property(boton, "scale", Vector2(1.0, 1.0), 0.18).set_trans(Tween.TRANS_SINE)

	_crear_monedas(boton)

	await tw.finished
	await get_tree().create_timer(0.4).timeout


func _crear_monedas(boton_elegido: Button) -> void:
	var textura_moneda = load("res://assets/icons/coin.png")
	var top_icon = get_node("MoneyIcon")
	var origen_top = top_icon.global_position + top_icon.size / 2.0
	var destino_icono = boton_elegido.global_position + boton_elegido.size / 2.0

	# Monedas que suben y actualizan el saldo en la parte superior (HUD).
	for i in range(3):
		_lanzar_moneda(textura_moneda, destino_icono, origen_top, true)

	# Monedas que vuelan hacia el ícono de la decisión elegida.
	for i in range(4):
		_lanzar_moneda(textura_moneda, origen_top, destino_icono, false)


func _lanzar_moneda(textura: Texture2D, desde: Vector2, hacia: Vector2, es_hacia_arriba: bool) -> void:
	var moneda = TextureRect.new()
	moneda.texture = textura
	moneda.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	moneda.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	moneda.size = Vector2(22, 22)
	moneda.position = desde - moneda.size / 2.0 + Vector2(randf_range(-12, 12), randf_range(-8, 8))
	moneda.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(moneda)

	var destino = hacia - moneda.size / 2.0 + Vector2(randf_range(-20, 20), randf_range(-16, 16))

	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(moneda, "position", destino, 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(moneda, "rotation", randf_range(-1.6, 1.6), 0.55)
	tw.chain().tween_property(moneda, "modulate:a", 0.0, 0.15)
	if es_hacia_arriba:
		tw.tween_callback(_pulso_money_icon)
	tw.tween_callback(moneda.queue_free)


func _pulso_money_icon() -> void:
	var icono = get_node("MoneyIcon")
	icono.pivot_offset = icono.size / 2.0
	var tw = create_tween()
	tw.tween_property(icono, "scale", Vector2(1.35, 1.35), 0.12).set_trans(Tween.TRANS_SINE)
	tw.tween_property(icono, "scale", Vector2(1.0, 1.0), 0.18).set_trans(Tween.TRANS_SINE)


func _continuar() -> void:
	if GameState.ciclo_final_completado():
		await SceneTransition.change_scene("res://scenes/Results.tscn")
	else:
		await SceneTransition.change_scene("res://scenes/Farm.tscn")


# ==========================================
# PROCESAR UNA DECISIÓN (AHORRAR / INVERTIR / GASTAR)
# ==========================================

func _procesar_decision(categoria: String, objetivo: int, boton: Button) -> void:
	var cantidad = _costo_real(objetivo)
	if cantidad <= 0:
		print("No tienes monedas para esta decisión.")
		return

	GameState.monedas -= cantidad

	match categoria:
		"ahorrar":
			GameState.monedas_ahorradas += cantidad
			GameState.fondo_emergencia += cantidad
			GameState.salud_financiera += 5
			GameState.puntos_ahorro += 5

			if GameState.meta_alcanzada():
				GameState.otorgar_sello("Meta de ahorro alcanzada")

		"invertir":
			GameState.monedas_invertidas += cantidad
			GameState.productividad += 10
			GameState.proteccion_activa = true
			GameState.puntos_invertir += 10

		"gastar":
			GameState.monedas_gastadas += cantidad
			GameState.salud_financiera -= 5
			GameState.puntos_gastar -= 15

	print("Decisión: ", categoria, " | Monedas usadas: ", cantidad, " | Monedas restantes: ", GameState.monedas)

	_bloquear_botones()
	await _animar_confirmacion(boton)
	_continuar()


func _on_save_button_pressed() -> void:
	_procesar_decision("ahorrar", COSTO_AHORRAR, get_node("SaveButton"))


func _on_invest_tools_button_pressed() -> void:
	GameState.veces_herramientas += 1
	_procesar_decision("invertir", COSTO_INVERTIR, get_node("InvestToolsButton"))


func _on_invest_seeds_button_pressed() -> void:
	GameState.veces_semillas += 1
	_procesar_decision("invertir", COSTO_INVERTIR, get_node("InvestSeedsButton"))


func _on_spend_candy_button_pressed() -> void:
	GameState.veces_dulces += 1
	_procesar_decision("gastar", COSTO_GASTAR, get_node("SpendCandyButton"))


func _on_spend_games_button_pressed() -> void:
	GameState.veces_videojuegos += 1
	_procesar_decision("gastar", COSTO_GASTAR, get_node("SpendGamesButton"))
