extends HBoxContainer


func set_amount(amount: int) -> void:
	get_node("AmountLabel").text = str(amount)
