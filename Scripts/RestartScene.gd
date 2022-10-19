extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		get_tree().change_scene("res://Scenes/FirstLevel.tscn")
