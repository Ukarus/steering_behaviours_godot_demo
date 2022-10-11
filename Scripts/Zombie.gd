extends KinematicBody2D

export (int) var max_hp
export (int) var dmg = 1
export (float) var max_speed = 100.0
var current_target
var steering_behaviours = load("res://Scripts/SteeringBehaviours.gd")
var class_moving_entity = load("res://Scripts/MovingEntity.gd")
onready var current_hp = max_hp
onready var moving_entity = MovingEntity.new(Vector2(), Vector2(), Vector2(), position, 0.8, 100, 0, 0)
onready var sb_node = steering_behaviours.new(
	moving_entity
)
onready var hurt_box = $HurtBox
onready var _animated_sprite = $AnimatedSprite
onready var _animation_player : AnimationPlayer = $AnimationPlayer
enum States {FLIGHT, ATTACK, DIE}
# With a variable that keeps track of the current state, we don't need to add more booleans.
var _state : int = States.FLIGHT
var velocity = Vector2()


func seek(target_position: Vector2):
	var desired_velocity = (target_position - global_position).normalized() * max_speed
	return desired_velocity - velocity

func _ready():
	moving_entity.m_vPosition = position
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _state == States.FLIGHT:
		_animation_player.play("flight")
		# Function to look at the current target
		# Right now if the target comes from left it's making the sprite upside down
		# look_at(current_target.position)
		var steering_force = seek(current_target.global_position)
		var acceleration = steering_force / 0.8
		velocity += acceleration * delta
		velocity.x = min(velocity.x, max_speed)
		velocity.y = min(velocity.y, max_speed)
		velocity = move_and_slide(velocity)
		_animated_sprite.flip_h = velocity.x < 0
		scale.x = -1 if velocity.x < 0 else 1
			
		
# 		var steering_force = sb_node.seek(current_target.position)
# 		var acceleration = steering_force / moving_entity.m_dMass
# 		moving_entity.m_vVelocity += acceleration * delta
# 		moving_entity.m_vVelocity.x = min(moving_entity.m_vVelocity.x, moving_entity.m_dMaxSpeed)
# 		moving_entity.m_vVelocity.y = min(moving_entity.m_vVelocity.y, moving_entity.m_dMaxSpeed)
# #		move_and_slide(moving_entity.m_vVelocity)
# 		position.x += moving_entity.m_vVelocity.x * delta
# 		position.y += moving_entity.m_vVelocity.y * delta
# 		# Update the local position of the enemy so the steering behaviour can calculate the steering force more precisely
# 		moving_entity.m_vPosition = position
	elif _state == States.ATTACK:
		_animation_player.play("attack")
	elif _state == States.DIE:
		pass
		
func set_current_target(target):
	current_target = target
	
func damage(damage_done):
	current_hp -= damage_done
	if current_hp < 1:
		_animated_sprite.play("death")
		queue_free()
		_state = States.DIE
		
func _on_AttackRange_body_entered(_body):
	_state = States.ATTACK

func _on_HurtBox_body_entered(body):
	if _state == States.ATTACK:
		body.take_damage(dmg)

func _on_AttackRange_body_exited(_body):
	_state = States.FLIGHT
