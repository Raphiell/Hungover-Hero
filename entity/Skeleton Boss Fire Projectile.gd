extends Spatial

var movement_direction = Vector3.ZERO
var movement_vector = Vector3.ZERO
var movement_speed = 7
var lifetime = 5

var fire_ignite_sound = preload("res://sound/fire_ignite.wav")
var fire_red_texture = preload("res://textures/skeleton_king_fire.png")
var fire_blue_texture = preload("res://textures/skeleton_king_fire_blue.png")

var boss_mode = true

onready var hitbox = $Hitbox
onready var anim = $AnimationPlayer
onready var body = $KinematicBody

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(global.boss_fire_group)
	anim.play("idle")
	if(global.player):
		var sound = AudioStreamPlayer.new()
		sound.stream = fire_ignite_sound
		sound.pitch_scale = rand_range(0.8, 1.2)
		get_tree().root.add_child(sound)
		var distanceToPlayer = global.player.global_transform.origin.distance_to(global_transform.origin)
		sound.volume_db = clamp(distanceToPlayer / 5, 1, 80) * -1
		sound.play(0)
		sound.add_to_group("AudioStreamPlayers")
	
	if(boss_mode):
		$Sprite3D.texture = fire_blue_texture

func _process(delta):
	if(global.player and boss_mode):
		var playerOrigin = global.player.global_transform.origin + Vector3(0, 0.3, 0)
		var vectorToPlayer = playerOrigin - global_transform.origin
		movement_direction = lerp(movement_direction, vectorToPlayer.normalized(), 0.03)
	
	#movement_vector = movement_direction * movement_speed * delta
	#global_transform.origin += movement_vector
	
	movement_vector = movement_direction * movement_speed
	body.move_and_slide(movement_vector)
	global_transform.origin = body.global_transform.origin
	body.transform.origin = Vector3.ZERO
	
	# Check for player
	for area in hitbox.get_overlapping_areas():
		if(area.get_parent().get("type") == "Player"):
			global.player.emit_signal("hit", 1, global_transform.origin)
			queue_free()
	
	if(lifetime > 0):
		lifetime -= delta
	else:
		queue_free()
