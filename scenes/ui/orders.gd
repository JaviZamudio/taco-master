extends Node

var orders: Array[Order] = []
var displayed_order: Order = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Backdrop.visible = false
	$Backdrop.gui_input.connect(handle_backdrop_input)
	
	add_order()

func add_order():
	var new_order: Order = Order.new()
	new_order.patience = 0
	new_order.payment = 0
	new_order.items = []

	var ingredients = get_ingredients()

	# Add a random number of items to the order (between 1 and 5)
	var items_count = randi() % 5 + 1
	var items: Array[OrderItem] = []
	for i in range(items_count):
		var order_item: OrderItem = OrderItem.new()
		order_item.delivered = false
		order_item.ingredients = {
			Ingredient.Type.BASE: choose_random_ingredient(Ingredient.Type.BASE, ingredients),
			Ingredient.Type.MEAT: choose_random_ingredient(Ingredient.Type.MEAT, ingredients),
			Ingredient.Type.VEGETABLE: null,
			Ingredient.Type.SAUCE: null
		}
		var complexity = 2 # base and meat are always present, so start complexity at 2

		# 50% chance to have any vegetable
		if randf() < 0.5:
			order_item.ingredients[Ingredient.Type.VEGETABLE] = choose_random_ingredient(Ingredient.Type.VEGETABLE, ingredients)
			complexity += 1
		# 70% chance to have any sauce
		if randf() < 0.7:
			order_item.ingredients[Ingredient.Type.SAUCE] = choose_random_ingredient(Ingredient.Type.SAUCE, ingredients)
			complexity += 1
		
		# item bonus + complexity * coefficient
		new_order.payment += 2 + complexity * 2 # each ingredient adds 2 to the payment
		new_order.patience += 3.0 + complexity * 0.5 # each ingredient adds 0.5 seconds to the patience

		items.append(order_item)

	new_order.items = items
	orders.append(new_order)
	add_order_summary_card(new_order)

func display_order_details(order: Order):
	if displayed_order == order:
		hide_order_details()
		return

	displayed_order = order
	$Backdrop.visible = true

	var taco_list: VBoxContainer = $Backdrop/OrderDetailsCard/TacoList
	# Get children of taco_list and free them
	for child in taco_list.get_children():
		child.queue_free()

	var item_index = 0
	for item in order.items:
		item_index += 1
		var taco_description_scene = preload("res://scenes/ui/taco_description.tscn")
		var taco_description_instance: HBoxContainer = taco_description_scene.instantiate()
		if item.delivered:
			# Make them look more white (more light/intensity or whatever) and less opacity/alpha
			taco_description_instance.modulate = Color(1.3, 1.3, 1.3, 0.3) # Example: reduce opacity to 50% for delivered items
		taco_description_instance.get_node("Label").text = str(item_index) + ". "

		var texture_rects = taco_description_instance.find_children("TextureRect*")
		var index = 0
		for ingredient: Ingredient in item.ingredients.values():
			# # Add first char of the ingredient
			# taco_description_instance.get_node("Label").text += ingredient.name[0] if ingredient else "-"
			if ingredient and index < texture_rects.size():
				var texture_rect = texture_rects[index] as TextureRect
				texture_rect.texture = ingredient.texture
				texture_rect.tooltip_text = ingredient.name
				index += 1

		# Clear the remaining texture rects
		for i in range(index, texture_rects.size()):
			var texture_rect = texture_rects[i] as TextureRect
			texture_rect.texture = null

		taco_list.add_child(taco_description_instance)

func add_order_summary_card(order: Order):
	var card_scene = preload("res://scenes/ui/order_summary_card.tscn")
	var card_instance: OrderSummaryCard = card_scene.instantiate()
	card_instance.order = order
	card_instance.display_order_details.connect(display_order_details)
	card_instance.order_completed.connect(handle_order_completed)
	$OrderCards.add_child(card_instance)

func get_ingredients():
	# Get all ingredients from the resources folder
	var ingredients = {
		Ingredient.Type.BASE: [],
		Ingredient.Type.MEAT: [],
		Ingredient.Type.VEGETABLE: [],
		Ingredient.Type.SAUCE: []
	}
	var dir: DirAccess = DirAccess.open("res://resources/ingredients")
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			if file_name.contains(".tres"):
				# clean the file name from .remap (leaving only the .tres extension)
				var clean_file_name = file_name.replace(".remap", "")
				var ingredient = load("res://resources/ingredients/" + clean_file_name) as Ingredient
				if not ingredients.has(ingredient.type):
					ingredients[ingredient.type] = []
				ingredients[ingredient.type].append(ingredient)
			file_name = dir.get_next()
		dir.list_dir_end()

	return ingredients

func choose_random_ingredient(ingredient_type: Ingredient.Type, ingredients: Dictionary) -> Ingredient:
	if not ingredients:
		ingredients = get_ingredients()

	if ingredients[ingredient_type].size() > 0:
		return ingredients[ingredient_type][randi() % ingredients[ingredient_type].size()]
	else:
		return null

func handle_backdrop_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		hide_order_details()

func hide_order_details():
	$Backdrop.visible = false
	self.displayed_order = null

func handle_order_completed(order: Order) -> void:
	print("Order completed: " + str(order))
	orders.erase(order)

	# TODO: Remove:
	self.add_order()
	self.add_order()
