extends AudioStreamPlayer

func _ready():
	play(0)

func _process(delta):
	if(global.player and $Origin):
		var distanceToPlayer = global.player.global_transform.origin.distance_to($Origin.global_transform.origin)
		volume_db = lerp(volume_db, clamp(distanceToPlayer, 1, 80) * -1, 0.1)
