extends KinematicBody2D

const sanity_increment = 1
const MIN_X = 20
const MAX_X = 1000
const MIN_Y = 20
const MAX_Y = 580

var Health_bar = preload("res://Enemies/EnemyHealthBar.tscn")
var health_bar

var MAX_HEALTH = 50
var MAX_SPEED = 250
var health
var speed
var player
var is_slowed = false
var is_immobilised = false
var rng = RandomNumberGenerator.new()
var size
var freeze_chance
var freeze_duration
var direction


# Called when the node enters the scene tree for the first time.
func _ready():
	health = MAX_HEALTH
	speed = MAX_SPEED
	player = get_parent().get_parent().get_node("Player")
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
	position += speed * direction.normalized() * delta
	
	health_bar.get_node("TextureProgress").value = round(float(health) / MAX_HEALTH * 100)
	
func take_damage(damage, element):
	health -= damage
	if element == "Freeze":
		freeze_chance = player.freeze_chance
		freeze_duration = player.freeze_duration
		if(rng.randi() % 100 < freeze_chance):
			is_immobilised = true
			get_node("appearance").modulate = Color(0, 0.5, 1)
			get_node("immobolise_timer").wait_time = freeze_duration
			get_node("immobolise_timer").start()
		else:
			is_slowed = true
			get_node("appearance").modulate = Color(0.5, 0.75, 1)
			get_node("slow_timer").wait_time = freeze_duration
			get_node("slow_timer").start()
			
func die():
	player.receive_bonus()
	player.change_sanity(sanity_increment)
	queue_free()
	
func check_if_outside():
	if position.x > MAX_X + 500 || position.x < MIN_X - 500 || position.y > MAX_Y + 500 || position.y < MAX_Y - 500:
		queue_free()
	
func _on_immobolise_timer_timeout():
	get_node("appearance").modulate = Color(1, 1, 1)
	is_immobilised = false

func _on_slow_timer_timeout():
	get_node("appearance").modulate = Color(1, 1, 1)
	is_slowed = false

func _on_hitbox_body_entered(body):
	pass
	
