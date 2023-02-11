extends HBoxContainer

onready var displayElement = $CurrentAction/CenterContainer
var elementInit = preload("res://UI/Elements.tscn")

var elementList = ["Earth", "Wind", "Fire", "Ice"]
var elements = []
var iconSpacing = -15
var counter = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	# generate a random number from 1 to 4
	# uhhhh
	var firstElement = elementInit.instance()
	var rng = elementList[randi() % 4]
	firstElement.animation = rng
	
	elements.append(rng)
	elementList.erase(rng)
	displayElement.add_child(firstElement)



func _process(delta):
	if (Input.is_action_just_pressed("ui_accept")):
		for element in displayElement.get_children():
			print(elements)
			element.animation = elements[(elements.find(element.animation) + 1) % elements.size()]
	if (Input.is_action_just_pressed("ui_down") && elementList.size() != 0):
		var rng = elementList[randi() % elementList.size()]
		var newElement = elementInit.instance()
		newElement.animation = rng
		elements.append(rng)
		elementList.erase(rng)
		displayElement.add_child(newElement)
		print(newElement.position.y)
		newElement.position.y += iconSpacing * (elements.size() - 1)
		print(newElement.position.y)
		
