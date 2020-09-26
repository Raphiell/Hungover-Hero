extends Spatial

func _ready():
	pass

func _process(delta):
	$Pivot.rotate_y(delta)
	
	if(Input.is_action_just_pressed("exit")):
		get_tree().quit()
	
	$Text/RichTextLabel.visible_characters = lerp($Text/RichTextLabel.visible_characters, 50, 0.1)
