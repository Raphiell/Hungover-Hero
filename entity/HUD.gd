extends Control

# Tutorial
var tutorial_timer_max = 7
var tutorial_timer = 0
var tutorial_opacity = 0

onready var crossbow_ammo_image = preload("res://textures/bolt.png")

onready var health_indicator = $"HUD Container/Health Indicator"
onready var hearts_container = $"HUD Container/Hearts Container"
onready var ammo_count = $"HUD Container/Ammo Count"
onready var ammo_sprite = $"HUD Container/Ammo"
onready var blue_key_sprite = $"HUD Container/Blue Key"
onready var tutorial_sprite = $"HUD Container/Tutorial"

var hearts_texture = preload("res://textures/heart_indicator.png")

var look_tutorial = preload("res://textures/look_tutorial.png")
var move_tutorial = preload("res://textures/move_tutorial.png")
var attack_tutorial = preload("res://textures/attack_tutorial.png")
var switch_weapon_tutorial = preload("res://textures/switch_weapon_tutorial.png")

func _ready():
	pass

func _process(delta):
	if(tutorial_sprite.modulate.a != tutorial_opacity):
		tutorial_sprite.modulate.a = lerp(tutorial_sprite.modulate.a, tutorial_opacity, 0.05)
	
	if(tutorial_timer > 0):
		tutorial_timer -= delta
		if(tutorial_timer <= 0):
			tutorial_opacity = 0

func show_tutorial(tutorialType: int):
	match tutorialType:
		global.tutorials.look:
			tutorial_sprite.texture = look_tutorial
		global.tutorials.move:
			tutorial_sprite.texture = move_tutorial
		global.tutorials.attack:
			tutorial_sprite.texture = attack_tutorial
		global.tutorials.switch_weapon:
			tutorial_sprite.texture = switch_weapon_tutorial
	
	tutorial_timer = tutorial_timer_max
	tutorial_opacity = 1

func update_key(has_key):
	blue_key_sprite.visible = has_key

func update_ammo_image(weaponType: int):
	match weaponType:
		2:
			ammo_sprite.texture = crossbow_ammo_image
		_:
			ammo_sprite.texture = null
			ammo_count.text = ""

func update_ammo_count(newCount: int):
	ammo_count.text = str(newCount)

func update_health(health: int, maxHealth: int):
	if(health != 0):
		health_indicator.frame = (health_indicator.hframes - 1) - ((health_indicator.hframes - 1) * ((1.0 * health) / maxHealth))
	else:
		health_indicator.frame = health_indicator.hframes - 1
	
	var halfHeart = (health % 2)
	var fullHearts = (health / 2)
	
	var maxHearts = maxHealth / 2 + (maxHealth % 2)
	
	# Clear out existing hearts
	for heart in hearts_container.get_children():
		heart.queue_free()
	
	# Redraw
	for i in maxHearts:
		var heart = Sprite.new()
		heart.texture = hearts_texture
		heart.hframes = 3
		heart.vframes = 1
		if(i < fullHearts):
			heart.frame = 2
		elif(halfHeart and i == fullHearts):
			heart.frame = 1
		else:
			heart.frame = 0
		heart.scale = Vector2(2,2)
		hearts_container.add_child(heart)
		if(i < 5):
			heart.position.y = 0
			heart.position.x = -(30 * clamp(maxHearts, 0, 5)) + (i * 30)
		else:
			heart.position.y = 30
			heart.position.x = -(30 * 5) + ((i - 5) * 30)
