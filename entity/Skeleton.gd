extends Spatial

var type = "Enemy"

var sight_range = 10

var movement_vector = Vector3.ZERO
var movement_direction = Vector3.ZERO
var movement_speed = 2
var health = 3
var hit_timer = 0
var hit_timer_max = 0.2

var spawner

var on_floor = false

var hit_sound = preload("res://sound/skeleton_hit.wav")

var pickup_scene = preload("res://entity/Pickup.tscn")

onready var eyes = $Eyes
onready var eye_cast = $Eyes/RayCast
onready var body = $KinematicBody
onready var hitbox = $Hitbox
onready var foot_cast = $RayCast
onready var sprite = $Sprite3D

signal hit

func _physics_process(delta):
	# If the player is close enough, check if you have line of sight
	if(global.player):
		var playerOrigin = global.player.global_transform.origin
		var vectorToPlayer = playerOrigin - global_transform.origin
		if(vectorToPlayer.length() <= sight_range and on_floor):
			# Cast a ray to see if you aren't obstructed
			eye_cast.cast_to = vectorToPlayer
			eye_cast.force_raycast_update()
			if(eye_cast.is_colliding()):
				if(eye_cast.get_collider().get_parent().get("type") == "Player"):
					movement_direction = vectorToPlayer.normalized()
				else:
					movement_direction = Vector3.ZERO
	
	# Check if on floor
	foot_cast.force_raycast_update()
	if(foot_cast.is_colliding()):
		movement_vector.y = -0.01
		on_floor = true
	else:
		on_floor = false
	
	var old_y = movement_vector.y
	movement_vector = Vector3(movement_direction.x, 0, movement_direction.z) * movement_speed
	movement_vector.y = old_y - global.GRAVITY
	body.move_and_slide(movement_vector)
	global_transform.origin = body.global_transform.origin
	body.transform.origin = Vector3.ZERO
	
	# Hit timer
	if(hit_timer > 0):
		hit_timer -= delta
		if(hit_timer <= 0):
			sprite.modulate = Color.white
	
	# Check for player
	for area in hitbox.get_overlapping_areas():
		if(area.get_parent().get("type") == "Player" and global.enemies_aggroed):
			global.player.emit_signal("hit", 1, global_transform.origin)

func _on_Skeleton_hit(damage: int):
	global.enemies_aggroed = true
	if(hit_timer <= 0):
		hit_timer = hit_timer_max
		sprite.modulate = Color.red
		health -= damage
		var sound = AudioStreamPlayer.new()
		sound.stream = hit_sound
		sound.pitch_scale = rand_range(0.8, 1.2)
		get_tree().root.add_child(sound)
		var distanceToPlayer = global.player.global_transform.origin.distance_to(global_transform.origin)
		sound.volume_db = clamp(distanceToPlayer * 2, 1, 80) * -1
		sound.play(0)
		sound.add_to_group("AudioStreamPlayers")
		if(health <= 0):
			if(randi() % 4 == 3):
				var pickup = pickup_scene.instance()
				pickup.pickup_type = global.pickup_types.health_potion 
				get_tree().root.add_child(pickup)
				pickup.global_transform.origin = global_transform.origin
			elif(randi() % 4 == 3 and global.player.crossbow_unlocked):
				var pickup = pickup_scene.instance()
				pickup.pickup_type = global.pickup_types.ammo 
				get_tree().root.add_child(pickup)
				pickup.global_transform.origin = global_transform.origin
			if(spawner):
				spawner.current_skeleton = null
			queue_free()
