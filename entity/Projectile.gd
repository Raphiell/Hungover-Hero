extends Spatial

var ready = false

var movement_direction = Vector3.ZERO
var movement_speed = 0
var particles = global.particles.none
var damage = 0

var bolt_hit_sound = preload("res://sound/bolt_stone_hit.wav")

onready var cast = $RayCast
onready var sprite = $Sprite3D

func prepare(from: Vector3, newMovementDirection: Vector3, newMovementSpeed: float, newParticles: int, type: int, newDamage: int):
	look_at(newMovementDirection, Vector3.UP)
	global_transform.origin = from
	movement_direction = newMovementDirection
	movement_speed = newMovementSpeed
	cast.cast_to = Vector3(0, 0, -newMovementDirection.length())
	particles = newParticles
	damage = newDamage
	ready = true
	
	match type:
		global.projectile_types.bolt:
			sprite.rotation_degrees.y = 135
			sprite.pixel_size = 0.04
		global.projectile_types.magic:
			pass

func _process(delta):
	if(ready):
		# Check if collision is coming up
		cast.force_raycast_update()
		if(cast.is_colliding()):
			if(cast.get_collider().name == "Hitbox"):
				cast.get_collider().get_parent().emit_signal("hit", damage)
			elif(cast.get_collider().get_parent().get("type") == "Button"):
				cast.get_collider().get_parent().emit_signal("press")
			else:
				var sound = AudioStreamPlayer.new()
				sound.stream = bolt_hit_sound
				sound.pitch_scale = rand_range(0.8, 1.2)
				get_tree().root.add_child(sound)
				var distanceToPlayer = global.player.global_transform.origin.distance_to(global_transform.origin)
				sound.volume_db = clamp(distanceToPlayer * 2, 1, 80) * -1
				sound.play(0)
				sound.add_to_group("AudioStreamPlayers")
			queue_free()
		
		global_transform.origin += movement_direction * movement_speed
		

