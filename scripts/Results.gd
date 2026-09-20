extends Control

const AchievementBadgeScene = preload("res://ui/components/AchievementBadge.tscn")


func _ready() -> void:
	var perfil = GameState.calcular_perfil_financiero()

	get_node("ProfileLabel").text = "Perfil financiero: " + perfil

	get_node("SealsLabel").text = "Sellos del Guardián: " + str(GameState.sellos)
	get_node("ChallengesLabel").text = "Mini desafíos superados: " + str(GameState.minidesafios_completados)

	_reaccionar_condor()
	_presentar_funcionario()
	_poblar_logros()
	_animar_economia()
	_animar_tarjetas()


func _formatear_puntos(valor: int) -> String:
	if valor > 0:
		return "+" + str(valor) + " pts"
	elif valor < 0:
		return str(valor) + " pts"
	else:
		return "0 pts"


# Contador animado de dinero: cuenta desde 0 hasta el valor final para dar
# una sensación más dinámica al resumen (en vez de mostrar el número fijo).
func _animar_fila_dinero(label: Label, etiqueta: String, monedas: int, sufijo_puntos: String = "") -> void:
	var tw = create_tween()
	tw.tween_method(
		func(v: float):
			var texto = etiqueta + ": " + str(int(round(v))) + " monedas"
			if sufijo_puntos != "":
				texto += "  (" + sufijo_puntos + ")"
			label.text = texto,
		0.0, float(monedas), 0.7
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _animar_economia() -> void:
	_animar_fila_dinero(get_node("ObtainedLabel"), "Obtenidas", GameState.monedas_obtenidas)
	_animar_fila_dinero(get_node("SavedLabel"), "Ahorradas", GameState.monedas_ahorradas, _formatear_puntos(GameState.puntos_ahorro))
	_animar_fila_dinero(get_node("InvestedLabel"), "Invertidas", GameState.monedas_invertidas, _formatear_puntos(GameState.puntos_invertir))
	_animar_fila_dinero(get_node("SpentLabel"), "Gastadas", GameState.monedas_gastadas, _formatear_puntos(GameState.puntos_gastar))

	var total_label = get_node("PointsTotalLabel")
	total_label.text = "Total puntos extra: 0 pts"
	total_label.pivot_offset = total_label.size / 2.0
	var tw = create_tween()
	tw.tween_interval(0.6)
	tw.tween_callback(func(): total_label.text = "Total puntos extra: " + _formatear_puntos(GameState.puntos_extra_total()))
	tw.tween_property(total_label, "scale", Vector2(1.15, 1.15), 0.12).set_trans(Tween.TRANS_SINE)
	tw.tween_property(total_label, "scale", Vector2(1.0, 1.0), 0.18).set_trans(Tween.TRANS_SINE)


func _reaccionar_condor() -> void:
	var condor = get_node("CondorDialog")
	var resultado = GameState.resultado_final()

	condor.set_pose(resultado)

	match resultado:
		"feliz":
			condor.set_message("¡Excelente trabajo! Tu producción y tus decisiones hicieron crecer tu economía. ¡Sigue así!")
		"dudoso":
			condor.set_message("Un resultado parejo... con más producción, ahorro e inversión podrías ganar aún más puntos extra.")
		_:
			condor.set_message("Esta jornada fue dura para tu economía. La próxima vez piensa bien antes de arriesgarte o gastar.")

	condor.animate_in()
	_iniciar_balanceo_condor()


# Pequeño balanceo continuo (además del "respirar" que ya trae el retrato)
# para que el cóndor, ahora más grande, se sienta con más vida en esta pantalla.
func _iniciar_balanceo_condor() -> void:
	var portrait = get_node("CondorDialog/Portrait")
	portrait.pivot_offset = portrait.size / 2.0

	var tw = create_tween()
	tw.set_loops()
	tw.tween_property(portrait, "rotation_degrees", 3.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(portrait, "rotation_degrees", -3.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


# Mensaje de cierre del funcionario del BDP invitando a las agencias.
# Entra un poco después que el cóndor para que no aparezcan los dos de golpe.
func _presentar_funcionario() -> void:
	var funcionario = get_node("FuncionarioDialog")
	funcionario.modulate.a = 0.0

	var tw = create_tween()
	tw.tween_interval(0.5)
	tw.tween_callback(funcionario.animate_in)
	tw.tween_callback(func():
		funcionario.set_message("¡Gracias por recorrer el camino para recibir un premio! Te esperamos en nuestras agencias: https://www.bdp.com.bo/nuestras-oficinas-2/")
	)


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


func _animar_tarjetas() -> void:
	for nombre in ["ProfileCard", "EconomyCard", "AchievementsCard"]:
		var card = get_node(nombre)
		card.modulate.a = 0.0
		card.pivot_offset = card.size / 2.0
		card.scale = Vector2(0.94, 0.94)
		var tw = create_tween()
		tw.tween_property(card, "modulate:a", 1.0, 0.3)
		tw.parallel().tween_property(card, "scale", Vector2(1.0, 1.0), 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _on_menu_button_pressed() -> void:
	await SceneTransition.change_scene("res://scenes/MainMenu.tscn")
