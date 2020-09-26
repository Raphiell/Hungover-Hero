extends Control

var current_cutscene = ""
var current_cutscene_pieces = []
var cutscene_playing = false
var cutscene_marker = -1
var currently_waiting = false
var post_audio_wait_seconds = 0
var look_direction = null
var dummy_coordinates = Vector3.ZERO

onready var cutscene_audio = $"Cutscene Audio"
onready var text_container = $Text
onready var text_background = $"Text Background"
onready var camera

# Screen shake
var screen_shake_timer_max = 0
var screen_shake_timer = 0

# Specific to Cutscenes
var skeleton_king = preload("res://entity/Skeleton King.tscn").instance()
var cure = preload("res://entity/Pickup.tscn").instance()

var end_screen_scene = preload("res://scene/End Screen.tscn")

func _ready():
	cutscene_audio.connect("finished", self, "play_cutscene_post_audio")
	text_background.visible = false
	text_container.visible = false
	global.cutscene_handler = self
	camera = global.player.get_node("Camera Base")

# "name" : [
#     [audio to play, time to wait after audio, locks, method to call, text], [audio to play, text], etc...
# ],
# "second cutscene" : [
#     ....
# ]
var cutscenes = {
	"opening" : [
		[null, 2, global.locks.lock_all, null, null],
		["opening_cutscene_audio_1.wav", 1, global.locks.lock_all, null, "Uggghhh"],
		["opening_cutscene_audio_2.wav", 1, global.locks.lock_move, "fade_in", "I don't feel great."],
		["opening_cutscene_audio_3.wav", 1.2, global.locks.lock_move, "show_look_tutorial", "Yesterday was one heck of a party."],
		["opening_cutscene_audio_4.wav", 1.5, global.locks.lock_move, null, "The doctor in town will have something for me, most likely..."],
		["opening_cutscene_audio_5.wav", 1.5, global.locks.lock_move, null, "but until then, I think I left some health juice around here somewhere..."],
		[null, 0.1, global.locks.none, "show_move_tutorial", null]
	],
	"first_health_potion" : [
		[null, 0.7, null, null, null],
		["health_potion_cutscene_audio_1.wav", 1, null, null, "*Drinking Noises*"],
		["health_potion_cutscene_audio_2.wav", 1.5, null, null, "Much better"],
		[null, 0.1, null, null,null]
	],
	"skeleton_king_start" : [
		[null, 1, global.locks.lock_all, "skeleton_king_start", null],
		[null, 1.6, global.locks.lock_all, "skeleton_king_fall", null],
		["skeleton_king_cutscene_audio_1.wav", 1, global.locks.lock_all, "skeleton_king_land", null],
		["skeleton_king_cutscene_audio_2.wav", 0.5, global.locks.lock_all, null, "YOU!"],
		["skeleton_king_cutscene_audio_3.wav", 0.5, global.locks.lock_all, null, "I'VE GOT A BONE TO PICK WITH YOU!"],
		["skeleton_king_cutscene_audio_4.wav", 0.5, global.locks.lock_all, null, "UNPROVOKED AND WITHOUT MERCY, YOU ATTACK MY SKELETONS!"],
		["skeleton_king_cutscene_audio_5.wav", 0.5, global.locks.lock_all, "skeleton_king_fade_out_background_music", "I WILL SEE TO IT THAT YOU MEET YOUR MAKER, VAGABOND!"],
		[null, 0.1, global.locks.none, "skeleton_king_start_fight", null, null]
	],
	"skeleton_king_final_stage": [
		["skeleton_king_final_stage_audio_1.wav", 0.5, global.locks.lock_move, null, "GAH! CURSE YOU!"],
		["skeleton_king_final_stage_audio_2.wav", 0.5, global.locks.lock_move, null, "I SEE WE HAVE TO DO THIS MAN TO SKELETON!... ME SPECIFICALLY!"],
		["skeleton_king_final_stage_audio_3.wav", 0.5, global.locks.lock_move, null, "I WILL WARN YOU THAT I WAS TOP OF MY CLASS IN WRESTLING!"],
		["skeleton_king_final_stage_audio_4.wav", 0.5, global.locks.lock_move, null, "EN GARDE!"],
		[null, 0.01, global.locks.none, "skeleton_king_start_final_stage", ""]
	],
	"skeleton_king_death": [
		["skeleton_king_death_audio_1.wav", 0.5, global.locks.lock_move, "skeleton_king_fade_out_battle_music", "*GRUNT*"],
		["skeleton_king_death_audio_2.wav", 0.5, global.locks.lock_move, null, "CURSE YOU FIEND!"],
		["skeleton_king_death_audio_3.wav", 0.5, global.locks.lock_move, null, "MAY YOUR BONES BE BRITTLE, AND YOUR JOINTS PAINFUL FOREVERMORE!"],
		["skeleton_king_death_audio_4.wav", 1, global.locks.lock_move, "skeleton_king_death_rumble", "UUUURRRRGHHHHHH"], # Screen rumble
		[null, 0.5, global.locks.lock_all, "skeleton_king_die", null]
	],
	"ending": [
		["final_scene_audio_1.wav", 0.5, global.locks.lock_move, null, "Huh look at that, just what I was looking for."],
		["health_potion_cutscene_audio_1.wav", 0.5, global.locks.lock_move, null, "*Drinking Noises*"],
		["final_scene_audio_2.wav", 0.5, global.locks.lock_move, null, "Ahhhhhhhhh..."],
		[null, 1, global.locks.lock_move, "final_fade_out", null],
		[null, 1, global.locks.lock_move, "end_screen", null]
	]
}

func start_cutscene(cutscene: String):
	current_cutscene = cutscene
	current_cutscene_pieces = cutscenes.get(current_cutscene)
	cutscene_playing = true
	cutscene_marker = 0
	play_cutscene_pre_audio()
	global.in_cutscene = true

func play_cutscene_pre_audio():
	# Get the current scene
	var current_scene = current_cutscene_pieces[cutscene_marker]
	
	# Call any methods
	if(current_scene[3]):
		call(current_scene[3])
	
	# Setup any locks
	if(current_scene[2]):
		global.lock = current_scene[2]
	else:
		global.lock = global.locks.none
	
	# Display any text
	if(current_scene[4]):
		text_container.visible = true
		text_background.visible = true
		text_container.text = current_scene[4]
		text_container.visible_characters = 0
	else:
		text_container.visible = false
		text_background.visible = false
	
	# Play any audio
	if(current_scene[0]):
		cutscene_audio.stream = load("res://sound/cutscene/" + current_cutscene_pieces[cutscene_marker][0])
		cutscene_audio.play(0)
	else:
		play_cutscene_post_audio()

func play_cutscene_post_audio():
	post_audio_wait_seconds = current_cutscene_pieces[cutscene_marker][1]
	currently_waiting = true

func progress_cutscene():
	cutscene_marker += 1
	if(cutscene_marker < current_cutscene_pieces.size()):
		play_cutscene_pre_audio()
	else:
		global.lock = global.locks.none
		global.in_cutscene = false

func _process(delta):
	if(post_audio_wait_seconds > 0 and currently_waiting):
		post_audio_wait_seconds -= delta
	elif(post_audio_wait_seconds <= 0 and currently_waiting):
		currently_waiting = false
		progress_cutscene()
	if(text_container.text.length() > 0 and text_container.visible_characters != text_container.text.length()):
		text_container.visible_characters += 1
	if(look_direction):
		camera.rotation.x = lerp_angle(camera.rotation.x, look_direction.x, 0.1)
		global.player.rotation.y = lerp_angle(global.player.rotation.y, look_direction.y, 0.1)
	if(screen_shake_timer > 0 and screen_shake_timer_max > 0):
		screen_shake_timer -= delta
		var camera = global.player.get_node("Camera Base/Camera") as Camera
		camera.transform.origin.x = rand_range(-0.5, 0.5) * (screen_shake_timer / screen_shake_timer_max)
		camera.transform.origin.y = rand_range(-0.5, 0.5) * (screen_shake_timer / screen_shake_timer_max)
	elif(screen_shake_timer <= 0 and screen_shake_timer_max > 0):
		screen_shake_timer_max = 0 
		camera.transform.origin.x = 0
		camera.transform.origin.z = 0

func show_look_tutorial():
	global.player.get_node("HUD").show_tutorial(global.tutorials.look)

func show_move_tutorial():
	global.player.get_node("HUD").show_tutorial(global.tutorials.move)

func show_attack_tutorial():
	global.player.get_node("HUD").show_tutorial(global.tutorials.attack)

func show_switch_weapon_tutorial():
	global.player.get_node("HUD").show_tutorial(global.tutorials.switch_weapon)

func fade_in():
	global.player.get_node("Fade/AnimationPlayer").play("Fade In")

func skeleton_king_start():
	global.music.start_skeleton_king_background_music()
	for entity in get_tree().get_nodes_in_group(global.triggerable_group):
		if(entity.get("trigger_id") == 998):
			entity.trigger()

func skeleton_king_fall():
	look_direction = null
	get_tree().root.get_node("World").add_child(skeleton_king)
	skeleton_king.global_transform.origin = dummy_coordinates
	dummy_coordinates = Vector3.ZERO

func skeleton_king_land():
	screen_shake_timer_max = 0.75
	screen_shake_timer = screen_shake_timer_max

func skeleton_king_start_fight():
	skeleton_king.in_combat = true
	global.music.start_skeleton_king_battle_music()

func skeleton_king_start_final_stage():
	skeleton_king.final_stage = true

func skeleton_king_death_rumble():
	screen_shake_timer_max = 2.7
	screen_shake_timer = screen_shake_timer_max

func skeleton_king_die():
	for entity in get_tree().get_nodes_in_group(global.triggerable_group):
		if(entity.get("trigger_id") == 999):
			entity.trigger()
	get_tree().root.get_node("World").add_child(cure)
	cure.pickup_type = global.pickup_types.cure
	cure.global_transform.origin = skeleton_king.global_transform.origin
	skeleton_king.queue_free()

func skeleton_king_fade_out_background_music():
	global.music.fade_out()

func skeleton_king_fade_out_battle_music():
	global.music.fade_out()
	
func final_fade_out():
	global.player.get_node("Fade/AnimationPlayer").play("Fade Out")
	
func end_screen():
	get_tree().change_scene_to(end_screen_scene)
