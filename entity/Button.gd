extends Spatial

export var button_id = -1

var type = "Button"

var pressed = false

signal press

var button_sound = preload("res://sound/button_press.wav")

onready var sprite = $Sprite3D

func _on_Button_press():
	if(!pressed):
		pressed = true
		sprite.frame = 1
		for entity in get_tree().get_nodes_in_group(global.triggerable_group):
			if(entity.get("trigger_id") == button_id):
				var sound = AudioStreamPlayer.new()
				sound.stream = button_sound
				get_tree().root.add_child(sound)
				var distanceToPlayer = global.player.global_transform.origin.distance_to(global_transform.origin)
				sound.volume_db = clamp(distanceToPlayer * 2, 1, 80) * -1
				sound.play(0)
				sound.add_to_group("AudioStreamPlayers")
				entity.trigger()
