extends Node

@onready var parent = get_parent()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if not body.hit() and parent.is_in_group("enemy"):
			parent.hit()
