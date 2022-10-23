extends Area2D


export (float) var speed = 1.0
export (float) var mist_damage = 2.0
export (bool) var should_move = true
var velocity = Vector2()
var bodies_to_damage = []


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if should_move:
		velocity.x += 1
		velocity = velocity.normalized() * speed * delta
		position.x += velocity.x
	
func _on_Mist_body_entered(body):
	bodies_to_damage.push_front(body)

func _on_Mist_body_exited(_body):
	bodies_to_damage.pop_front()

func _on_DamageTimer_timeout():
	for b in bodies_to_damage:
		b.take_damage(mist_damage)
