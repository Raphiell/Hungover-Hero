extends Spatial

var skeleton_scene = preload("res://entity/Skeleton.tscn")
var current_skeleton = null
var spawn_timer_max = 3
var spawn_timer = spawn_timer_max

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false

func _process(delta):
	if(spawn_timer > 0 and !current_skeleton):
		spawn_timer -= delta
	elif(spawn_timer <= 0):
		spawn_timer = spawn_timer_max
		current_skeleton = skeleton_scene.instance()
		current_skeleton.spawner = self
		get_tree().root.add_child(current_skeleton)
		current_skeleton.global_transform.origin = global_transform.origin
