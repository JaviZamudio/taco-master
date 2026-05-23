extends Area2D

var draggable_ingredient_scene: PackedScene = preload("res://scenes/draggable_ingredient.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var draggable_ingredient = draggable_ingredient_scene.instantiate() as Area2D
		self.add_child(draggable_ingredient)
