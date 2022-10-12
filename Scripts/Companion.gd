extends KinematicBody2D

export (NodePath) var player_path
export (float) var follow_speed = 2.0
export (float) var max_speed = 10.0
export (float) var mass = 1.0
export (int) var max_hp = 100
export (PackedScene) var arrows
enum decceleration {slow = 3, normal = 2, fast = 1}
# An enum allows us to keep track of valid states.
enum States {FOLLOW, ATTACK, WAIT, ATTACK_DELAY}
# With a variable that keeps track of the current state, we don't need to add more booleans.
var _state : int = States.FOLLOW
var velocity = Vector2()
var decceleration_tweaker = 0.3
var current_hp
# this will act as a stack
var targets = []
var direction = "right"
const DISTANCE_THRESHOLD = 10.0

onready var player = get_node(player_path)
onready var timer = $Timer
onready var attack_timer = $AttackTimer
onready var animated_sprite = $AnimatedSprite
onready var animation_player = $AnimationPlayer
onready var attack_radius = $BowAttackRadius
onready var left_arrow_pos = $LeftArrowPos
onready var right_arrow_pos = $RightArrowPos
onready var melee_attack_radius = $MeleeAttackRadius

signal update_current_hp

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	current_hp = max_hp
	if player != null:
		player.connect("make_companion_wait", self, "set_wait")
		player.connect("make_companion_follow", self, "set_follow_with_delay")
		
func move_with_interpolation(delta):
	position = position.linear_interpolate(player.global_position, delta * follow_speed)

func seek(target_position: Vector2) -> Vector2:
	var desired_velocity = (target_position - position).normalized() * max_speed
	return desired_velocity - velocity

func arrive(target_position: Vector2, decceleration: int):
	var to_target = target_position - position
	var dist = to_target.length()
	
	if (dist > 0):
		var speed = dist / ((decceleration as float) * decceleration_tweaker)
		speed = min(speed, max_speed)
		var desired_velocity = to_target * speed / dist
		
		return desired_velocity - velocity
	return Vector2()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _state == States.FOLLOW:
		animation_player.play("run")
		var steering_force = arrive(player.global_position, decceleration.fast)
		var acceleration = steering_force / mass
		velocity += acceleration * delta
		velocity.x = min(velocity.x, max_speed)
		velocity.y = min(velocity.y, max_speed)
		if velocity.x > 0:
			direction = "left"
		elif velocity.x < 0:
			direction = "right"
		velocity = move_and_slide(velocity)
	elif _state == States.ATTACK:
		animation_player.play("attack_bow")
		# Replace this logic for group nodes
		var enemies = get_tree().get_nodes_in_group("enemies")
		if enemies.size() < 1:
			_state = States.FOLLOW
			return
		# choose target randomly
		# or choose it closest to companion
		var current_target = enemies[0]
		var a = arrows.instance()
		add_child(a)
		if current_target.position.x < position.x:
			a.position = left_arrow_pos.position
		else:
			a.position = right_arrow_pos.position
		# Predict the target future movement
		a.target_pos = current_target.position
		a.look_at(current_target.position)
		_state = States.ATTACK_DELAY
	elif _state == States.ATTACK_DELAY:
		if !animation_player.is_playing():
			animation_player.play("idle")
		attack_timer.start()
	elif _state == States.WAIT:
		animation_player.play("idle")
	animated_sprite.flip_h = direction == "left"
		

func take_damage(dmg: int):
	current_hp -= dmg
	emit_signal("update_current_hp", current_hp)

func get_velocity():
	return velocity
	
func get_speed():
	return max_speed
	
func set_wait():
	_state = States.WAIT

func set_follow_with_delay():
	timer.start()

func _on_Timer_timeout():
	_state = States.FOLLOW
	timer.stop()

func _on_AttackRadius_body_entered(body):
	targets.append(body)
	if _state != States.ATTACK_DELAY and _state != States.ATTACK:
		_state = States.ATTACK


func _on_AttackTimer_timeout():
	_state = States.ATTACK
	attack_timer.stop()
