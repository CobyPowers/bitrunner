extends Node2D

const LAVA_HEADSTART = 6

@onready var game_manager = get_node_or_null("/root/Game/GameManager")

@onready var next_segment_anchor = $NextSegmentAnchor
@onready var segment_spawn_trigger = $SegmentSpawnTrigger
@onready var entered_trigger = $EnteredTrigger
@onready var entered_sfx = $EnteredTrigger/EnteredSFX
@onready var canvas_modulate = $CanvasModulate

@export var segments: Array[Resource]

func _ready() -> void:
	if not game_manager:
		printerr("Level segments must be placed alongside a game manager")
		get_tree().quit(1)
	if segments.size() <= 0:
		printerr("Root level segment must have a list of segments to pick from during the generation process")
		get_tree().quit(1)
		
	canvas_modulate.visible = false

func get_random_segment() -> Resource:
	rand_from_seed(Engine.get_frames_drawn())
	return segments[randi_range(0, segments.size() - 1)]

func spawn_random_segment(position: Vector2 = next_segment_anchor.global_position):
	var segment = get_random_segment().instantiate()
	segment.position = position
	segment.segments = segments
	get_parent().call_deferred("add_child", segment)

func _on_segment_spawn_trigger_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	
	# Disable further collisions
	segment_spawn_trigger.set_deferred("monitoring", false)
	
	# Spawn random segment
	spawn_random_segment()

func _on_entered_trigger_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	
	# Disable further collisions
	entered_trigger.set_deferred("monitoring", false)

	entered_sfx.play()
	game_manager.advance_lava(global_position, LAVA_HEADSTART)
