extends Spatial

export var checkpoint_id = -1
export var checkpoint_priority = -1

func _ready():
	add_to_group(global.checkpoint_group)
	visible = false

func _on_Area_body_entered(body):
	if(body.get_parent().get("type") == "Player" and checkpoint_priority >= global.current_checkpoint_priority):
		global.current_checkpoint = checkpoint_id
		global.current_checkpoint_priority = checkpoint_priority
