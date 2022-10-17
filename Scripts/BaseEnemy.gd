extends KinematicBody2D

export (int) var max_hp = 1
export (int) var attack_damage = 1
export (float) var max_speed = 100.0
export (float) var mass = 0.5
var velocity = Vector2()
var current_target : Node
var current_hp : float


func set_current_target(target):
	current_target = target
