extends Node

const MIN_X = 20
const MAX_X = 1000
const MIN_Y = 20
const MAX_Y = 550

var Fiery = preload("res://Enemies/Fiery.tscn")
var Icy = preload("res://Enemies/Icy.tscn")
var Sandy = preload("res://Enemies/Sandy.tscn")
var Woody = preload("res://Enemies/Woody.tscn")
var FieryBoss = preload("res://Enemies/FieryBoss.tscn")
var SandyBoss = preload("res://Enemies/SandyBoss.tscn")
var WoodyBoss = preload("res://Enemies/Woody.tscn")
var Terror = preload("res://Enemies/TerrorDragon.tscn")
var enemy
var Enemies = {
	0: Woody,
	1: Fiery,
	2: Sandy,
	3: Icy
}
var variant = "normal"
var Level_Variant = {
	0: "normal",
	1: "babies",
	2: "adults",
	3: "woody",
	4: "fiery",
	5: "sandy",
	6: "icy"
}
var Bosses = {
	0: FieryBoss,
	1: SandyBoss,
	2: WoodyBoss
}
var level = 1 # 1 - infinity
var curr_flock_size
var enemy_index
var rng = RandomNumberGenerator.new()
var num_of_timer_childs = 3
var bossfight_countdown = 3
var prev_flock_finished = true

func _process(delta):
	# All enemies are dead
	if prev_flock_finished && get_child_count() == num_of_timer_childs:
		prev_flock_finished = false
		if level >= 4 and bossfight_countdown <= 0:
			bossfight_countdown = 3
			summon_boss()
		else:
			if level >= 4:
				variant = Level_Variant[randi() % 7]
			if(rng.randi() % 2 == 0): 
				bossfight_countdown -= 1
			$FlockTimer.start()


func _on_FlockTimer_timeout():
	# current flock starts
	enemy_index = 0
	curr_flock_size = rng.randf_range(5, max(5, 2 * level)) # 5 - 2 * level
	$EnemyTimer.wait_time = rng.randf_range(0.1, max(6 * pow(1.4, -level), 1))
	$EnemyTimer.start()

func _on_EnemyTimer_timeout():
	summon_a_small_monster()
	enemy_index += 1
	if enemy_index < curr_flock_size:
		$EnemyTimer.wait_time = rng.randf_range(0.1, max(6 * pow(1.4, -level), 1))
		$EnemyTimer.start()
	else:
		prev_flock_finished = true
		
func _on_TerrorTimer_timeout():
	if $"../Player".sanity < $"../Player".SANITY_THRESHOLD:
		var terror = Terror.instance()
		var pos_list = randomise_init_pos()
		terror.position.x = pos_list[0]
		terror.position.y = pos_list[1]
		terror.scale = Vector2(3,3)
		add_child(terror)

func summon_a_small_monster():
	match variant:
		"normal":
			enemy = Enemies[rng.randi() % min(level, 4)].instance()
			if rng.randi() % 2 == 1:
				enemy.size = enemy.Size.small
			else:
				enemy.size = enemy.Size.big
		"babies":
			enemy = Enemies[rng.randi() % 4].instance()
			if rng.randi() % 10 < 8:
				enemy.size = enemy.Size.small
			else:
				enemy.size = enemy.Size.big
		"adults":
			enemy = Enemies[rng.randi() % 4].instance()
			if rng.randi() % 10 < 8:
				enemy.size = enemy.Size.big
			else:
				enemy.size = enemy.Size.small
		"woody":
			enemy = Enemies[rng.randi() % 4].instance()
			if rng.randi() % 10 < 8:
				enemy = Woody.instance()
			if rng.randi() % 2 == 1:
				enemy.size = enemy.Size.small
			else:
				enemy.size = enemy.Size.big
		"fiery":
			enemy = Enemies[rng.randi() % 4].instance()
			if rng.randi() % 10 < 8:
				enemy = Fiery.instance()
			if rng.randi() % 2 == 1:
				enemy.size = enemy.Size.small
			else:
				enemy.size = enemy.Size.big
		"sandy":
			enemy = Enemies[rng.randi() % 4].instance()
			if rng.randi() % 10 < 8:
				enemy = Sandy.instance()
			if rng.randi() % 2 == 1:
				enemy.size = enemy.Size.small
			else:
				enemy.size = enemy.Size.big
		"icy":
			enemy = Enemies[rng.randi() % 4].instance()
			if rng.randi() % 10 < 8:
				enemy = Icy.instance()
			if rng.randi() % 2 == 1:
				enemy.size = enemy.Size.small
			else:
				enemy.size = enemy.Size.big
	var pos_list = randomise_init_pos()
	enemy.position.x = pos_list[0]
	enemy.position.y = pos_list[1]
	enemy.scale = Vector2(3,3)
	add_child(enemy)

func summon_boss():
	enemy = Bosses[rng.randi() % 3].instance()
	var pos_list = randomise_init_pos()
	enemy.position.x = pos_list[0]
	enemy.position.y = pos_list[1]
	enemy.scale = Vector2(3,3)
	add_child(enemy)
	
func randomise_init_pos():
	var x
	var y
	var x_deviation = rng.randi() % 20;
	var y_deviation = rng.randi() % 20;
	var n = rng.randi() % 4
	match n:
		0:
			x = MAX_X + x_deviation
			y = MAX_X + y_deviation
		1:
			x = MAX_X + x_deviation
			y = MIN_Y - y_deviation
		2:
			x = MIN_X - x_deviation
			y = MAX_X + y_deviation
		3:
			x = MIN_X - x_deviation
			y = MIN_Y - y_deviation
	return [x, y]

func change_level():
	level += 1
	print(level)
	print(variant)

