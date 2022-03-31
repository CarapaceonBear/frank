extends KinematicBody

var path = []
var path_node = 0
var target

var speed = 3
var turn_speed = 4
var cached_pos = Vector3(0,0,0)
var face_towards : Vector3
var seeking_player = false

var health = 100
var attack_targets = 0
var attack_damage = 20
var point_value = 50
var attacking = false

onready var nav = get_parent()
onready var player = $"../../FirstPerson"
onready var damage_region = $DamageRegion
var colliders
onready var fellow_detector = $Reach

signal enemy_killed
signal points(point_value)

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
			#if fellow_detector.is_colliding():
				#direction.x += 10
			move_and_slide(direction.normalized() * speed, Vector3.UP)
			var facing = self.transform.looking_at((global_transform.origin + face_towards), Vector3.UP)
			transform = transform.interpolate_with(facing, turn_speed * delta)
	colliders = damage_region.get_overlapping_bodies()
	for x in colliders:
		if x.is_in_group("broken_barricade"):
			seeking_player = true
		elif x.has_method("take_damage") and not attacking:
			attacking = true
			attack_targets += 1
			yield(get_tree().create_timer(1), "timeout")
			attacking = false
			if attack_targets > 0:
				x.take_damage(attack_damage)

func where_was_i():
	var n = 1
	while n == 1:
		face_towards = global_transform.origin - cached_pos
		cached_pos = global_transform.origin
		yield(get_tree().create_timer(.3), "timeout")

# called on spawn
func get_barricade(location):
	target = location

# called on update timer
func update_target(location):
	if seeking_player:
		target = location
	move_to(target)

func move_to(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	path_node = 0

func lose_health(value):
	health -= value

func die():
	emit_signal("enemy_killed")
	emit_signal("points", point_value)
	queue_free()

func _on_Area_body_entered(body):
	if body.is_in_group("broken_barricade"):
		seeking_player = true

func _on_Area_body_exited(body):
	if body.has_method("take_damage"):
		attack_targets -= 1
