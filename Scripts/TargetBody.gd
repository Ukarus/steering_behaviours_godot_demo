extends KinematicBody2D

#const FOLLOW_SPEED = 20.0
var velocity = Vector2()
export (int) var speed = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_input():
	velocity = Vector2()
	if Input.is_action_pressed("left"):
		velocity.x -=1
	if Input.is_action_pressed("right"):
		velocity.x += 1
	if Input.is_action_pressed("up"):
		velocity.y -= 1
	if Input.is_action_pressed("down"):
		velocity.y += 1
	
	velocity = velocity.normalized() * speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	get_input()
	velocity = move_and_slide(velocity)
	
func get_speed():
	return speed
#var mouse_pos = Vector2()
#
#func _physics_process(delta):
#	if mouse_pos != Vector2.ZERO:
#		position = position.linear_interpolate(mouse_pos, delta * FOLLOW_SPEED)
#		if position == mouse_pos:
#			mouse_pos = Vector2()
#	else:
#		mouse_pos = Vector2()
#
#	if Input.is_action_just_pressed("left_click"):
#		mouse_pos = get_global_mouse_position()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
