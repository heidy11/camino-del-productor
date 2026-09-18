extends Control


func _ready() -> void:
	get_node("Layout/ComponentsRow/CoinDisplay").set_amount(340)
	get_node("Layout/ComponentsRow/CycleIndicator").set_cycle(2, 3)
	get_node("Layout/ComponentsRow/AchievementBadge").set_text("Meta de ahorro alcanzada")
	get_node("Layout/ComponentsRow/StatusIndicator").set_status(true, "¡Correcto!")
	get_node("Layout/ComponentsRow/StarRating").set_stars(3, 5)
	get_node("Layout/DialogBox").set_message("¡Hola! Soy el Cóndor Guardián. Te acompañaré en tu camino como productor.")
	get_node("Layout/EventCard").set_event(load("res://assets/icons/rain.png"), "LLUVIA", "La lluvia puede beneficiar tu cultivo, pero también puede generar riesgos.")
