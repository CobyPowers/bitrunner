extends CharacterBody2D

@onready var game_manager = get_node_or_null("/root/Game/GameManager")

@export var speed = 100.0
@export var dash_speed = 150.0
@export var jump_velocity = 300.0
@export var gravity_scale = 1

@export var disabled = false
@export var invinsible = false

@onready var animated_sprite = $AnimatedSprite2D
@onready var jump_sfx = $Jump
@onready var hit_sfx = $Hit

var dashing = false

func overcharge():
	speed *= 3.5
	dash_speed *= 3.5
	jump_velocity *= 3.0
	gravity_scale *= 8.0
	invinsible = true

func reset():
	speed = 100.0
	dash_speed = 150.0
	jump_velocity = 300.0
	gravity_scale = 1
	invinsible = false

func hit() -> bool:
	# Only apply hits if the player is active and not invinsible
	if not invinsible and not disabled:
		disabled = true
		hit_sfx.play()
		animated_sprite.play("hit")
		animated_sprite.connect("animation_finished", func(): _kill(), CONNECT_ONE_SHOT)
	# Return whether or not the hit was successful
	return not invinsible

func _kill():
	animated_sprite.play("death")
	animated_sprite.connect("animation_finished", func(): 
		if game_manager:
			game_manager.trigger_game_over()
	, CONNECT_ONE_SHOT)

func _physics_process(delta: float) -> void:
	# Add the gravity
	if not is_on_floor():
		velocity += get_gravity() * gravity_scale * delta

	# If disabled, don't process input
	if disabled:
		velocity.x = 0
		move_and_slide()
		return

	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump_sfx.play()
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
