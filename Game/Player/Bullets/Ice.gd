extends Area2D


func _on_ExistenceTimer_timeout():
	# do some effects
	queue_free()
