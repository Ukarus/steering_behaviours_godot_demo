#extends KinematicBody2D
extends "res://Scripts/MovingEntity.gd" 

enum decceleration {slow = 3, normal = 2, fast = 1}
export (NodePath) var target_path
var target : Node2D
var sb
var velocity = Vector2()
var decceleration_vehicle = decceleration.normal

class SteeringBehaviours:
	var a = 5
	
	func print_value_of_a():
		print(a)

#func _init():
#	sb = SteeringBehaviours.new()

func seek(target_position: Vector2):
	var desired_velocity = (target_position - position).normalized() * m_dMaxSpeed
	return desired_velocity - m_vVelocity
	
func arrive(target_position: Vector2, decceleration: int):
	var to_target = target_position - position
	var dist = to_target.length()
	
	if (dist > 0):
		var decceleration_tweaker = 0.3
		var speed = dist / ((decceleration as float) * decceleration_tweaker)
		speed = min(speed, m_dMaxSpeed)
		var desired_velocity = to_target * speed / dist
		
		return desired_velocity - m_vVelocity
	return Vector2()

func pursuit(target_position: Vector2):
	var toEvader = target_position - position
	var relative_heading = m_vVelocity.dot(target.velocity)
	
	if (toEvader.dot(m_vVelocity) > 0) && (relative_heading < -0.95):
		return seek(target_position)
	
	var look_ahead_time = toEvader.length() / (m_dMaxSpeed + target.get_speed())
#	print(target.get_speed() * look_ahead_time)
	return seek(target_position + target.velocity * look_ahead_time)

# Called when the node enters the scene tree for the first time.
func _ready():
	target = get_node(target_path)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity = Vector2()
#	var steering_force = seek(target.position)
#	var steering_force = arrive(target.position, decceleration.fast)
	var steering_force = pursuit(target.position)
	var acceleration = steering_force / m_dMass
	m_vVelocity += acceleration * delta
	m_vVelocity.x = min(m_vVelocity.x, m_dMaxSpeed)
	m_vVelocity.y = min(m_vVelocity.y, m_dMaxSpeed)
#	move_and_slide(m_vVelocity)
	position.x += m_vVelocity.x * delta
	position.y += m_vVelocity.y * delta
