extends Control


func _ready() -> void:
	var perfil = GameState.calcular_perfil_financiero()

	get_node("SummaryContainer/ProfileLabel").text = "Perfil financiero: " + perfil
	get_node("SummaryContainer/ObtainedLabel").text = "Monedas obtenidas: " + str(GameState.monedas_obtenidas)
	get_node("SummaryContainer/SavedLabel").text = "Monedas ahorradas: " + str(GameState.monedas_ahorradas)
	get_node("SummaryContainer/InvestedLabel").text = "Monedas invertidas: " + str(GameState.monedas_invertidas)
	get_node("SummaryContainer/SpentLabel").text = "Monedas gastadas: " + str(GameState.monedas_gastadas)
	get_node("SummaryContainer/EmergencyLabel").text = "Fondo de emergencia: " + str(GameState.fondo_emergencia)
	get_node("SummaryContainer/HealthLabel").text = "Salud financiera: " + str(GameState.salud_financiera)
	get_node("SummaryContainer/ProductivityLabel").text = "Productividad: " + str(GameState.productividad)
	get_node("SummaryContainer/ChallengesLabel").text = "Mini desafíos superados: " + str(GameState.minidesafios_completados)
	get_node("SummaryContainer/SealsLabel").text = "Sellos del Guardián: " + str(GameState.sellos)
	get_node("SummaryContainer/GoalLabel").text = "Meta de ahorro alcanzada: " + ("Sí" if GameState.meta_alcanzada() else "No")


func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
