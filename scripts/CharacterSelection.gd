extends Control


var personaje_seleccionado = ""
var sexo_seleccionado = ""


func _ready() -> void:
	pass


func _on_fox_male_button_pressed() -> void:
	personaje_seleccionado = "Zorro"
	sexo_seleccionado = "Masculino"
	print("Personaje seleccionado: ", personaje_seleccionado, " ", sexo_seleccionado)


func _on_fox_female_button_pressed() -> void:
	personaje_seleccionado = "Zorro"
	sexo_seleccionado = "Femenino"
	print("Personaje seleccionado: ", personaje_seleccionado, " ", sexo_seleccionado)


func _on_jucumari_male_button_pressed() -> void:
	personaje_seleccionado = "Jucumari"
	sexo_seleccionado = "Masculino"
	print("Personaje seleccionado: ", personaje_seleccionado, " ", sexo_seleccionado)


func _on_jucumari_female_button_pressed() -> void:
	personaje_seleccionado = "Jucumari"
	sexo_seleccionado = "Femenino"
	print("Personaje seleccionado: ", personaje_seleccionado, " ", sexo_seleccionado)


func _on_capibara_male_button_pressed() -> void:
	personaje_seleccionado = "Capibara"
	sexo_seleccionado = "Masculino"
	print("Personaje seleccionado: ", personaje_seleccionado, " ", sexo_seleccionado)


func _on_capibara_female_button_pressed() -> void:
	personaje_seleccionado = "Capibara"
	sexo_seleccionado = "Femenino"
	print("Personaje seleccionado: ", personaje_seleccionado, " ", sexo_seleccionado)


func _on_continue_button_pressed() -> void:
	if personaje_seleccionado == "":
		print("Debes seleccionar un personaje")
		return

	GameState.personaje = personaje_seleccionado
	GameState.sexo = sexo_seleccionado

	print("Personaje guardado: ", GameState.personaje)
	print("Sexo guardado: ", GameState.sexo)

	get_tree().change_scene_to_file("res://scenes/Farm.tscn")
