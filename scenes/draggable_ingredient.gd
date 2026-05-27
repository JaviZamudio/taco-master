extends Draggable

@export var ingredient: Ingredient

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.texture = ingredient.texture
	self.was_dropped = false

func handle_drop():
	was_dropped = true
	if self.dropzone and self.dropzone.take_item(self):
		self.queue_free()
	else:
		var go_back_tween = create_tween()
		go_back_tween.tween_property(self, "global_position", original_position, 0.09)
		go_back_tween.finished.connect(self.queue_free)
