extends KinematicBody2D


export (int) var speed = 200
export (int) var max_hp = 5
var velocity = Vector2()
var direction = "right"
signal make_companion_wait
signal make_companion_follow
signal damage_enemy
signal update_player_hud

enum States {ATTACK, RUN, IDLE}
# With a variable that keeps track of the current state, we don't need to add more booleans.
var _state : int = States.IDLE
onready var current_hp = max_hp
onready var animation_player = $AnimationPlayer
onready var animated_sprite = $AnimatedSprite
onready var attack_range = $AttackRange


func get_input():
	velocity = Vector2()
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
	
	if Input.is_action_just_pressed("attack_light"):
		animation_player.play("attack1")
	# if it's not moving and attacking
	if velocity.x == 0 && velocity.y == 0 && animation_player.current_animation != "attack1":
		animation_player.play("idle")
	if velocity.x != 0 or velocity.y != 0:
		animation_player.play("run")
	velocity = velocity.normalized() * speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	get_input()
	velocity = move_and_slide(velocity)

func get_velocity():
	return velocity
	
func get_speed():
	return speed
	
func _on_CompanionRange_body_shape_entered(_body_rid, _body, _body_shape_index, _local_shape_index):
	emit_signal("make_companion_wait")

func _on_CompanionRange_body_shape_exited(_body_rid, _body, _body_shape_index, _local_shape_index):
	emit_signal("make_companion_follow")

func _on_AttackRange_body_entered(body):
	if body.is_in_group("enemies"):
		body.damage(1)
#	emit_signal("damage_enemy", 1)

func take_damage(dmg: int):
	current_hp -= dmg
	emit_signal("update_player_hud", current_hp)
