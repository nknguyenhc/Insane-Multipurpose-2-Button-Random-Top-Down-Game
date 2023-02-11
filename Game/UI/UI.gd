extends Node2D

onready var displayElement = $CurrentAction/CenterContainer
var elementInit = preload("res://UI/Elements.tscn")

var elementList = ["Earth", "Wind", "Fire", "Ice"]
var elements = []
var counter = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	# generate a random number from 1 to 4
	# uhhhh
	var firstElement = elementInit.instance()
	var rng = elementList[randi() % 4]
	firstElement.animation = rng
	elements.append(rng)
	displayElement.add_child(firstElement)
	elements.append(elementList[randi() % 4])



func _process(delta):
	if (Input.is_action_just_pressed("ui_accept")):
		counter += 1
		for element in displayElement.get_children():
			element.animation = elements[counter % elements.size()]
