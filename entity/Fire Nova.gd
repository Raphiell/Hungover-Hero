extends Spatial

var tracker = 0

var fire_texture = preload("res://textures/skeleton_king_fire.png")
var fire_nova_sound = preload("res://sound/nova_sound.wav")

func _process(delta):
	tracker += delta
	$"Wave Container".scale += Vector3(0.2, 0.2, 0.2)
	if(tracker >= 2):
		queue_free()

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(0, 15):
		create_fire(cos(i / 2.5), sin(i / 2.5))
	if(global.player):
		var sound = AudioStreamPlayer.new()
		sound.stream = fire_nova_sound
		sound.pitch_scale = rand_range(0.8, 1.2)
		get_tree().root.add_child(sound)
		var distanceToPlayer = global.player.global_transform.origin.distance_to(global_transform.origin)
		sound.volume_db = clamp(distanceToPlayer / 10, 1, 80) * -1
		sound.play(0)
		sound.add_to_group("AudioStreamPlayers")

func create_fire(x, z):
	var sprite = Sprite3D.new()
	sprite.texture = fire_texture
	sprite.billboard = SpatialMaterial.BILLBOARD_FIXED_Y
	sprite.transparent = true
	sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_OPAQUE_PREPASS
	sprite.hframes = 2
	$"Wave Container".add_child(sprite)
	sprite.transform.origin = Vector3(x / 5, 0, z / 5)
