extends Node


static func seek(
		target_position: Vector2,
		entity_position: Vector2,
		max_speed: float,
		velocity: Vector2
	) -> Vector2:
	var desired_velocity = (target_position - entity_position).normalized() * max_speed
	return desired_velocity - velocity


static func arrive(
		target_position: Vector2, 
		entity_position: Vector2,
		decceleration: int,
		max_speed: float,
		decceleration_tweaker: float,
		velocity: Vector2
	) -> Vector2:
	var to_target = target_position - entity_position
	var dist = to_target.length()
	
	if (dist > 0):
		var speed = dist / ((decceleration as float) * decceleration_tweaker)
		speed = min(speed, max_speed)
		var desired_velocity = to_target * speed / dist
		
		return desired_velocity - velocity
	return Vector2()
