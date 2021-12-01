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

# sprites
var handgun = preload("res://images/player/handgun/handgun_idle.png")
var rifle = preload("res://images/player/rifle/rifle_idle.png")
var shotgun = preload("res://images/player/shotgun/shotgun_idle.png")

# reference to slayer sprite
onready var slayer_sprite = get_node("Sprite")

# rifle variables
var fire_rate = 10.0
onready var update_delta = 1 / fire_rate
var current_time = 0
# credit to https://godotengine.org/qa/58018/how-to-make-is_action_pressed-rate-bit-slower
# for helping me figure out how to slow down the fire rate

# reference to world (current scene)
# var world = get_tree().current_scene

# ready function, called once at beginning of game
func _ready():
	yield(get_tree(), "idle_frame")
	get_tree().call_group("zombies", "set_slayer", self)

 # separate physics process function for firing the rifle so it doesn't overload
func _process(delta):
	current_time += delta
	if (current_time < update_delta):
		return
	
	if (gun == "rifle"):
		if Input.is_action_pressed("shoot"):
			current_time = 0
			shoot_handgun()
# credit to https://godotengine.org/qa/58018/how-to-make-is_action_pressed-rate-bit-slower
# for helping me figure out how to slow down the fire rate

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
	
		# switching weapons, changes sprite and shooting mode
		if Input.is_action_pressed("switch_handgun"):
			slayer_sprite.set_texture(handgun)
			gun = "handgun"
		if Input.is_action_pressed("switch_rifle"):
			slayer_sprite.set_texture(rifle)
			gun = "rifle"
		if Input.is_action_pressed("switch_shotgun"):
			slayer_sprite.set_texture(shotgun)
			gun = "shotgun"
	
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
					# switch_gun()
	
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
# can also be used to shoot rifle due to separate _process function handling rifle shots
func shoot_handgun():
	# create instance of bullet
	var bullet = bulletPath.instance()
	
	# determines rotation, where the player is looking
	# sets the rotation of the bullet instance equal to where player is aiming when fired
	var look_v = get_global_mouse_position() - global_position
	bullet.rotation = atan2(look_v.y, look_v.x)
	
	# make bullet a child of the parent
	var world = get_tree().current_scene
	world.add_child(bullet)
	# get_parent().add_child(bullet)
	bullet.position = $Node2D/Position2D.global_position
	
	# move the bullet
	bullet.bullet_velocity = get_global_mouse_position() - bullet.position

# shooting shotgun, should fire spread of buckshot
# in 3 different angles
func shoot_shotgun():
	# create instance of bullets
	var bullet = bulletPath.instance()
	var bullet2 = bulletPath.instance()
	var bullet3 = bulletPath.instance()
	
	# determines rotation, where the player is looking
	# sets the rotation of the bullet instances equal to where player is aiming when fired
	var look_v = get_global_mouse_position() - global_position
	bullet.rotation = atan2(look_v.y, look_v.x)
	bullet2.rotation = atan2(look_v.y, look_v.x) #* -0.1
	bullet3.rotation = atan2(look_v.y, look_v.x) #* 0.1
	
	# make bullets children of their parent
	var world = get_tree().current_scene
	world.add_child(bullet)
	world.add_child(bullet2)
	world.add_child(bullet3)
	bullet.position = $Node2D/Position2D.global_position
	bullet2.position = $Node2D/Position2D2.global_position
	bullet3.position = $Node2D/Position2D3.global_position
	
	# move the bullet
	# print(bullet.rotation)
	bullet.bullet_velocity = get_global_mouse_position() - bullet.position
	# bullet pathing needed this interesting logic, otherwise the bullets would sometimes combine
	# and not spread enough depending on where I was aiming. problem solved!
	if (bullet.rotation > -2.3 && bullet.rotation < .7):
		bullet2.bullet_velocity = get_global_mouse_position() + Vector2(90, 90) - bullet.position
		bullet3.bullet_velocity = get_global_mouse_position() - Vector2(90, 90) - bullet.position
		# print ("bing")
	else:
		bullet2.bullet_velocity = get_global_mouse_position() - Vector2(90, 90) - bullet.position
		bullet3.bullet_velocity = get_global_mouse_position() + Vector2(90, 90) - bullet.position
		# print("bong")
