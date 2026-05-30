class_name OrderSummaryCard
extends Control

signal display_order_details(order)
signal order_completed(order)

var order: Order
var is_completed: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not order:
		printerr("OrderSummaryCard: No order assigned to the card.")
		return

	# Choose a tinct color (any basic named color)
	var colors = ["red", "green", "blue", "yellow", "cyan", "magenta"]
	var color_name = colors[randi() % colors.size()]
	var color = Color(color_name)
	color.s = color.s * 0.5 # Reduce saturation for a more pastel look
	self.modulate = color

	update_summary_label()
	$DropZoneControl/Area2D.item_taken.connect(_on_item_taken)

func update_summary_label():
	var delivered_items = order.items.filter(func(item): return item.delivered)
	var total_items = order.items.size()
	$OrderSummaryLabel.text = "%d / %d" % [delivered_items.size(), total_items]

func _on_item_taken(item: Draggable) -> void:

	var correct_item = false
	# Check if the taken item matches any undelivered item in the order
	for order_item in order.items:
		if order_item.delivered:
			continue

		if compare_items(order_item, item):
			order_item.delivered = true
			update_summary_label()
			correct_item = true
			break

	if not correct_item:
		print("Taken item does not match any undelivered item in the order.")
		# TODO: Add feedback for incorrect item (e.g., shake the card, play a sound, etc.)
	else:
		# Check if all items are delivered
		var all_delivered = order.items.all(func(i): return i.delivered)
		if all_delivered:
			handle_order_completed()

	item.queue_free() # Remove the item from the scene after taking it

func compare_items(order_item: OrderItem, item: Draggable) -> bool:
	if not "ingredient_layers" in item:
		return false

	for ingredient_type in Ingredient.Type.values():
		var order_ingredient = order_item.ingredients.get(ingredient_type, null)
		var item_ingredient = item.ingredient_layers.get(ingredient_type, null)

		if order_ingredient != item_ingredient:
			return false

	return true

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		display_order_details.emit(order)

func handle_order_completed():
	is_completed = true
	order_completed.emit(order)
	self.queue_free() # Remove the card from the scene when the order is completed
