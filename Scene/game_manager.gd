extends Node
var coin_count = 0

func _ready():
	add_to_group("Game")
func add_coin():
	coin_count+=1
	update_coin_label()
func update_coin_label():
	var label= 
