extends KinematicBody2D

var Health_bar = preload("res://Enemies/EnemyHealthBar.tscn")
var health_bar

enum Size{small, big}

const sanity_increment = 1

var MAX_HEALTH
var MAX_SPEED
var damage
var health
var speed
var player
var is_slowed = false
var is_immobilised = false
var is_blown_away = false
var is_attacking_ship = false
var rng = RandomNumberGenerator.new()
var size
var freeze_chance
var freeze_duration

# Called when the node enters the scene tree for the first time.
func _ready():
	if size == Size.small:
		MAX_HEALTH = 30
		MAX_SPEED = 100
		damage = 4
		get_node("appearance").animation = "baby"
	else:
		MAX_HEALTH = 100
		MAX_SPEED = 20
		damage = 8
		get_node("appearance").animation = "adult"
	health = MAX_HEALTH
	speed = MAX_SPEED
	player = get_parent().get_parent().get_node("Player")
	health_bar = Health_bar.instance()
	health_bar.position.x -= 0
	health_bar.position.y -= 8
	add_child(health_bar)


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
	position += speed * (player.position - position).normalized() * delta
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
	if element == "Wind":
		if size == Size.small:
			is_blown_away = true
			$blow_timer.start()

func die():
	player.change_sanity(sanity_increment)
	queue_free()

func deal_damage(damage):
	player.take_damage(damage);

func _on_immobolise_timer_timeout():
	get_node("appearance").modulate = Color(1, 1, 1)
	is_immobilised = false

func _on_slow_timer_timeout():
	get_node("appearance").modulate = Color(1, 1, 1)
	is_slowed = false

func _on_hitbox_body_entered(body):
	if body == player:
		is_attacking_ship = true

func _on_blow_timer_timeout():
	is_blown_away = false
