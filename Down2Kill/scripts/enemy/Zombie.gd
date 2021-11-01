extends KinematicBody2D

# move speed for default enemies, slower than player
const MOVE_SPEED = 200

onready var raycast = $RayCast2D

# reference to player, initially null
var slayer = null

# zombies are added prior to zombies being called in the slayer script
func _ready():
	add_to_group("zombies")

func _physics_process(delta):
	if slayer == null:
		return
	
	# determine where the slayer is 
	var v_to_slayer = slayer.global_position - global_position
	v_to_slayer = v_to_slayer.normalized()
	
	# rotation
	global_rotation = atan2(v_to_slayer.y, v_to_slayer.x)
	
	# movement
	move_and_collide(v_to_slayer * MOVE_SPEED * delta)
	
	# kill player
	if raycast.is_colliding():
		var coll = raycast.get_collider()
		if coll.name == "Slayer":
			coll.kill()

# kill the zombie
func kill():
	queue_free()

# set player
func set_slayer(s):
	slayer = s
