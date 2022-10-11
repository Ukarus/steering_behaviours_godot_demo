extends Node2D

export (PackedScene) var enemy_scene
export (NodePath) var player_path
export (NodePath) var companion_path
export (int) var enemies_to_spawn = 10

onready var player = get_node(player_path)
onready var companion = get_node(companion_path)
onready var timer = $Timer
onready var path2d = $EnemyPath
onready var enemy_spawn_location = $EnemyPath/EnemySpawnLocation
var enemies_spawned = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

# TODO: Add area 2d to detect when player and companion enter the area
func _on_Timer_timeout():
	# if we reached the limit of enemies to spawn 
	if enemies_spawned >= enemies_to_spawn:
		timer.stop()
	# Instance the bat enemy
	var enemy = enemy_scene.instance()
#	var rand_target = player if (randi() % 100 > 50) else companion
	enemy.set_current_target(player)
	
	enemy_spawn_location.offset = randi()

	enemy.position = enemy_spawn_location.position
	
	add_child(enemy)
	enemies_spawned += 1
	
func _on_AttackPlayersArea_body_entered(_body):
	timer.start()
