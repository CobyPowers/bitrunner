extends Node2D

@export var speed = 55

@onready var animated_sprite = $AnimatedSprite2D
@onready var raycast_left = $RayCastLeft
@onready var raycast_right = $RayCastRight
@onready var raycast_left_diag = $RayCastLeftDiag
@onready var raycast_right_diag = $RayCastRightDiag

var direction = 1

func _process(delta: float):
	# Check if touching wall on left
	if raycast_left.is_colliding():
		animated_sprite.flip_h = true
		direction = -1
	
	# Check if touching wall on right	
	if raycast_right.is_colliding():
		animated_sprite.flip_h = false
		direction = 1
		
	# Check if there is ground to the left
	if not raycast_left_diag.is_colliding():
		animated_sprite.flip_h = true
		direction = -1
		
	# Check if there is ground to the right
	if not raycast_right_diag.is_colliding():
		animated_sprite.flip_h = false
		direction = 1
		
	position.x += direction * speed * delta
