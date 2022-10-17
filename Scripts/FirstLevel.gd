extends Node2D

export (PackedScene) var victory_scene
onready var player = $Player
onready var companion = $Companion
onready var hud = $HUD
onready var player_bar = $HUD/PlayerContainer/ProgressBar
onready var companion_bar = $HUD/CompanionContainer/ProgressBar
onready var walls_tilemap = $Walls
onready var enemy_spawner = $EnemySpawner

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

# TODO: Check that there are no more enemies spawning
func open_gates():
	walls_tilemap.set_cell(24, -1, -1)
	walls_tilemap.set_cell(24, 0, -1)
	walls_tilemap.set_cell(24, 1, -1)
	

func update_companion_hud(new_hp):
	$HUD/CompanionContainer/ProgressBar.value = new_hp

func update_player_hud(new_hp):
	player_bar.value = new_hp
	
func show_defeat_menu():
	hud.show_restart()

func _on_VictoryZone_body_entered(_body):
	hud.visible = false
	get_tree().paused = true
	var vi = victory_scene.instance()
	add_child(vi)
