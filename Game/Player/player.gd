extends KinematicBody2D


var game

const MAX_HEALTH = 100
var health = MAX_HEALTH
var invincibility = false

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
var wind_count = 5
var wind_power_up_count = 15
var freeze_enabled = true


func _ready():
	game = get_parent()


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
	health -= damage
	invincibility = true
	$GeneralTimers/InvincibilityTimer.start()


func _on_InvincibilityTimer_timeout():
	invincibility = false


func switch_button():
	button1 = "button2"
	button2 = "button1"


func switch_skill():
	skill_index = (skill_index + 1) % num_of_skills_attained
	$GeneralTimers/SwitchDetector.stop()


func _on_SwitchDetector_timeout():
	listening_switch_skill = false


func acquire_new_skill():
	if num_of_skills_attained < 4:
		num_of_skills_attained += 1


func is_Earth():
	return skill_index == 0


func Earth_attack():
	if earth_enabled:
		earth_enabled = false
		$SkillTimers/EarthCooldown.start()
		var earth_bullet = EarthBullet.instance()
		earth_bullet.position = position
		earth_bullet.target = game.nearest_enemy()
		if skill_powering_up:
			earth_bullet.power_up()


func Fire_attack():
	if fire_enabled:
		fire_enabled = false
		$SkillTimers/FireCooldown.start()
		var fire = Fire.instance()
		fire.position = position
		if skill_powering_up:
			fire.power_up()


func Wind_attack():
	if wind_enabled:
		wind_enabled = false
		$SkillTimers/WindCooldown.start()
		var count = wind_count
		if skill_powering_up:
			count = wind_power_up_count
		for enemy in game.nearest_enemies(count):
			var wind = Wind.instance()
			wind.position = enemy.position
			wind.target = enemy
			if skill_powering_up:
				wind.power_up()


func Freeze_attack():
	for enemy in game.get_node("Enemies").get_children():
		enemy.take_damage(0, "Freeze")


func _on_EarthCooldown_timeout():
	earth_enabled = true


func _on_FireCooldown_timeout():
	fire_enabled = true


func _on_WindCooldown_timeout():
	wind_enabled = true
