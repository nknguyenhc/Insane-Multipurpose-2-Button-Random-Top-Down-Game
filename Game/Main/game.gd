extends Node


var EarthAiming = preload("res://Player/EarthAiming.tscn")
var earth_aiming
var current_enemy_aimed


func _physics_process(delta):
	if $Player.is_Earth():
		
		var nearest_enemy = nearest_enemy()
		
		if nearest_enemy == null: # no enemies around
			delete_earth_aiming()
		elif nearest_enemy != current_enemy_aimed: # nearest enemy changed, or there was no previously nearest enemy
			earth_aiming = EarthAiming.instance()
			earth_aiming.position = nearest_enemy.position
		elif !weakref(current_enemy_aimed).get_ref(): # previous nearest enemy is queue freed
			delete_earth_aiming()
		
		current_enemy_aimed = nearest_enemy
	
	else:
		delete_earth_aiming()


func nearest_enemy():
	var enemies = $Enemies.get_children()
	if enemies.size() > 0:
		var nearest_enemy = enemies[0]
		var smallest_distance = (nearest_enemy.position - $Player.position).length()
		for enemy in enemies:
			var distance = (enemy.position - $Player.position).length()
			if distance < smallest_distance:
				smallest_distance = distance
				nearest_enemy = enemy
		return nearest_enemy
	else:
		return null


func nearest_enemies(n):
	var nearest_enemies = []
	var enemies = $Enemies.get_children()
	for enemy in enemies:
		if nearest_enemies.size() < n:
			insert(nearest_enemies, enemy)
		elif (enemy.position - $Player.position).length() < (nearest_enemies[n - 1].position - $Player.position).length():
			insert(nearest_enemies, enemy)
	return nearest_enemies


func insert(enemies, new_enemy):
	var i = 0
	while i < enemies.size():
		if (new_enemy.position - $Player.position).length() < (enemies[i].position - $Player.position).length():
			enemies.insert(i, new_enemy)
			break
		else:
			i += 1


func delete_earth_aiming():
	if weakref(earth_aiming).get_ref():
		earth_aiming.queue_free()