extends Spatial

export(int) var trigger_id = -1
export(Vector3) var to_position = Vector3.ZERO

var opening = false
var opening_amount = Vector3.ZERO
var movement_tracker = 0

export var door_opening_time = 200

enum opening_sounds {
	stone,
	wood
}

export(opening_sounds) var opening_sound = opening_sounds.stone

var door_opening_audio_stream_player = AudioStreamPlayer.new()
var door_opening_sound
var stone_opening_sound = preload("res://sound/stone_door_opening.wav")
var wood_opening_sound = preload("res://sound/wood_door_opening.wav")

# Called when the node enters the scene tree for the first time.
func _ready():
	if(opening_sound == opening_sounds.stone):
		door_opening_sound = stone_opening_sound
	else:
		door_opening_sound = wood_opening_sound
	
	add_to_group(global.triggerable_group)
	opening_amount = (transform.origin - to_position) / door_opening_time
	door_opening_audio_stream_player.stream = door_opening_sound
	add_child(door_opening_audio_stream_player)


func trigger():
	opening = true
	door_opening_audio_stream_player.play(0)
	
func _process(delta):
	if(opening):
		var distanceToPlayer = global.player.global_transform.origin.distance_to(global_transform.origin)
		movement_tracker += 1
		if(movement_tracker < door_opening_time):
			transform.origin -= opening_amount
			door_opening_audio_stream_player.volume_db = clamp(distanceToPlayer * 2, 1, 80) * -1
		else:
			door_opening_audio_stream_player.volume_db = lerp(door_opening_audio_stream_player.volume_db, -30, 0.1)
			if(door_opening_audio_stream_player.volume_db <= -29):
				door_opening_audio_stream_player.stop()
		
