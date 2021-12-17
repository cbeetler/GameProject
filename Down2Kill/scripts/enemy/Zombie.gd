extends KinematicBody2D

# move speed for default enemies, slower than player
const MOVE_SPEED = 200

# reference to raycast
onready var raycast = $RayCast2D

# zombie health
var health = 3

# reference to player, initially null
var slayer = null

# determine if close enought to chase after
var chase = false;

# reference to death sound
var deathSound = preload("res://sounds/zomDeath.mp3")

# zombies are added prior to zombies being called in the slayer script
func _ready():
	add_to_group("zombies")

func _physics_process(delta):
	if slayer == null:
		return
	
	var distanceFrom = get_global_position().distance_to(slayer.get_global_position())
	# print(distanceFrom)
	if (distanceFrom < 1500):
		chase = true;
	
	if (chase):
		# determine where the slayer is 
		var v_to_slayer = slayer.global_position - global_position	
		v_to_slayer = v_to_slayer.normalized()
		
		# rotation
		global_rotation = atan2(v_to_slayer.y, v_to_slayer.x)
		
		# movement
		if (!slayer.isDead):
			move_and_collide(v_to_slayer * MOVE_SPEED * delta)
		
		# kill player
		if raycast.is_colliding():
			var coll = raycast.get_collider()
			if coll.name == "Slayer":
				coll.hit()
				move_and_collide(v_to_slayer * -1 * MOVE_SPEED * delta)

# set player
func set_slayer(s):
	slayer = s

# handles zombie getting shot
# determines if they are ready to die
func _on_zombie_area_area_entered(area):
	# if bullet enters zombie area, check what gun is active and lowe health
	if (area.name == "bullet_area"):
		if (slayer.gun == "handgun"):
			health -= 1
		elif (slayer.gun == "shotgun"):
			health -=3
		elif (slayer.gun == "rifle"):
			health -=2
		# despawn bullets that hit
		area.get_parent().queue_free()
	# add elif statement to despawn bullets that hit objects when you get that far
	
	if (health <= 0):
		# if !$AudioStreamPlayer2D.is_playing():
			# $AudioStreamPlayer2D.stream = deathSound
			# $AudioStreamPlayer2D.play()
		queue_free()
