extends KinematicBody2D

export (float) var follow_speed = 2.0
export (float) var max_speed = 10.0
export (float) var mass = 1.0
export (float) var bow_attack_distance = 100.0
export (float) var melee_attack_distance = 50.0
export (float) var melee_attack_damage = 2.0
export (int) var max_hp = 100
export (NodePath) var player_path
export (PackedScene) var arrows
enum decceleration {slow = 3, normal = 2, fast = 1}
# An enum allows us to keep track of valid states.
enum States {FOLLOW, ATTACK, MELEE_ATTACK, IDLE, ATTACK_DELAY}
# With a variable that keeps track of the current state, we don't need to add more booleans.
var _state : int = States.FOLLOW
var velocity = Vector2()
var decceleration_tweaker = 0.3
var current_hp

onready var player : KinematicBody2D = get_node(player_path)
onready var timer = $Timer
onready var attack_timer = $AttackTimer
onready var animated_sprite = $AnimatedSprite
onready var animation_player = $AnimationPlayer
onready var attack_radius = $BowAttackRadius
onready var left_arrow_pos = $LeftArrowPos
onready var right_arrow_pos = $RightArrowPos
onready var melee_attack_radius = $MeleeAttackRadius

signal update_current_hp
signal companion_died

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	current_hp = max_hp
	if player != null:
		player.connect("make_companion_wait", self, "set_wait")
		player.connect("make_companion_follow", self, "set_follow_with_delay")

# Function to check if there are enemies in a certain attack threshold
# If there's an enemy close, return the state corresponding to the type of attack
func are_enemies_in_attack_range():
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		var distance_to_enemy = global_position.distance_to(e.global_position)
		# Check closest state of attack first
		if distance_to_enemy < melee_attack_distance:
			return States.MELEE_ATTACK
		elif distance_to_enemy < bow_attack_distance:
			return States.ATTACK
	return States.FOLLOW

func get_target_position():
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		return e.global_position
	
	
func flip_sprite():
	if velocity.x > 0:
		animated_sprite.flip_h = true
	elif velocity.x < 0:
		animated_sprite.flip_h = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _state == States.FOLLOW:
		var new_state =  are_enemies_in_attack_range()
		if new_state in [States.MELEE_ATTACK, States.ATTACK]:
			_state = new_state
			return
		animation_player.play("run")
		var steering_force = SteeringBehaviours.arrive(
			player.global_position,
			global_position,
			decceleration.fast,
			max_speed,
			decceleration_tweaker,
			velocity
		)
		var acceleration = steering_force / mass
		velocity += acceleration * delta
		velocity.x = min(velocity.x, max_speed)
		velocity.y = min(velocity.y, max_speed)
		velocity = move_and_slide(velocity)
	elif _state == States.ATTACK:
		animation_player.play("attack_bow")
		var new_arrow = arrows.instance()
		var direction_to_enemy = global_position.direction_to(get_target_position())
		animated_sprite.flip_h = direction_to_enemy.x < 0
		new_arrow.direction = direction_to_enemy
		add_child(new_arrow)
		new_arrow.global_position = right_arrow_pos.global_position if direction_to_enemy.x > 0 else left_arrow_pos.global_position
		_state = States.ATTACK_DELAY
	elif _state == States.MELEE_ATTACK:
		animation_player.play("melee_attack")
		_state = States.ATTACK_DELAY
	elif _state == States.ATTACK_DELAY:
		attack_timer.start()
		_state = States.IDLE
	elif _state == States.IDLE:		
		if !animation_player.is_playing() or animation_player.current_animation == "run":
			animation_player.play("idle")
#	flip_sprite()
		

func take_damage(dmg: int):
	current_hp -= dmg
	if current_hp <= 0:
		emit_signal("companion_died")
	emit_signal("update_current_hp", current_hp)

func get_velocity():
	return velocity
	
func get_speed():
	return max_speed
	
func set_wait():
	_state = States.IDLE

func set_follow_with_delay():
	timer.start()

func _on_Timer_timeout():
	_state = States.FOLLOW
	timer.stop()

func _on_AttackRadius_body_entered(body):
	pass
	if _state != States.ATTACK_DELAY and _state != States.ATTACK:
		_state = States.ATTACK


func _on_AttackTimer_timeout():
	_state = are_enemies_in_attack_range()
	attack_timer.stop()


func _on_MeleeAttackRadius_body_entered(body):
	if body.is_in_group("enemies"):
		body.damage(melee_attack_damage)
