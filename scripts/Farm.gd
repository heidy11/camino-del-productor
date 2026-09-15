extends Node2D


var terreno_preparado = false
var cultivo_seleccionado = false
var sembrado = false


func _ready() -> void:
	print("Entraste a la Finca de las Alturas")


func _process(delta: float) -> void:
	pass


func _on_prepare_button_pressed() -> void:
	terreno_preparado = true
	print("Terreno preparado")
	
func _on_papa_button_pressed() -> void:
	if not terreno_preparado:
		print("Primero debes preparar el terreno")
		return
	
	GameState.cultivo = "Papa"
	cultivo_seleccionado = true
	
	print("Cultivo seleccionado: Papa")
	
func _on_quinua_button_pressed() -> void:
	if not terreno_preparado:
		print("Primero debes preparar el terreno")
		return
	
	GameState.cultivo = "Quinua"
	cultivo_seleccionado = true
	
	print("Cultivo seleccionado: Quinua")
	
func _on_plant_button_pressed() -> void:
	if not terreno_preparado:
		print("Primero debes preparar el terreno")
		return
	
	if GameState.cultivo == "":
		print("Primero debes elegir un cultivo")
		return
	
	sembrado = true
	
	print("Has sembrado: ", GameState.cultivo)
	
	get_tree().change_scene_to_file("res://scenes/Growth.tscn")
	if not terreno_preparado:
		print("Primero debes preparar el terreno")
		return
	
	if GameState.cultivo == "":
		print("Primero debes elegir un cultivo")
		return
	
	sembrado = true
	
	print("Has sembrado: ", GameState.cultivo)
