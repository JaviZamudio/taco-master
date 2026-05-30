extends Area2D

signal item_taken(item)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func take_item(item: Draggable) -> bool:
	if not "ingredient_layers" in item:
		return false

	emit_signal("item_taken", item)
	return true
