extends Node

var orders = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Backdrop.visible = false
	add_order()

	print("Orders: ", orders)

func add_order():
	var new_order = {
		"patience": 0,
		"payment": 0,
		"items": []
	}
	
	var ingredients = get_ingredients()

	# Add a random number of items to the order (between 1 and 5)
	var items_count = randi() % 5 + 1
	var items = []
	for i in range(items_count):
		var item = {
			"delivered": false,
			"Ingredients": {
				Ingredient.Type.BASE: choose_random_ingredient(Ingredient.Type.BASE, ingredients),
				Ingredient.Type.MEAT: choose_random_ingredient(Ingredient.Type.MEAT, ingredients),
				Ingredient.Type.VEGETABLE: null,
				Ingredient.Type.SAUCE: null
			}
		}
		var complexity = 2 # base and meat are always present, so start complexity at 2

		# 50% chance to have any vegetable
		if randf() < 0.5:
			item["Ingredients"][Ingredient.Type.VEGETABLE] = choose_random_ingredient(Ingredient.Type.VEGETABLE, ingredients)
			complexity += 1
		# 70% chance to have any sauce
		if randf() < 0.7:
			item["Ingredients"][Ingredient.Type.SAUCE] = choose_random_ingredient(Ingredient.Type.SAUCE, ingredients)
			complexity += 1
		
		# item bonus + complexity * coefficient
		new_order["payment"] += 2 + complexity * 2 # each ingredient adds 2 to the payment
		new_order["patience"] += 3 + complexity * 0.5 # each ingredient adds 0.5 seconds to the patience

		items.append(item)

	new_order["items"] = items
	orders.append(new_order)

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
			if file_name.ends_with(".tres"):
				var ingredient = load("res://resources/ingredients/" + file_name) as Ingredient
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