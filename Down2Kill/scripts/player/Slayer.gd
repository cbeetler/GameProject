extends KinematicBody2D

# constant player movement speed
const MOVE_SPEED = 300

# reference to the raycast
onready var raycast = $RayCast2D

# reference to bullet
const bulletPath = preload("res://Scenes/Bullet.tscn")

# which gun is active, initially handgun
var gun = "handgun"

# player health
var health = 3
var isDead = false

# related to dashing
var dash_speed = 600
var isDashing = false

# ready function, called once at beginning of game
func _ready():
	yield(get_tree(), "idle_frame")
	get_tree().call_group("zombies", "set_slayer", self)

# physics process, called once every frame rate
func _physics_process(delta):
	# blank vector for movement
	var move_v = Vector2()
	var dash_v = Vector2()
	
	if (!isDead):
		# determine dashing
		if Input.is_action_pressed("dash"):
			isDashing = true
		elif Input.is_action_just_released("dash"):
			isDashing = false
	
		# movement
		if Input.is_action_pressed("move_up"):
			move_v.y -= 1
		if Input.is_action_pressed("move_down"):
			move_v.y += 1
		if Input.is_action_pressed("move_left"):
			move_v.x -= 1
		if Input.is_action_pressed("move_right"):
			move_v.x += 1
	
		# move at appropriate speed
		move_v = move_v.normalized()
		if (!isDashing):
			move_and_collide(move_v * MOVE_SPEED * delta)
		else:
			move_and_collide(move_v * dash_speed * delta)
	
		# determines rotation, where the player is looking
		var look_v = get_global_mouse_position() - global_position
		global_rotation = atan2(look_v.y, look_v.x)
	
		# shooting
		if (gun != "rifle"):
			if Input.is_action_just_pressed("shoot"):
				if (gun == "handgun"):
					shoot_handgun()
				if (gun == "shotgun"):
					shoot_shotgun()
		# gun shoots way too fast, need to figure out how to make delay between bullets
		else:
			if Input.is_action_pressed("shoot"):
				shoot_rifle()
	
	# restart game
	if (isDead):
		if Input.is_action_just_pressed("ui_accept"):
			isDead = false
			restart()

# method for being killed
# reloads the current scene
func kill():
	isDead = true
	hide()

# reloads the current scene, can only happen if player is dead
func restart():
	get_tree().reload_current_scene()

# method for being hit by a zombie
# reduces health by 1, if health falls to 0 player dies
func hit():
	health -=3
	
	if (health <= 0):
		kill()

# shooting handgun, semi-automatic, requires multiple clicks for multiple shots
func shoot_handgun():
	# create instance of bullet
	var bullet = bulletPath.instance()
	
	# determines rotation, where the player is looking
	# sets the rotation of the bullet instance equal to where player is aiming when fired
	var look_v = get_global_mouse_position() - global_position
	bullet.rotation = atan2(look_v.y, look_v.x)
	
	# make bullet a child of the parent
	get_parent().add_child(bullet)
	bullet.position = $Node2D/Position2D.global_position
	
	# move the bullet
	bullet.bullet_velocity = get_global_mouse_position() - bullet.position

# shooting shotgun, should fire spread of buckshot
func shoot_shotgun():
	null

# =========== NEEDS MODIFICATION ===========
# shooting rifle, should fire continuously as mouse is held
# but not as continuously as it currently is
func shoot_rifle():
	# create instance of bullet
	var bullet = bulletPath.instance()
	
	# determines rotation, where the player is looking
	# sets the rotation of the bullet instance equal to where player is aiming when fired
	var look_v = get_global_mouse_position() - global_position
	bullet.rotation = atan2(look_v.y, look_v.x)
	
	# make bullet a child of the parent
	get_parent().add_child(bullet)
	bullet.position = $Node2D/Position2D.global_position
	
	# move the bullet
	bullet.bullet_velocity = get_global_mouse_position() - bullet.position

func switch_gun(gun):
	null
