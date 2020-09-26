extends Spatial

var sight_range = 15

var attack_timer_max = 1
var attack_timer = attack_timer_max

var fireball_scene = preload("res://entity/Skeleton Boss Fire Projectile.tscn")

onready var eye_cast = $RayCast
onready var fireball_spawn_location = $"Fireball Spawn Location"

func _process(delta):
	if(global.player):
		var playerOrigin = global.player.global_transform.origin
		var vectorToPlayer = playerOrigin - global_transform.origin
		if(vectorToPlayer.length() <= sight_range):
			# Cast a ray to see if you aren't obstructed
			eye_cast.cast_to = vectorToPlayer
			eye_cast.force_raycast_update()
			if(eye_cast.is_colliding()):
				if(eye_cast.get_collider().get_parent().get("type") == "Player"):
					attack_cycle(delta)

func attack_cycle(delta):
	if(attack_timer > 0):
		attack_timer -= delta
	else:
		attack_timer = attack_timer_max
		var fireball = fireball_scene.instance()
		fireball.boss_mode = false
		var playerOrigin = global.player.global_transform.origin
		var vectorToPlayer = playerOrigin - global_transform.origin
		fireball.movement_direction = vectorToPlayer.normalized()
		get_tree().root.add_child(fireball)
		fireball.global_transform.origin = fireball_spawn_location.global_transform.origin
		
