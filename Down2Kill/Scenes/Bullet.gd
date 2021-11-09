# idk how this ended up in the location it is in
# but the game doesn't work when I move it :') 

extends KinematicBody2D

var bullet_velocity = Vector2(1, 0)
var bullet_speed = 800

func _physics_process(delta):
	var collision_info = move_and_collide(bullet_velocity.normalized() * delta * bullet_speed)
	
