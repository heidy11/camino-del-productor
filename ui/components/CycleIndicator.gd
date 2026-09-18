extends PanelContainer


func set_cycle(current: int, max_cycles: int) -> void:
	get_node("CycleLabel").text = "Ciclo " + str(current) + " / " + str(max_cycles)
