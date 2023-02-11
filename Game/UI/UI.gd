extends HBoxContainer

onready var displayElement = $RightHalf/VBoxContainer/ActionContainer/CurrentAction/CenterContainer
var elementInit = preload("res://UI/Elements.tscn")

var elementList = ["Earth", "Fire", "Wind", "Ice"]
var elements = []
var iconSpacing = -15
var counter = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	# generate a random number from 1 to 4
	# uhhhh
	var firstElement = elementInit.instance()
	var elem = elementList[0]
	firstElement.animation = elem
	
	elements.append(elem)
	elementList.erase(elem)
	displayElement.add_child(firstElement)


func change_element():
	for element in displayElement.get_children():
		print(elements)
		element.animation = elements[(elements.find(element.animation) + 1) % elements.size()]


func add_element():
	var elem = elementList[0]
	var newElement = elementInit.instance()
	newElement.animation = elem
	elements.append(elem)
	elementList.erase(elem)
	displayElement.add_child(newElement)
	print(newElement.position.y)
	newElement.position.y += iconSpacing * (elements.size() - 1)
	print(newElement.position.y)
