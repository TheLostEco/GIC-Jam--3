extends Node2D




func _on_area_2d_body_entered(body):
	if body.name == "Player":
		GameManager.add_coin(1)
		queue_free()
