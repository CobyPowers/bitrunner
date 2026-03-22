extends Node2D

@export var speed = 55

@onready var animated_sprite = $AnimatedSprite2D
@onready var killzone = $Killzone
@onready var respawn_timer = $RespawnTimer
@onready var raycast_left = $RayCastLeft
@onready var raycast_right = $RayCastRight
@onready var raycast_left_diag = $RayCastLeftDiag
@onready var raycast_right_diag = $RayCastRightDiag

var direction = 1
var stunned = false

func hit():
	if stunned: return
	stunned = true
	killzone.set_deferred("monitoring", false)
	animated_sprite.play("hit")
	animated_sprite.connect("animation_finished", func():
		visible = false
		respawn_timer.start()
	, CONNECT_ONE_SHOT)

func _process(delta: float):
	if stunned:
		return
	
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

func _on_respawn_timer_timeout() -> void:
	visible = true
	animated_sprite.play("spawn")
	animated_sprite.connect("animation_finished", func():
		killzone.monitoring = true
		stunned = false
		animated_sprite.play("idle")
	, CONNECT_ONE_SHOT)
