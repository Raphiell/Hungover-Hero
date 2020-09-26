extends Spatial

var flicker_timer = 0
var flicker_timer_max = 0.1

func _process(delta):
	flicker_timer -= delta
	if(flicker_timer <= 0):
		$OmniLight.light_energy = rand_range(0.9, 1.1)
		flicker_timer = flicker_timer_max
