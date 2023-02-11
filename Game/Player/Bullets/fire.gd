extends Area2D


var DPF


func _physics_process(delta):
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.name != "Player":
			# do some effects
			body.take_damage(DPF, "Fire")


func _on_ExistenceTimer_timeout():
	# do some effects
	queue_free()
