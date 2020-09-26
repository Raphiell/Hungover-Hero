extends Spatial

onready var player_look_location = $"Player Look Location"
onready var spawn_location = $"Skeleton King Spawn Location"

var triggered = false

func _on_Trigger_body_entered(body):
	if(body.get_parent().get("type") == "Player" and !triggered and global.enemies_aggroed):
		player_look_location.look_at(global.player.global_transform.origin - (global.player.global_transform.origin - player_look_location.global_transform.origin) * 2, Vector3.UP)
		global.cutscene_handler.look_direction = player_look_location.rotation
		global.cutscene_handler.start_cutscene("skeleton_king_start")
		global.cutscene_handler.dummy_coordinates = spawn_location.global_transform.origin
		triggered = true
		if(global.player.crossbow_ammo < 30):
			global.player.crossbow_ammo = 30
			global.player.update_ammo(0, 2)
		global.player.boss_ammo_count = global.player.crossbow_ammo
		match global.player.max_health:
			4:
				global.player.health = 4
			6:
				global.player.health = 5
			8:
				global.player.health = 6
		global.player.update_health(0)
