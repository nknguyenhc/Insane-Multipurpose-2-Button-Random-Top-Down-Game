extends Area2D


var DPF
var target


func _physics_process(delta):
	target.take_damage(DPF, "Wind")


func _on_ExistenceTimer_timeout():
	queue_free()
