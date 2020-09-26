extends Spatial

var z_spawn_timer = 0
var z_spawn_timer_max = 0.2

var z_texture = preload("res://textures/z.png")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(z_spawn_timer > 0):
		z_spawn_timer -= delta
	else:
		z_spawn_timer = z_spawn_timer_max
		var z_sprite = Sprite3D.new()
		z_sprite.texture = z_texture
		z_sprite.billboard = SpatialMaterial.BILLBOARD_FIXED_Y
