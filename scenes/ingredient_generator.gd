extends Area2D

@export var ingredient: Ingredient

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var draggable_ingredient_scene: PackedScene = preload("res://scenes/draggable_ingredient.tscn")
		
		var draggable_ingredient = draggable_ingredient_scene.instantiate() as Draggable
		draggable_ingredient.ingredient = self.ingredient
		draggable_ingredient.original_position = self.global_position

		get_tree().current_scene.add_child(draggable_ingredient)
