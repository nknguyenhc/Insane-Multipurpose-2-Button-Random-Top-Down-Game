extends KinematicBody2D


var game
var UI

const MAX_HEALTH = 100
var health = MAX_HEALTH
var invincibility = false

const MAX_SANITY = 100
var sanity = MAX_SANITY
const SANITY_THRESHOLD = 30
const PROB = 0.6
var rng = RandomNumberGenerator.new()

var disabled_skill_index

var button1 = "button1"
var button2 = "button2"
var listening_switch_skill = false

var skill_powering_up = false
var skill_index = 0
var num_of_skills_attained = 1
const EarthBullet = preload("res://Player/Bullets/EarthBullet.tscn")
var earth_enabled = true
const Fire = preload("res://Player/Bullets/Fire.tscn")
var fire_enabled = true
const Wind = preload("res://Player/Bullets/Wind.tscn")
var wind_enabled = true
var freeze_enabled = true

const stats = {
	earth_damage = 40,
	earth_power_up_damage = 100,
	fire_dpf = 0.1,
	fire_power_up_dpf = 0.17,
	wind_count = 5,
	wind_power_up_count = 8,
	wind_dpf = 0.25,
	wind_power_up_dpf = 0.4,
	freeze_lower_chance = 20,
	freeze_power_up_chance = 40,
	freeze_lower_duration = 1,
	freeze_power_up_duration = 2
}
const changes = {
	"earth_damage": {
		"increment": 5,
		"min": 10,
		"max": 80
	},
	"earth_power_up_damage": {
		"increment": 12
	},
	"fire_dpf": {
		"increment": 0.02,
		"min": 0.03,
		"max": 0.2
	},
	"fire_power_up": {
		"increment": 0.03
	},
	"wind_count": {
		"increment": 1,
		"min": 3,
		"max": 10
	},
	"wind_power_up_count": {
		"increment": 2
	},
	"wind_dpf": {
		"increment": 0.06
	},
	"wind_power_up_dpf": {
		"increment": 0.1
	},
	"freeze_lower_chance": {
		"increment": 2,
		"min": 5,
		"max": 35
	},
	"freeze_power_up_chance": {
		"increment": 4
	},
	"freeze_lower_duration": {
		"increment": 0.1
	},
	"freeze_power_up_duration": {
		"increment": 0.2
	}
}

var freeze_chance
var freeze_duration


func _ready():
	game = get_parent()
	UI = game.get_node("UI")


func _physics_process(delta):
	
	# skills
	if Input.is_action_just_pressed(button1):
		skill_powering_up = true
		if not listening_switch_skill:
			$GeneralTimers/SwitchDetector.start()
			listening_switch_skill = true
		else:
			switch_skill()
	
	if Input.is_action_just_released(button1):
		skill_powering_up = false
	
	if Input.is_action_just_pressed(button2):
		if skill_index == 0:
			Earth_attack()
		elif skill_index == 1:
			Fire_attack()
		elif skill_index == 2:
			Wind_attack()
		elif skill_index == 3:
			Freeze_attack()


func take_damage(damage):
	if not invincibility:
		health -= damage
		invincibility = true
		$GeneralTimers/InvincibilityTimer.start()
		UI.get_node("RightHalf/VBoxContainer/Container/HealthBar/TextureProgress").value = health
		$AnimationPlayer.play("default")
		print(health)


func change_sanity(value):
	if sanity + value <= MAX_SANITY:
		if sanity + value < 0:
			sanity = 0
		else:
			sanity += value
	else:
		sanity = MAX_SANITY
	UI.get_node("RightHalf/VBoxContainer/Container/SanityBar/TextureProgress").value = sanity


func _on_InvincibilityTimer_timeout():
	invincibility = false


func switch_buttons():
	button1 = "button2"
	button2 = "button1"
	if UI.get_node("LeftHalf/HBoxContainer2/VBoxContainer/SwitchKey/Label").text == "Switch":
		UI.get_node("LeftHalf/HBoxContainer2/VBoxContainer/SwitchKey/Label").text = "Action"
		UI.get_node("LeftHalf/HBoxContainer2/VBoxContainer2/ActionKey/Label").text = "Switch"
	else:
		UI.get_node("LeftHalf/HBoxContainer2/VBoxContainer/SwitchKey/Label").text = "Switch"
		UI.get_node("LeftHalf/HBoxContainer2/VBoxContainer2/ActionKey/Label").text = "Action"


func change_background():
	pass


func switch_skill():
	skill_index = (skill_index + 1) % num_of_skills_attained
	$GeneralTimers/SwitchDetector.stop()
	UI.change_element()


func _on_SwitchDetector_timeout():
	listening_switch_skill = false


func acquire_new_skill():
	if num_of_skills_attained < 4:
		num_of_skills_attained += 1


func is_Earth():
	return skill_index == 0


func Earth_attack():
	if earth_enabled:
		print("earth attack!")
		earth_enabled = false
		$SkillTimers/EarthCooldown.start()
		var earth_bullet = EarthBullet.instance()
		earth_bullet.scale = Vector2(5, 5)
		earth_bullet.position = position
		earth_bullet.target = game.nearest_enemy()
		if !skill_powering_up:
			earth_bullet.DAMAGE = stats["earth_damage"]
		else:
			earth_bullet.DAMAGE = stats["earth_power_up_damage"]
		get_parent().add_child(earth_bullet)


func Fire_attack():
	if fire_enabled:
		fire_enabled = false
		$SkillTimers/FireCooldown.start()
		var fire = Fire.instance()
		fire.scale = Vector2(5, 5)
		fire.position = position
		if !skill_powering_up:
			fire.DPF = stats["fire_dpf"]
		else:
			fire.DPF = stats["fire_power_up_dpf"]
		get_parent().add_child(fire)


func Wind_attack():
	if wind_enabled:
		wind_enabled = false
		$SkillTimers/WindCooldown.start()
		var count = stats["wind_count"]
		if skill_powering_up:
			count = stats["wind_power_up_count"]
		for enemy in game.nearest_enemies(count):
			var wind = Wind.instance()
			wind.scale = Vector2(5, 5)
			wind.position = enemy.position
			wind.target = enemy
			if !skill_powering_up:
				wind.DPF = stats["wind_dpf"]
			else:
				wind.DPF = stats["wind_power_up_dpf"]
			get_parent().add_child(wind)


func Freeze_attack():
	if freeze_enabled:
		freeze_enabled = false
		$SkillTimers/FreezeCooldown.start()
		if !skill_powering_up:
			freeze_chance = stats["freeze_lower_chance"]
			freeze_duration = stats["freeze_lower_duration"]
		else:
			freeze_chance = stats["freeze_power_up_chance"]
			freeze_duration = stats["freeze_power_up_duration"]
		for enemy in game.get_node("Enemies").get_children():
			enemy.take_damage(0, "Freeze")


func _on_EarthCooldown_timeout():
	earth_enabled = true


func _on_FireCooldown_timeout():
	fire_enabled = true


func _on_WindCooldown_timeout():
	wind_enabled = true


func _on_FreezeCooldown_timeout():
	freeze_enabled = true


func prob_benchmark():
	return (MAX_SANITY - sanity) / MAX_SANITY * PROB


func flip_skill_state():
	if disabled_skill_index == 0:
		earth_enabled = !earth_enabled
	elif disabled_skill_index == 1:
		fire_enabled = !fire_enabled
	elif disabled_skill_index == 2:
		wind_enabled = !wind_enabled
	elif disabled_skill_index == 3:
		freeze_enabled = !freeze_enabled


func receive_bonus():
	var p = rng.randf()
	var power_up
	if p < prob_benchmark():
		var randint = rng.randf_range(0, 2)
		match randint:
			0: # switch buttons
				switch_buttons()
			1: # disable one skill
				disabled_skill_index = rng.randf_range(0, num_of_skills_attained - 1)
				flip_skill_state()
				$SkillTimers/DisableTimer.start()
			2: # change background
				change_background()
		
		power_up = -1
	else:
		power_up = 1
	
	var randint = rng.randf_range(0, num_of_skills_attained - 1)
	match randint:
		0:
			var new_stats = stats["earth_damage"] + power_up * changes["earth_damage"]["increment"]
			if new_stats >= changes["earth_damage"]["min"] and new_stats <= changes["earth_damage"]["max"]:
				stats["earth_damage"] = new_stats
				stats["earth_power_up_damage"] += power_up * changes["earth_power_up_damage"]["increment"]
		1:
			var new_stats = stats["fire"] + power_up * changes["fire_dpf"]["increment"]
			if new_stats >= changes["fire_dpf"]["min"] and new_stats <= changes["fire_dpf"]["max"]:
				stats["fire_dpf"] = new_stats
				stats["fire_power_up_dpf"] += power_up * changes["fire_power_up_dpf"]["increment"]
		2:
			var new_stats = stats["wind_count"] + power_up * changes["wind_count"]["increment"]
			if new_stats >= changes["wind_count"]["min"] and new_stats <= changes["wind_count"]["max"]:
				stats["wind_count"] = new_stats
				stats["wind_power_up_count"] += power_up * changes["wind_power_up_count"]["increment"]
				stats["wind_dpf"] += power_up * changes["wind_dpf"]["increment"]
				stats["wind_power_up_dpf"] += power_up * changes["wind_power_up_dpf"]["increment"]
		3:
			var new_stats = stats["freeze_lower_chance"] + power_up * changes["freeze_lower_chance"]["increment"]
			if new_stats >= changes["freeze_lower_chance"]["min"] and new_stats <= changes["freeze_lower_chance"]["max"]:
				stats["freeze_lower_chance"] = new_stats
				stats["freeze_power_up_chance"] += power_up * changes["freeze_power_up_chance"]["increment"]
				stats["freeze_lower_duration"] += power_up * changes["freeze_lower_duration"]["increment"]
				stats["freeze_power_up_duration"] += power_up * changes["freeze_power_up_duration"]["increment"]


func _on_DisableTimer_timeout():
	flip_skill_state()
