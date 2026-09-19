extends HBoxContainer

const STAR_FILLED = preload("res://assets/icons/star_filled.png")
const STAR_EMPTY = preload("res://assets/icons/star_empty.png")


func set_stars(count: int, max_stars: int) -> void:
	for child in get_children():
		child.queue_free()

	for i in range(max_stars):
		var star = TextureRect.new()
		star.custom_minimum_size = Vector2(28, 28)
		star.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		star.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		star.texture = STAR_FILLED if i < count else STAR_EMPTY
		add_child(star)
