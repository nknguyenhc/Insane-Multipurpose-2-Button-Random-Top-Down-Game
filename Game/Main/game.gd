extends Node


var EarthAiming = preload("res://Player/EarthAiming.tscn")
var earth_aiming
var current_enemy_aimed


func _ready():
	$Player.scale = Vector2(0.5, 0.5)


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
	enemies.remove(0)
	enemies.remove(0)
	enemies.remove(0)
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
	enemies.remove(0)
	enemies.remove(0)
	enemies.remove(0)
	var attack_num = min(n, enemies.size())
	var distances = []
	for enemy in enemies:
		distances.append((enemy.position - $Player.position).length())
	distances.sort()
	for i in range(0, attack_num):
		for enemy in enemies:
			if (enemy.position - $Player.position).length() == distances[i]:
				nearest_enemies.append(enemy)
	return nearest_enemies
	
func delete_earth_aiming():
	if weakref(earth_aiming).get_ref():
		earth_aiming.queue_free()

