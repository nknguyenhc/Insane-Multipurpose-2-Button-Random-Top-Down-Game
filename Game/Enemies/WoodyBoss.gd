extends KinematicBody2D

var Health_bar = preload("res://Enemies/EnemyHealthBar.tscn")
var health_bar

const sanity_increment = 20

var MAX_HEALTH = 1000
var MAX_SPEED = 20
var health
var speed
var player
var is_slowed = false
var is_immobilised = false
var stay_put = false
var rng = RandomNumberGenerator.new()
var freeze_chance
var freeze_duration
var level

var Woody = preload("res://Enemies/Woody.tscn")
var woody

# Called when the node enters the scene tree for the first time.
func _ready():
	level = get_parent().level
	health = MAX_HEALTH
	speed = MAX_SPEED
	player = get_parent().get_parent().get_node("Player")
	$move_timer.start()
	$summon_timer.wait_time = rng.randf_range(1, max(2, 50.0 / level))
	health_bar = Health_bar.instance()
	health_bar.position.x -= 0
	health_bar.position.y -= 15
	add_child(health_bar)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
	if stay_put:
		speed = 0
	position += speed * (player.position - position).normalized() * delta
	health_bar.get_node("TextureProgress").value = round(float(health) / MAX_HEALTH * 100)
	

func take_damage(damage, element):
	health -= damage
	if element == "Freeze":
		freeze_chance = player.freeze_chance / 2
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
	player.change_sanity(sanity_increment)
	queue_free()
	
func _on_immobolise_timer_timeout():
	is_immobilised = false
	get_node("appearance").modulate = Color(1, 1, 1)

func _on_slow_timer_timeout():
	is_slowed = false
	get_node("appearance").modulate = Color(1, 1, 1)

func _on_hitbox_body_entered(body):
	pass
	
func _on_move_timer_timeout():
	stay_put = true
	
func _on_summon_timer_timeout():
	get_parent().prev_flock_finished = true
	woody = Woody.instance()
	woody.position.x = rng.randf_range(position.x - 20, position.x + 20)
	woody.position.y = rng.randf_range(position.y - 20, position.y + 20)
	if rng.randi() % 2 == 1:
		woody.size = woody.Size.small
	else:
		woody.size = woody.Size.big
	if woody.size == woody.Size.small:
		woody.scale = Vector2(2.5,2.5)
	else:
		woody.scale = Vector2(4,4)
	get_parent().add_child(woody)
	$summon_timer.wait_time = rng.randf_range(1, max(2, 50.0 / level))
	$summon_timer.start()
