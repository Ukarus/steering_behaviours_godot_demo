extends Node2D

export (PackedScene) var victory_screen
export (PackedScene) var restart_scene
onready var player = $Player
onready var companion = $Companion
onready var hud = $HUD
onready var player_bar = $HUD/PlayerContainer/ProgressBar
onready var companion_bar = $HUD/CompanionContainer/ProgressBar
onready var walls_tilemap = $Walls
onready var enemy_spawner = $EnemySpawner

var zones = {
	1: {
		"gates": [
			{
				"x": 24,
				"y": -1
			},
			{
				"x": 24,
				"y": 0
			},
			{
				"x": 24,
				"y": 1
			},
		]
	},
	2: {
		"gates": [
			{
				"x": 39,
				"y": -1
			},
			{
				"x": 39,
				"y": 0
			},
			{
				"x": 39,
				"y": 1
			},
		]
	},
}

# Called when the node enters the scene tree for the first time.
func _ready():
	companion.connect("update_current_hp", self, "update_companion_hud")
	companion.connect("companion_died", self, "show_defeat_menu")
	player.connect("update_player_hud", self, "update_player_hud")
	player.connect("player_died", self, "show_defeat_menu")
	player_bar.max_value = player.max_hp
	player_bar.value = player.current_hp
	companion_bar.max_value = companion.max_hp
	companion_bar.value = companion.current_hp
	enemy_spawner.connect("enemy_spawn_timer_stopped", self, "open_gates")
	$EnemySpawner2.connect("enemy_spawn_timer_stopped", self, "open_gates")
	

# TODO: Check that there are no more enemies spawning
func open_gates(zone: int):
	var gates = zones[zone]["gates"]
	for g in gates:
		walls_tilemap.set_cell(g["x"], g["y"], -1)
	

func update_companion_hud(new_hp):
	$HUD/CompanionContainer/ProgressBar.value = new_hp

func update_player_hud(new_hp):
	player_bar.value = new_hp
	
func show_defeat_menu():
	get_tree().change_scene_to(restart_scene)

func _on_VictoryZone_body_entered(_body):
	$AnimationPlayer.play("fade")
	yield($AnimationPlayer, "animation_finished")
	get_tree().change_scene_to(victory_screen)
