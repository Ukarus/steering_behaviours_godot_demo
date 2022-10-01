extends Area2D

export (float) var speed = 20
export (Vector2) var target_pos
export (float) var time_to_live = 5
export (int) var dmg = 1
var direction: Vector2
var velocity = Vector2()
var elapsed_time = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	direction = target_pos - position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity = Vector2()
	if elapsed_time > time_to_live:
		queue_free()
	# if x direction is left
	if direction.x < 0:
		velocity.x -= 1
	else:
		velocity.x += 1
	
	if direction.y < 0:
		velocity.y -= 1
	else:
		velocity.y += 1
	
	velocity = velocity.normalized() * speed
	position += velocity * delta
	elapsed_time += delta

func _on_Arrow_body_entered(body):
	body.damage(dmg)
	queue_free()
