extends Node2D

const EASE_TYPE = Tween.EASE_OUT
const EASE_TRANSITION = Tween.TRANS_EXPO

const MUSIC_DISTORTION_EASE_TRANSITION = Tween.TRANS_SINE

const CAMERA_ZOOM_EASE_DURATION = 1.5
const CAMERA_TILT_EASE_DURATION = 0.75
const CAMERA_EFFECT_EASE_DURATION = 0.75
const MUSIC_EASE_DURATION = 1.5

const DEFAULT_CRT_CURVATURE = 0
const DEFAULT_CRT_CHROMA_OFFSET = 1.5

const MUSIC_DISTORTION_DRIVE = 0.3

const RAGE_MODE_CAMERA_ZOOM = Vector2(0.25, 0.25)
const RAGE_MODE_CAMERA_TILT = -3.0
const RAGE_MODE_TIME_SCALE = 0.25
const RAGE_MODE_MUSIC_PITCH = 0.4
const RAGE_MODE_CRT_CURVATURE = 0.06
const RAGE_MODE_CRT_CHROMA_OFFSET = 3.0

const RAGE_MODE_DURATION = 15
const RAGE_MODE_WAIT = 60

const PAUSED_CAMERA_ZOOM = Vector2(0.25, 0.25)
const PAUSED_CAMERA_TILT = -3.0
const PAUSED_MUSIC_PITCH = 0.6
const PAUSED_CRT_CURVATURE = 0.03
const PAUSED_CRT_CHROMA_OFFSET = 3.0

const GAME_OVER_MUSIC_PITCH = 0.4
const GAME_OVER_CHROMA_OFFSET = 3.0

@onready var player = get_node("../Player")
@onready var camera = get_node("../Player/Camera2D")
@onready var music = get_node("../Player/Music")
@onready var lava = get_node("../Lava")
@onready var rage_mode_timer = get_node("../RageModeTimer")
@onready var score_timer = get_node("../ScoreTimer")
@onready var game_over_timer = get_node("../GameOverTimer")
@onready var game_over_ui = get_node("../UI/GameOverUI")
@onready var pause_ui = get_node("../UI/PauseUI")
@onready var rage_ui = get_node("../UI/RageUI")
@onready var rage_text = get_node("../UI/RageUI/RageText")
@onready var rage_fluff_text = get_node("../UI/RageFluffText")
@onready var rage_start_timer_text = get_node("../UI/RageStartTimerText")
@onready var rage_remaining_timer_text = get_node("../UI/RageUI/RageRemainingTimerText")
@onready var score_text = get_node("../UI/ScoreText")
@onready var crt_filter = get_node("../UI/CRTFilter")
@onready var blackout = get_node("../UI/Blackout")

@onready var init_camera_zoom = camera.zoom
@onready var init_rage_text_pos = rage_text.position
@onready var init_rage_fluff_text_pos = rage_fluff_text.position

@export var debug_mode = true
var rage_mode = false
var rage_mode_starting = false
var game_over = false
var paused = false

var score = 0

func reset_screen(reset_music: bool = true):
	zoom_camera()
	tilt_camera()
	tween_crt_filter_curvature()
	tween_crt_filter_chroma_offset()
	
	if reset_music:
		tween_music_pitch()

func create_game_tween() -> Tween:
	return get_tree().create_tween().set_parallel(true).set_ignore_time_scale(true).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_trans(EASE_TRANSITION).set_ease(EASE_TYPE)

func zoom_camera(value: Vector2 = Vector2.ZERO, ease_transition: Tween.TransitionType = EASE_TRANSITION, duration: float = CAMERA_ZOOM_EASE_DURATION):
	if rage_mode and not paused:
		value = RAGE_MODE_CAMERA_ZOOM
	create_game_tween().set_trans(ease_transition).tween_property(camera, "zoom", init_camera_zoom + value, duration)

func tilt_camera(value: float = 0, ease_transition: Tween.TransitionType = EASE_TRANSITION, duration: float = CAMERA_TILT_EASE_DURATION):
	if rage_mode and not paused:
		value = RAGE_MODE_CAMERA_TILT
	create_game_tween().set_trans(ease_transition).tween_property(camera, "rotation_degrees", value, duration)

func get_crt_filter_curvature() -> float:
	return crt_filter.material.get_shader_parameter("curvature")

func set_crt_filter_curvature(value: float):
	crt_filter.material.set_shader_parameter("curvature", value)

func tween_crt_filter_curvature(value: float = DEFAULT_CRT_CURVATURE):
	if rage_mode and not paused:
		value = RAGE_MODE_CRT_CURVATURE
	create_game_tween().tween_method(
	  set_crt_filter_curvature,  
	  get_crt_filter_curvature(),
	  value,
	  CAMERA_EFFECT_EASE_DURATION
	)

func get_crt_filter_chroma_offset() -> float:
	return crt_filter.material.get_shader_parameter("chroma_offset_px")

func set_crt_filter_chroma_offset(value: float):
	crt_filter.material.set_shader_parameter("chroma_offset_px", value)

func tween_crt_filter_chroma_offset(value: float = DEFAULT_CRT_CHROMA_OFFSET):
	if rage_mode and not paused:
		value = RAGE_MODE_CRT_CHROMA_OFFSET
	create_game_tween().tween_method(
	  set_crt_filter_chroma_offset,  
	  get_crt_filter_chroma_offset(),
	  value,
	  CAMERA_EFFECT_EASE_DURATION
	)

func tween_music_pitch(value: float = 1):
	if rage_mode and not paused:
		value = RAGE_MODE_MUSIC_PITCH
	create_game_tween().tween_property(music, "pitch_scale", value, MUSIC_EASE_DURATION)

func tween_ui_alpha(ui: CanvasItem, value: float = 0):
	create_game_tween().tween_property(ui, "modulate:a", value, CAMERA_EFFECT_EASE_DURATION)

func enable_audio_effects(tween_duration: int = 0):
	var distortion_effect = AudioServer.get_bus_effect(1, 1) as AudioEffectDistortion
	
	if tween_duration > 0:
		distortion_effect.drive = 0
	
	AudioServer.set_bus_effect_enabled(1, 0, true) # Reverb
	AudioServer.set_bus_effect_enabled(1, 1, true) # Distortion
	
	if tween_duration > 0:
		create_game_tween().set_trans(MUSIC_DISTORTION_EASE_TRANSITION).tween_property(distortion_effect, "drive", MUSIC_DISTORTION_DRIVE, tween_duration)

func disable_audio_effects():
	AudioServer.set_bus_effect_enabled(1, 0, false) # Reverb
	AudioServer.set_bus_effect_enabled(1, 1, false) # Distortion

func activate_rage_mode():
	if game_over or rage_mode: return
	rage_mode = true
	
	Engine.time_scale = RAGE_MODE_TIME_SCALE
	enable_audio_effects()
	zoom_camera()
	tilt_camera()
	tween_ui_alpha(rage_ui, 1)
	tween_crt_filter_curvature()
	tween_crt_filter_chroma_offset()
	tween_music_pitch()
	player.overcharge()
	
func deactivate_rage_mode():
	if not rage_mode: return
	rage_mode = false
	
	Engine.time_scale = 1
	disable_audio_effects()
	tween_ui_alpha(rage_ui)
	reset_screen()
	player.reset()

func trigger_game_over():
	if game_over: return
	game_over = true
	
	score_timer.stop()
	rage_mode_timer.stop()
	game_over_timer.start()
	
	if rage_mode:
		deactivate_rage_mode()
		
	tween_ui_alpha(game_over_ui, 1)
	tween_music_pitch(GAME_OVER_MUSIC_PITCH)
	tween_crt_filter_chroma_offset(GAME_OVER_CHROMA_OFFSET)

func pause_game():
	paused = true
	get_tree().paused = true
	zoom_camera(PAUSED_CAMERA_ZOOM)
	tilt_camera(PAUSED_CAMERA_TILT)
	if rage_mode: tween_ui_alpha(rage_ui)
	tween_ui_alpha(pause_ui, 1)
	tween_music_pitch(PAUSED_MUSIC_PITCH)
	tween_crt_filter_curvature(PAUSED_CRT_CURVATURE)
	tween_crt_filter_chroma_offset(PAUSED_CRT_CHROMA_OFFSET)

func unpause_game():
	paused = false
	get_tree().paused = false
	if rage_mode: tween_ui_alpha(rage_ui, 1)
	tween_ui_alpha(pause_ui)
	reset_screen()

func advance_lava(new_position: Vector2, headstart: float = 0):
	lava.advance(new_position, headstart)

func _ready() -> void:
	camera.zoom -= Vector2.ONE
	blackout.set_active(true)
	blackout.transition(func(): pass)
	zoom_camera(Vector2.ZERO, EASE_TRANSITION, CAMERA_ZOOM_EASE_DURATION * 2)
	
var frame_count = 0
func _process(_delta: float) -> void:
	frame_count = (frame_count % 6969) + 1
	if frame_count % 10 == 0:
		rage_text.set_position(Vector2(init_rage_text_pos.x + randf() * 5, init_rage_text_pos.y + randf() * 5))
		rage_fluff_text.set_position(Vector2(init_rage_fluff_text_pos.x + randf() * 5, init_rage_fluff_text_pos.y + randf() * 5))
	
	var rage_time_left_str = str(int(rage_mode_timer.time_left))
	rage_remaining_timer_text.text = rage_time_left_str + " seconds left"
	rage_start_timer_text.text = rage_time_left_str
	score_text.text = "Score: " + str(score)
	
	if Input.is_action_just_pressed("dash") and debug_mode:
		if rage_mode: deactivate_rage_mode() 
		else: activate_rage_mode()
	
	if Input.is_action_just_pressed("pause") and not game_over:
		if paused: unpause_game() 
		else: pause_game()

func _on_game_over_timer_timeout() -> void:
	reset_screen(false)
	tween_music_pitch(0)
	blackout.transition(func(): get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))

func _on_rage_mode_timer_timeout() -> void:
	if rage_mode: # Rage mode is currently active
		deactivate_rage_mode()
		rage_mode_timer.wait_time = RAGE_MODE_WAIT - 10
	elif rage_mode_starting: # Rage mode is about to start
		rage_mode_starting = false
		tween_ui_alpha(rage_start_timer_text)
		tween_ui_alpha(rage_fluff_text)
		activate_rage_mode()
		rage_mode_timer.wait_time = RAGE_MODE_DURATION
	else: # Rage mode is not active nor is it about to start
		rage_mode_starting = true
		enable_audio_effects(10)
		zoom_camera(RAGE_MODE_CAMERA_ZOOM, MUSIC_DISTORTION_EASE_TRANSITION, 10)
		tilt_camera(RAGE_MODE_CAMERA_TILT, MUSIC_DISTORTION_EASE_TRANSITION, 10)
		tween_ui_alpha(rage_start_timer_text, 1)
		tween_ui_alpha(rage_fluff_text, 1)
		rage_mode_timer.wait_time = 10
	
	# Restart timer to account for new wait time
	rage_mode_timer.start()

func _on_score_timer_timeout() -> void:
	score += 1
