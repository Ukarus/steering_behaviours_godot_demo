extends Node2D

export (PackedScene) var enemy_scene
export (NodePath) var player_path
export (NodePath) var companion_path

onready var player = get_node(player_path)
onready var companion = get_node(companion_path)
onready var path2d = $EnemyPath
onready var enemy_spawn_location = $EnemyPath/EnemySpawnLocation

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

func _on_Timer_timeout():
	var enemy = enemy_scene.instance()
	var rand_target = player if (randi() % 100 > 50) else companion
	enemy.set_current_target(rand_target)
	
	enemy_spawn_location.offset = randi()
	var direction = enemy_spawn_location.rotation + PI /2
	enemy.position = enemy_spawn_location.position
	
#	direction += rand_range(-PI / 4, PI / 4)
#	enemy.look_at(rand_target.position)
	
#	enemy.connect("enemy_died", companion, "remove_first_enemy")
	
	add_child(enemy)
#	player.connect("damage_enemy", enemy, "damage")
