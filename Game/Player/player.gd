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
var sanity_decreasing = false
var sanity_decrease_pf = 0.08
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
const Ice = preload("res://Player/Bullets/Ice.tscn")

var earth_disabled = false
var fire_disabled = false
var wind_disabled = false
var freeze_disabled = false


const stats = {
	earth_damage = 15,
	earth_power_up_damage = 22.5,
	fire_dpf = 0.3,
	fire_power_up_dpf = 0.5,
	wind_count = 5,
	wind_power_up_count = 8,
	wind_dpf = 0.15,
	wind_power_up_dpf = 0.2,
	freeze_lower_chance = 20,
	freeze_power_up_chance = 40,
	freeze_lower_duration = 1,
	freeze_power_up_duration = 2
}
const changes = {
	"earth_damage": {
		"increment": 3,
		"min": 15,
		"max": 30
	},
	"earth_power_up_damage": {
		"increment": 10
	},
	"fire_dpf": {
		"increment": 0.06,
		"min": 0.3,
		"max": 0.6
	},
	"fire_power_up_dpf": {
		"increment": 0.15
	},
	"wind_count": {
		"increment": 1,
		"min": 5,
		"max": 10
	},
	"wind_power_up_count": {
		"increment": 2
	},
	"wind_dpf": {
		"increment": 0.03
	},
	"wind_power_up_dpf": {
		"increment": 0.1
	},
	"freeze_lower_chance": {
		"increment": 4,
		"min": 20,
		"max": 40
	},
	"freeze_power_up_chance": {
		"increment": 10
	},
	"freeze_lower_duration": {
		"increment": 0.1
	},
	"freeze_power_up_duration": {
		"increment": 0.2
	}
}

var freeze_chance = stats["freeze_lower_chance"]
var freeze_duration = stats["freeze_lower_duration"]

var background_changed = false
var bonus_label
var background


func _ready():
	game = get_parent()
	UI = game.get_node("UI")
	bonus_label = get_parent().get_node("UI").get_node("LeftHalf").get_node("HBoxContainer") \
			.get_node("Container").get_node("BonusLabel")
	background = game.get_node("Background/ParallaxBackground/Background")

func _physics_process(delta):
	
	# skills
	if Input.is_action_just_pressed(button1):
		$GeneralTimers/SanityTimer.start()
		skill_powering_up = true
		if not listening_switch_skill:
			$GeneralTimers/SwitchDetector.start()
			listening_switch_skill = true
		else:
			switch_skill()
			listening_switch_skill = false
	
	if Input.is_action_just_released(button1):
		skill_powering_up = false
		sanity_decreasing = false
		$GeneralTimers/SanityTimer.stop()
	
	if sanity_decreasing:
		change_sanity(-sanity_decrease_pf)
	
	if Input.is_action_just_pressed(button2):
		if skill_index == 0:
			Earth_attack()
		elif skill_index == 1:
			Fire_attack()
		elif skill_index == 2:
			Wind_attack()
		elif skill_index == 3:
			Freeze_attack()
	
	if health <= 0:
		get_parent().get_parent().player_die()


func take_damage(damage):
	if not invincibility:
		health = min(health - damage, MAX_HEALTH)
		invincibility = true
		$GeneralTimers/InvincibilityTimer.start()
		UI.get_node("RightHalf/VBoxContainer/Container/HealthBar/TextureProgress").value = health
		if damage > 0: 
			$AnimationPlayer.play("default")
		else:
			$AnimationPlayer.play("recovery")


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
	display_bonus("Buttons have been switched!")
	button1 = "button2"
	button2 = "button1"
	if UI.get_node("LeftHalf/HBoxContainer2/VBoxContainer/SwitchKey/Label").text == "Switch":
		UI.get_node("LeftHalf/HBoxContainer2/VBoxContainer/SwitchKey/Label").text = "Action"
		UI.get_node("LeftHalf/HBoxContainer2/VBoxContainer2/ActionKey/Label").text = "Switch"
	else:
		UI.get_node("LeftHalf/HBoxContainer2/VBoxContainer/SwitchKey/Label").text = "Switch"
		UI.get_node("LeftHalf/HBoxContainer2/VBoxContainer2/ActionKey/Label").text = "Action"


func change_background():
	background_changed = true
	var time = rng.randi_range(10, 20)
	display_bonus("Insanity zone for " + String(time) + " seconds!")
	
	var timer = $GeneralTimers/BackgroundTimer
	var second_fade = $GeneralTimers/SecondFadeTimer
	timer.wait_time = time
	second_fade.wait_time = time - 1
	timer.start()
	second_fade.start()
	$GeneralTimers/InsanityPopUpTimer.start()	
	background.get_node("Fade").play("default")


func switch_skill():
	skill_index = (skill_index + 1) % num_of_skills_attained
	$GeneralTimers/SwitchDetector.stop()
	UI.change_element()


func _on_SwitchDetector_timeout():
	listening_switch_skill = false


func acquire_new_skill():
	if num_of_skills_attained < 4:
		num_of_skills_attained += 1
		UI.add_element()
		skill_index = 0


func is_Earth():
	return skill_index == 0


func Earth_attack():
	if earth_enabled and not earth_disabled:
		earth_enabled = false
		$SkillTimers/EarthCooldown.start()
		var earth_bullet = EarthBullet.instance()
		earth_bullet.scale = Vector2(5, 5)
		earth_bullet.position = position
		earth_bullet.position.x += 130
		earth_bullet.target = game.nearest_enemy()
		if !skill_powering_up:
			earth_bullet.DAMAGE = stats["earth_damage"]
			earth_bullet.get_node("AnimatedSprite").animation = "small"
		else:
			$SkillTimers/EarthCooldown.wait_time = 0.4
			earth_bullet.DAMAGE = stats["earth_power_up_damage"]
			earth_bullet.get_node("AnimatedSprite").animation = "default"
		get_parent().add_child(earth_bullet)


func Fire_attack():
	if fire_enabled and not fire_disabled:
		fire_enabled = false
		$SkillTimers/FireCooldown.start()
		var fire = Fire.instance()
		fire.position = position
		if !skill_powering_up:
			fire.scale = Vector2(1.2, 1.2)
			fire.DPF = stats["fire_dpf"]
		else:
			fire.scale = Vector2(1.5, 1.5)
			fire.DPF = stats["fire_power_up_dpf"]
		get_parent().add_child(fire)


func Wind_attack():
	if wind_enabled and not wind_disabled:
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
	if freeze_enabled and not freeze_disabled:
		freeze_enabled = false
		$SkillTimers/FreezeCooldown.start()
		var ice = Ice.instance()
		ice.scale = Vector2(10, 10)
		ice.position = position
		if !skill_powering_up:
			freeze_chance = stats["freeze_lower_chance"]
			freeze_duration = stats["freeze_lower_duration"]
		else:
			freeze_chance = stats["freeze_power_up_chance"]
			freeze_duration = stats["freeze_power_up_duration"]
		var enemies = game.get_node("Enemies").get_children()
		enemies.remove(0)
		enemies.remove(0)
		enemies.remove(0)
		for enemy in enemies:
			enemy.take_damage(0, "Freeze")
		get_parent().add_child(ice)


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


func flip_skill_state(time):
	if disabled_skill_index == 0:
		earth_disabled = true
		display_bonus("Earth disabled for " + String(time) + " seconds!")
	elif disabled_skill_index == 1:
		fire_disabled = true
		display_bonus("Fire disabled for " + String(time) + " seconds!")
	elif disabled_skill_index == 2:
		wind_disabled = true
		display_bonus("Wind disabled for " + String(time) + " seconds!")
	elif disabled_skill_index == 3:
		freeze_disabled = true
		display_bonus("Freeze disabled for " + String(time) + " seconds!")


func receive_bonus():
	var p = rng.randf()
	var power_up
	if p < prob_benchmark():
		var randint = rng.randi() % 4
		match randint:
			0: # switch buttons
				switch_buttons()
			1: # disable one skill
				disabled_skill_index = rng.randi() % num_of_skills_attained
				var time = rng.randi_range(5, 15)
				$SkillTimers/DisableTimer.wait_time = time
				$SkillTimers/DisableTimer.start()
				flip_skill_state(time)
			2: # change background
				if not background_changed:
					change_background()
				else:
					switch_buttons()
			3: # health regen
				var recovery = rng.randi_range(10, min(MAX_HEALTH - health, 15))
				take_damage(-recovery)
				display_bonus("Health recovered by " + String(recovery) + "!")
					
	else:
		var tt = "up"
		if rng.randi() % 10 < 8:
			power_up = 1
		else:
			power_up = -1
			tt = "down"
	
		var randint = rng.randi() % num_of_skills_attained
		match randint:
			0:
				var new_stats = stats["earth_damage"] + power_up * changes["earth_damage"]["increment"]
				if new_stats >= changes["earth_damage"]["min"] and new_stats <= changes["earth_damage"]["max"]:
					stats["earth_damage"] = new_stats
					stats["earth_power_up_damage"] += power_up * changes["earth_power_up_damage"]["increment"]
				display_bonus("Earth has been powered " + tt + "!")
			1:
				var new_stats = stats["fire_dpf"] + power_up * changes["fire_dpf"]["increment"]
				if new_stats >= changes["fire_dpf"]["min"] and new_stats <= changes["fire_dpf"]["max"]:
					stats["fire_dpf"] = new_stats
					stats["fire_power_up_dpf"] += power_up * changes["fire_power_up_dpf"]["increment"]
				display_bonus("Fire has been powered " + tt + "!")
			2:
				var new_stats = stats["wind_count"] + power_up * changes["wind_count"]["increment"]
				if new_stats >= changes["wind_count"]["min"] and new_stats <= changes["wind_count"]["max"]:
					stats["wind_count"] = new_stats
					stats["wind_power_up_count"] += power_up * changes["wind_power_up_count"]["increment"]
					stats["wind_dpf"] += power_up * changes["wind_dpf"]["increment"]
					stats["wind_power_up_dpf"] += power_up * changes["wind_power_up_dpf"]["increment"]
				display_bonus("Wind has been powered " + tt + "!")
			3:
				var new_stats = stats["freeze_lower_chance"] + power_up * changes["freeze_lower_chance"]["increment"]
				if new_stats >= changes["freeze_lower_chance"]["min"] and new_stats <= changes["freeze_lower_chance"]["max"]:
					stats["freeze_lower_chance"] = new_stats
					stats["freeze_power_up_chance"] += power_up * changes["freeze_power_up_chance"]["increment"]
					stats["freeze_lower_duration"] += power_up * changes["freeze_lower_duration"]["increment"]
					stats["freeze_power_up_duration"] += power_up * changes["freeze_power_up_duration"]["increment"]
				display_bonus("Freeze has been powered " + tt + "!")

func display_bonus(text):
	bonus_label.text = text
	bonus_label.show()
	$GeneralTimers/BonusDisplayTimer.start()

func _on_DisableTimer_timeout():
	earth_disabled = false
	fire_disabled = false
	wind_disabled = false
	freeze_disabled = false


func _on_SanityTimer_timeout():
	sanity_decreasing = true


func _on_BackgroundTimer_timeout():
	background_changed = false
	game.get_node("Background/ParallaxBackground/Background/ColorRect").hide()

func _on_BonusDisplayTimer_timeout():
	bonus_label.hide()


func _on_InsanityPopUpTimer_timeout():
	background.get_node("ColorRect").show()


func _on_SecondFadeTimer_timeout():
	background.get_node("Fade").play("default")
