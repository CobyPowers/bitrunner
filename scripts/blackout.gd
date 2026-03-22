extends ColorRect

const EASE_STYLE = Tween.TRANS_SINE
const EASE_DIRECTION = Tween.EASE_OUT

@export var ease_duration = 0.5

var active = false

func _ready() -> void:
	visible = true
	modulate.a = 0

func transition(callback: Callable, delay: int = 0):
	active = not active
	if delay > 0:
		await get_tree().create_timer(delay).timeout
	var tween = get_tree().create_tween().set_trans(EASE_STYLE).set_ease(EASE_DIRECTION)
	tween.tween_property(self, "modulate:a", int(active), ease_duration)
	tween.connect("finished", callback)

func set_active(value: bool):
	active = value
	modulate.a = int(value)
