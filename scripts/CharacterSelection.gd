extends Control


var personaje_seleccionado = ""
var sexo_seleccionado = ""
var sprite_seleccionado = ""
var boton_actual: Button = null

const SPRITES = {
	"Zorro_Masculino": "res://assets/characters/zorro_m.png",
	"Zorro_Femenino": "res://assets/characters/zorro_f.png",
	"Jucumari_Masculino": "res://assets/characters/jucumari_m.png",
	"Jucumari_Femenino": "res://assets/characters/jucumari/JucumariFemenino.png",
	"Capibara_Masculino": "res://assets/characters/capibara_m.png",
	"Capibara_Femenino": "res://assets/characters/capibara/CapibaraFemenino.png",
}


func _ready() -> void:
	_seleccionar("Zorro", "Masculino", get_node("CharacterContainer/FoxMaleButton"), false)


func _seleccionar(personaje: String, sexo: String, boton: Button, animate: bool = true) -> void:
	personaje_seleccionado = personaje
	sexo_seleccionado = sexo
	sprite_seleccionado = SPRITES[personaje + "_" + sexo]

	var preview = get_node("PreviewFrame")
	var name_label = get_node("NameLabel")
	var gender_label = get_node("GenderLabel")
	var nueva_textura = load(sprite_seleccionado)

	name_label.text = personaje.to_upper()
	gender_label.text = sexo

	if boton_actual and boton_actual != boton:
		boton_actual.get_node("SelectedBadge").visible = false

	boton.get_node("SelectedBadge").visible = true
	boton_actual = boton

	if animate:
		_animar_cambio_personaje(preview, nueva_textura)
		_animar_seleccion_tarjeta(boton)
	else:
		preview.texture = nueva_textura
		preview.pivot_offset = preview.size / 2.0

	print("Personaje seleccionado: ", personaje_seleccionado, " ", sexo_seleccionado)


func _animar_cambio_personaje(preview: TextureRect, nueva_textura: Texture2D) -> void:
	preview.pivot_offset = preview.size / 2.0

	var tw = create_tween()
	tw.tween_property(preview, "scale", Vector2(0.82, 0.82), 0.12).set_trans(Tween.TRANS_SINE)
	tw.parallel().tween_property(preview, "modulate:a", 0.25, 0.12)
	tw.tween_callback(func(): preview.texture = nueva_textura)
	tw.tween_property(preview, "scale", Vector2(1.0, 1.0), 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(preview, "modulate:a", 1.0, 0.2)


func _animar_seleccion_tarjeta(boton: Button) -> void:
	boton.pivot_offset = boton.size / 2.0

	var tw = create_tween()
	tw.tween_property(boton, "scale", Vector2(1.12, 1.12), 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(boton, "scale", Vector2(1.0, 1.0), 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)


func _on_fox_male_button_pressed() -> void:
	_seleccionar("Zorro", "Masculino", get_node("CharacterContainer/FoxMaleButton"))


func _on_fox_female_button_pressed() -> void:
	_seleccionar("Zorro", "Femenino", get_node("CharacterContainer/FoxFemaleButton"))


func _on_jucumari_male_button_pressed() -> void:
	_seleccionar("Jucumari", "Masculino", get_node("CharacterContainer/JucumariMaleButton"))


func _on_jucumari_female_button_pressed() -> void:
	_seleccionar("Jucumari", "Femenino", get_node("CharacterContainer/JucumariFemaleButton"))


func _on_capibara_male_button_pressed() -> void:
	_seleccionar("Capibara", "Masculino", get_node("CharacterContainer/CapibaraMaleButton"))


func _on_capibara_female_button_pressed() -> void:
	_seleccionar("Capibara", "Femenino", get_node("CharacterContainer/CapibaraFemaleButton"))


func _on_continue_button_pressed() -> void:
	if personaje_seleccionado == "":
		print("Debes seleccionar un personaje")
		return

	GameState.personaje = personaje_seleccionado
	GameState.sexo = sexo_seleccionado
	GameState.personaje_sprite = sprite_seleccionado

	print("Personaje guardado: ", GameState.personaje)
	print("Sexo guardado: ", GameState.sexo)

	await SceneTransition.change_scene("res://scenes/Farm.tscn")
