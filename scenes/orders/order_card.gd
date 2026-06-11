class_name OrderCard
extends Control

signal display_order_details(order)
signal order_completed(order)

var order: Order
var is_completed: bool = false

# ENGINE METHODS

func _ready() -> void:
	if not order:
		printerr("OrderCard: No order assigned to the card.")
		return

	# Choose a tinct color (any basic named color)
	var colors = ["red", "green", "blue", "yellow", "cyan", "magenta"]
	var color_name = colors[randi() % colors.size()]
	var color = Color(color_name)
	color.s = color.s * 0.3 # Reduce saturation for less intensity
	$Panel/OrderSummaryLabel.modulate = color
	
	# Start with -100px in y and animate to 0 with a tween
	$Panel.position.y = -200
	var tween = create_tween()
	tween.tween_property($Panel, "position:y", 0, 0.5).set_ease(Tween.EASE_OUT)

	# Set patience bar
	$PatienceTimer.start(1.0) # Start the patience timer with 1 second intervals
	$Panel/PatienceBar.max_value = order.patience - 1
	$Panel/PatienceBar.value = order.patience - 1
	$Panel/PatienceBar.modulate = get_patience_color()

	update_summary_label()
	$Panel/DropZoneControl/Area2D.item_taken.connect(_on_item_taken)
	$PatienceTimer.timeout.connect(_on_patience_timer_timeout)

func update_summary_label():
	var delivered_items = order.items.filter(func(item): return item.delivered)
	var total_items = order.items.size()
	$Panel/OrderSummaryLabel.text = "%d / %d" % [delivered_items.size(), total_items]

func compare_order_items(order_item: OrderItem, item: Draggable) -> bool:
	if not "ingredient_layers" in item:
		return false

	for ingredient_type in Ingredient.Type.values():
		var order_ingredient = order_item.ingredients.get(ingredient_type, null)
		var item_ingredient = item.ingredient_layers.get(ingredient_type, null)

		if order_ingredient != item_ingredient:
			return false

	return true

func handle_order_completed():
	var callback = func ():
		is_completed = true
		order_completed.emit(order)
		self.queue_free() # Remove the card from the scene when the order is completed

	# Animate the card moving up and fading out
	var tween = create_tween()
	tween.parallel().tween_property($Panel, "position:y", -200, 0.5).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property($Panel, "modulate:a", 0, 0.5).set_ease(Tween.EASE_IN)
	tween.tween_callback(callback)

func set_patience(value: float) -> void:
	# Clamp patience value between 0 and max
	order.patience = clamp(value, 0, $Panel/PatienceBar.max_value)

	var patience_decrease_tween: Tween = create_tween()
	patience_decrease_tween.parallel().tween_property($Panel/PatienceBar, "value", order.patience - 1, 0.5).set_ease(Tween.EASE_OUT)
	patience_decrease_tween.parallel().tween_property($Panel/PatienceBar, "modulate", get_patience_color(), 0.5).set_ease(Tween.EASE_OUT)

	# Handle patience running out
	if value <= 0:
		# TODO: Handle failure as different event, like order expired, instead of just completing it
		handle_order_completed() # Treat as completed (failed) when patience runs out
		print("Order failed due to running out of patience.")

# EVENT HANDLERS

func _on_item_taken(item: Draggable) -> void:
	if "ingredient" in item:
		if item.ingredient.type != Ingredient.Type.SNACK:
			return
		
		# If item is SNACK, add patience but reduce payment
		set_patience(self.order.patience + 2)
		self.order.payment *= 0.9
		return
			

	var correct_item = false
	# Check if the taken item matches any undelivered item in the order
	for order_item in order.items:
		if order_item.delivered:
			continue

		if compare_order_items(order_item, item):
			order_item.delivered = true
			update_summary_label()
			correct_item = true
			break

	if not correct_item:
		print("Taken item does not match any undelivered item in the order.")
		# TODO: Add feedback for incorrect item (e.g., shake the card, play a sound, etc.)
		set_patience(self.order.patience - 3) # Penalize more for incorrect items
	else:
		set_patience(self.order.patience + 3)
		# Check if all items are delivered
		var all_delivered = order.items.all(func(i): return i.delivered)
		if all_delivered:
			handle_order_completed()

	item.queue_free() # Remove the item from the scene after taking it

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		display_order_details.emit(order)

func _on_patience_timer_timeout() -> void:
	if is_completed:
		return # Don't penalize completed orders

	# Decrease patience
	set_patience(self.order.patience - 1)

# HELPER FUNCTIONS

func get_patience_color() -> Color:
	# Modify hue from green to red based on remaining patience
	var remaining_patience = $Panel/PatienceBar.value
	var max_patience = $Panel/PatienceBar.max_value
	var hue = lerp(0.0, 0.33, remaining_patience / max_patience) # Green to Red

	return Color.from_hsv(hue, 1, 1)
