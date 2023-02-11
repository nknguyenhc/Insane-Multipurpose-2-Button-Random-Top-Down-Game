extends KinematicBody2D

const freeze_chance = 20 #out of 100

enum Size{small, big}

var MAX_HEALTH = 100
var MAX_SPEED = 10
var damage = 8
var health
var speed
var player = get_parent().get_node("Player")
var is_slowed = false
var is_immobilised = false
var is_blown_away = false
var is_attacking_ship = false
var rng = RandomNumberGenerator.new()
var size

# Called when the node enters the scene tree for the first time.
func _ready():
	if size == Size.small:
		MAX_HEALTH = 20
		MAX_SPEED = 50
		damage = 4
		get_node("appearance").animation = "baby"
	health = MAX_HEALTH
	speed = MAX_SPEED
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if health <= 0:
		die()
	if !is_blown_away:
		speed = lerp(speed, MAX_SPEED, 0.01)
	if is_slowed:
		speed = MAX_SPEED / 2
		get_node("appearance").speed_scale = 0.5
	else:
		get_node("appearance").speed_scale = 1
	if is_immobilised:
		speed = 0
	if is_blown_away:
		speed = lerp(speed, - MAX_SPEED * 2, 0.01)
	if is_attacking_ship:
		speed = 0
		if not is_immobilised:
			deal_damage(damage)
	position += speed * (player.position - position) * delta

	

func take_damage(damage, element):
	if element == "Fire":
		health -= damage * 1.5
	elif element != "Freeze":
		health -= damage
	if element == "Wind":
		if size == Size.small:
			is_blown_away = true;
			
func die():
	queue_free()
	
func deal_damage(damage):
	player.take_damage(damage);
	
func _on_immobolise_timer_timeout():
	is_immobilised = false

func _on_slow_timer_timeout():
	is_slowed = false

func _on_hitbox_body_entered(body):
	if body == player:
		is_attacking_ship = true
