extends Node2D

const EASE_STYLE = Tween.TRANS_SINE
const EASE_DIRECTION = Tween.EASE_OUT

const MUSIC_EASE_DURATION = 1
const BLACKOUT_EASE_DURATION = 0.5

const TITLE_TEXT_ROTATE_SPEED = 0.25
const TITLE_TEXT_ROTATE_ANGLE = 3.0

@onready var music = $Music
@onready var title_text = $UI/TitleText
@onready var blackout = $UI/Blackout

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	music.volume_db = -35
	var tween = get_tree().create_tween().set_trans(EASE_STYLE).set_ease(EASE_DIRECTION)
	tween.tween_property(music, "volume_db", 0, MUSIC_EASE_DURATION)
	blackout.set_active(true)
	blackout.transition(func(): pass)

func _on_start_button_pressed() -> void:
	blackout.transition(func(): get_tree().change_scene_to_file("res://scenes/game.tscn"))
	
func _on_credits_button_pressed() -> void:
	blackout.transition(func(): get_tree().change_scene_to_file("res://scenes/credits.tscn"))

func _on_quit_button_pressed() -> void:
	blackout.transition(func(): get_tree().quit())

var time = 0
func _process(delta: float) -> void:
	time += delta
	title_text.rotation_degrees = sin(2 * PI * time * TITLE_TEXT_ROTATE_SPEED) * TITLE_TEXT_ROTATE_ANGLE
