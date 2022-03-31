extends Spatial

var health = 5
onready var animation = $PlayerBlocker/AnimationPlayer
onready var health_counter = $Spatial/Viewport/Health
onready var enemy_target = $EnemyTarget
onready var enemy_blocker = $EnemyBlocker/CollisionShape2
onready var interactable = $Interactable

func _ready():
	pass

func take_damage():
	interactable.add_to_group("damaged_barricade")
	health -= 1
	health = clamp(health, 0, 5)
	health_counter.text = str(health)
	if health == 0:
		barricade_break()
		enemy_target.add_to_group("broken_barricade")

func barricade_break():
	animation.play("break")
	enemy_blocker.disabled = true

func barricade_fix():
	health += 1
	health = clamp(health, 0, 5)
	animation.play("default")
	enemy_blocker.disabled = false
	health_counter.text = str(health)
	enemy_target.remove_from_group("broken_barricade")
	if health == 5:
		interactable.remove_from_group("damaged_barricade")


