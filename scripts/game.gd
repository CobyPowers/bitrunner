extends Node2D

const CAMERA_EASE_STYLE = Tween.TRANS_EXPO
const CAMERA_EASE_DIRECTION = Tween.EASE_OUT

const CAMERA_ZOOM_EASE_DURATION = 2.0
const CAMERA_TILT_EASE_DURATION = 1
const CAMERA_RED_FILTER_EASE_DURATION = 1

const RAGE_MODE_TIME_SCALE = 0.25
const RAGE_MODE_GRAVITY = 0.0

@onready var player = $Player
@onready var camera = $Player/Camera2D
@onready var timer = $Timer
@onready var red_filter = $CanvasLayer/RedFilter

@onready var init_camera_zoom = camera.zoom

var rage_mode = false

func reset_camera():
	var tween = get_tree().create_tween().set_parallel(true).set_ignore_time_scale(true).set_trans(CAMERA_EASE_STYLE).set_ease(CAMERA_EASE_DIRECTION)
	tween.tween_property(camera, "zoom", init_camera_zoom, CAMERA_ZOOM_EASE_DURATION)
	tween.tween_property(camera, "rotation_degrees", 0, CAMERA_TILT_EASE_DURATION)
	tween.tween_property(red_filter, "modulate:a", 0, CAMERA_RED_FILTER_EASE_DURATION)

func zoom_camera(zoom: Vector2 = init_camera_zoom):
	var tween = get_tree().create_tween().set_ignore_time_scale(true).set_trans(CAMERA_EASE_STYLE).set_ease(CAMERA_EASE_DIRECTION)
	tween.tween_property(camera, "zoom", zoom, CAMERA_ZOOM_EASE_DURATION)

func tilt_camera(tilt: float = -3.0):
	var tween = get_tree().create_tween().set_ignore_time_scale(true).set_trans(CAMERA_EASE_STYLE).set_ease(CAMERA_EASE_DIRECTION)
	tween.tween_property(camera, "rotation_degrees", tilt, CAMERA_TILT_EASE_DURATION)

func red_filter_camera(intensity: float = 1):
	var tween = get_tree().create_tween().set_ignore_time_scale(true).set_trans(CAMERA_EASE_STYLE).set_ease(CAMERA_EASE_DIRECTION)
	tween.tween_property(red_filter, "modulate:a", intensity, CAMERA_TILT_EASE_DURATION)

func enable_audio_effects():
	AudioServer.set_bus_effect_enabled(0, 0, true) # Reverb
	AudioServer.set_bus_effect_enabled(0, 1, true) # Low Pass Filter

func disable_audio_effects():
	AudioServer.set_bus_effect_enabled(0, 0, false) # Reverb
	AudioServer.set_bus_effect_enabled(0, 1, false) # Low Pass Filter

func activate_rage_mode():
	if rage_mode: return
	rage_mode = true
	Engine.time_scale = RAGE_MODE_TIME_SCALE
	enable_audio_effects()
	red_filter_camera()
	tilt_camera()
	player.double_speed()
	
func deactivate_rage_mode():
	if not rage_mode: return
	rage_mode = false
	Engine.time_scale = 1
	disable_audio_effects()
	reset_camera()
	player.reset_speed()

func _ready() -> void:
	camera.zoom -= Vector2.ONE
	zoom_camera()

func _on_timer_timeout() -> void:
	print("Updating rage mode...")
	activate_rage_mode() if not rage_mode else deactivate_rage_mode()
