extends Node

func _on_body_entered(body: Node2D) -> void:
	var groups = body.get_groups()
	for group in groups:
		if group == "player":
			print("Player has died!")
