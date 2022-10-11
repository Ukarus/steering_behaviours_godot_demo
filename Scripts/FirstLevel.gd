extends Node2D


export (PackedScene) var victory_scene
onready var player = $Player
onready var companion = $Companion
onready var hud = $HUD

# Called when the node enters the scene tree for the first time.
func _ready():
	companion.connect("update_current_hp", self, "update_companion_hud")
	player.connect("update_player_hud", self, "update_player_hud")
	player.connect("player_died", self, "show_defeat_menu")
	
func update_companion_hud(new_hp):
	$HUD/CompanionContainer/ProgressBar.value = new_hp

func update_player_hud(new_hp):
	$HUD/PlayerContainer/ProgressBar.value = new_hp
	
func show_defeat_menu():
	hud.show_restart()


func _on_VictoryZone_body_entered(_body):
	hud.visible = false
	get_tree().paused = true
	var vi = victory_scene.instance()
	add_child(vi)
