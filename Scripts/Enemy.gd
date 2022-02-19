extends KinematicBody

var path = []
var path_node = 0
var target
var first_exempt = 0

var speed = 2
var turn_speed = 4
var cached_pos = Vector3(0,0,0)
var face_towards : Vector3

var health = 100

onready var nav = get_parent()
onready var player = $"../../FirstPerson"

signal enemy_killed

func _ready():
	player.connect("update_location", self, "update_target")
	where_was_i()

func _process(delta):
	if health <= 0:
		die()

func _physics_process(delta):
	if path_node < path.size():
		var direction = (path[path_node] - global_transform.origin)
		if direction.length() < 1:
			path_node += 1
		else:
			move_and_slide(direction.normalized() * speed, Vector3.UP)
			var facing = self.transform.looking_at((global_transform.origin + face_towards), Vector3.UP)
			transform = transform.interpolate_with(facing, turn_speed * delta)

func where_was_i():
	var n = 1
	while n == 1:
		face_towards = global_transform.origin - cached_pos
		cached_pos = global_transform.origin
		yield(get_tree().create_timer(.3), "timeout")


func update_target(location):
	target = location
	move_to(target)

func move_to(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	path_node = 0

func lose_health(value):
	health -= value
	print("Ow")

func die():
	emit_signal("enemy_killed")
	queue_free()

