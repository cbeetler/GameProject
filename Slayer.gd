extends KinematicBody2D

# constant player movement speed
const MOVE_SPEED = 300

# reference to the raycast
onready var raycast = $RayCast2D

# ready function, called once at beginning of game
func _ready():
	yield(get_tree(), "idle_frame")
	get_tree().call_group("zombies", "set_slayer", self)

# physics process, called once every frame rate
func _physics_process(delta):
	# blank vector for movement
	var move_v = Vector2()
	
	# movement input
	if Input.is_action_pressed("move_up"):
		move_v.y -= 1
	if Input.is_action_pressed("move_down"):
		move_v.y += 1
	if Input.is_action_pressed("move_left"):
		move_v.x -= 1
	if Input.is_action_pressed("move_right"):
		move_v.x += 1
	
	move_v = move_v.normalized()
	move_and_collide(move_v * MOVE_SPEED * delta)
	
	# determines rotation, where the player is looking
	var look_v = get_global_mouse_position() - global_position
	global_rotation = atan2(look_v.y, look_v.x)
	
	# shooting
	if Input.is_action_just_pressed("shoot"):
		var coll = raycast.get_collider()
		# if the node the raycast collides with is a zombie, kill it
		if raycast.is_colliding() and coll.has_method("kill"):
			coll.kill()

# method for being killed
# reloads the current scene
func kill():
	get_tree().reload_current_scene()
