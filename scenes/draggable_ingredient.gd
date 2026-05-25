extends Area2D

@export var ingredient: Ingredient

var was_dropped: bool = false
var possible_dropzones: Array[Area2D] = []
var original_position: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.texture = ingredient.texture


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not was_dropped:
		self.global_position = get_global_mouse_position()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("dropzones"):
		possible_dropzones.append(area)


func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("dropzones"):
		possible_dropzones.erase(area)


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not (event is InputEventMouseButton):
		return

	var mouse_event = event as InputEventMouseButton

	if mouse_event.button_index == MOUSE_BUTTON_LEFT:
		if mouse_event.pressed:
			was_dropped = false
		else:
			var global_pos = self.global_position
			if possible_dropzones.size() > 0:
				was_dropped = true
				var closest_dropzone = null
				for dropzone in possible_dropzones:
					if closest_dropzone == null or global_pos.distance_to(dropzone.position) < global_pos.distance_to(closest_dropzone.position):
						closest_dropzone = dropzone
				self.global_position = closest_dropzone.position
				closest_dropzone.take_ingredient(self)
			else:
				was_dropped = true
				var go_back_tween = create_tween()
				go_back_tween.tween_property(self, "global_position", original_position, 0.05)
				go_back_tween.finished.connect(queue_free)
