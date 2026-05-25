class_name Ingredient
extends Resource

enum Type {
	VEGETABLE, # Onion + Cilantro
	MEAT, # Beef, Pastor, Chorizo, Arrachera
	BASE, # Corn Tortilla
	SAUCE, # Green, Red
	SNACK, # Chips, Cacahuate, etc.
}

@export var name: String
@export var texture: Texture2D
@export var type: Type
