extends Control


var progreso = 0.0
var tiempo_crecimiento = 10.0
var crecimiento_completo = false
var desafio_completado = false
var evento_generado = false
var evento = ""
var produccion_base = 100
var produccion_final = 100

func _ready() -> void:
	var crop_label = get_node("CropLabel")
	var growth_progress = get_node("GrowthProgress")

	if GameState.cultivo == "Papa":
		crop_label.text = "🥔 PAPA"
		tiempo_crecimiento = 10.0
	elif GameState.cultivo == "Quinua":
		crop_label.text = "🌾 QUINUA"
		tiempo_crecimiento = 6.0
	else:
		crop_label.text = "🌱 SIN CULTIVO"

	growth_progress.value = 0


func _process(delta: float) -> void:
	var growth_progress = get_node("GrowthProgress")

	if progreso < 100:
		progreso += (100.0 / tiempo_crecimiento) * delta
		growth_progress.value = progreso
	
		if progreso >= 100:
			progreso = 100
			crecimiento_completo = true
			print("El cultivo está listo para cosechar")
			
func generar_evento() -> void:
	var eventos = ["Soleado", "Lluvia", "Helada"]
	evento = eventos.pick_random()
	
	GameState.evento_actual = evento
	evento_generado = true
	
	var event_title = get_node("EventPanel/EventTitle")
	var event_description = get_node("EventPanel/EventDescription")
	var event_button = get_node("EventPanel/EventButton")
	
	if evento == "Soleado":
		event_title.text = "☀️ DÍA SOLEADO"
		event_description.text = "El clima favorece el crecimiento de tu cultivo."
		produccion_final = produccion_base
	
	elif evento == "Lluvia":
		event_title.text = "🌧️ LLUVIA"
		event_description.text = "La lluvia puede beneficiar tu cultivo, pero también puede generar riesgos."
		produccion_final = produccion_base
	
	elif evento == "Helada":
		event_title.text = "❄️ HELADA"
		event_description.text = "Una helada puede reducir tu producción si no estás preparado."
		produccion_final = produccion_base * 0.7
	
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
	desafio_completado = true

	print("Respuesta incorrecta")
	print("El dinero gastado ya no estará disponible para afrontar un imprevisto.")


func _on_option_b_button_pressed() -> void:
	desafio_completado = true
	GameState.minidesafios_completados += 1
	
	print("¡Correcto!")
	print("Guardar una parte de tus monedas ayuda a prepararte para imprevistos.")

func _on_option_c_button_pressed() -> void:
	desafio_completado = true

	print("Respuesta incorrecta")
	print("Comprar algo innecesario reduce los recursos disponibles para el futuro.")


func _on_event_button_pressed() -> void:
	GameState.produccion = produccion_final
	
	print("Evento gestionado: ", GameState.evento_actual)
	print("Producción obtenida: ", GameState.produccion)
