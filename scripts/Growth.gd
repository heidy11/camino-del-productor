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
		crop_icon.texture = load("res://assets/icons/quinua.png")
	else:
		crop_label.text = "🌱 SIN CULTIVO"

	produccion_final = produccion_base
	growth_progress.value = 0
	crop_icon.pivot_offset = crop_icon.size / 2.0
	crop_icon.scale = Vector2(1, 1) if usa_etapas_papa else Vector2(0.3, 0.3)


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
		else:
			var factor = 0.3 + (progreso / 100.0) * 0.9
			crop_icon.scale = Vector2(factor, factor)

		if progreso >= 100:
			progreso = 100
			crecimiento_completo = true
			print("El cultivo está listo para cosechar")
			
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

	if evento == "Soleado":
		event_title.text = "☀️ DÍA SOLEADO"
		event_description.text = "El clima favorece el crecimiento de tu cultivo."
		produccion_final = produccion_base
		event_icon.texture = load("res://assets/icons/sun.png")
		background.texture = load("res://assets/backgrounds/EscenarioGrowthVarianteSoleada.png")

	elif evento == "Lluvia":
		event_title.text = "🌧️ LLUVIA"
		event_description.text = "La lluvia puede beneficiar tu cultivo, pero también puede generar riesgos."
		produccion_final = produccion_base
		event_icon.texture = load("res://assets/icons/rain.png")
		background.texture = load("res://assets/backgrounds/EscenarioGrowthVarianteLluvia.png")

	elif evento == "Helada":
		event_title.text = "❄️ HELADA"
		event_icon.texture = load("res://assets/icons/frost.png")
		background.texture = load("res://assets/backgrounds/EscenarioGrowthVarianteHelada.png")
		if GameState.proteccion_activa:
			event_description.text = "Gracias a tu inversión preventiva, el daño de la helada fue menor."
			produccion_final = produccion_base * 0.85
		else:
			event_description.text = "Una helada puede reducir tu producción si no estás preparado."
			produccion_final = produccion_base * 0.7

	GameState.proteccion_activa = false

	print("Evento climático: ", evento)
	get_node("EventPanel").visible = true
	event_button.visible = true
	print("Evento climático: ", evento)
	print("Producción final: ", produccion_final)


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

	get_tree().change_scene_to_file("res://scenes/Market.tscn")
	


func _on_option_a_button_pressed() -> void:

	if desafio_completado:
		return

	desafio_completado = true
	GameState.salud_financiera = max(0, GameState.salud_financiera - 5)

	print("Respuesta incorrecta")
	print("El dinero gastado ya no estará disponible para afrontar un imprevisto.")


func _on_option_b_button_pressed() -> void:
	if desafio_completado:
		return

	desafio_completado = true
	GameState.minidesafios_completados += 1
	GameState.otorgar_sello("Mini desafío financiero superado")

	print("¡Correcto!")
	print("Guardar una parte de tus monedas ayuda a prepararte para imprevistos.")

func _on_option_c_button_pressed() -> void:

	if desafio_completado:
		return

	desafio_completado = true
	GameState.salud_financiera = max(0, GameState.salud_financiera - 5)

	print("Respuesta incorrecta")
	print("Comprar algo innecesario reduce los recursos disponibles para el futuro.")


func _on_event_button_pressed() -> void:
	if not evento_generado:
		return

	get_node("EventPanel").visible = false
