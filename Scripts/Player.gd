extends KinematicBody2D

const ATTACK_DAMAGE = 1
export (int) var speed = 200
export (int) var max_hp = 5
var velocity = Vector2()
var direction = "right"
signal make_companion_wait
signal make_companion_follow
signal update_player_hud
signal player_died

enum States {ATTACK, RUN, IDLE, DIE, ROLL}
# With a variable that keeps track of the current state, we don't need to add more booleans.
var _state : int = States.IDLE
onready var current_hp = max_hp
onready var animation_player = $AnimationPlayer
onready var animated_sprite = $AnimatedSprite
onready var attack_range = $AttackRange


func get_input():
	if Input.is_action_pressed("left"):
		velocity.x -=1
		direction = "left"
		attack_range.scale.x = -1
	if Input.is_action_pressed("right"):
		velocity.x += 1
		direction = "right"
		attack_range.scale.x = 1
	if Input.is_action_pressed("up"):
		velocity.y -= 1
	if Input.is_action_pressed("down"):
		velocity.y += 1
	animated_sprite.flip_h = direction == "left"
	velocity = velocity.normalized() * speed
	
func is_attack_pressed():
	if Input.is_action_just_pressed("attack_light"):
		reset_modulate_sprite()
		_state = States.ATTACK
		animation_player.play("attack1")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	velocity = Vector2()
	get_input()
	match _state:
		States.IDLE:
			animation_player.play("idle")
			if Input.is_action_just_pressed("roll"):
				_state = States.ROLL
			is_attack_pressed()
			# if any of the input movement buttons is pressed
			if velocity.x != 0 or velocity.y != 0:
				_state = States.RUN
				animation_player.play("run")
		States.ATTACK:
			# if any of the input movement buttons is pressed
			if !animation_player.is_playing():
				_state = States.IDLE
		States.RUN:
			if Input.is_action_just_pressed("roll"):
				_state = States.ROLL
			is_attack_pressed()
			if velocity.x == 0 && velocity.y == 0:
				_state = States.IDLE
			# if i want to keep moving when attacking just put this line outside of the match block
			velocity = move_and_slide(velocity)
		States.DIE:
			if animation_player.current_animation != "die":
				animation_player.play("die")
		States.ROLL:
			is_attack_pressed()
			if animation_player.current_animation != "roll":
				animation_player.play("roll")
			velocity = move_and_slide(velocity)

func reset_modulate_sprite():
	animated_sprite.modulate = Color(1, 1, 1, 1)

func get_velocity():
	return velocity
	
func get_speed():
	return speed
	
func go_to_idle():
	_state = States.IDLE
	
func _on_CompanionRange_body_shape_entered(_body_rid, _body, _body_shape_index, _local_shape_index):
	emit_signal("make_companion_wait")

func _on_CompanionRange_body_shape_exited(_body_rid, _body, _body_shape_index, _local_shape_index):
	emit_signal("make_companion_follow")

func _on_AttackRange_body_entered(body):
	if body.is_in_group("enemies") and body.has_method("damage"):
		body.damage(ATTACK_DAMAGE)

func take_damage(dmg: int):
	if _state != States.ROLL:
		animation_player.play("take_damage")
		current_hp -= dmg
	if current_hp <= 0 and _state != States.DIE:
		_state = States.DIE
	emit_signal("update_player_hud", current_hp)

func take_hp_potion(points):
	current_hp += points
	emit_signal("update_player_hud", current_hp)
