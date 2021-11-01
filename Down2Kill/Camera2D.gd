extends Camera2D

onready var slayer = get_node("/root/MainScene/Slayer")

func _process(delta):
	position.x = slayer.position.x
	position.y = slayer.position.y
