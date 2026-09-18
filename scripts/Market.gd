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

	crop_label.text = "Cultivo: " + GameState.cultivo
	production_label.text = "Producción: " + str(GameState.produccion) + " unidades"
	price_label.text = "Precio: " + str(precio_por_unidad) + " monedas por unidad"

	if GameState.cultivo == "Quinua":
		crop_icon.texture = load("res://assets/crops/quinua/QuinuaMadura.png")
	else:
		crop_icon.texture = load("res://assets/crops/papa/PapaMadura.png")

	ganancia = GameState.produccion * precio_por_unidad

	total_label.text = "Ganancia: " + str(ganancia) + " monedas"


func _on_sell_button_pressed() -> void:
	GameState.monedas += ganancia
	GameState.monedas_obtenidas += ganancia

	print("Producción vendida")
	print("Ganancia obtenida: ", ganancia)
	print("Monedas actuales: ", GameState.monedas)

	get_tree().change_scene_to_file("res://scenes/Decision.tscn")
