extends Area2D

const TRASH_CLOSED_TEXTURE: Texture2D = preload("res://assets/graphics/trash_closed-no_bg.png")
const TRASH_OPEN_TEXTURE: Texture2D = preload("res://assets/graphics/trash_open-no_bg.png")

@onready var sprite: Sprite2D = $Sprite2D
var hovered_draggables := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.area_entered.connect(self._on_area_entered)
	self.area_exited.connect(self._on_area_exited)
	_set_open_state(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func take_item(item: Draggable) -> bool:
	if not item:
		return false

	item.hide()
	item.queue_free()
	hovered_draggables = 0
	_set_open_state(false)
	return true

func _on_area_entered(area: Area2D) -> void:
	if area is Draggable:
		hovered_draggables += 1
		_set_open_state(true)

func _on_area_exited(area: Area2D) -> void:
	if area is Draggable:
		hovered_draggables = maxi(hovered_draggables - 1, 0)
		if hovered_draggables == 0:
			_set_open_state(false)

func _set_open_state(is_open: bool) -> void:
	sprite.texture = TRASH_OPEN_TEXTURE if is_open else TRASH_CLOSED_TEXTURE
