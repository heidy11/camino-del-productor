extends Control

var precio_por_unidad = 2
var ganancia = 0


func _ready() -> void:
	actualizar_feria()


func actualizar_feria() -> void:
	var crop_label = get_node("CropLabel")
	var production_label = get_node("ProductionLabel")
	var price_label = get_node("PriceLabel")
	var total_label = get_node("TotalLabel")
	var crop_icon = get_node("CropIcon")

	crop_label.text = GameState.cultivo
	production_label.text = str(GameState.produccion) + " unidades"
	price_label.text = str(precio_por_unidad) + " monedas por unidad"

	if GameState.cultivo == "Quinua":
		crop_icon.texture = load("res://assets/crops/quinua/QuinuaMadura.png")
	else:
		crop_icon.texture = load("res://assets/crops/papa/PapaMadura.png")

	ganancia = GameState.produccion * precio_por_unidad

	total_label.text = str(ganancia) + " monedas"


func _on_sell_button_pressed() -> void:
	get_node("SellButton").disabled = true

	GameState.monedas += ganancia
	GameState.monedas_obtenidas += ganancia

	print("Producción vendida")
	print("Ganancia obtenida: ", ganancia)
	print("Monedas actuales: ", GameState.monedas)

	await _animar_venta()

	await SceneTransition.change_scene("res://scenes/Decision.tscn")


func _animar_venta() -> void:
	var coin_icon = get_node("TotalIcon")
	var total_label = get_node("TotalLabel")

	coin_icon.pivot_offset = coin_icon.size / 2.0

	var tw_icon = create_tween()
	tw_icon.tween_property(coin_icon, "scale", Vector2(1.4, 1.4), 0.18).set_trans(Tween.TRANS_SINE)
	tw_icon.tween_property(coin_icon, "scale", Vector2(1.0, 1.0), 0.25).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

	var tw_count = create_tween()
	tw_count.tween_method(_actualizar_contador_ganancia, 0.0, float(ganancia), 0.55).set_trans(Tween.TRANS_SINE)

	await tw_count.finished
	await get_tree().create_timer(0.4).timeout


func _actualizar_contador_ganancia(valor: float) -> void:
	get_node("TotalLabel").text = "+" + str(int(valor)) + " monedas"
