extends Spatial

var roundNumber = 1
var rng = RandomNumberGenerator.new()
var spawnNumber
var enemiesRemaining

onready var enemy_container = $Navigation
onready var zombo = preload("res://scenes/Zombo.tscn") 
onready var spawn01 = $SpawnPoint01
onready var spawn02 = $SpawnPoint02
onready var spawn03 = $SpawnPoint03
onready var spawn04 = $SpawnPoint04

func _ready():
	rng.randomize()
	rounds()

func spawn_enemy(number):
	enemiesRemaining = number
	var iterations = 0
	while (iterations < number):
		var temp = zombo.instance()

		spawnNumber = rng.randi_range(1, 4)

		temp.connect("enemy_killed", self, "enemy_killed")
		enemy_container.add_child(temp)
		match spawnNumber:
			1:
				temp.transform = spawn01.global_transform
			2:
				temp.transform = spawn02.global_transform
			3:
				temp.transform = spawn03.global_transform
			4:
				temp.transform = spawn04.global_transform
		yield(get_tree().create_timer(.5), "timeout")
		iterations += 1

func enemy_killed():
	enemiesRemaining -= 1
	if enemiesRemaining == 0:
		roundNumber += 1
		yield(get_tree().create_timer(2), "timeout")
		rounds()

func rounds():
	match(roundNumber):
		1:
			spawn_enemy(4)
		2:
			spawn_enemy(7)
		3:
			spawn_enemy(10)
		4:
			print("You win!")

