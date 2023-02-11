extends Node

var Fiery = preload("res://Enemies/Fiery.tscn")
var Icy = preload("res://Enemies/Icy.tscn")
var Sandy = preload("res://Enemies/Sandy.tscn")
var Woody = preload("res://Enemies/Woody.tscn")
var enemy
var Enemies = {
	0: Fiery,
	1: Icy,
	2: Sandy,
	3: Woody
}

var num_of_enemy_in_each_flock
var enemy_index = 0
var rng = RandomNumberGenerator.new()
var num_of_timer_childs = 1

func _process(delta):
	# All enemies are dead
	if get_child_count() == num_of_timer_childs:
		$FlockTimer.start()


func _on_FlockTimer_timeout():
	num_of_enemy_in_each_flock = 2 + (rng.randi() % 3)
	while (enemy_index < num_of_enemy_in_each_flock):
		summon_a_small_monster()


func summon_a_small_monster():
	enemy = Enemies[rng.randi() % 4].instance()
	enemy.size = enemy.Size[rng.randi() % 2]
	add_child(enemy)
	#position?motion?
