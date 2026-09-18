extends Control


func _ready() -> void:
	actualizar_dinero()


func actualizar_dinero() -> void:
	var money_label = get_node("MoneyLabel")
	var goal_label = get_node("GoalLabel")

	money_label.text = "Tienes: " + str(GameState.monedas) + " monedas"
	goal_label.text = "Meta de ahorro: " + str(GameState.monedas_ahorradas) + " / " + str(GameState.meta_ahorro)


func _continuar() -> void:
	if GameState.ciclo_final_completado():
		get_tree().change_scene_to_file("res://scenes/Results.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/Farm.tscn")


func _on_save_button_pressed() -> void:
	var cantidad = 50

	if GameState.monedas < cantidad:
		print("No tienes suficientes monedas para ahorrar.")
		return

	GameState.monedas -= cantidad
	GameState.monedas_ahorradas += cantidad
	GameState.fondo_emergencia += cantidad

	GameState.salud_financiera += 5

	if GameState.meta_alcanzada():
		GameState.otorgar_sello("Meta de ahorro alcanzada")

	print("Has ahorrado: ", cantidad)
	print("Monedas restantes: ", GameState.monedas)
	print("Total ahorrado: ", GameState.monedas_ahorradas)

	_continuar()


func _on_invest_button_pressed() -> void:
	var cantidad = 100

	if GameState.monedas < cantidad:
		print("No tienes suficientes monedas para invertir.")
		return

	GameState.monedas -= cantidad
	GameState.monedas_invertidas += cantidad

	GameState.productividad += 10
	GameState.proteccion_activa = true

	print("Has invertido: ", cantidad)
	print("Monedas restantes: ", GameState.monedas)
	print("Productividad: ", GameState.productividad)

	_continuar()


func _on_spend_button_pressed() -> void:
	var cantidad = 50

	if GameState.monedas < cantidad:
		print("No tienes suficientes monedas para gastar.")
		return

	GameState.monedas -= cantidad
	GameState.monedas_gastadas += cantidad

	GameState.salud_financiera -= 5

	print("Has gastado: ", cantidad)
	print("Monedas restantes: ", GameState.monedas)
	print("Total gastado: ", GameState.monedas_gastadas)

	_continuar()
