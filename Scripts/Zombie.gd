extends KinematicBody2D

export (int) var max_hp
export (int) var attack_damage = 1
export (float) var max_speed = 100.0
export (float) var mass = 0.5
var current_target
onready var current_hp = max_hp
onready var hurt_box = $HurtBox
onready var _animated_sprite = $AnimatedSprite
onready var _animation_player : AnimationPlayer = $AnimationPlayer
enum States {FLIGHT, ATTACK, DIE}
# With a variable that keeps track of the current state, we don't need to add more booleans.
var _state : int = States.FLIGHT
var velocity = Vector2()

func _ready():
	_animated_sprite.flip_h = current_target.global_position.x < global_position.x
#	scale.x = -1 if current_target.global_position.x < global_position.x else 1

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _state == States.FLIGHT:
		_animation_player.play("flight")
		var steering_force = SteeringBehaviours.seek(
			current_target.global_position,
			global_position,
			max_speed,
			velocity
		)
		var acceleration = steering_force / mass
		velocity += acceleration * delta
		velocity.x = min(velocity.x, max_speed)
		velocity.y = min(velocity.y, max_speed)
		velocity = move_and_slide(velocity)
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
#	body.take_damage(attack_damage)
	if _state == States.ATTACK:
		body.take_damage(attack_damage)

func _on_AttackRange_body_exited(_body):
	_state = States.FLIGHT
