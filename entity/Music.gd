extends Spatial

var skeleton_king_background_music = preload("res://sound/music/skeleton_king_background_sound.wav")
var skeleton_king_battle_music = preload("res://sound/music/skeleton_king_music_start.wav")
var skeleton_king_battle_music_loop = preload("res://sound/music/skeleton_king_music_loop.wav")

onready var audio = $AudioStreamPlayer

var fade_out = false
var fade_in = false
var battle_music = false

func _ready():
	global.music = self

func fade_out():
	fade_out = true

func start_skeleton_king_background_music():
	audio.volume_db = 0
	audio.stream = skeleton_king_background_music
	audio.play(0)

func start_skeleton_king_battle_music():
	audio.volume_db = -80
	audio.stream = skeleton_king_battle_music
	audio.play(0)
	fade_in = true
	battle_music = true

func _process(delta):
	if(fade_out):
		audio.volume_db = lerp(audio.volume_db, -60, 0.05)
		if(audio.volume_db < -45):
			fade_out = false
			battle_music = false
			audio.stop()
	if(fade_in):
		audio.volume_db = lerp(audio.volume_db, 0, 0.1)
		if(audio.volume_db > -2):
			fade_in = false

func _on_AudioStreamPlayer_finished():
	if(battle_music):
		audio.stream = skeleton_king_battle_music_loop
		audio.play(0)
