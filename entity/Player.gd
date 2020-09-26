extends Spatial

export var skip_opening = false

var type = "Player"

# Movement
var movement_vector = Vector3.ZERO
var movement_speed = 5
var jump_strength = 4
var on_floor = false
var on_ladder = false
var jump_grace_period_timer = 0
var jump_grace_period_timer_max = 0.2

# Footstep sounds
var footstep_timer = 0
var footstep_timer_max = 0.6
var footstep_sounds = [
	preload("res://sound/footstep_1.wav"),
	preload("res://sound/footstep_2.wav"),
	preload("res://sound/footstep_3.wav"),
	preload("res://sound/footstep_4.wav")
]

# Looking
var vertical_sensitivity = 0.3
var horizontal_sensitivity = 0.4

# Weapon
enum weapons {
	none,
	sword,
	crossbow
}
export var current_weapon = weapons.none
var weapon_bob_tracker = 0
var original_weapon_position = Vector3.ZERO

var boss_ammo_count = 0

var sword_texture = preload("res://textures/sword.png")
var sword_upgraded_texture = preload("res://textures/sword_upgraded.png")
var sword_cooldown_timer_max = 0.25
var sword_cooldown_timer = 0
var sword_power = 1
var sword_animation_position_tracker = Vector3.ZERO
var sword_sound = preload("res://sound/sword_swing.wav")

var crossbow_texture = preload("res://textures/crossbow.png")
var crossbow_upgraded_texture = preload("res://textures/crossbow_upgraded.png")
var projectile = preload("res://entity/Projectile.tscn")
var crossbow_cooldown_timer_max = 0.6
var crossbow_cooldown_timer = 0
var max_crossbow_ammo = 120
var crossbow_ammo = 5
var crossbow_sound = preload("res://sound/crossbow_sound.wav")
var crossbow_power = 1

# Health
var max_health = 4
var health = max_health - 1
var hit_timer = 0
var hit_timer_max = 1
var player_hit_sound = preload("res://sound/player_hit.wav")

# Unlocks
var sword_unlocked = false
var crossbow_unlocked = false
var high_jump_unlocked = false
var climbing_gloves_unlocked = false
var magical_dynamite_unlocked = false

# Keys
export var has_blue_key = false
var has_red_key = false
var has_yellow_key = false

# Nodes
onready var body = $KinematicBody
onready var cast = $RayCast
onready var camera_base = $"Camera Base"
onready var weapon_sprite = $"Camera Base/Camera/Weapon Container/Weapon"
onready var weapon_container = $"Camera Base/Camera/Weapon Container"
onready var weapon_animator = $"Camera Base/Camera/Weapon Container/Weapon/AnimationPlayer"
onready var projectile_origin = $"Camera Base/Camera/Projectile Origin"
onready var reticle = $Reticle
onready var hitbox = $Hitbox
onready var hud = $HUD
onready var sword_hitbox = $"Camera Base/Camera/Sword Hitbox"
onready var fade = $Fade/AnimationPlayer

# Signals
signal hit
signal big_hit

func _ready():
	global.player = self
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Move Reticle to position
	original_weapon_position = weapon_sprite.transform.origin
	reticle.set_position((get_viewport().size / 2) - reticle.rect_size / 2)
	hud.update_health(health, max_health)
	hud.update_ammo_count(crossbow_ammo)
	
	update_weapon(current_weapon)
	hud.update_key(has_blue_key)
	
	if(!skip_opening):
		$Fade.modulate.a = 1
		call_deferred("start_opening_cutscene")
	else:
		fade.play("Fade In")

func start_opening_cutscene():
	global.cutscene_handler.start_cutscene("opening")

func _physics_process(delta):
	# Hit Timer
	if(hit_timer > 0):
		hit_timer -= delta
	
	# Jump Grace period
	if(!on_floor and jump_grace_period_timer > 0):
		jump_grace_period_timer -= delta
		
	# Check if on floor
	cast.force_raycast_update()
	if(cast.is_colliding()):
		on_floor = true
		movement_vector.y = -0.01
		jump_grace_period_timer = jump_grace_period_timer_max
	else:
		on_floor = false
	
	# Get movement Input
	var movementDirection: Vector3 = Vector3.ZERO
	
	if(global.lock != global.locks.lock_move and global.lock != global.locks.lock_all):
		if(Input.is_action_pressed("left")):
			movementDirection += Vector3.LEFT
		if(Input.is_action_pressed("right")):
			movementDirection += Vector3.RIGHT
		if(Input.is_action_pressed("forward")):
			movementDirection += Vector3.FORWARD
		if(Input.is_action_pressed("back")):
			movementDirection += Vector3.BACK
		if(Input.is_action_just_pressed("jump") and jump_grace_period_timer > 0):
			jump_grace_period_timer = 0
			movement_vector.y = jump_strength
	
	# Apply Movement to movement_vector
	if(on_ladder):
		movement_vector = movementDirection.normalized().rotated(Vector3.RIGHT, camera_base.rotation.x).rotated(Vector3.UP, rotation.y) * movement_speed / 2
		if(Input.is_action_pressed("jump") and global.lock != global.locks.lock_move and global.lock != global.locks.lock_all):
			movement_vector.y = movement_speed / 2
	else:
		var old_y = movement_vector.y
		movement_vector = lerp(movement_vector, movementDirection.normalized().rotated(Vector3.UP, rotation.y) * movement_speed, 0.1)
		
		# Gravity
		movement_vector.y = old_y - global.GRAVITY
	
	body.move_and_slide(movement_vector)
	global_transform.origin = body.global_transform.origin
	body.transform.origin = Vector3.ZERO
	
	# Footstep sounds
	var percentOfMaxMovement =  Vector3(movement_vector.x, 0, movement_vector.z).length() / movement_speed
	if(percentOfMaxMovement > 0 and on_floor):
		footstep_timer += delta * percentOfMaxMovement
		if(footstep_timer >= footstep_timer_max):
			footstep_timer = 0
			var sound = AudioStreamPlayer.new()
			sound.stream = footstep_sounds[randi() % footstep_sounds.size()]
			add_child(sound)
			sound.volume_db = -20
			sound.play(0)
			sound.add_to_group("AudioStreamPlayers")
	
	# Bob Weapon Sprite
	if(movementDirection.length() > 0.1):
		weapon_bob_tracker += delta
		weapon_sprite.transform.origin.y = original_weapon_position.y + sin(weapon_bob_tracker * 10) / 50
		weapon_sprite.transform.origin.x = original_weapon_position.x + sin(weapon_bob_tracker * 5) / 50
	else:
		weapon_bob_tracker = 0
		weapon_sprite.transform.origin.y = lerp(weapon_sprite.transform.origin.y, original_weapon_position.y, 0.2)
		weapon_sprite.transform.origin.x = lerp(weapon_sprite.transform.origin.x, original_weapon_position.x, 0.2)
	
	# Attacking
	if(crossbow_cooldown_timer > 0):
		crossbow_cooldown_timer -= delta
	if(sword_cooldown_timer > 0):
		sword_cooldown_timer -= delta
	if(Input.is_action_pressed("click") and global.lock == global.locks.none):
		match current_weapon:
			weapons.sword:
				if(sword_cooldown_timer <= 0):
					sword_cooldown_timer = sword_cooldown_timer_max
					weapon_animator.play("Attack")
					var sound = AudioStreamPlayer.new()
					sound.stream = sword_sound
					add_child(sound)
					sound.pitch_scale = rand_range(0.9, 1.1)
					sound.volume_db = -1
					sound.play(0)
					sound.add_to_group("AudioStreamPlayers")
					for area in sword_hitbox.get_overlapping_areas():
						if(area.get_parent().get("type") == "Enemy"):
							area.get_parent().emit_signal("hit", sword_power)
						elif(area.get_parent().get("type") == "Button"):
							area.get_parent().emit_signal("press")
			weapons.crossbow:
				if(crossbow_cooldown_timer <= 0 and crossbow_ammo > 0):
					update_ammo(-1, weapons.crossbow)
					var facing = Vector3.FORWARD.rotated(Vector3.RIGHT, camera_base.rotation.x).rotated(Vector3.UP, rotation.y)
					var newProjectile = projectile.instance()
					get_parent().add_child(newProjectile)
					newProjectile.prepare(projectile_origin.global_transform.origin, facing, 0.5, global.particles.none, global.projectile_types.bolt, crossbow_power)
					crossbow_cooldown_timer = crossbow_cooldown_timer_max
					var sound = AudioStreamPlayer.new()
					sound.stream = crossbow_sound
					add_child(sound)
					sound.pitch_scale = rand_range(0.9, 1.1)
					sound.volume_db = -10
					sound.play(0)
					sound.add_to_group("AudioStreamPlayers")
	
	# Weapon Switching
	if(Input.is_action_just_released("switch_weapon") and global.lock == global.locks.none):
		if(sword_unlocked and crossbow_unlocked):
			if(current_weapon == weapons.crossbow):
				update_weapon(weapons.sword)
			else:
				update_weapon(weapons.crossbow)
	
	# Check collisions
	on_ladder = false
	for area in hitbox.get_overlapping_areas():
		if(area.get_parent().get("type") == "Ladder"):
			on_ladder = true
		if(area.get_parent().get("type") == "Pickup"):
			var pickupType = area.get_parent().pickup_type
			if(area.get_parent().pickupable):
				match pickupType:
					global.pickup_types.health_potion:
						if(health < max_health):
							update_health(1)
							area.get_parent().pickup()
					global.pickup_types.ammo:
						if(crossbow_ammo < max_crossbow_ammo):
							update_ammo(10, weapons.crossbow)
							area.get_parent().pickup()
					global.pickup_types.health_upgrade:
						max_health += 2
						area.get_parent().pickup()
						update_health(99)
					global.pickup_types.sword:
						sword_unlocked = true
						update_weapon(weapons.sword)
						area.get_parent().pickup()
						hud.show_tutorial(global.tutorials.attack)
					global.pickup_types.crossbow:
						crossbow_unlocked = true
						update_weapon(weapons.crossbow)
						area.get_parent().pickup()
						hud.show_tutorial(global.tutorials.switch_weapon)
					global.pickup_types.blue_key:
						has_blue_key = true
						area.get_parent().pickup()
						hud.update_key(has_blue_key)
					global.pickup_types.sword_damage_upgrade:
						sword_power += 1
						area.get_parent().pickup()
						sword_texture = sword_upgraded_texture
						update_weapon(weapons.sword)
					global.pickup_types.crossbow_upgrade:
						crossbow_power += 1
						area.get_parent().pickup()
						crossbow_texture = crossbow_upgraded_texture
						update_weapon(weapons.crossbow)
						crossbow_cooldown_timer_max = 0.3
					global.pickup_types.cure:
						area.get_parent().pickup()
						global.cutscene_handler.start_cutscene("ending")

func _input(event: InputEvent) -> void:
	# Check if mouse is locked
	if(Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Mouse Look
	if(event is InputEventMouseMotion and global.lock != global.locks.lock_look and global.lock != global.locks.lock_all):
		# Vertical Looking
		camera_base.rotation.x  = clamp(
			camera_base.rotation.x - (event.relative.y / 100) * vertical_sensitivity,
			-PI / 2,
			PI / 2)
		
		# Rotate the player horizontally (y-axis)
		rotation.y -= (event.relative.x / 100) * horizontal_sensitivity
	elif(event is InputEventKey):
		if(Input.is_action_just_pressed("exit")):
			get_tree().quit()

func update_weapon(newWeapon: int):
	current_weapon = newWeapon
	match newWeapon:
		weapons.none:
			weapon_sprite.texture = null
			hud.update_ammo_image(weapons.none)
		weapons.sword:
			weapon_sprite.rotation_degrees.z = 45
			weapon_sprite.texture = sword_texture
			hud.update_ammo_image(weapons.sword)
		weapons.crossbow:
			weapon_sprite.rotation_degrees.z = 0
			weapon_sprite.texture = crossbow_texture
			hud.update_ammo_image(weapons.crossbow)
			hud.update_ammo_count(crossbow_ammo)

func update_health(change: int):
	health = clamp(health + change, 0, max_health)
	if(health >= 0):
		hud.update_health(health, max_health)
	if(health == 0):
		global.lock = global.locks.lock_all
		fade.play("Death Fade Out")
		hit_timer = 2

func update_ammo(change: int, weaponType: int):
	match weaponType:
		weapons.crossbow:
			crossbow_ammo = clamp(crossbow_ammo + change, 0, max_crossbow_ammo)
			if(current_weapon == weapons.crossbow):
				hud.update_ammo_count(crossbow_ammo)

func _on_Player_hit(damage, from):
	if(hit_timer <= 0 and health > 0 and !global.in_cutscene):
		movement_vector = (global_transform.origin - from).normalized() * 5
		hit_timer = hit_timer_max
		update_health(-damage)
		var sound = AudioStreamPlayer.new()
		sound.stream = player_hit_sound
		add_child(sound)
		sound.pitch_scale = rand_range(0.9, 1.1)
		sound.volume_db = -10
		sound.play(0)
		sound.add_to_group("AudioStreamPlayers")

func _on_AnimationPlayer_animation_finished(anim_name):
	if(anim_name == "Death Fade Out"):
		fade.play("Fade In")
		global.lock = global.locks.none
		if(global.current_checkpoint == -1):
			transform.origin = global.spawn_point
			rotation.y = deg2rad(-180)
			camera_base.rotation.x = 0
		else:
			for checkpoint in get_tree().get_nodes_in_group(global.checkpoint_group):
				if(checkpoint.checkpoint_id == global.current_checkpoint):
					global_transform.origin = checkpoint.global_transform.origin
					rotation.y = checkpoint.rotation.y
					# Boss Checkpoint
					if(global.current_checkpoint == 999):
						global.skeleton_king.kill_minions()
						global.skeleton_king.health = global.skeleton_king.max_health
						global.skeleton_king.resize()
						match max_health:
							4:
								update_health(4)
							6:
								update_health(5)
							8:
								update_health(6)
						crossbow_ammo = boss_ammo_count
						update_ammo(0, weapons.crossbow)
					else:
						update_health(2)
					break
		for pickup in get_tree().get_nodes_in_group(global.respawnable_group):
			pickup.respawn()

func _on_Player_big_hit(damage, from):
	if(!global.in_cutscene):
		movement_vector = (global_transform.origin - from).normalized() * 10
		movement_vector.y = 6
		global_transform.origin.y += 0.25
		on_floor = false
		hit_timer = hit_timer_max
		update_health(-damage)
		var sound = AudioStreamPlayer.new()
		sound.stream = player_hit_sound
		add_child(sound)
		sound.pitch_scale = rand_range(0.9, 1.1)
		sound.volume_db = 0
		sound.play(0)
		sound.add_to_group("AudioStreamPlayers")
