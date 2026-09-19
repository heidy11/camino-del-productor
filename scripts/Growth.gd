extends Control


var progreso = 0.0
var tiempo_crecimiento = 10.0
var crecimiento_completo = false
var desafio_completado = false
var evento_generado = false
var evento = ""
var produccion_base = 100
var produccion_final = 100

var usa_etapas_papa = false
var papa_stage_textures = []
var papa_stage_index = -1

var usa_quinua = false
var quinua_brote_textura: Texture2D = null
var quinua_madura_textura: Texture2D = null
var quinua_madura_mostrada = false
var brillo_cosecha_mostrado = false

func _ready() -> void:
	var crop_label = get_node("CropLabel")
	var growth_progress = get_node("GrowthProgress")
	var crop_icon = get_node("CropIcon")

	if GameState.cultivo == "Papa":
		crop_label.text = "🥔 PAPA"
		tiempo_crecimiento = 10.0
		produccion_base = 100
		usa_etapas_papa = true
		papa_stage_textures = [
			load("res://assets/crops/papa/PapaSemilla.png"),
			load("res://assets/crops/papa/PapaBrote.png"),
			load("res://assets/crops/papa/PapaCreciendo.png"),
			load("res://assets/crops/papa/PapaMadura.png"),
		]
		papa_stage_index = 0
		crop_icon.texture = papa_stage_textures[0]
	elif GameState.cultivo == "Quinua":
		crop_label.text = "🌾 QUINUA"
		tiempo_crecimiento = 6.0
		produccion_base = 70
		usa_quinua = true
		quinua_brote_textura = load("res://assets/crops/quinua/QuinuaBrote.png")
		quinua_madura_textura = load("res://assets/crops/quinua/QuinuaMadura.png")
		crop_icon.texture = quinua_brote_textura
	else:
		crop_label.text = "🌱 SIN CULTIVO"

	produccion_final = produccion_base
	growth_progress.value = 0
	crop_icon.pivot_offset = crop_icon.size / 2.0
	crop_icon.scale = Vector2(1, 1) if usa_etapas_papa else Vector2(0.35, 0.35)

	var condor = get_node("CondorDialog")
	condor.set_pose("explicando")
	condor.set_message("Si ahorras hoy, mañana podrás invertir en tu producción.")
	condor.animate_in()


func _process(delta: float) -> void:
	var growth_progress = get_node("GrowthProgress")
	var crop_icon = get_node("CropIcon")

	if progreso < 100:
		progreso += (100.0 / tiempo_crecimiento) * delta
		growth_progress.value = progreso

		if usa_etapas_papa:
			var stage = clamp(int(progreso / 25.0), 0, 3)
			if stage != papa_stage_index:
				papa_stage_index = stage
				crop_icon.texture = papa_stage_textures[stage]
		elif usa_quinua:
			var factor = 0.35 + (progreso / 100.0) * 0.85
			crop_icon.scale = Vector2(factor, factor)
		else:
			var factor = 0.3 + (progreso / 100.0) * 0.9
			crop_icon.scale = Vector2(factor, factor)

		if progreso >= 100:
			progreso = 100
			crecimiento_completo = true
			if usa_quinua and not quinua_madura_mostrada:
				quinua_madura_mostrada = true
				crop_icon.texture = quinua_madura_textura
				crop_icon.scale = Vector2(1.0, 1.0)
			_brillo_cosecha_lista(crop_icon)
			print("El cultivo está listo para cosechar")


func _brillo_cosecha_lista(crop_icon: TextureRect) -> void:
	if brillo_cosecha_mostrado:
		return
	brillo_cosecha_mostrado = true

	crop_icon.pivot_offset = crop_icon.size / 2.0
	var escala_original = crop_icon.scale

	var tw = create_tween()
	tw.tween_property(crop_icon, "modulate", Color(1.5, 1.5, 1.1, 1.0), 0.18).set_trans(Tween.TRANS_SINE)
	tw.tween_property(crop_icon, "modulate", Color(1, 1, 1, 1), 0.28).set_trans(Tween.TRANS_SINE)

	var tw_scale = create_tween()
	tw_scale.tween_property(crop_icon, "scale", escala_original * 1.15, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw_scale.tween_property(crop_icon, "scale", escala_original, 0.22).set_trans(Tween.TRANS_SINE)
			
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

	if evento == "Soleado":
		event_title.text = "☀️ DÍA SOLEADO"
		event_description.text = "El clima favorece el crecimiento de tu cultivo."
		produccion_final = produccion_base
		event_icon.texture = load("res://assets/icons/sun.png")
		background.texture = load("res://assets/backgrounds/EscenarioGrowthVarianteSoleada.png")
		condor.set_pose("neutral")
		condor.set_message(event_description.text)
		weather.set_weather("soleado")

	elif evento == "Lluvia":
		event_title.text = "🌧️ LLUVIA"
		event_description.text = "La lluvia puede beneficiar tu cultivo, pero también puede generar riesgos."
		produccion_final = produccion_base
		event_icon.texture = load("res://assets/icons/rain.png")
		background.texture = load("res://assets/backgrounds/EscenarioGrowthVarianteLluvia.png")
		condor.set_pose("senalando")
		condor.set_message(event_description.text)
		weather.set_weather("lluvia")

	elif evento == "Helada":
		event_title.text = "❄️ HELADA"
		event_icon.texture = load("res://assets/icons/frost.png")
		background.texture = load("res://assets/backgrounds/EscenarioGrowthVarianteHelada.png")
		risk_badge.visible = true
		if GameState.proteccion_activa:
			event_description.text = "Gracias a tu inversión preventiva, el daño de la helada fue menor."
			produccion_final = produccion_base * 0.85
		else:
			event_description.text = "Una helada puede reducir tu producción si no estás preparado."
			produccion_final = produccion_base * 0.7
		condor.set_pose("preocupado")
		condor.set_message(event_description.text)
		weather.set_weather("helada")
		_sacudir_pantalla()

	GameState.proteccion_activa = false

	print("Evento climático: ", evento)
	get_node("EventPanel").visible = true
	event_button.visible = true
	print("Evento climático: ", evento)
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

	print("Cosechando producción: ", GameState.produccion)

	await SceneTransition.change_scene("res://scenes/Market.tscn")
	


func _on_option_a_button_pressed() -> void:

	if desafio_completado:
		return

	desafio_completado = true
	GameState.salud_financiera = max(0, GameState.salud_financiera - 5)

	var mensaje = "El dinero gastado ya no estará disponible para afrontar un imprevisto."
	get_node("CondorDialog").set_pose("preocupado")
	get_node("CondorDialog").set_message(mensaje)
	_mostrar_resultado_desafio(false, "Incorrecto")

	print("Respuesta incorrecta")
	print(mensaje)


func _on_option_b_button_pressed() -> void:
	if desafio_completado:
		return

	desafio_completado = true
	GameState.minidesafios_completados += 1
	GameState.otorgar_sello("Mini desafío financiero superado")

	var mensaje = "¡Correcto! Guardar una parte de tus monedas ayuda a prepararte para imprevistos."
	get_node("CondorDialog").set_pose("celebrando")
	get_node("CondorDialog").set_message(mensaje)
	_mostrar_resultado_desafio(true, "¡Correcto!")

	print("¡Correcto!")
	print(mensaje)

func _on_option_c_button_pressed() -> void:

	if desafio_completado:
		return

	desafio_completado = true
	GameState.salud_financiera = max(0, GameState.salud_financiera - 5)

	var mensaje = "Comprar algo innecesario reduce los recursos disponibles para el futuro."
	get_node("CondorDialog").set_pose("preocupado")
	get_node("CondorDialog").set_message(mensaje)
	_mostrar_resultado_desafio(false, "Incorrecto")

	print("Respuesta incorrecta")
	print(mensaje)


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


func _on_event_button_pressed() -> void:
	if not evento_generado:
		return

	get_node("EventPanel").visible = false
