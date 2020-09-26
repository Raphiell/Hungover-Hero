extends Area

func _on_Killzone_area_entered(area):
	if(area.get_parent().get("type") == "Player"):
		global.player.emit_signal("hit", 999, global.player.global_transform.origin)
