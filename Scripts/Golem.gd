extends "res://Scripts/BaseEnemy.gd"

enum States {WALK, ATTACK}
# With a variable that keeps track of the current state, we don't need to add more booleans.
var _state : int = States.WALK
onready var _animation_player = $AnimationPlayer
onready var _animated_sprite = $AnimatedSprite

# Called when the node enters the scene tree for the first time.
func _ready():
	_animated_sprite.flip_h = current_target.global_position.x < global_position.x
	$HurtBox.scale.x = -1 if current_target.global_position.x < global_position.x else 1
	current_hp = max_hp


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _state == States.WALK:
		_animation_player.play("walk")
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
		
func damage(dmg_taken):
	current_hp -= dmg_taken
	if current_hp < 1:
		queue_free()

func _on_AttackRange_body_entered(_body):
	_state = States.ATTACK

func _on_AttackRange_body_exited(_body):
	_state = States.WALK

func _on_HurtBox_body_entered(body):
	body.take_damage(attack_damage)
