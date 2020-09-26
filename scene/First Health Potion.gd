tool
extends Spatial

var type = "Pickup"

export(bool) var respawnable = false
var pickupable = true
var cutscene_experienced = false

export(global.pickup_types) var pickup_type = global.pickup_types.health_potion setget set_pickup_type
func set_pickup_type(newPickupType: int):
	pickup_type = newPickupType
	load_image()

var bob_tracker = rand_range(0, 100)

onready var particles_container = $"Particles Container"
var sparkle_particles = preload("res://particles/Sparkle Particles.tscn")

var health_potion_texture = preload("res://textures/health_potion.png")
var health_potion_pickup_sound = preload("res://sound/potion_pickup_sound.wav")

var ammo_texture = preload("res://textures/ammo_pickup.png")
var ammo_pickup_sound = preload("res://sound/ammo_pickup_sound.wav")

var health_upgrade_texture = preload("res://textures/health_upgrade.png")
var health_upgrade_pickup_sound = preload("res://sound/ammo_pickup_sound.wav")

var sword_texture = preload("res://textures/sword.png")
var sword_pickup_sound = preload("res://sound/ammo_pickup_sound.wav")

var crossbow_texture = preload("res://textures/crossbow.png")
var crossbow_pickup_sound = preload("res://sound/ammo_pickup_sound.wav")


onready var sprite = $Sprite3D

func pickup():
	if(!cutscene_experienced):
		global.cutscene_handler.start_cutscene("first_health_potion")
	var sound = AudioStreamPlayer.new()
	var stream
	match pickup_type:
		global.pickup_types.ammo:
			stream = ammo_pickup_sound
		global.pickup_types.health_potion:
			stream = health_potion_pickup_sound
		global.pickup_types.health_upgrade:
			stream = health_upgrade_pickup_sound
		global.pickup_types.sword:
			stream = sword_pickup_sound
		global.pickup_types.crossbow:
			stream = crossbow_pickup_sound
	sound.stream = stream 
	get_tree().root.add_child(sound)
	sound.play(0)
	sound.add_to_group("AudioStreamPlayers")
	pickupable = false
	visible = false

func load_image():
	if(is_inside_tree()):
		if(Engine.editor_hint):
			sprite = $Sprite3D
			particles_container = $"Particles Container"
		
		for particles in particles_container.get_children():
			particles.queue_free()
		
		match pickup_type:
			global.pickup_types.health_potion:
				sprite.texture = health_potion_texture
			global.pickup_types.ammo:
				sprite.texture = ammo_texture
			global.pickup_types.health_upgrade:
				sprite.texture = health_upgrade_texture
				sprite.scale = Vector3.ONE * 2
				var particles = sparkle_particles.instance()
				particles_container.add_child(particles)
			global.pickup_types.sword:
				sprite.texture = sword_texture
			global.pickup_types.crossbow:
				sprite.texture = crossbow_texture

func respawn():
	pickupable = true
	visible = true
	cutscene_experienced = true

# Called when the node enters the scene tree for the first time.
func _ready():
	set_pickup_type(pickup_type)
	if(respawnable and !Engine.editor_hint):
		add_to_group(global.respawnable_group)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	bob_tracker += delta
	if(Engine.editor_hint):
		$Sprite3D.transform.origin.y = sin(bob_tracker) / 20
	else:
		sprite.transform.origin.y = sin(bob_tracker) / 20
	
