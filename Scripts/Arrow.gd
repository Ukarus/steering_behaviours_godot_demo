extends Area2D

export (float) var speed = 20.0
#export (Vector2) var target_pos
export (float) var time_to_live = 4.0
export (int) var dmg = 1
var direction: Vector2 = Vector2()
var velocity = Vector2()
var elapsed_time = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	look_at(global_position + direction)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += direction * speed * delta
	elapsed_time += delta
	if elapsed_time >= time_to_live:
		queue_free()



func _on_Arrow_body_entered(body):
	if body.has_method("damage"):
		body.damage(dmg)
	queue_free()
