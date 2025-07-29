extends Node2D




func _on_area_2d_body_entered(body):
	if body.name == "Player":
		get_tree().call_group("game","add_coin")
		queue_free()
