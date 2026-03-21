extends Node2D

@onready var player = $Player
@onready var camera = $Player/Camera2D

func tween_camera():
	var tween = get_tree().create_tween()
	camera.zoom -= Vector2.ONE
	tween.tween_property(camera, "zoom", camera.zoom + Vector2.ONE, 2.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

func _ready() -> void:
	tween_camera()

func _process(delta: float) -> void:
	pass
