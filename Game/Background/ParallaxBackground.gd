extends ParallaxBackground


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _process(delta):
	scroll_offset.x -= 1000 * delta
