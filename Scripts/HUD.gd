extends CanvasLayer

onready var restart_container = $RestartContainer
var is_restarting = false
# var first_level = preload("res://Scenes/FirstLevel.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	restart_container.visible = false
	
func show_restart():
	get_tree().paused = true
	restart_container.visible = true
	is_restarting = true

func _unhandled_input(event):
	if is_restarting and event.is_action_pressed("ui_accept"):
		get_tree().paused = false
		get_tree().change_scene("res://Scenes/FirstLevel.tscn")
