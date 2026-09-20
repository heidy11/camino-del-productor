extends Control


const ESCALA_MIN := 0.55
const ESCALA_MAX := 1.15
const COSTO_CARPA := 30
const COLOR_RESULTADO_CORRECTO := Color(0.157, 0.678, 0.376, 0.96)
const COLOR_RESULTADO_INCORRECTO := Color(0.792, 0.204, 0.180, 0.96)

const TRIVIA_PREGUNTAS := [
	{
		"principal": {
			"pregunta": "Quieres comprar una pelota nueva en un mes. ¿Cuál es la mejor forma de lograrlo?",
			"opciones": [
				"Gastar todo tu dinero apenas lo recibes.",
				"Guardar un poco de dinero cada semana hasta juntar lo suficiente.",
			],
			"correcta": 1,
			"explicacion": "Guardar un poco cada semana te ayuda a alcanzar tu meta sin gastar todo de una vez.",
		},
		"secundaria": {
			"pregunta": "Ana recibe 10 bolivianos de propina cada semana y guarda 2 en su alcancía. ¿Qué está haciendo bien?",
			"opciones": [
				"Está ahorrando una parte de su dinero para el futuro.",
				"Está gastando todo su dinero en dulces.",
			],
			"correcta": 0,
			"explicacion": "Guardar una parte de lo que recibes, aunque sea poco, es un buen hábito de ahorro.",
		},
	},
	{
		"principal": {
			"pregunta": "Tienes dinero ahorrado. ¿Cuál de estas opciones es una necesidad y no solo un gusto?",
			"opciones": [
				"Comprar útiles escolares para estudiar.",
				"Comprar un juguete nuevo aunque ya tienes varios.",
			],
			"correcta": 0,
			"explicacion": "Las necesidades son cosas que de verdad necesitamos, como los útiles escolares. Los gustos, como un juguete extra, pueden esperar.",
		},
		"secundaria": {
			"pregunta": "Pedro tiene 20 bolivianos. Necesita cuadernos para el colegio, pero también quiere un videojuego nuevo. ¿Qué debería comprar primero?",
			"opciones": [
				"Los cuadernos, porque los necesita para estudiar.",
				"El videojuego, porque le gusta más.",
			],
			"correcta": 0,
			"explicacion": "Cuando el dinero es limitado, primero se cubren las necesidades y después los gustos.",
		},
	},
	{
		"principal": {
			"pregunta": "Quieres juntar dinero para comprar una bicicleta. ¿Qué te ayuda más a lograrlo?",
			"opciones": [
				"Ponerte una meta y anotar cuánto ahorras cada semana.",
				"Esperar a ver si algún día te alcanza el dinero, sin ningún plan.",
			],
			"correcta": 0,
			"explicacion": "Tener una meta clara y anotar tu ahorro te ayuda a saber cuánto te falta y a no rendirte.",
		},
		"secundaria": {
			"pregunta": "Sofía quiere comprar un libro que cuesta 30 bolivianos. Decide ahorrar 5 bolivianos cada semana. ¿Cuántas semanas necesitará ahorrar?",
			"opciones": [
				"6 semanas.",
				"3 semanas.",
			],
			"correcta": 0,
			"explicacion": "30 dividido entre 5 es 6, así que Sofía necesita ahorrar durante 6 semanas para lograr su meta.",
		},
	},
]

var progreso = 0.0
var tiempo_crecimiento = 10.0
var crecimiento_completo = false
var desafio_completado = false
var evento_generado = false
var evento = ""
var produccion_base = 100
var produccion_final = 100
var nombre_cultivo_actual = ""

var stage_textures: Array = []
var stage_index := -1
var brillo_cosecha_mostrado = false
var crop_icons: Array = []

var opcion_buttons: Array = []
var pregunta_actual: Dictionary = {}
var pregunta_respondida := false

func _obtener_crop_icons() -> Array:
	# Recoge el CropIcon original y cualquier duplicado (CropIcon2, CropIcon3, ...)
	# que se haya creado en el editor para formar el montículo del cultivo,
	# de modo que todos crezcan y cambien de etapa juntos.
	var nodos: Array = []
	for hijo in get_children():
		if hijo is TextureRect and String(hijo.name).begins_with("CropIcon"):
			nodos.append(hijo)
	return nodos


func _ready() -> void:
	var crop_label = get_node("CropLabel")
	var growth_progress = get_node("GrowthProgress")
	crop_icons = _obtener_crop_icons()

	if GameState.cultivo == "Papa":
		nombre_cultivo_actual = "Papa"
		crop_label.text = "La Papa está creciendo"
		tiempo_crecimiento = 10.0
		produccion_base = int(round(100.0 * GameState.productividad / 100.0))
		stage_textures = [
			load("res://assets/crops/papa/PapaSemilla.png"),
			load("res://assets/crops/papa/PapaBrote.png"),
			load("res://assets/crops/papa/PapaCreciendo.png"),
			load("res://assets/crops/papa/PapaMadura.png"),
		]
	elif GameState.cultivo == "Quinua":
		nombre_cultivo_actual = "Quinua"
		crop_label.text = "La Quinua está creciendo"
		tiempo_crecimiento = 6.0
		produccion_base = int(round(70.0 * GameState.productividad / 100.0))
		stage_textures = [
			load("res://assets/crops/quinua/QuinuaSemilla.png"),
			load("res://assets/crops/quinua/QuinuaBrote.png"),
			load("res://assets/crops/quinua/QuinuaCreciendo.png"),
			load("res://assets/crops/quinua/QuinuaMadura.png"),
		]
	else:
		crop_label.text = "Tu cultivo está creciendo"
		stage_textures = []

	stage_index = 0
	produccion_final = produccion_base
	growth_progress.value = 0

	for icon in crop_icons:
		if stage_textures.size() > 0:
			icon.texture = stage_textures[0]
		icon.pivot_offset = icon.size / 2.0
		icon.scale = Vector2(ESCALA_MIN, ESCALA_MIN)

	var condor = get_node("CondorDialog")
	condor.set_pose("explicando")
	condor.set_message("Si ahorras hoy, mañana podrás invertir en tu producción.")
	condor.animate_in()

	opcion_buttons = [
		get_node("ChallengePanel/OptionAButton"),
		get_node("ChallengePanel/OptionBButton"),
		get_node("ChallengePanel/OptionCButton"),
	]
	_iniciar_desafio()

	_animar_entrada_escenario()
	_iniciar_balanceo_regadera()
	_conectar_hover_continuar()


# Pequeña entrada escalonada para que la pantalla no aparezca de golpe:
# título, etiqueta del cultivo, barra de progreso y el panel del desafío.
func _animar_entrada_escenario() -> void:
	var titulo = get_node("TitleBanner")
	titulo.modulate.a = 0.0
	titulo.pivot_offset = titulo.size / 2.0
	titulo.scale = Vector2(0.85, 0.85)
	var tw_titulo = create_tween()
	tw_titulo.set_parallel(true)
	tw_titulo.tween_property(titulo, "modulate:a", 1.0, 0.3)
	tw_titulo.tween_property(titulo, "scale", Vector2(1.0, 1.0), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	var title_label = get_node("Title")
	title_label.modulate.a = 0.0
	var tw_title_label = create_tween()
	tw_title_label.tween_property(title_label, "modulate:a", 1.0, 0.3)

	var etiqueta = get_node("CropLabel")
	var pos_original = etiqueta.position.y
	etiqueta.modulate.a = 0.0
	etiqueta.position.y = pos_original - 10.0
	var tw_etiqueta = create_tween()
	tw_etiqueta.set_parallel(true)
	tw_etiqueta.tween_property(etiqueta, "modulate:a", 1.0, 0.35).set_delay(0.15)
	tw_etiqueta.tween_property(etiqueta, "position:y", pos_original, 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_delay(0.15)

	var barra = get_node("GrowthProgress")
	barra.modulate.a = 0.0
	var tw_barra = create_tween()
	tw_barra.tween_property(barra, "modulate:a", 1.0, 0.35).set_delay(0.25)

	var regadera = get_node("RegaderaProp")
	regadera.modulate.a = 0.0
	regadera.pivot_offset = Vector2(regadera.size.x / 2.0, regadera.size.y)
	regadera.scale = Vector2(0.8, 0.8)
	var tw_regadera = create_tween()
	tw_regadera.set_parallel(true)
	tw_regadera.tween_property(regadera, "modulate:a", 1.0, 0.35).set_delay(0.3)
	tw_regadera.tween_property(regadera, "scale", Vector2(1.0, 1.0), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.3)

	var panel = get_node("ChallengePanel")
	panel.modulate.a = 0.0
	panel.pivot_offset = panel.size / 2.0
	panel.scale = Vector2(0.9, 0.9)
	var tw_panel = create_tween()
	tw_panel.set_parallel(true)
	tw_panel.tween_property(panel, "modulate:a", 1.0, 0.35).set_delay(0.35)
	tw_panel.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.35)


# Balanceo suave y continuo de la regadera para que la escena se sienta viva.
func _iniciar_balanceo_regadera() -> void:
	var regadera = get_node("RegaderaProp")
	regadera.pivot_offset = Vector2(regadera.size.x / 2.0, regadera.size.y)
	var tw = create_tween()
	tw.set_loops()
	tw.tween_property(regadera, "rotation_degrees", 3.0, 1.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(regadera, "rotation_degrees", -3.0, 1.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _conectar_hover_continuar() -> void:
	var boton = get_node("ContinueButton")
	boton.mouse_entered.connect(_on_continue_hover)
	boton.mouse_exited.connect(_on_continue_unhover)


func _on_continue_hover() -> void:
	var boton = get_node("ContinueButton")
	boton.pivot_offset = boton.size / 2.0
	var tw = create_tween()
	tw.tween_property(boton, "scale", Vector2(1.06, 1.06), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_continue_unhover() -> void:
	var boton = get_node("ContinueButton")
	var tw = create_tween()
	tw.tween_property(boton, "scale", Vector2(1.0, 1.0), 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _process(delta: float) -> void:
	var growth_progress = get_node("GrowthProgress")

	if progreso < 100:
		progreso += (100.0 / tiempo_crecimiento) * delta
		growth_progress.value = progreso

		if stage_textures.size() > 0:
			var stage = clamp(int(progreso / 25.0), 0, stage_textures.size() - 1)
			if stage != stage_index:
				stage_index = stage
				for icon in crop_icons:
					icon.texture = stage_textures[stage]
				_pulso_cambio_etapa()

		var factor = lerp(ESCALA_MIN, ESCALA_MAX, progreso / 100.0)
		for icon in crop_icons:
			icon.pivot_offset = icon.size / 2.0
			icon.scale = Vector2(factor, factor)

		if progreso >= 100:
			progreso = 100
			crecimiento_completo = true
			if nombre_cultivo_actual != "":
				get_node("CropLabel").text = "¡La " + nombre_cultivo_actual + " está lista para cosechar!"
			_brillo_cosecha_lista()
			print("El cultivo está listo para cosechar")


func _pulso_cambio_etapa() -> void:
	for icon in crop_icons:
		var tw = create_tween()
		tw.tween_property(icon, "modulate", Color(1.3, 1.3, 1.05, 1.0), 0.12).set_trans(Tween.TRANS_SINE)
		tw.tween_property(icon, "modulate", Color(1, 1, 1, 1), 0.22).set_trans(Tween.TRANS_SINE)


func _brillo_cosecha_lista() -> void:
	if brillo_cosecha_mostrado:
		return
	brillo_cosecha_mostrado = true

	for icon in crop_icons:
		icon.pivot_offset = icon.size / 2.0
		var escala_original = icon.scale

		var tw = create_tween()
		tw.tween_property(icon, "modulate", Color(1.5, 1.5, 1.1, 1.0), 0.18).set_trans(Tween.TRANS_SINE)
		tw.tween_property(icon, "modulate", Color(1, 1, 1, 1), 0.28).set_trans(Tween.TRANS_SINE)

		var tw_scale = create_tween()
		tw_scale.tween_property(icon, "scale", escala_original * 1.15, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw_scale.tween_property(icon, "scale", escala_original, 0.22).set_trans(Tween.TRANS_SINE)


func _mostrar_panel_evento() -> void:
	var dim = get_node("EventDim")
	dim.visible = true
	dim.modulate.a = 0.0
	var tw_dim = create_tween()
	tw_dim.tween_property(dim, "modulate:a", 1.0, 0.25)

	var panel = get_node("EventPanel")
	panel.visible = true
	panel.modulate.a = 0.0
	panel.pivot_offset = panel.size / 2.0
	panel.scale = Vector2(0.85, 0.85)

	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(panel, "modulate:a", 1.0, 0.25)
	tw.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func generar_evento() -> void:
	if evento_generado:
		return

	var eventos = ["Soleado", "Lluvia", "Helada"]
	evento = eventos.pick_random()

	GameState.evento_actual = evento
	evento_generado = true

	var event_title = get_node("EventPanel/EventTitle")
	var event_description = get_node("EventPanel/EventDescription")
	var event_button = get_node("EventPanel/EventButton")
	var event_icon = get_node("EventPanel/EventIcon")
	var background = get_node("Background")
	var condor = get_node("CondorDialog")
	var weather = get_node("WeatherEffects")
	var risk_badge = get_node("EventPanel/RiskBadge")

	risk_badge.visible = false
	event_button.visible = false
	_mostrar_panel_evento()

	if evento == "Soleado":
		event_title.text = "☀️ DÍA SOLEADO"
		event_icon.texture = load("res://assets/icons/sun.png")
		background.texture = load("res://assets/backgrounds/EscenarioGrowthVarianteSoleada.png")
		condor.set_pose("neutral")
		weather.set_weather("soleado")

		var factor = randf_range(1.00, 1.15)
		produccion_final = int(round(produccion_base * factor))
		if factor >= 1.08:
			event_description.text = "¡El clima favoreció mucho tu cultivo! Produjiste más de lo esperado."
		else:
			event_description.text = "El clima favorece el crecimiento de tu cultivo."
		condor.set_message(event_description.text)

		GameState.historial_clima.append(evento)
		GameState.proteccion_activa = false
		event_button.visible = true
		print("Evento climático: ", evento)
		print("Producción final: ", produccion_final)

	elif evento == "Lluvia":
		event_title.text = "🌧️ LLUVIA"
		event_icon.texture = load("res://assets/icons/rain.png")
		background.texture = load("res://assets/backgrounds/EscenarioGrowthVarianteLluvia.png")
		condor.set_pose("senalando")
		weather.set_weather("lluvia")

		var factor = randf_range(0.85, 1.10)
		produccion_final = int(round(produccion_base * factor))
		if factor < 1.0:
			event_description.text = "La lluvia fue intensa y afectó un poco tu producción."
		else:
			event_description.text = "La lluvia benefició tu cultivo este ciclo."
		condor.set_message(event_description.text)

		GameState.historial_clima.append(evento)
		GameState.proteccion_activa = false
		event_button.visible = true
		print("Evento climático: ", evento)
		print("Producción final: ", produccion_final)

	elif evento == "Helada":
		event_title.text = "❄️ HELADA"
		event_icon.texture = load("res://assets/icons/frost.png")
		background.texture = load("res://assets/backgrounds/EscenarioGrowthVarianteHelada.png")
		risk_badge.visible = true
		weather.set_weather("helada")
		_sacudir_pantalla()
		_resolver_helada()


func _es_segunda_helada_seguida() -> bool:
	return GameState.historial_clima.size() > 0 and GameState.historial_clima[-1] == "Helada"


func _resolver_helada() -> void:
	var condor = get_node("CondorDialog")
	var event_description = get_node("EventPanel/EventDescription")
	var event_button = get_node("EventPanel/EventButton")

	if GameState.proteccion_activa:
		condor.set_pose("preocupado")
		event_description.text = "Gracias a tu inversión anterior, podrás afrontar mejor esta helada."
		condor.set_message(event_description.text)
		_finalizar_helada("inversion")
	elif GameState.monedas >= COSTO_CARPA:
		condor.set_pose("pensativo")
		var msg = "¡Se acerca una helada! Tienes " + str(GameState.monedas) + " monedas. ¿Compras una carpa antiheladas por " + str(COSTO_CARPA) + " monedas para proteger tu cultivo?"
		event_description.text = msg
		condor.set_message(msg)
		event_button.visible = false
		get_node("EventPanel/CarpaButton").visible = true
		get_node("EventPanel/ArriesgarseButton").visible = true
	else:
		condor.set_pose("preocupado")
		event_description.text = "No te alcanza para una carpa antiheladas, pero puedes proteger parte de tu cultivo con lo que tienes a mano."
		condor.set_message(event_description.text)
		_finalizar_helada("parcial_gratis")


func _on_carpa_button_pressed() -> void:
	GameState.monedas -= COSTO_CARPA
	GameState.veces_carpa_comprada += 1
	get_node("EventPanel/CarpaButton").visible = false
	get_node("EventPanel/ArriesgarseButton").visible = false
	_finalizar_helada("carpa")


func _on_arriesgarse_button_pressed() -> void:
	get_node("EventPanel/CarpaButton").visible = false
	get_node("EventPanel/ArriesgarseButton").visible = false
	_finalizar_helada("arriesgo")


func _finalizar_helada(tipo_proteccion: String) -> void:
	var segunda_seguida = _es_segunda_helada_seguida()
	var factor: float
	var mensaje: String

	match tipo_proteccion:
		"inversion":
			factor = randf_range(0.65, 0.85)
			mensaje = "Gracias a tu inversión anterior, el daño de la helada fue menor."
		"carpa":
			factor = randf_range(0.70, 0.90)
			mensaje = "La carpa antiheladas protegió gran parte de tu cultivo."
		"arriesgo":
			factor = randf_range(0.15, 0.35)
			mensaje = "Decidiste arriesgarte sin protección y la helada golpeó fuerte tu cultivo."
		"parcial_gratis":
			factor = 0.50
			mensaje = "No te alcanzaba para la carpa, pero lograste proteger la mitad de tu cultivo con lo que tenías a mano."
		_:
			factor = 0.5
			mensaje = "La helada afectó tu cultivo."

	if segunda_seguida:
		if tipo_proteccion == "inversion" or tipo_proteccion == "carpa":
			factor *= randf_range(0.55, 0.8)
			mensaje += " Es la segunda helada seguida, así que el golpe fue aún más duro de lo normal."
		else:
			factor = 0.0
			mensaje = "Dos heladas seguidas sin protección acabaron con toda tu cosecha de este ciclo."

	produccion_final = int(round(produccion_base * factor))
	GameState.historial_clima.append("Helada")
	GameState.proteccion_activa = false

	var condor = get_node("CondorDialog")
	condor.set_pose("preocupado" if factor < 0.5 else "pensativo")
	get_node("EventPanel/EventDescription").text = mensaje
	condor.set_message(mensaje)
	get_node("EventPanel").visible = true
	get_node("EventPanel/EventButton").visible = true

	print("Evento climático: Helada (", tipo_proteccion, ")")
	print("Producción final: ", produccion_final)


func _sacudir_pantalla() -> void:
	var pos_original = position
	var tw = create_tween()
	tw.tween_property(self, "position", pos_original + Vector2(-6, 0), 0.045)
	tw.tween_property(self, "position", pos_original + Vector2(6, 0), 0.045)
	tw.tween_property(self, "position", pos_original + Vector2(-4, 0), 0.045)
	tw.tween_property(self, "position", pos_original, 0.045)


func _on_continue_button_pressed() -> void:
	if not crecimiento_completo:
		print("El cultivo todavía está creciendo")
		return

	if not evento_generado:
		generar_evento()
		return

	if not desafio_completado:
		print("Debes completar el mini desafío")
		return

	GameState.produccion = produccion_final
	GameState.produccion_base = produccion_base

	print("Cosechando producción: ", GameState.produccion)

	await SceneTransition.change_scene("res://scenes/Market.tscn")
	


func _on_option_a_button_pressed() -> void:
	_on_opcion_pressed(0)


func _on_option_b_button_pressed() -> void:
	_on_opcion_pressed(1)


func _on_option_c_button_pressed() -> void:
	_on_opcion_pressed(2)


func _iniciar_desafio() -> void:
	if GameState.ciclo_actual <= 1:
		# Primer ciclo (primera cosecha): se elige una pregunta al azar
		# y se recuerda cuál fue, para usar su pregunta relacionada en el siguiente ciclo.
		var idx = randi() % TRIVIA_PREGUNTAS.size()
		GameState.trivia_indice_elegido = idx
		_mostrar_pregunta(TRIVIA_PREGUNTAS[idx]["principal"])
	else:
		# Segundo ciclo (segunda cosecha): pregunta secundaria relacionada
		# con la que se respondió en el ciclo anterior.
		var idx = GameState.trivia_indice_elegido
		if idx < 0 or idx >= TRIVIA_PREGUNTAS.size():
			idx = randi() % TRIVIA_PREGUNTAS.size()
		_mostrar_pregunta(TRIVIA_PREGUNTAS[idx]["secundaria"])


func _mostrar_pregunta(datos: Dictionary) -> void:
	pregunta_actual = datos
	pregunta_respondida = false

	get_node("ChallengePanel/QuestionLabel").text = datos["pregunta"]

	var status = get_node("ChallengePanel/ResultStatus")
	status.visible = false

	var letras = ["A", "B", "C"]
	var opciones: Array = datos["opciones"]
	var y = 86.0
	var alto_fila = 74.0

	for i in range(opcion_buttons.size()):
		var boton: Button = opcion_buttons[i]
		if i < opciones.size():
			boton.visible = true
			boton.text = letras[i] + ") " + opciones[i]
			boton.offset_top = y
			boton.offset_bottom = y + alto_fila - 8.0
			y += alto_fila
		else:
			boton.visible = false

	status.offset_top = y + 6.0
	status.offset_bottom = y + 32.0


func _on_opcion_pressed(indice: int) -> void:
	if pregunta_respondida or pregunta_actual.is_empty():
		return
	if indice >= pregunta_actual["opciones"].size():
		return

	pregunta_respondida = true

	var acierto: bool = indice == pregunta_actual["correcta"]
	var mensaje: String = pregunta_actual["explicacion"]
	var condor = get_node("CondorDialog")

	if acierto:
		condor.set_pose("celebrando")
	else:
		GameState.salud_financiera = max(0, GameState.salud_financiera - 5)
		condor.set_pose("preocupado")

	condor.set_message(mensaje)
	_mostrar_resultado_desafio(acierto, "¡Correcto!" if acierto else "Incorrecto")
	_mostrar_animacion_resultado(acierto)

	print("Respuesta ", "correcta" if acierto else "incorrecta")
	print(mensaje)

	desafio_completado = true
	GameState.minidesafios_completados += 1
	GameState.otorgar_sello("Mini desafío financiero superado")


func _mostrar_resultado_desafio(acierto: bool, mensaje: String) -> void:
	var status = get_node("ChallengePanel/ResultStatus")
	status.set_status(acierto, mensaje)
	status.visible = true
	status.modulate.a = 0.0
	status.scale = Vector2(0.7, 0.7)
	status.pivot_offset = Vector2(60, 13)

	var tw = create_tween()
	tw.tween_property(status, "modulate:a", 1.0, 0.15)
	tw.parallel().tween_property(status, "scale", Vector2(1.0, 1.0), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _mostrar_animacion_resultado(acierto: bool) -> void:
	var banner: Panel = get_node("ResultBanner")
	var label: Label = get_node("ResultBanner/ResultLabel")

	var estilo := StyleBoxFlat.new()
	estilo.bg_color = COLOR_RESULTADO_CORRECTO if acierto else COLOR_RESULTADO_INCORRECTO
	estilo.corner_radius_top_left = 36
	estilo.corner_radius_top_right = 36
	estilo.corner_radius_bottom_right = 36
	estilo.corner_radius_bottom_left = 36
	banner.add_theme_stylebox_override("panel", estilo)

	label.text = "¡CORRECTO!" if acierto else "INCORRECTO"

	banner.visible = true
	banner.modulate.a = 0.0
	banner.scale = Vector2(0.82, 0.82)
	banner.pivot_offset = banner.size / 2.0

	var tw = create_tween()
	tw.tween_property(banner, "modulate:a", 1.0, 0.12)
	tw.parallel().tween_property(banner, "scale", Vector2(1.0, 1.0), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_interval(0.65)
	tw.tween_property(banner, "modulate:a", 0.0, 0.25)
	tw.tween_callback(func(): banner.visible = false)


func _on_event_button_pressed() -> void:
	if not evento_generado:
		return

	var dim = get_node("EventDim")
	var tw_dim = create_tween()
	tw_dim.tween_property(dim, "modulate:a", 0.0, 0.2)
	tw_dim.tween_callback(func(): dim.visible = false)

	var panel = get_node("EventPanel")
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(panel, "modulate:a", 0.0, 0.2)
	tw.tween_property(panel, "scale", Vector2(0.9, 0.9), 0.2)
	tw.chain().tween_callback(_on_panel_evento_oculto.bind(panel))


func _on_panel_evento_oculto(panel: Panel) -> void:
	panel.visible = false
	panel.modulate.a = 1.0
	panel.scale = Vector2(1.0, 1.0)
