extends Node2D

export (PackedScene) var enemy_scene
export (PackedScene) var reward
export (NodePath) var player_path
export (NodePath) var companion_path
export (int) var enemies_to_spawn = 10
export (int) var zone_to_open

onready var player = get_node(player_path)
onready var companion = get_node(companion_path)
onready var timer = $Timer
onready var path2d = $EnemyPath
onready var enemy_spawn_location = $EnemyPath/EnemySpawnLocation
var enemies_spawned = 0
var has_spawn_been_triggered = false

signal enemy_spawn_timer_stopped

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

# Spawns a reward on a random location
func spawn_random_reward():
	var hp1 = reward.instance()
	enemy_spawn_location.offset = randi()
	hp1.position = enemy_spawn_location.position
	add_child(hp1)

func _on_Timer_timeout():
	# if we reached the limit of enemies to spawn 
	if enemies_spawned >= enemies_to_spawn:
		
		timer.stop()
		spawn_random_reward()
		emit_signal("enemy_spawn_timer_stopped", zone_to_open)
#		print("emitting signal stopped with zone to open: %s" % zone_to_open)
		return
	# Instance the bat enemy
	var enemy = enemy_scene.instance()
	var rand_target = player if (randi() % 100 > 50) else companion
	enemy.set_current_target(rand_target)
	
	enemy_spawn_location.offset = randi()

	enemy.position = enemy_spawn_location.position
	
	add_child(enemy)
	enemies_spawned += 1
	
func _on_AttackPlayersArea_body_entered(_body):
	if !has_spawn_been_triggered:
		timer.start()
		has_spawn_been_triggered = true
