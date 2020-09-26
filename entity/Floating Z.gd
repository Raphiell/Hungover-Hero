extends Spatial

export var time_until_start = 0
var time_tracker = 0
var time_until_disappear = 5

onready var sprite = $Sprite3D

func _ready():
	visible = false

func _process(delta):
	if(time_until_start > 0):
		time_until_start -= delta
	else:
		visible = true
		if(Engine.editor_hint):
			sprite = $Sprite3D
		time_tracker += delta
		sprite.offset.x = sin(time_tracker) * 10
		sprite.offset.y += delta * 5
		
		time_until_disappear -= delta
		if(time_until_disappear <= 0):
			sprite.offset.y = 0
			time_until_disappear = 5
