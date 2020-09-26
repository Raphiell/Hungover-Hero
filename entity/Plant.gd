extends Spatial

var plant_textures = [
	preload("res://textures/plant_1.png"),
	preload("res://textures/plant_2.png"),
	preload("res://textures/plant_3.png")
]

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite3D.texture = plant_textures[randi() % plant_textures.size()]
	$Sprite3D.pixel_size = rand_range(0.04, 0.06)
	if(randi() % 100 == 99):
		$Sprite3D.pixel_size = 0.1
	
	if(randi() % 2 == 1):
		queue_free()
	
	global_transform.origin += Vector3(rand_range(-0.1, 0.1), 0, rand_range(-0.1, 0.1))
