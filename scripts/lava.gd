extends TileMapLayer

@export var rise_speed = 7.0
@export var shift_frequency = 0.25
@export var shift_amplitude = 10

var time = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta
	self.position.x = sin(2 * PI * time * shift_frequency) * shift_amplitude
	self.position.y -= delta * rise_speed
