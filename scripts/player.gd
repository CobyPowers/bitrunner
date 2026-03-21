extends CharacterBody2D

@export var speed = 100.0
@export var dash_speed = 150.0
@export var jump_velocity = 300.0
@export var gravity_scale = 1

@export var disabled = false

@onready var animated_sprite = $AnimatedSprite2D

var dashing = false

func double_speed():
	speed *= 3.5
	dash_speed *= 3.5
	jump_velocity *= 2.0
	gravity_scale *= 3.5

func reset_speed():
	speed = 100.0
	dash_speed = 150.0
	jump_velocity = 300.0
	gravity_scale = 1

func _physics_process(delta: float) -> void:
	if disabled:
		return
	
	# Add the gravity
	if not is_on_floor():
		velocity += get_gravity() * gravity_scale * delta

	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_velocity

	# Get movement direction
	var direction = Input.get_axis("move_left", "move_right")

	if direction != 0 and Input.is_action_just_pressed("dash") and not dashing:
		animated_sprite.play("dash")
		dashing = true
	
	var anim_name = animated_sprite.animation
	var anim_playing = animated_sprite.is_playing()
	if anim_name == "dash" and not anim_playing:
		dashing = false
	
	if not dashing:
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	
	# Flip sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		
	if direction:
		velocity.x = direction * (dash_speed if dashing else speed)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
