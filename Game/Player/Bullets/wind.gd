extends Area2D


var DPF = 0.25
var target


func _physics_process(delta):
	target.take_damage(DPF, "Wind")


func power_up():
	DPF = 0.4


func _on_ExistenceTimer_timeout():
	queue_free()
