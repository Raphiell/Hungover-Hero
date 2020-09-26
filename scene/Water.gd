extends StaticBody

var original_position

var wave_tracker = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	original_position = global_transform.origin

func _process(delta):
	wave_tracker += delta
	global_transform.origin.y = original_position.y + sin(wave_tracker) / 10
