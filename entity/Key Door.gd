extends Spatial

enum key_types {
	blue,
	red,
	yellow
}

export(key_types) var key_type = key_types.blue
export(Vector3) var to_position = Vector3.ZERO

var opening = false
var opening_amount = Vector3.ZERO
var movement_tracker = 0

export var door_opening_time = 200

var door_opening_audio_stream_player = AudioStreamPlayer.new()
var door_opening_sound = preload("res://sound/stone_door_opening.wav")
var lock_open_sound = preload("res://sound/lock_open.wav")

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(global.triggerable_group)
	opening_amount = (transform.origin - to_position) / door_opening_time
	door_opening_audio_stream_player.stream = door_opening_sound
	add_child(door_opening_audio_stream_player)

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

func _on_Area_area_entered(area):
	if(area.get_parent().get("type") == "Player" and !opening):
		match key_type:
			key_types.blue:
				if(global.player.has_blue_key):
					opening = true
					door_opening_audio_stream_player.play(0)
					var sound = AudioStreamPlayer.new()
					sound.stream = lock_open_sound
					sound.pitch_scale = rand_range(0.8, 1.2)
					get_tree().root.add_child(sound)
					var distanceToPlayer = global.player.global_transform.origin.distance_to(global_transform.origin)
					sound.volume_db = clamp(distanceToPlayer / 2, 1, 80) * -1
					sound.play(0)
					sound.add_to_group("AudioStreamPlayers")
			key_types.red:
				if(global.player.has_red_key):
					opening = true
					door_opening_audio_stream_player.play(0)
			key_types.yellow:
				if(global.player.has_yellow_key):
					opening = true
					door_opening_audio_stream_player.play(0)
		global.player.hud.update_key(false)
