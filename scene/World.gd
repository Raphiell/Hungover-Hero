extends Spatial

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in $QodotMap.get_children():
		if(child is StaticBody):
			child.collision_layer = 524291
