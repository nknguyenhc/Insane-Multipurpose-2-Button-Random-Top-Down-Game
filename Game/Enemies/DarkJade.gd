extends KinematicBody2D

const freeze_chance = 20

var MAX_HEALTH = 50
var MAX_SPEED = 50
var health
var speed
var player = get_parent().get_node("Player")
var is_slowed = false
var is_immobilised = false
var rng = RandomNumberGenerator.new()
var size

# Called when the node enters the scene tree for the first time.
func _ready():
	health = MAX_HEALTH
	speed = MAX_SPEED
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	check_if_outside()
	if health <= 0:
		die()
	speed = lerp(speed, MAX_SPEED, 0.01)
	if is_slowed:
		speed = MAX_SPEED / 2
		get_node("appearance").speed_scale = 0.5
	else:
		get_node("appearance").speed_scale = 1
	if is_immobilised:
		speed = 0
	position += speed * (player.position - position) * delta
	
func take_damage(damage, element):
	health -= damage
	if element == "Freeze":
		if(rng.randi() % 100 < freeze_chance):
			is_immobilised = true
			get_node("immobolise_timer").wait_time = 1.0 #TBC
			get_node("immobolise_timer").start()
		else:
			is_slowed = true
			get_node("slow_timer").wait_time = 1.0 #TBC
			get_node("slow_timer").start()
			
func die():
	player.receive_bonus()
	queue_free()
	
func check_if_outside():
	if false: #TBC
		queue_free()
	
func _on_immobolise_timer_timeout():
	is_immobilised = false

func _on_slow_timer_timeout():
	is_slowed = false

func _on_hitbox_body_entered(body):
	pass
