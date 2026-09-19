extends Control


func _ready() -> void:
	actualizar_dinero()

	var condor = get_node("CondorDialog")
	condor.set_pose("pensativo")
	condor.set_message("Piensa bien: cada decisión tiene una consecuencia distinta.")
	condor.animate_in()


func actualizar_dinero() -> void:
	var money_label = get_node("MoneyLabel")
	var goal_label = get_node("GoalLabel")

	money_label.text = "Tienes: " + str(GameState.monedas) + " monedas"
	goal_label.text = "Meta de ahorro: " + str(GameState.monedas_ahorradas) + " / " + str(GameState.meta_ahorro)


func _bloquear_botones() -> void:
	get_node("SaveButton").disabled = true
	get_node("InvestButton").disabled = true
	get_node("SpendButton").disabled = true


func _animar_confirmacion(boton: Button) -> void:
	boton.pivot_offset = boton.size / 2.0
	var tw = create_tween()
	tw.tween_property(boton, "scale", Vector2(1.08, 1.08), 0.12).set_trans(Tween.TRANS_SINE)
	tw.tween_property(boton, "scale", Vector2(1.0, 1.0), 0.18).set_trans(Tween.TRANS_SINE)

	_crear_monedas(boton.global_position + boton.size / 2.0)

	await tw.finished
	await get_tree().create_timer(0.25).timeout


func _crear_monedas(origen: Vector2) -> void:
	var textura_moneda = load("res://assets/icons/coin.png")

	for i in range(5):
		var moneda = TextureRect.new()
		moneda.texture = textura_moneda
		moneda.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		moneda.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		moneda.size = Vector2(22, 22)
		moneda.position = origen - moneda.size / 2.0 + Vector2(randf_range(-12, 12), 0)
		moneda.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(moneda)

		var destino = moneda.position + Vector2(randf_range(-24, 24), -randf_range(50, 90))

		var tw = create_tween()
		tw.set_parallel(true)
		tw.tween_property(moneda, "position", destino, 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tw.tween_property(moneda, "modulate:a", 0.0, 0.55)
		tw.tween_property(moneda, "rotation", randf_range(-1.2, 1.2), 0.55)
		tw.chain().tween_callback(moneda.queue_free)


func _continuar() -> void:
	if GameState.ciclo_final_completado():
		await SceneTransition.change_scene("res://scenes/Results.tscn")
	else:
		await SceneTransition.change_scene("res://scenes/Farm.tscn")


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

	_bloquear_botones()
	await _animar_confirmacion(get_node("SaveButton"))
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

	_bloquear_botones()
	await _animar_confirmacion(get_node("InvestButton"))
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

	_bloquear_botones()
	await _animar_confirmacion(get_node("SpendButton"))
	_continuar()
