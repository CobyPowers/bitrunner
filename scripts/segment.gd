extends Node2D

@onready var game_scene = get_node_or_null("/root/Game")

@onready var next_segment_anchor = $NextSegmentAnchor
@onready var segment_spawn_trigger = $SegmentSpawnTrigger
@onready var entered_trigger = $EnteredTrigger
@onready var entered_sfx = $EnteredTrigger/EnteredSFX
@onready var canvas_modulate = $CanvasModulate

@export var segments: Array[Resource]

func _ready() -> void:
	if not game_scene:
		printerr("Level segments must only be placed in the game scene")
		get_tree().quit(1)
	if segments.size() <= 0:
		printerr("Root level segment must have a list of segments to pick from during the generation process")
		get_tree().quit(1)
		
	canvas_modulate.visible = false

func _on_segment_spawn_trigger_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	
	# Disable further collisions
	segment_spawn_trigger.set_deferred("monitoring", false)
	
	# Fetch random segment
	rand_from_seed(Engine.get_frames_drawn())
	var segment_res = segments[randi_range(0, segments.size() - 1)]
	
	# Spawn new segment
	var segment = segment_res.instantiate() as Node2D
	segment.transform = next_segment_anchor.transform
	segment.segments = segments
	call_deferred("add_child", segment)

func _on_entered_trigger_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	
	# Disable further collisions
	entered_trigger.set_deferred("monitoring", false)

	entered_sfx.play()
	game_scene.advance_lava(global_position + Vector2(0, 50))
