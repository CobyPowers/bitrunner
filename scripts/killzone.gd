extends Node

@onready var game_scene = get_node_or_null("/root/Game")

func _on_body_entered(body: Node2D) -> void:
	if not game_scene:
		set_deferred("monitoring", false)
		return		
	if body.is_in_group("player") and not game_scene.debug_mode:
		game_scene.trigger_game_over()
