extends Node

var Start = preload("res://Main/Start.tscn")
var Game = preload("res://Main/Game.tscn")
var start
var game


func _ready():
	start = Start.instance()
	add_child(start)

func player_die():
	get_node("Game").queue_free()
	start = Start.instance()
	add_child(start)

func start_game():
	get_node("Start").queue_free()
	game = Game.instance()
	add_child(game)
