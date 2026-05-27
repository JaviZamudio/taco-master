class_name Draggable
extends Area2D

var was_dropped: bool = true
var dropzone: Area2D
var original_position: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# connect signals for detecting dropzones
	self.area_entered.connect(self._on_area_entered)
	self.area_exited.connect(self._on_area_exited)
	self.input_event.connect(self._on_input_event)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not was_dropped:
		self.global_position = get_global_mouse_position()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("dropzones"):
		dropzone = area


func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("dropzones"):
		dropzone = null

func handle_drop():
	printerr("handle_drop not implemented")
	pass

func handle_pickup():
	was_dropped = false
	if not original_position:
		original_position = dropzone.position if dropzone else self.global_position

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not (event is InputEventMouseButton):
		return

	var mouse_event = event as InputEventMouseButton

	if mouse_event.button_index == MOUSE_BUTTON_LEFT:
		if mouse_event.pressed:
			self.handle_pickup()
		else:
			self.handle_drop()
