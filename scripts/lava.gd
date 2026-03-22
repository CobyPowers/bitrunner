extends TileMapLayer

const EASE_STYLE = Tween.TRANS_EXPO
const EASE_DIRECTION = Tween.EASE_OUT

const LAVA_RISE_DURATION = 3

@export var rise_speed = 10
@export var shift_frequency = 0.2
@export var shift_amplitude = 50
 
var time = 0
var advancing = false

func advance(new_position: Vector2, headstart: float = 0):
	advancing = true
	var tween = get_tree().create_tween().set_ignore_time_scale(true).set_trans(EASE_STYLE).set_ease(EASE_DIRECTION)
	tween.tween_property(self, "position:y", new_position.y, LAVA_RISE_DURATION)
	tween.connect("finished", func(): advancing = false; print(position, new_position + Vector2.UP * headstart * rise_speed), CONNECT_ONE_SHOT)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not advancing:
		time += delta
		position.x = sin(2 * PI * time * shift_frequency) * shift_amplitude
		position.y -= delta * rise_speed
