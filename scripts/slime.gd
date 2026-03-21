extends Node2D

@export var speed = 55

@onready var animated_sprite = $AnimatedSprite2D
@onready var raycast_left = $RayCastLeft
@onready var raycast_right = $RayCastRight

var direction = 1

func _process(delta: float):
	if raycast_left.is_colliding():
		animated_sprite.flip_h = true
		direction = -1
		
	if raycast_right.is_colliding():
		animated_sprite.flip_h = false
		direction = 1
		
	position.x += direction * speed * delta
