extends Area2D


var DPF
var target


func _physics_process(delta):
	if weakref(target).get_ref():
		target.take_damage(DPF, "Wind")


func _on_ExistenceTimer_timeout():
	queue_free()
