extends Spatial

onready var vine_1 = $"Vine Holster/Vine 1"
onready var vine_2 = $"Vine Holster/Vine 2"

export(int) var length = 5
	
func _ready():
	length += (randi() % 4) - 1
	vine_1.region_rect = Rect2(0, 0, 12, length * 14)
	vine_2.region_rect = Rect2(0, 0, 12, length * 14)
	vine_1.transform.origin.y = -(1.5 * (length * 14)) / 100
	vine_2.transform.origin.y = -(1.5 * (length * 14)) / 100
	rotation_degrees.y = rand_range(0, 90)
