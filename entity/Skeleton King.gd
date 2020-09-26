extends Spatial

var type = "Enemy"

var sight_range = 10

enum attacks {
	skele_summon,
	fireball,
	nova
}

var in_combat = false
var waiting_for_attack = true
var current_attack = -1
var attack_timer_max = 5
var attack_timer = 0
var in_skele_summon_timer_max = 1
var in_skele_summon_timer = in_skele_summon_timer_max
var skele_summon_timer_max = 0.3
var skele_summon_timer = skele_summon_timer_max
var skeleton_scene = preload("res://entity/Boss Skeleton.tscn")
var fire_eyes_attack_pattern = true
var in_fire_eyes_timer_max = 5
var in_fire_eyes_timer = in_fire_eyes_timer_max
var fire_eyes_summon_timer_max = 0.1
var fire_eyes_summon_timer = fire_eyes_summon_timer_max
var fire_scene = preload("res://entity/Skeleton Boss Fire Projectile.tscn")
var nova_range = 1.8
var nova_scene = preload("res://entity/Fire Nova.tscn")
var player_too_close = false
var final_stage_cutscene = false
var final_stage = false
var dying = false

var movement_vector = Vector3.ZERO
var movement_direction = Vector3.ZERO
var movement_speed = 2
var max_health = 120
var health = max_health
var hit_timer = 0
var hit_timer_max = 0.2
var final_stage_health = 20

var hit_sound = preload("res://sound/skeleton_hit.wav")

onready var eyes = $Eyes
onready var eye_cast = $Eyes/RayCast
onready var body = $KinematicBody
onready var hitbox = $Hitbox
onready var foot_cast = $RayCast
onready var sprite_origin = $"Sprite Origin"
onready var sprite = $"Sprite Origin/Sprite3D"
onready var skeleton_spawn_location = $"Skeleton Spawn Location"
onready var fire_spawn_location = $"Sprite Origin/Fire Spawn Location"

signal hit

func _physics_process(delta):
	# Check if on floor
	foot_cast.force_raycast_update()
	if(foot_cast.is_colliding()):
		movement_vector.y = -0.01
	
	var old_y = movement_vector.y
	movement_vector = Vector3(movement_direction.x, 0, movement_direction.z) * movement_speed
	movement_vector.y = old_y - global.GRAVITY / 2
	body.move_and_slide(movement_vector)
	global_transform.origin = body.global_transform.origin
	body.transform.origin = Vector3.ZERO
	
	# Hit timer
	if(hit_timer > 0):
		hit_timer -= delta
		if(hit_timer <= 0):
			sprite.modulate = Color.white
	
	# Check for player
	if(final_stage and !dying):
		var playerOrigin = global.player.global_transform.origin
		var vectorToPlayer = playerOrigin - global_transform.origin
		movement_direction = vectorToPlayer.normalized()
		for area in hitbox.get_overlapping_areas():
			if(area.get_parent().get("type") == "Player"):
				global.player.emit_signal("hit", 1, global_transform.origin)
	
	if(in_combat):
		if(health > final_stage_health):
			if(attack_timer > 0 and waiting_for_attack):
				attack_timer -= delta
			elif(waiting_for_attack):
				waiting_for_attack = false
				attack_timer = attack_timer_max
				# Check if player is close enough to nova
				var playerOrigin = global.player.global_transform.origin
				var vectorToPlayer = playerOrigin - global_transform.origin
				if(vectorToPlayer.length() <= nova_range):
					current_attack = attacks.nova
				elif(fire_eyes_attack_pattern or (health - 2) < final_stage_health):
					current_attack = attacks.fireball
				else:
					current_attack = attacks.skele_summon
			else:
				match current_attack:
					attacks.nova:
						nova_phase()
					attacks.fireball:
						fire_eye_phase(delta)
					attacks.skele_summon:
						skele_summon_phase(delta)
		elif(!final_stage_cutscene):
			final_stage_cutscene = true
			kill_minions()
			global.cutscene_handler.start_cutscene("skeleton_king_final_stage")

func kill_minions():
	for skele in get_tree().get_nodes_in_group(global.boss_skeleton_group):
		skele.drops = false
		skele.emit_signal("hit", 999)
	for fireball in get_tree().get_nodes_in_group(global.boss_fire_group):
		fireball.queue_free()

func nova_phase():
	var nova = nova_scene.instance()
	get_tree().root.add_child(nova)
	nova.global_transform.origin = global_transform.origin
	waiting_for_attack = true
	attack_timer = attack_timer_max / 3
	global.player.emit_signal("big_hit", 1, global_transform.origin)

func skele_summon_phase(delta):
	if(in_skele_summon_timer > 0):
		in_skele_summon_timer -= delta
		if(skele_summon_timer > 0):
			skele_summon_timer -= delta
		else:
			skele_summon_timer = skele_summon_timer_max
			if((health - 2) > final_stage_health):
				var summoned_skeleton = skeleton_scene.instance()
				var random_rotation = deg2rad(rand_range(0, 360))
				var random_direction = Vector3(0,0,3).rotated(Vector3.UP, random_rotation)
				summoned_skeleton.movement_direction.x = random_direction.x
				summoned_skeleton.movement_direction.z = random_direction.z
				summoned_skeleton.movement_vector.y = 5
				get_tree().root.add_child(summoned_skeleton)
				summoned_skeleton.global_transform.origin = skeleton_spawn_location.global_transform.origin
				_on_Skeleton_hit(2)
	else:
		in_skele_summon_timer = in_skele_summon_timer_max
		skele_summon_timer = skele_summon_timer_max
		fire_eyes_attack_pattern = true
		waiting_for_attack = true

func fire_eye_phase(delta):
	if(in_fire_eyes_timer > 0):
		in_fire_eyes_timer -= delta
		if(fire_eyes_summon_timer > 0):
			fire_eyes_summon_timer -= delta
		else:
			fire_eyes_summon_timer = fire_eyes_summon_timer_max
			var summoned_fire = fire_scene.instance()
			get_tree().root.add_child(summoned_fire)
			summoned_fire.global_transform.origin = fire_spawn_location.global_transform.origin
	else:
		in_fire_eyes_timer = in_fire_eyes_timer_max
		fire_eyes_summon_timer = fire_eyes_summon_timer_max
		fire_eyes_attack_pattern = false
		waiting_for_attack = true

func _on_Skeleton_hit(damage: int):
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
		sprite_origin.scale = Vector3(0.3, 0.3, 0.3) + (Vector3((1.0 * health) / max_health, (1.0 * health) / max_health, 1) * 0.7)
		if(health <= 0):
			global.cutscene_handler.start_cutscene("skeleton_king_death")
			movement_direction = Vector3.ZERO
			dying = true

func resize():
	sprite_origin.scale = Vector3(0.3, 0.3, 0.3) + (Vector3((1.0 * health) / max_health, (1.0 * health) / max_health, 1) * 0.7)

func _ready():
	global.skeleton_king = self
