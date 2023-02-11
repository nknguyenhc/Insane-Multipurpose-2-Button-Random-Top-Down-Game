extends Area2D


var DPF = 0.1


func _physics_process(delta):
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.name != "Player":
			# do some effects
			body.take_damage(DPF, "Fire")


func power_up():
	DPF = 0.17


func _on_ExistenceTimer_timeout():
	# do some effects
	queue_free()
