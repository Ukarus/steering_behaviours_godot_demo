extends Camera2D

export (Array, NodePath) var targets
export var move_speed = 0.5  # camera position lerp speed
export var zoom_speed = 0.25  # camera zoom lerp speed
var nodes

# Called when the node enters the scene tree for the first time.
func _ready():
	nodes = []
	for t in targets:
		nodes.append(get_node(t))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var p = Vector2.ZERO
	for target in nodes:
		p += target.position
	p /= targets.size()
	position = lerp(position, p, move_speed)
