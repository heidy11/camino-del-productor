extends Control

const AchievementBadgeScene = preload("res://ui/components/AchievementBadge.tscn")


func _ready() -> void:
	var perfil = GameState.calcular_perfil_financiero()

	get_node("ProfileLabel").text = "Perfil financiero: " + perfil
	get_node("ObtainedLabel").text = "Obtenidas: " + str(GameState.monedas_obtenidas)
	get_node("SavedLabel").text = "Ahorradas: " + str(GameState.monedas_ahorradas)
	get_node("InvestedLabel").text = "Invertidas: " + str(GameState.monedas_invertidas)
	get_node("SpentLabel").text = "Gastadas: " + str(GameState.monedas_gastadas)
	get_node("EmergencyLabel").text = "Fondo de emergencia: " + str(GameState.fondo_emergencia)

	get_node("HealthLabel").text = "Salud financiera: " + str(GameState.salud_financiera)
	get_node("ProductivityLabel").text = "Productividad: " + str(GameState.productividad)
	get_node("ResilienceLabel").text = "Resiliencia: " + str(GameState.resiliencia)
	get_node("GoalLabel").text = "Meta de ahorro alcanzada: " + ("Sí" if GameState.meta_alcanzada() else "No")

	get_node("SealsLabel").text = "Sellos del Guardián: " + str(GameState.sellos)
	get_node("ChallengesLabel").text = "Mini desafíos superados: " + str(GameState.minidesafios_completados)

	_poblar_logros()
	_animar_barras()
	_animar_tarjetas()


func _poblar_logros() -> void:
	var list = get_node("AchievementsList")

	for child in list.get_children():
		child.queue_free()

	if GameState.logros.is_empty():
		var empty_label = Label.new()
		empty_label.text = "Aún no hay logros en esta partida."
		list.add_child(empty_label)
		return

	for logro in GameState.logros:
		var badge = AchievementBadgeScene.instantiate()
		list.add_child(badge)
		badge.set_text(logro)
		badge.modulate.a = 0.0
		badge.scale = Vector2(0.7, 0.7)
		badge.pivot_offset = Vector2(14, 14)

	await get_tree().process_frame

	var index = 0
	for badge in list.get_children():
		var tw = create_tween()
		tw.tween_interval(index * 0.08)
		tw.tween_property(badge, "modulate:a", 1.0, 0.2)
		tw.parallel().tween_property(badge, "scale", Vector2(1.0, 1.0), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		index += 1


func _animar_barras() -> void:
	_animar_barra(get_node("HealthBar"), float(GameState.salud_financiera))
	_animar_barra(get_node("ProductivityBar"), float(GameState.productividad))
	_animar_barra(get_node("ResilienceBar"), float(GameState.resiliencia))


func _animar_barra(barra: ProgressBar, valor_final: float) -> void:
	barra.value = 0.0
	var tw = create_tween()
	tw.tween_property(barra, "value", valor_final, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _animar_tarjetas() -> void:
	for nombre in ["ProfileCard", "EconomyCard", "IndicatorsCard", "AchievementsCard"]:
		var card = get_node(nombre)
		card.modulate.a = 0.0
		card.pivot_offset = card.size / 2.0
		card.scale = Vector2(0.94, 0.94)
		var tw = create_tween()
		tw.tween_property(card, "modulate:a", 1.0, 0.3)
		tw.parallel().tween_property(card, "scale", Vector2(1.0, 1.0), 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _on_menu_button_pressed() -> void:
	await SceneTransition.change_scene("res://scenes/MainMenu.tscn")
