extends Area2D


const SPEED = 15
var DAMAGE

var target
var velocity = Vector2.RIGHT
var homing = false
const MAX_ANGLE_CHANGE = 10 # in degrees


func _physics_process(delta):
	if target != null and weakref(target).get_ref():
		var desired_direction = target.position - position
		var clockwise = velocity.angle_to(desired_direction) <= PI
		var angle_change
		if clockwise:
			angle_change = min(rad2deg(velocity.angle_to(desired_direction)), MAX_ANGLE_CHANGE)
		else:
			angle_change = max(rad2deg(velocity.angle_to(desired_direction)), -MAX_ANGLE_CHANGE)
		rotation_degrees += angle_change
	
	velocity = Vector2(cos(deg2rad(rotation_degrees)), sin(deg2rad(rotation_degrees))) * SPEED
	position += velocity


func _on_EarthBullet_body_entered(body):
	if body == target:
		body.take_damage(DAMAGE, "Earth")
		# do the effects
		queue_free()
