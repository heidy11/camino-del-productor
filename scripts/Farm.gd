extends Node2D


var terreno_preparado = false
var cultivo_seleccionado = false
var sembrado = false


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

	print("Entraste a la Finca de las Alturas")
	print("Ciclo actual: ", GameState.ciclo_actual)


func _on_prepare_button_pressed() -> void:
	if terreno_preparado:
		print("El terreno ya está preparado")
		return

	terreno_preparado = true

	print("Terreno preparado")


func _on_papa_button_pressed() -> void:
	if terreno_preparado == false:
		print("Primero debes preparar el terreno")
		return

	if cultivo_seleccionado:
		print("Ya elegiste un cultivo")
		return

	GameState.cultivo = "Papa"
	cultivo_seleccionado = true

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

	print("Cultivo seleccionado: Quinua")


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

	print("Has sembrado: ", GameState.cultivo)

	get_tree().change_scene_to_file("res://scenes/Growth.tscn")
