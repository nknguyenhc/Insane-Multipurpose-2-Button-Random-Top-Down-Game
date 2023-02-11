extends KinematicBody2D

const sanity_increment = 1

var Health_bar = preload("res://Enemies/EnemyHealthBar.tscn")
var health_bar

var MAX_HEALTH = 50
var MAX_SPEED = 100
var health
var speed
var player
var is_slowed = false
var is_immobilised = false
var rng = RandomNumberGenerator.new()
var size
var freeze_chance
var freeze_duration


# Called when the node enters the scene tree for the first time.
func _ready():
	health = MAX_HEALTH
	speed = MAX_SPEED
	player = get_parent().get_parent().get_node("Player")
	freeze_chance = player.freeze_chance
	freeze_duration = player.freeze_duration
	health_bar = Health_bar.instance()
	health_bar.position.x -= 0
	health_bar.position.y -= 8
	add_child(health_bar)
	

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
	position += speed * (player.position - position).normalized() * delta
	
	health_bar.get_node("TextureProgress").value = round(float(health) / MAX_HEALTH * 100)
	
func take_damage(damage, element):
	health -= damage
	if element == "Freeze":
		if(rng.randi() % 100 < freeze_chance):
			is_immobilised = true
			get_node("immobolise_timer").wait_time = freeze_duration
			get_node("immobolise_timer").start()
		else:
			is_slowed = true
			get_node("slow_timer").wait_time = freeze_duration
			get_node("slow_timer").start()
			
func die():
	player.receive_bonus()
	player.change_sanity(sanity_increment)
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
