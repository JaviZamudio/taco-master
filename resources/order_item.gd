class_name OrderItem
extends Resource

var delivered: bool = false
var ingredients: Dictionary[Ingredient.Type, Ingredient] = {
    Ingredient.Type.BASE: null,
    Ingredient.Type.MEAT: null,
    Ingredient.Type.VEGETABLE: null,
    Ingredient.Type.SAUCE: null
}