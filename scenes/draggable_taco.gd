extends Draggable

var ingredient_layers: Dictionary[Ingredient.Type, Ingredient] = {
	Ingredient.Type.BASE: null,
	Ingredient.Type.MEAT: null,
	Ingredient.Type.VEGETABLE: null,
	Ingredient.Type.SAUCE: null,
}
var previous_dropzone: Area2D

func take_ingredient(ingredient: Ingredient) -> bool:
	if ingredient.type in ingredient_layers:
		if not ingredient_layers[ingredient.type]:
			ingredient_layers[ingredient.type] = ingredient

			var sprite_name = (ingredient.Type.find_key(ingredient.type) as String).to_pascal_case() + "Sprite"
			var sprite = $Sprites.get_node(sprite_name) as Sprite2D
			sprite.texture = ingredient.texture

			return true
		else:
			print("already have an ingredient of type: ", ingredient.type)
			return false
	else:
		print("ingredient type not supported: ", ingredient.type)
		return false
			

func handle_drop():
	was_dropped = true
	if self.dropzone and self.dropzone.has_method("take_item") and self.dropzone.take_item(self ):
		# if we had a previous dropzone, clear its taco reference
		if previous_dropzone:
			self.previous_dropzone.taco = null

		self.position = self.dropzone.position
		self.original_position = self.position

		# current dropzone becomes the previous dropzone for next drop
		self.previous_dropzone = self.dropzone
	else:
		var go_back_tween = create_tween()
		go_back_tween.tween_property(self , "global_position", original_position, 0.09)
