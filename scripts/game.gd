extends Node2D

const EASE_STYLE = Tween.TRANS_EXPO
const EASE_DIRECTION = Tween.EASE_OUT

const CAMERA_ZOOM_EASE_DURATION = 1.5
const CAMERA_TILT_EASE_DURATION = 0.75
const CAMERA_EFFECT_EASE_DURATION = 0.75
const MUSIC_EASE_DURATION = 1.5

const RAGE_MODE_TIME_SCALE = 0.25
const RAGE_MODE_MUSIC_PITCH = 0.4
const RAGE_MODE_CRT_CURVATURE = 0.06
const RAGE_MODE_CRT_CHROMA_OFFSET = 3.0

const GAME_OVER_MUSIC_PITCH = 0.4

@onready var player = $Player
@onready var camera = $Player/Camera2D
@onready var music = $Player/Music
@onready var lava = $Lava
@onready var rage_mode_timer = $RageModeTimer
@onready var score_timer = $ScoreTimer
@onready var game_over_timer = $GameOverTimer
@onready var game_over_ui = $UI/GameOverUI
@onready var rage_ui = $UI/RageUI
@onready var rage_text = $UI/RageUI/RageText
@onready var rage_remaining_text = $UI/RageUI/RageRemainingText
@onready var score_text = $UI/Score
@onready var crt_filter = $UI/CRTFilter
@onready var blackout = $UI/Blackout

@onready var init_camera_zoom = camera.zoom
@onready var init_rage_text_pos = rage_text.position

var score = 0
var debug_mode = false
var rage_mode = false
var game_over = false

func reset_camera():
	var tween = get_tree().create_tween().set_parallel(true).set_ignore_time_scale(true).set_trans(EASE_STYLE).set_ease(EASE_DIRECTION)
	tween.tween_property(camera, "zoom", init_camera_zoom, CAMERA_ZOOM_EASE_DURATION)
	tween.tween_property(camera, "rotation_degrees", 0, CAMERA_TILT_EASE_DURATION)
	tween.tween_property(rage_ui, "modulate:a", 0, CAMERA_EFFECT_EASE_DURATION)
	tween.tween_method(
	  set_crt_filter_curvature,  
	  get_crt_filter_curvature(),
	  0.0,
	  CAMERA_EFFECT_EASE_DURATION
	);
	tween.tween_method(
	  set_crt_filter_chroma_offset,  
	  get_crt_filter_chroma_offset(),
	  0.0,
	  CAMERA_EFFECT_EASE_DURATION
	);

func zoom_camera(zoom: Vector2 = init_camera_zoom):
	var tween = get_tree().create_tween().set_ignore_time_scale(true).set_trans(EASE_STYLE).set_ease(EASE_DIRECTION)
	tween.tween_property(camera, "zoom", zoom, CAMERA_ZOOM_EASE_DURATION)

func tilt_camera(tilt: float = -3.0):
	var tween = get_tree().create_tween().set_ignore_time_scale(true).set_trans(EASE_STYLE).set_ease(EASE_DIRECTION)
	tween.tween_property(camera, "rotation_degrees", tilt, CAMERA_TILT_EASE_DURATION)

func get_crt_filter_curvature() -> float:
	return crt_filter.material.get_shader_parameter("curvature")

func set_crt_filter_curvature(value: float):
	crt_filter.material.set_shader_parameter("curvature", value)

func get_crt_filter_chroma_offset() -> float:
	return crt_filter.material.get_shader_parameter("chroma_offset_px")

func set_crt_filter_chroma_offset(value: float):
	crt_filter.material.set_shader_parameter("chroma_offset_px", value)

func enable_camera_effects(intensity: float = 1):
	var tween = get_tree().create_tween().set_parallel(true).set_ignore_time_scale(true).set_trans(EASE_STYLE).set_ease(EASE_DIRECTION)
	tween.tween_property(rage_ui, "modulate:a", intensity, CAMERA_EFFECT_EASE_DURATION)
	tween.tween_method(
	  set_crt_filter_curvature,  
	  get_crt_filter_curvature(),
	  RAGE_MODE_CRT_CURVATURE,
	  CAMERA_EFFECT_EASE_DURATION
	)
	tween.tween_method(
	  set_crt_filter_chroma_offset,  
	  get_crt_filter_chroma_offset(),
	  RAGE_MODE_CRT_CHROMA_OFFSET,
	  CAMERA_EFFECT_EASE_DURATION
	)

func enable_audio_effects():
	music.pitch_scale = RAGE_MODE_MUSIC_PITCH
	AudioServer.set_bus_effect_enabled(1, 0, true) # Reverb
	AudioServer.set_bus_effect_enabled(1, 1, true) # Distortion

func disable_audio_effects():
	music.pitch_scale = 1
	AudioServer.set_bus_effect_enabled(1, 0, false) # Reverb
	AudioServer.set_bus_effect_enabled(1, 1, false) # Distortion

func activate_rage_mode():
	if game_over or rage_mode: return
	rage_mode = true
	
	Engine.time_scale = RAGE_MODE_TIME_SCALE
	zoom_camera(init_camera_zoom + Vector2(0.25, 0.25))
	enable_audio_effects()
	enable_camera_effects()
	tilt_camera()
	player.overcharge()
	
func deactivate_rage_mode():
	if not rage_mode: return
	rage_mode = false
	
	Engine.time_scale = 1
	disable_audio_effects()
	reset_camera()
	player.reset()

func show_game_over_ui():
	var tween = get_tree().create_tween().set_parallel(true).set_ignore_time_scale(true).set_trans(EASE_STYLE).set_ease(EASE_DIRECTION)
	tween.tween_property(game_over_ui, "modulate:a", 1, CAMERA_EFFECT_EASE_DURATION)
	tween.tween_property(music, "pitch_scale", GAME_OVER_MUSIC_PITCH, MUSIC_EASE_DURATION)

func trigger_game_over():
	if game_over: return
	game_over = true
	
	score_timer.stop()
	player.kill()
	deactivate_rage_mode()
	show_game_over_ui()
	game_over_timer.start()

func advance_lava(new_position: Vector2):
	lava.advance(new_position)

func _ready() -> void:
	camera.zoom -= Vector2.ONE
	blackout.set_active(true)
	blackout.transition(func(): pass)
	zoom_camera()
	
var frame_count = 0
func _process(_delta: float) -> void:
	frame_count = (frame_count % 6969) + 1
	if rage_mode:
		rage_remaining_text.text = str(int(rage_mode_timer.time_left)) + " seconds left"
		if frame_count % 10 == 0:
			rage_text.set_position(Vector2(init_rage_text_pos.x + randf() * 5, init_rage_text_pos.y + randf() * 5))
		
	score_text.text = "Score: " + str(score)
	
	if debug_mode and Input.is_action_just_pressed("dash"):
		activate_rage_mode() if not rage_mode else deactivate_rage_mode()

func _on_game_over_timer_timeout() -> void:
	blackout.transition(func(): get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))

func _on_rage_mode_timer_timeout() -> void:
	if rage_mode:
		deactivate_rage_mode()
		rage_mode_timer.wait_time = 60
	else:
		activate_rage_mode()
		rage_mode_timer.wait_time = 10
	
	# Restart timer to account for new wait time
	rage_mode_timer.start()

func _on_score_timer_timeout() -> void:
	score += 1
