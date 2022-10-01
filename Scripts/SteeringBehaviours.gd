extends Node
	
# export (int) var max_speed = 20
export (float) var decceleration_tweaker = 0.3
enum decceleration {slow = 3, normal = 2, fast = 1}
var moving_entity: MovingEntity

func _init(me):
	self.moving_entity = me

func seek(target_position: Vector2):
	var desired_velocity = (target_position - moving_entity.m_vPosition).normalized() * moving_entity.m_dMaxSpeed
	return desired_velocity - moving_entity.m_vVelocity
	
func pursuit(target_position: Vector2, target: Node2D):
	var toEvader = target_position - moving_entity.m_vPosition
	var relative_heading = moving_entity.m_vVelocity.dot(target.get_velocity())
	
	if (toEvader.dot(moving_entity.m_vVelocity) > 0) && (relative_heading < -0.95):
		return seek(target_position)
	
	var look_ahead_time = toEvader.length() / (moving_entity.m_dMaxSpeed + target.get_speed())
#	print(target.get_speed() * look_ahead_time)
	return seek(target_position + target.velocity * look_ahead_time)

# func arrive(target_position: Vector2, decceleration: int, current_position: Vector2, current_velocity: Vector2):
# 	var to_target = target_position - current_position
# 	var dist = to_target.length()
	
# 	if (dist > 0):
# 		var speed = dist / ((decceleration as float) * decceleration_tweaker)
# 		speed = min(speed, max_speed)
# 		var desired_velocity = to_target * speed / dist
		
# 		return desired_velocity - current_velocity
# 	return Vector2()
