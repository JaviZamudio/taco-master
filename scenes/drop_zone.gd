extends Area2D

var taco_scene: PackedScene = preload("uid://cp47xovehn5qn")
var taco: Draggable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func take_item(item: Draggable) -> bool:
	if item.has_method("take_ingredient"):
		if not self.taco:
			self.taco = item
			return true
	else:
		if item.ingredient.type == Ingredient.Type.BASE and not self.taco:
			self.taco = self.taco_scene.instantiate() as Draggable
			get_tree().current_scene.add_child(self.taco)
			self.taco.position = position
			self.taco.original_position = position
			self.taco.previous_dropzone = self
			self.taco.was_dropped = true
			
		if self.taco:
			return self.taco.take_ingredient(item.ingredient)

	return false
