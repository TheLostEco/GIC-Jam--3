extends Control

@onready var animation_player_5: AnimationPlayer = $AnimationPlayer5

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/level_1.tscn")
	animation_player_5.play("fade")
