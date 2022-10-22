extends Area2D

export (float) var recovery_points = 15.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _on_HealthPotion_body_entered(body):
	body.take_hp_potion(recovery_points)
	queue_free()
