extends KinematicBody2D

export (int) var max_hp
export (int) var dmg = 1
var is_alive = true
var current_target
var steering_behaviours = load("res://Scripts/SteeringBehaviours.gd")
var class_moving_entity = load("res://Scripts/MovingEntity.gd")
onready var current_hp = max_hp
onready var moving_entity = MovingEntity.new(Vector2(), Vector2(), Vector2(), position, 0.8, 100, 0, 0)
onready var sb_node = steering_behaviours.new(
	moving_entity
)
onready var _animated_sprite = $AnimatedSprite
onready var _animation_player : AnimationPlayer = $AnimationPlayer
enum States {FLIGHT, ATTACK, DIE}
# With a variable that keeps track of the current state, we don't need to add more booleans.
var _state : int = States.FLIGHT

#func _ready():
#	print("max hp: %s" % max_hp)
#	print("current hp: %s" % current_hp)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _state == States.FLIGHT:
		_animation_player.play("flight")
		# Function to look at the current target
		# Right now if the target comes from left it's making the sprite upside down
		look_at(current_target.position)
		var steering_force = sb_node.pursuit(current_target.position, current_target)
		var acceleration = steering_force / moving_entity.m_dMass
		moving_entity.m_vVelocity += acceleration * delta
		moving_entity.m_vVelocity.x = min(moving_entity.m_vVelocity.x, moving_entity.m_dMaxSpeed)
		moving_entity.m_vVelocity.y = min(moving_entity.m_vVelocity.y, moving_entity.m_dMaxSpeed)
		move_and_slide(moving_entity.m_vVelocity)
		# Update the local position of the enemy so the steering behaviour can calculate the steering force more precisely
		moving_entity.m_vPosition = position
	elif _state == States.ATTACK:
		_animation_player.play("attack")
		
func set_current_target(target):
	current_target = target
	
func damage(dmg):
	current_hp -= dmg
	if current_hp < 1:
		is_alive = false
		_animated_sprite.play("death")
		queue_free()
		
func _on_AttackRange_body_entered(body):
	_state = States.ATTACK

func _on_HurtBox_body_entered(body):
	if _state == States.ATTACK:
		body.take_damage(dmg)
