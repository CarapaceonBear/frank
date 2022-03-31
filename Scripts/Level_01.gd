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
onready var spawn05 = $SpawnPoint05
onready var barricade01 = $Barricades/Barricade01/Target
onready var barricade02 = $Barricades/Barricade02/Target
onready var barricade03 = $Barricades/Barricade03/Target
onready var barricade04 = $Barricades/Barricade04/Target
onready var barricade05 = $Barricades/Barricade05/Target
var barricade_location

onready var player = $FirstPerson

func _ready():
	rng.randomize()
	rounds()

func spawn_enemy(number):
	enemiesRemaining = number
	var iterations = 0
	while (iterations < number):
		var temp = zombo.instance()

		spawnNumber = rng.randi_range(1, 5)

		temp.connect("enemy_killed", self, "enemy_killed")
		temp.connect("points", player, "recieve_points")
		enemy_container.add_child(temp)
		match spawnNumber:
			1:
				temp.transform = spawn01.global_transform
				barricade_location = barricade01.global_transform.origin
			2:
				temp.transform = spawn02.global_transform
				barricade_location = barricade02.global_transform.origin
			3:
				temp.transform = spawn03.global_transform
				barricade_location = barricade03.global_transform.origin
			4:
				temp.transform = spawn04.global_transform
				barricade_location = barricade04.global_transform.origin
			5:
				temp.transform = spawn05.global_transform
				barricade_location = barricade05.global_transform.origin
		temp.get_barricade(barricade_location)
		yield(get_tree().create_timer(.8), "timeout")
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
			spawn_enemy(16)
		5:
			spawn_enemy(22)
		6:
			spawn_enemy(30)
		7:
			spawn_enemy(40)
		8:
			spawn_enemy(50)

