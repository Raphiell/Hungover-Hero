extends Node

const GRAVITY = 0.2

var player
var skeleton_king
var cutscene_handler
var music

var triggerable_group = "triggerable"
var checkpoint_group = "checkpoints"
var respawnable_group = "respawnables"
var boss_skeleton_group = "boss_skeletons"
var boss_fire_group = "boss_fire"

var spawn_point = Vector3(-0.9, 2, -1.8)

var lock = locks.none

var enemies_aggroed = false

var in_cutscene = false

var current_checkpoint = -1
var current_checkpoint_priority = -1

enum tutorials {
	look,
	move,
	attack,
	switch_weapon
}

enum locks {
	none,
	lock_all,
	lock_look,
	lock_move
}

enum particles {
	none,
	fire,
	ice,
	smoke
}

enum projectile_types {
	bolt,
	magic
}

enum pickup_types {
	health_potion,
	ammo,
	health_upgrade,
	crossbow,
	crossbow_upgrade,
	sword,
	blue_key,
	sword_damage_upgrade,
	cure
}

func _process(delta):
	for audioStreamPlayer in get_tree().get_nodes_in_group("AudioStreamPlayers"):
		if(!audioStreamPlayer.is_playing()):
			audioStreamPlayer.queue_free()
